import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<List<dynamic>> receiveEnginedataSendToDartserver(
    var engineDbaddr, var displayDbAddr, DateTime check) async {
  print('Sending data to server at: ${DateTime.now()}');
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
      var resultSet = responseData['results'][0]['resultSet'][0];

      var parkingLot = resultSet['parking_lot'];
      var parkingLotList = parkingLot.split(',');
      parkingLotList.removeAt(0); // "start" 제거
      parkingLotList.sort();

      String url2 = displayDbAddr;
      var raw = {
        "transaction": [
          {
            "statement": "#I_Rawdata",
            "values": {
              "id": resultSet['id'],
              "timestamp": resultSet['timestamp'],
              "parking_lot": resultSet['parking_lot']
            }
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

      for (var lot in resultSet2) {
        var tag = lot["tag"];
        if (parkingLotList.contains(tag)) {
          lot["isUsed"] = 1;
        } else {
          lot["isUsed"] = 0;
        }
      }

      DateTime now = DateTime.now();

      int currentHour = now.hour;
      int currentMinute = now.minute;
      int currentSecond = now.second;
      int currentDay = now.day;
      int currentMonth = now.month;
      int currentYear = now.year;

      DateTime oneHourBefore = now.subtract(Duration(hours: 1));
      DateTime oneDayBefore = now.subtract(Duration(days: 1));
      DateTime oneMonthBefore = DateTime(now.year, now.month - 1, now.day);
      DateTime oneYearBefore = DateTime(now.year - 1, now.month, now.day);

      String formattedHour = DateFormat('yyyy-MM-dd HH').format(oneHourBefore);
      String formattedDay = DateFormat('yyyy-MM-dd').format(oneDayBefore);
      String formattedMonth = DateFormat('yyyy-MM').format(oneMonthBefore);
      String formattedYear = DateFormat('yyyy').format(oneYearBefore);

      // 각 주차장 상태 업데이트 및 RawData 저장
      for (var lot in resultSet2) {
        var body3 = {
          "transaction": [
            {
              "statement": "#U_TbLots",
              "values": {"isUsed": lot['isUsed'], "tag": lot['tag']}
            },
            {
              "statement": "#I_TbLotStatus",
              "values": {
                "lot": lot['uid'],
                "isParked": lot['isUsed'],
                "added": resultSet['timestamp']
              }
            }
          ]
        };
        await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(body3),
        );
      }

      // HTTP 클라이언트 생성
      var client = http.Client();

      // **시간별 통계 처리 (매시간 0분 0초)**
      if (currentMinute == 0 && currentSecond == 0) {
        var rowStatus = {
          'transaction': [
            {"query": "#S_TbLotStatus"}
          ]
        };
        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];

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
        var rowDb2 = rowResult2['results'][0]['resultSet'];

        Map<dynamic, dynamic> processedResult2 = {};
        Map<dynamic, dynamic> processedResult3 = {};
        Map<dynamic, dynamic> processedResult = {};

        for (var item in rowDb) {
          int tag = item['lot'];
          var value = item['isParked'];
          processedResult2[tag] = processedResult2[tag] ?? false;
          if (value == 1) {
            processedResult2[tag] = true;
          }
        }

        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
          processedResult[tag] = item['uid'];
        }

        var check = {
          'transaction': [
            {
              "query": "#S_CountProcessedDb",
              "values": {"time": formattedHour}
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
        if (checkVal == 0) {
          for (var key in processedResult.keys) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_processedDB",
                  "values": {
                    "lot": processedResult[key],
                    "car_type": processedResult3[key],
                    "hour_parking": processedResult2[key],
                    "recorded_hour": formattedHour
                  }
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

        var deleteRawData = {
          'transaction': [
            {"statement": "#D_TbLotStatus"}
          ]
        };
        await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(deleteRawData),
        );
      }

      // **일별 통계 처리 (매일 1시 0분 0초)**
      if (currentHour == 1 && currentMinute == 0 && currentSecond == 30) {
        var rowStatus = {
          'transaction': [
            {
              "query": "#S_ProcessedDB",
              "values": {'checkdate': '$formattedDay%'}
            }
          ]
        };
        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];

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
        var rowDb2 = rowResult2['results'][0]['resultSet'];

        Map<dynamic, dynamic> processedResult2 = {};
        Map<dynamic, dynamic> processedResult = {};
        for (var item in rowDb) {
          int tag = item['lot'];
          int lot = item['lot'];
          var value = item['hour_parking'];
          processedResult2[tag] = processedResult2[tag] ?? false;
          if (value == 1) {
            processedResult2[tag] = true;
          }
          processedResult[lot] = item['lot'];
        }

        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }

        var check = {
          'transaction': [
            {
              "query": "#S_CountRecordedDay",
              "values": {"time": formattedDay}
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
        if (checkVal == 0) {
          for (var key in processedResult.keys) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_PerDay",
                  "values": {
                    "lot": processedResult[key],
                    "car_type": processedResult3[key],
                    "day_parking": processedResult2[key],
                    "fromattedTime": formattedDay
                  }
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
      }

      // **월별 통계 처리 (매월 2일 0시 0분 0초)**
      if (currentDay == 1 && currentHour == 0 && currentMinute == 0 && currentSecond == 43) {
        var rowStatus = {
          'transaction': [
            {
              "query": "#S_PerDay",
              "values": {'checkdate': '$formattedMonth%'}
            }
          ]
        };
        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];

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
        var rowDb2 = rowResult2['results'][0]['resultSet'];

        Map<dynamic, dynamic> processedResult2 = {};
        Map<dynamic, dynamic> processedResult = {};
        for (var item in rowDb) {
          int tag = item['lot'];
          int lot = item['lot'];
          var value = item['day_parking'];
          processedResult2[tag] = processedResult2[tag] ?? false;
          if (value == 1) {
            processedResult2[tag] = true;
          }
          processedResult[lot] = item['lot'];
        }

        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }

        var check = {
          'transaction': [
            {
              "query": "#S_CountPerMonth",
              "values": {"time": formattedMonth}
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
        if (checkVal == 0) {
          for (var key in processedResult.keys) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_PerMonth",
                  "values": {
                    "lot": processedResult[key],
                    "car_type": processedResult3[key],
                    "month_parking": processedResult2[key],
                    "fromattedTime": formattedMonth
                  }
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
      }

      // **연간 통계 처리 (매년 1월 1일 0시 0분 0초)**
      if (currentMonth == 1 && currentDay == 1 && currentHour == 0 && currentMinute == 0 && currentSecond == 55) {
        var rowStatus = {
          'transaction': [
            {
              "query": "#S_PerMonth",
              "values": {'checkdate': '$formattedYear%'}
            }
          ]
        };
        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];
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
        var rowDb2 = rowResult2['results'][0]['resultSet'];

        Map<dynamic, dynamic> processedResult2 = {};
        Map<dynamic, dynamic> processedResult = {};
        for (var item in rowDb) {
          int tag = item['lot'];
          int lot = item['lot'];
          var value = item['month_parking'];
          processedResult2[tag] = processedResult2[tag] ?? false;
          if (value == 1) {
            processedResult2[tag] = true;
          }
          processedResult[lot] = item['lot'];
        }
        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }
        var check = {
          'transaction': [
            {
              "query": "#S_CountPerYear",
              "values": {"time": formattedYear}
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
        if (checkVal == 0) {
          for (var key in processedResult.keys) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_PerYear",
                  "values": {
                    "lot": processedResult[key],
                    "car_type": processedResult3[key],
                    "year_parking": processedResult2[key],
                    "fromattedTime": formattedYear
                  }
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
      }
      client.close();
      return parkingLotList;
    } else {
      print(
          'Failed to send data to server. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while sending data to server: $e');
  }
  return [];
}
