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
      // print(parkingLotList);
      // print(parkingLotList);
      // int id = resultSet['id'];

      // var timestamp = resultSet['timestamp'];
      // var parkinglot = resultSet['parking_lot'];
      // print(parkinglot);
      String url2 = displayDbAddr;
      var raw = {
        "transaction": [
          {
            "statement": "#I_Rawdata",
            "values": { "id": resultSet['id'], "timestamp": resultSet['timestamp'], "parking_lot": resultSet['parking_lot'] }
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
          {"statement": "#S_TbLots"}
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
      DateTime checks = check.subtract(Duration(seconds: 10));
      int hour = checks.hour;
      int day = checks.day;
      int month = checks.month;
      int year = checks.year;
      // String strDay = DateFormat('yyyy-M-dd').format(check);
      DateTime onedayBefore = now.subtract(Duration(days: 1));
      String strDay = DateFormat('yyyy-M-d').format(onedayBefore);
      String strMonth = DateFormat('yyyy-M').format(onedayBefore);
      String strYear = DateFormat('yyyy').format(onedayBefore);
      // print('12초빼기 : $checks');
      // print('지금 시각 : $now');
      for (int i = 0; i < resultSet2.length; i++) {
        String url = displayDbAddr;
        var body3 = {
          "transaction": [
            {
              "statement": "#U_TbLots",
              "values": { "isUsed": resultSet2[i]['isUsed'], "tag": resultSet2[i]['tag'] }
            },
            {
              "statement": "#I_TbLotStatus",
              "values": { "lot": resultSet2[i]['uid'], "isParked": resultSet2[i]['isUsed'], "added": resultSet['timestamp'] }
            }
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body3),
        );
      }

      //2초 -> 1시간 단위로 db를 뽑아내는 코드
      // if (1 ==1) {
      if (hour != now.hour) {
        var rowStatus = {
          'transaction': [
            {"statement": "#S_TbLotStatus"}
          ]
        };
        var rowResponse = await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];

        var rowLot = {
          'transaction': [
            {"statement": "#S_TbLots"}
          ]
        };
        var rowResponse2 = await http.post(
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
          int lot = item['uid'];
          processedResult3[tag] = item['lot_type'];
          processedResult[lot] = processedResult[lot] ?? 0;
          processedResult[lot] = item['uid'];
        }

        DateTime oneHourBefore = now.subtract(Duration(hours: 1));
        String fromattedTime =
            "${oneHourBefore.year}-${oneHourBefore.month}-${oneHourBefore.day} ${oneHourBefore.hour}";

        var check = {
          'transaction': [
            {
              "statement": "#S_CountProcessedDb",
              "values": {"time": fromattedTime}
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
        print(checkVal);
        if (checkVal == 0) {
          for (int i = 1; i <= rowDb2.length; i++) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_processedDB",
                  "values": { "lot": processedResult[i], "car_type": processedResult3[i], "hour_parking": processedResult2[i], "recorded_hour": fromattedTime }
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

        var deleteRawData = {
          'transaction': [
            {"statement": "#D_TbLotStatus"}
          ]
        };
        await http.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(deleteRawData),
        );
      }

      //1시간 -> 하루 단위로 db를 뽑아내는 코드
      // if (1 == 1) {
      //now.subtract(Duration(days: 1))
      if (day != now.day) {
        var rowStatus = {
          'transaction': [
            {
              "statement": "#S_ProcessedDB",
              "values": {'checkdate': '$strDay%'}
            }
          ]
        };
        var client = http.Client();

        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];
        // print(rowDb);
        var rowLot = {
          'transaction': [
            {"statement": "#S_TbLots"}
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
          // else if (value == 0) {
          //   processedResult2[tag] = false;
          // }이거 주석인 이유는. 한번이라도 찬 경우는 1로 보기 때문에 0이 아닌 1로 변환함
          processedResult[lot] = processedResult[lot] ?? 0;
          processedResult[lot] = item['lot'];
        }

        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }

        DateTime oneHourBefore = now.subtract(Duration(days: 1));
        String fromattedTime =
            "${oneHourBefore.year}-${oneHourBefore.month}-${oneHourBefore.day}";
        var check = {
          'transaction': [
            {
              "statement": "#S_CountRecordedDay",
              "values": {"time": fromattedTime}
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
        print(processedResult2);
        if (checkVal == 0) {
          for (int i = 1; i <= rowDb2.length; i++) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_PerDay",
                  "values": { "lot": processedResult[i], "car_type": processedResult3[i], "day_parking": processedResult2[i], "fromattedTime": fromattedTime }
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
        client.close();
      }

      //하루 -> 월 단위로 db를 뽑아내는 코드
      // if (1 == 1) {
      if (month != now.month) {
        var rowStatus = {
          'transaction': [
            {
              "statement": "#S_PerDay",
              "values": {'checkdate': '$strMonth%'}
            }
          ]
        };
        var client = http.Client();

        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];
        // print(rowDb);
        var rowLot = {
          'transaction': [
            {"statement": "#S_TbLots"}
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
          processedResult[lot] = processedResult[lot] ?? 0;
          processedResult[lot] = item['lot'];
        }

        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }

        // DateTime oneHourBefore = now.subtract(Duration(days: 30));
        String fromattedTime = "${now.year}-${now.month - 1}";
        var check = {
          'transaction': [
            {
              "statement": "#S_CountPerMonth",
              "values": {"time": fromattedTime}
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
        print(processedResult3);
        if (checkVal == 0) {
          for (int i = 1; i <= rowDb2.length; i++) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement": "#I_PerMonth",
                  "values": { "lot": processedResult[i], "car_type": processedResult3[i], "month_parking": processedResult2[i], "fromattedTime": fromattedTime }
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
        client.close();
      }

      //월 -> 연 단위로 db를 뽑아내는 코드
      if (year != now.year) {
        var rowStatus = {
          'transaction': [
            {
              "statement": "#S_PerMonth",
              "values": {'checkdate': '$strYear%'}
            }
          ]
        };
        var client = http.Client();

        var rowResponse = await client.post(
          Uri.parse(url2),
          headers: headers,
          body: jsonEncode(rowStatus),
        );
        var rowResult = jsonDecode(rowResponse.body);
        var rowDb = rowResult['results'][0]['resultSet'];
        // print(rowDb);
        var rowLot = {
          'transaction': [
            {"statement": "#S_TbLots"}
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
          processedResult[lot] = processedResult[lot] ?? 0;
          processedResult[lot] = item['lot'];
        }

        Map<dynamic, dynamic> processedResult3 = {};
        for (var item in rowDb2) {
          int tag = item['uid'];
          processedResult3[tag] = item['lot_type'];
        }

        String fromattedTime = "${now.year - 1}";
        var check = {
          'transaction': [
            {
              "statement": "#S_CountPerYear",
              "values": {"time": fromattedTime}
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
        print(processedResult3);
        if (checkVal == 0) {
          for (int i = 1; i <= rowDb2.length; i++) {
            var uploadProcessedData = {
              'transaction': [
                {
                  "statement" : "#I_PerYear",
                  "values": { "lot": processedResult[i], "car_type": processedResult3[i], "year_parking": processedResult2[i], "fromattedTime": fromattedTime }
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
        client.close();
      }
      return parkingLotList;
      //return to Main.dart and send that to client
    } else {
      print(
          'Failed to send data to server. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred while sending data to server: $e');
  }
  return [];
}
