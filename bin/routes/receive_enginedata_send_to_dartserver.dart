import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<dynamic>> receiveEnginedataSendToDartserver(
    var engineDbaddr, var displayDbAddr, DateTime check) async {
  print('Sending data to server at: ${DateTime.now()}');

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Map<String, DateTime> calculateTimeRange(DateTime now) {
    DateTime endTime = DateTime(now.year, now.month, now.day, now.hour);
    DateTime startTime = endTime.subtract(const Duration(hours: 1));
    return {"start_time": startTime, "end_time": endTime};
  }

  DateTime now = DateTime.now();
  var timeRange = calculateTimeRange(now);
  String formattedStartTime = formatDateTime(timeRange["start_time"]!);
  String formattedEndTime = formatDateTime(timeRange["end_time"]!);
  try {
    String url = engineDbaddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {"query": "#S1"}
      ]
    };
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['results'][0]['resultSet'].isEmpty) {
        print('No data returned from engine DB.');
        return [];
      }
      var resultSet = responseData['results'][0]['resultSet'][0];
      var parkingLot = resultSet['parking_lot'];
      var parkingLotList = parkingLot.split(',');
      if (parkingLotList.isNotEmpty) {
        parkingLotList.removeAt(0); // "start" 제거
        parkingLotList.sort();
      }
      
      String url2 = displayDbAddr;
      var raw = {
        "transaction": [
          {
            "statement": "#I_Rawdata",
            "values": {"id": resultSet['id'], "timestamp": resultSet['timestamp'], "parking_lot": resultSet['parking_lot']}
          }
        ]
      };
      await http.post(
        Uri.parse(url2),
        headers: headers,
        body: jsonEncode(raw),
      );

      var body2 = {
        "transaction": [
          {"query": "#S_TbLots"}
        ]
      };
      var response2 = await http.post(
        Uri.parse(url2),
        headers: headers,
        body: jsonEncode(body2),
      );
      var responseData2 = jsonDecode(response2.body);
      var resultSet2 = responseData2['results'][0]['resultSet'];

      // resultSet2가 비어있을 경우 대비
      if (resultSet2.isEmpty) {
        print("No lots data found.");
        return [];
      }

      // 주차 여부 업데이트
      for (var lot in resultSet2) {
        var tag = lot["tag"];
        lot["isUsed"] = parkingLotList.contains(tag) ? 1 : 0;
      }

      DateTime now = DateTime.now();
      DateTime checks = check.subtract(Duration(seconds: 10));
      int hour = checks.hour;
      int day = checks.day;
      int month = checks.month;
      int year = checks.year;

      // 날짜 포맷 계산
      // 어제 날짜
      DateTime oneDayBefore = DateTime(now.year, now.month, now.day - 1);
      String strDay = DateFormat('yyyy-MM-dd').format(oneDayBefore);
      String strMonth = DateFormat('yyyy-MM').format(oneDayBefore);
      String strYear = DateFormat('yyyy').format(oneDayBefore);

      // TbLots 업데이트 및 TbLotStatus에 기록
      for (var lotData in resultSet2) {
        String url = displayDbAddr;
        var body3 = {
          "transaction": [
            {
              "statement": "#U_TbLots",
              "values": {"isUsed": lotData['isUsed'], "tag": lotData['tag']}
            },
            {
              "statement": "#I_TbLotStatus",
              "values": {"lot": lotData['uid'], "isParked": lotData['isUsed'], "added": resultSet['timestamp']}
            }
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body3),
        );
      }

      // 시간 단위 처리: 한 시간 전 시각
      if (hour != now.hour) {
        var rowStatus = {
          'transaction': [
            {
              "query": "#S_TbLotStatus",
              "values": {"start_time": formattedStartTime, "end_time": formattedEndTime}
            }
          ]
        };
        var rowResponse = await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'] ?? [];

        var rowLot = {
          'transaction': [
            {"query": "#S_TbLots"}
          ]
        };
        var rowResponse2 = await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowLot),
        );
        var rowResult2 = jsonDecode(rowResponse2.body);
        var rowDb2 = rowResult2['results'][0]['resultSet'] ?? [];

        // lot별 현재 주차 상태를 bool로 변환
        Map<int, bool> processedResult2 = {};
        // lot별 타입 및 uid를 관리
        Map<int, dynamic> processedResult3 = {}; // lot_type
        Map<int, int> processedResult = {}; // lot uid 맵핑

        for (var item in rowDb) {
          int lot = item['lot'];
          int value = item['isParked'];
          // lot별로 주차 여부를 저장 (한 번이라도 1이면 true)
          processedResult2[lot] = processedResult2[lot] ?? false;
          if (value == 1) {
            processedResult2[lot] = true;
          }
        }

        for (var item in rowDb2) {
          int uid = item['uid'];
          processedResult3[uid] = item['lot_type'];
          processedResult[uid] = uid;
        }

        // 한 시간 전의 기록 시간
        DateTime oneHourBefore = now.subtract(Duration(hours: 1));
        String formattedTime = "${oneHourBefore.year.toString().padLeft(4, '0')}-${oneHourBefore.month.toString().padLeft(2, '0')}-${oneHourBefore.day.toString().padLeft(2, '0')} ${oneHourBefore.hour.toString().padLeft(2, '0')}";

        var check = {
          'transaction': [
            {
              "query": "#S_CountProcessedDb",
              "values": {"time": formattedTime}
            }
          ]
        };
        var checkDb = await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(check),
        );
        var dcCheckDb = jsonDecode(checkDb.body);
        var checkVal = dcCheckDb['results'][0]['resultSet'][0]['count'];

        if (checkVal == 0 && rowDb2.isNotEmpty) {
          // rowDb2를 그대로 순회, uid를 key로 사용
          for (var item in rowDb2) {
            int uid = item['uid'];
            bool parked = processedResult2[uid] ?? false;
            var carType = processedResult3[uid];

            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_processedDB",
                  "values": {"lot": uid, "car_type": carType, "hour_parking": parked ? 1 : 0, "recorded_hour": formattedTime}
                }
              ]
            };
            await http.post(
              Uri.parse(url2),
              headers: headers,
              body: jsonEncode(uploadProcessedData),
            );
          }
        }
      }

      // 하루 단위 처리
      if (day != now.day) {
        var client = http.Client();
        try {
          var rowStatus = {
            'transaction': [
              {
                "query": "#S_ProcessedDB",
                "values": {'checkdate': '$strDay%'}
              }
            ]
          };
          var rowResponse = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowStatus),
          );
          var rowResult = jsonDecode(rowResponse.body);
          var rowDb = rowResult['results'][0]['resultSet'] ?? [];

          var rowLot = {
            'transaction': [
              {"query": "#S_TbLots"}
            ]
          };
          var rowResponse2 = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowLot),
          );
          var rowResult2 = jsonDecode(rowResponse2.body);
          var rowDb2 = rowResult2['results'][0]['resultSet'] ?? [];

          Map<int, bool> processedResult2 = {};
          Map<int, int> processedResult = {};
          Map<int, dynamic> processedResult3 = {};

          for (var item in rowDb) {
            int lot = item['lot'];
            int value = item['hour_parking'];
            processedResult2[lot] = processedResult2[lot] ?? false;
            if (value == 1) {
              processedResult2[lot] = true;
            }
            processedResult[lot] = lot;
          }

          for (var item in rowDb2) {
            int uid = item['uid'];
            processedResult3[uid] = item['lot_type'];
          }

          String formattedTime = "${oneDayBefore.year.toString().padLeft(4, '0')}-${oneDayBefore.month.toString().padLeft(2, '0')}-${oneDayBefore.day.toString().padLeft(2, '0')}";

          var check = {
            'transaction': [
              {
                "query": "#S_CountRecordedDay",
                "values": {"time": formattedTime}
              }
            ]
          };
          var checkDb = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(check),
          );
          var dcCheckDb = jsonDecode(checkDb.body);
          var checkVal = dcCheckDb['results'][0]['resultSet'][0]['count'];

          if (checkVal == 0 && rowDb2.isNotEmpty) {
            for (var item in rowDb2) {
              int uid = item['uid'];
              bool parked = processedResult2[uid] ?? false;
              var carType = processedResult3[uid];

              var uploadProcessedData = {
                'transaction': [
                  {
                    "statement": "#I_PerDay",
                    "values": {"lot": uid, "car_type": carType, "day_parking": parked ? 1 : 0, "fromattedTime": formattedTime}
                  }
                ]
              };
              await client.post(
                Uri.parse(url2),
                headers: headers,
                body: jsonEncode(uploadProcessedData),
              );
            }
            // var deleteRawData = {
            //   'transaction': [
            //     {"statement": "#init_TbLotStatus"}
            //   ]
            // };
            // await client.post(
            //   Uri.parse(url2),
            //   headers: headers,
            //   body: jsonEncode(deleteRawData),
            // );
          }
        } finally {
          client.close();
        }
      }

      // 월 단위 처리: 지난 달
      // 안전한 지난달 계산
      int prevMonth = now.month - 1;
      int prevYear = now.year;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear -= 1;
      }

      if (month != now.month) {
        var client = http.Client();
        try {
          var rowStatus = {
            'transaction': [
              {
                "query": "#S_PerDay",
                "values": {'checkdate': '$strMonth%'}
              }
            ]
          };
          var rowResponse = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowStatus),
          );
          var rowResult = jsonDecode(rowResponse.body);
          var rowDb = rowResult['results'][0]['resultSet'] ?? [];

          var rowLot = {
            'transaction': [
              {"query": "#S_TbLots"}
            ]
          };
          var rowResponse2 = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowLot),
          );
          var rowResult2 = jsonDecode(rowResponse2.body);
          var rowDb2 = rowResult2['results'][0]['resultSet'] ?? [];

          Map<int, bool> processedResult2 = {};
          Map<int, int> processedResult = {};
          Map<int, dynamic> processedResult3 = {};

          for (var item in rowDb) {
            int lot = item['lot'];
            int value = item['day_parking'];
            processedResult2[lot] = processedResult2[lot] ?? false;
            if (value == 1) {
              processedResult2[lot] = true;
            }
            processedResult[lot] = lot;
          }

          for (var item in rowDb2) {
            int uid = item['uid'];
            processedResult3[uid] = item['lot_type'];
          }

          String formattedTime =
              "$prevYear-${prevMonth.toString().padLeft(2, '0')}";

          var check = {
            'transaction': [
              {
                "query": "#S_CountPerMonth",
                "values": {"time": formattedTime}
              }
            ]
          };
          var checkDb = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(check),
          );
          var dcCheckDb = jsonDecode(checkDb.body);
          var checkVal = dcCheckDb['results'][0]['resultSet'][0]['count'];

          if (checkVal == 0 && rowDb2.isNotEmpty) {
            for (var item in rowDb2) {
              int uid = item['uid'];
              bool parked = processedResult2[uid] ?? false;
              var carType = processedResult3[uid];

              var uploadProcessedData = {
                'transaction': [
                  {
                    "statement": "#I_PerMonth",
                    "values": {"lot": uid, "car_type": carType, "month_parking": parked ? 1 : 0, "fromattedTime": formattedTime}
                  }
                ]
              };
              await client.post(
                Uri.parse(url2),
                headers: headers,
                body: jsonEncode(uploadProcessedData),
              );
            }
          }
        } finally {
          client.close();
        }
      }

      // 연 단위 처리: 지난 해
      if (year != now.year) {
        var client = http.Client();
        try {
          var rowStatus = {
            'transaction': [
              {
                "query": "#S_PerMonth",
                "values": {'checkdate': '$strYear%'}
              }
            ]
          };

          var rowResponse = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowStatus),
          );
          var rowResult = jsonDecode(rowResponse.body);
          var rowDb = rowResult['results'][0]['resultSet'] ?? [];

          var rowLot = {
            'transaction': [
              {"query": "#S_TbLots"}
            ]
          };
          var rowResponse2 = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(rowLot),
          );
          var rowResult2 = jsonDecode(rowResponse2.body);
          var rowDb2 = rowResult2['results'][0]['resultSet'] ?? [];

          Map<int, bool> processedResult2 = {};
          Map<int, int> processedResult = {};
          Map<int, dynamic> processedResult3 = {};

          for (var item in rowDb) {
            int lot = item['lot'];
            int value = item['month_parking'];
            processedResult2[lot] = processedResult2[lot] ?? false;
            if (value == 1) {
              processedResult2[lot] = true;
            }
            processedResult[lot] = lot;
          }

          for (var item in rowDb2) {
            int uid = item['uid'];
            processedResult3[uid] = item['lot_type'];
          }

          String formattedTime = "${now.year - 1}";

          var check = {
            'transaction': [
              {
                "query": "#S_CountPerYear",
                "values": {"time": formattedTime}
              }
            ]
          };
          var checkDb = await client.post(
            Uri.parse(url2),
            headers: headers,
            body: jsonEncode(check),
          );
          var dcCheckDb = jsonDecode(checkDb.body);
          var checkVal = dcCheckDb['results'][0]['resultSet'][0]['count'];

          if (checkVal == 0 && rowDb2.isNotEmpty) {
            for (var item in rowDb2) {
              int uid = item['uid'];
              bool parked = processedResult2[uid] ?? false;
              var carType = processedResult3[uid];

              var uploadProcessedData = {
                'transaction': [
                  {
                    "statement": "#I_PerYear",
                    "values": {"lot": uid, "car_type": carType, "year_parking": parked ? 1 : 0, "fromattedTime": formattedTime}
                  }
                ]
              };
              await client.post(
                Uri.parse(url2),
                headers: headers,
                body: jsonEncode(uploadProcessedData),
              );
            }
          }
        } finally {
          client.close();
        }
      }

      return parkingLotList; // 정상 처리 후 parkingLotList 반환
    } else {
      print(
          'Failed to send data to server. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while sending data to server: $e');
  }
  return [];
}
