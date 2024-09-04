import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> firstSetting(url) async {
  try {
    final folderPath = 'json_folder/';
    final files = Directory(folderPath).listSync();
    var header = {'Content-Type': 'application/json'};
    print(files);
    print(url);
    List<String> filePath = [];
    List<String> fileNames = [];
    for (var file in files) {
      if (file is File) {
        fileNames.add(file.path.split('/').last);
        filePath.add(file.path);
      }
    }
    var body = {
      "transaction": [
        {
          "query": "#S_Tag",
        }
      ]
    };
    var response = await http.post(
      Uri.parse(url!),
      headers: header,
      body: jsonEncode(body),
    );
    var deresponse = jsonDecode(response.body);
    var checkTable = deresponse['results'][0]['resultSet'];
    if (checkTable.isNotEmpty) {
      print('tb_lots check complete');
    } else {
      for (int i = 0; i < fileNames.length; i++) {
        String floor = '';
        if (fileNames[i].startsWith('지상')) {
          floor += 'F';
        } else if (fileNames[i].startsWith('지하')) {
          floor += 'B';
        }
        RegExp regExp = RegExp(r'\d');
        Match? match = regExp.firstMatch(fileNames[i]);
        if (match != null) {
          floor += match.group(0)!; // 숫자가 있으면 추가
        }
        var body = {
          "transaction": [
            {
              "statement": "#I_ParkingZone",
              "values": { "parking_name": fileNames[i], "file_address": filePath[i], "floor": floor }
            }
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: header,
          body: jsonEncode(body),
        );
      }
      print('tb_lots table null!!');
      for (final file in files) {
        if (file is File) {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content);
          for (final item in jsonData['tb_lots'].values) {
            String tag = item['tag'];
            int lotType = item['lot_type'];
            String point = item['point'];
            String asset = item['asset'];
            String floor = item['floor'];
            var header = {'Content-Type': 'application/json'};
            var body = {
              "transaction": [
                {
                  "statement": "#I_TbLots",
                  "VALUES": {"tag": tag, "lot_type": lotType, "point": point, "asset": asset, "floor": floor}
                }
              ]
            };
            await http.post(
              Uri.parse(url!),
              headers: header,
              body: jsonEncode(body),
            );
          }
        }
      }
      print('tb_lots insert progress complete!');
    }
  } catch (e) {
    print('최초 세팅 문제 발생: $e');
  }
}
