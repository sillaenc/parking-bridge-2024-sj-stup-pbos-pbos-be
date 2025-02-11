// /bin/routes/receive_enginedata_send_to_dartserver.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../data/db.dart';

/// 엔진 DB(ws4sqlite, sqlite)에서 데이터를 가져오기 위한 HTTP 요청 함수
Future<Map<String, dynamic>?> fetchEngineData(String engineDbAddr) async {
  String url = engineDbAddr;
  Map<String, String> headers = {'Content-Type': 'application/json'};
  // ws4sqlite에서 실행할 쿼리 키는 "S1" (쿼리 내용 예: SELECT id, datetime(timestamp, localtime) AS timestamp, parking_lot FROM parking_data ORDER BY timestamp DESC LIMIT 1)
  Map<String, dynamic> body = {
    "transaction": [
      {"query": "#S1"}  // "#" 제거
    ]
  };
  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(body),
  );
  // print(response.body);
  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);
    if (responseData['results'] != null &&
        responseData['results'][0]['resultSet'] != null &&
        responseData['results'][0]['resultSet'].isNotEmpty) {
      return responseData['results'][0]['resultSet'][0];
    } else {
      print('No data returned from engine DB.');
      return null;
    }
  } else {
    print('Failed to fetch engine data. Status code: ${response.statusCode}');
    return null;
  }
}

