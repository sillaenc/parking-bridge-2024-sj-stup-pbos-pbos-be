import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> firstSetting(url) async {
  try {
    final folderPath = 'bin/data/json_folder/';
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
          "query": "SELECT tag FROM tb_lots",
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
        var body = {
          "transaction": [
            {
              "query": "INSERT INTO tb_parking_zone (parking_name, file_address) VALUES (:parking_name, :file_address)",
              "values": { "parking_name": fileNames[i], "file_address": filePath[i] }
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
            var header = {'Content-Type': 'application/json'};
            var body = {
              "transaction": [
                {
                  "query": "INSERT INTO tb_lots ('tag', 'lot_type', 'point', 'asset') VALUES (:tag, :lot_type, :point, :asset)",
                  "VALUES": {"tag": tag, "lot_type": lotType, "point": point, "asset": asset}
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