/// 엔진 DB(ws4sqlite)와 디스플레이 DB(PostgreSQL)를 연계하여 데이터를 처리하는 함수
Future<List<dynamic>> receiveEnginedataSendToDartserver(
    //String engineDbAddr, String displayDbAddr, DateTime check) async {
    String engineDbAddr, DateTime check) async {
  print('Sending data to server at: ${DateTime.now()}');

  // 날짜/시간 포맷 함수
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  // 한 시간 단위 시간 범위 계산 함수
  Map<String, DateTime> calculateTimeRange(DateTime now) {
    DateTime endTime = DateTime(now.year, now.month, now.day, now.hour);
    DateTime startTime = endTime.subtract(const Duration(hours: 1));
    return {"start_time": startTime, "end_time": endTime};
  }

  DateTime now = DateTime.now();
  // 이전 체크 시각 (중복 실행 방지용)
  DateTime previousCheck = check.subtract(const Duration(seconds: 10));

  // --- 엔진 DB (sqlite) 접근 (ws4sqlite) ---
  Map<String, dynamic>? engineResult = await fetchEngineData(engineDbAddr);
  if (engineResult == null) {
    return [];
  }
  
  // 엔진 DB 결과에서 필요한 데이터 추출  
  // engineResult는 { 'id': ..., 'timestamp': ..., 'parking_lot': 'start,lot1,lot2,...' } 형태로 반환된다고 가정
  var id = engineResult['id'];
  var timestamp = engineResult['timestamp'];
  var parkingLotStr = engineResult['parking_lot'];

  List<String> parkingLotList = parkingLotStr.split(',');
  if (parkingLotList.isNotEmpty) {
    parkingLotList.removeAt(0); // "start" 항목 제거
    parkingLotList.sort();
  }

  // --- 디스플레이 DB (PostgreSQL) 접근 ---
  final db = await Database.getInstance();
  
  // 원시 데이터 기록 (I_Rawdata 쿼리)
  await db.query("I_Rawdata", {
    "id": id,
    "timestamp": timestamp,
    "parking_lot": parkingLotStr
  });

  // 주차 구역(lot) 정보 조회 (S_TbLots 쿼리)
  List<Map<String, dynamic>> lots = await db.query("S_TbLots");
  if (lots.isEmpty) {
    print("No lots data found.");
    return [];
  }
  
  // 각 주차 구역의 사용 여부(isUsed) 업데이트
  for (var lot in lots) {
    String tag = lot["tag"];
    lot["isUsed"] = parkingLotList.contains(tag) ? 1 : 0;
  }
  
  // 각 구역에 대해 TbLots 업데이트와 TbLotStatus 기록 수행
  for (var lotData in lots) {
    await db.query("U_TbLots", {
      "isUsed": lotData['isUsed'],
      "tag": lotData['tag']
    });
    await db.query("I_TbLotStatus", {
      "lot": lotData['uid'],
      "isParked": lotData['isUsed'],
      "added": timestamp
    });
  }
  
  // --- 시간 단위 처리 (한 시간 전 데이터 기록) ---
  // if (previousCheck.hour != now.hour) {
  if (1==1) {
    var timeRange = calculateTimeRange(now);
    String formattedStartTime = formatDateTime(timeRange["start_time"]!);
    print(formattedStartTime);
    String formattedEndTime = formatDateTime(timeRange["end_time"]!);

    // 한 시간 범위 내 TbLotStatus 기록 조회 (S_TbLotStatus 쿼리)
    List<Map<String, dynamic>> lotStatus = await db.query("S_TbLotStatus", {
      "start_time": formattedStartTime,
      "end_time": formattedEndTime
    });
    // 최신 주차 구역 정보 재조회
    List<Map<String, dynamic>> lotsData = await db.query("S_TbLots");

    // 각 lot별 주차 여부 집계 (한 번이라도 1이면 true)
    Map<int, bool> parkingStatus = {};
    
    for (var item in lotStatus) {
      int lotId = item['lot'];
      int isParked = item['isParked'];
      parkingStatus[lotId] = (parkingStatus[lotId] ?? false) || (isParked == 1);
    }
    // 각 lot의 타입 정보 매핑
    Map<int, dynamic> lotTypes = {};
    for (var item in lotsData) {
      int uid = item['uid'];
      lotTypes[uid] = item['lot_type'];
    }
    
    DateTime oneHourBefore = now.subtract(const Duration(hours: 1));
    String formattedHour =
        "${oneHourBefore.year.toString().padLeft(4, '0')}-"
        "${oneHourBefore.month.toString().padLeft(2, '0')}-"
        "${oneHourBefore.day.toString().padLeft(2, '0')} "
        "${oneHourBefore.hour.toString().padLeft(2, '0')}";

    // 해당 시간에 이미 기록된 데이터가 있는지 확인 (S_CountProcessedDb 쿼리)
    List<Map<String, dynamic>> countResult = await db.query("S_CountProcessedDb", {"time": formattedHour});
    int count = countResult.first['count'] ?? 0;
    if (count == 0 && lotsData.isNotEmpty) {
      for (var item in lotsData) {
        int uid = item['uid'];
        bool parked = parkingStatus[uid] ?? false;
        await db.query("I_processedDB", {
          "lot": uid,
          "car_type": lotTypes[uid],
          "hour_parking": parked ? 1 : 0,
          "recorded_hour": formattedHour
        });
      }
    }
  }
  
  // --- 일 단위 처리 (어제 데이터 기록) ---
  if (previousCheck.day != now.day) {
    DateTime oneDayBefore = now.subtract(const Duration(days: 1));
    String strDay = DateFormat('yyyy-MM-dd').format(oneDayBefore);
    String strMonth = DateFormat('yyyy-MM').format(oneDayBefore);
    String strYear = DateFormat('yyyy').format(oneDayBefore);

    List<Map<String, dynamic>> processedDay = await db.query("S_ProcessedDB", {"checkdate": '$strDay%'});
    List<Map<String, dynamic>> lotsData = await db.query("S_TbLots");

    // 일 단위 주차 여부 집계
    Map<int, bool> dayParkingStatus = {};
    for (var item in processedDay) {
      int lot = item['lot'];
      int hourParking = item['hour_parking'];
      dayParkingStatus[lot] = (dayParkingStatus[lot] ?? false) || (hourParking == 1);
    }
    Map<int, dynamic> lotTypes = {};
    for (var item in lotsData) {
      int uid = item['uid'];
      lotTypes[uid] = item['lot_type'];
    }
    
    // 어제 기록이 이미 존재하는지 확인 (S_CountRecordedDay 쿼리)
    List<Map<String, dynamic>> dayCountResult =
        await db.query("S_CountRecordedDay", {"time": strDay});
    int dayCount = dayCountResult.first['count'];
    if (dayCount == 0 && lotsData.isNotEmpty) {
      for (var item in lotsData) {
        int uid = item['uid'];
        bool parked = dayParkingStatus[uid] ?? false;
        await db.query("I_PerDay", {
          "lot": uid,
          "car_type": lotTypes[uid],
          "day_parking": parked ? 1 : 0,
          "fromattedTime": strDay
        });
      }
    }
    
    // --- 월 단위 처리 (지난 달 데이터 기록) ---
    int prevMonthCalc = now.month - 1;
    int prevYearCalc = now.year;
    if (prevMonthCalc < 1) {
      prevMonthCalc = 12;
      prevYearCalc--;
    }
    if (previousCheck.month != now.month) {
      String formattedMonth = "$prevYearCalc-${prevMonthCalc.toString().padLeft(2, '0')}";
      List<Map<String, dynamic>> processedPerDay =
          await db.query("S_PerDay", {"checkdate": '$strMonth%'});
      lotsData = await db.query("S_TbLots");

      Map<int, bool> monthParkingStatus = {};
      for (var item in processedPerDay) {
        int lot = item['lot'];
        int dayParking = item['day_parking'];
        monthParkingStatus[lot] =
            (monthParkingStatus[lot] ?? false) || (dayParking == 1);
      }
      lotTypes = {};
      for (var item in lotsData) {
        int uid = item['uid'];
        lotTypes[uid] = item['lot_type'];
      }
      List<Map<String, dynamic>> monthCountResult =
          await db.query("S_CountPerMonth", {"time": formattedMonth});
      int monthCount = monthCountResult.first['count'];
      if (monthCount == 0 && lotsData.isNotEmpty) {
        for (var item in lotsData) {
          int uid = item['uid'];
          bool parked = monthParkingStatus[uid] ?? false;
          await db.query("I_PerMonth", {
            "lot": uid,
            "car_type": lotTypes[uid],
            "month_parking": parked ? 1 : 0,
            "fromattedTime": formattedMonth
          });
        }
      }
    }
    
    // --- 연 단위 처리 (지난 해 데이터 기록) ---
    if (previousCheck.year != now.year) {
      String formattedYear = "${now.year - 1}";
      List<Map<String, dynamic>> processedPerMonth =
          await db.query("S_PerMonth", {"checkdate": '$strYear%'});
      lotsData = await db.query("S_TbLots");

      Map<int, bool> yearParkingStatus = {};
      for (var item in processedPerMonth) {
        int lot = item['lot'];
        int monthParking = item['month_parking'];
        yearParkingStatus[lot] =
            (yearParkingStatus[lot] ?? false) || (monthParking == 1);
      }
      lotTypes = {};
      for (var item in lotsData) {
        int uid = item['uid'];
        lotTypes[uid] = item['lot_type'];
      }
      List<Map<String, dynamic>> yearCountResult =
          await db.query("S_CountPerYear", {"time": formattedYear});
      int yearCount = yearCountResult.first['count'];
      if (yearCount == 0 && lotsData.isNotEmpty) {
        for (var item in lotsData) {
          int uid = item['uid'];
          bool parked = yearParkingStatus[uid] ?? false;
          await db.query("I_PerYear", {
            "lot": uid,
            "car_type": lotTypes[uid],
            "year_parking": parked ? 1 : 0,
            "fromattedTime": formattedYear
          });
        }
      }
    }
  }
  
  return parkingLotList;
}
