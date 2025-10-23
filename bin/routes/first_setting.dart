import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> firstSetting(url) async {
  try {
    final folderPath = 'json_folder/';
    final displayPath = 'display/';
    final directory = Directory(folderPath);
    final directory2 = Directory(displayPath);
    if (!directory.existsSync()) {
      print('디렉토리가 존재하지 않습니다: $folderPath');
      return;
    }
    List<FileSystemEntity> files = directory.listSync();
    List<FileSystemEntity> files2 = directory2.listSync();
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files2.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    List<String> filePath = [];
    List<String> fileNames = []; // /json_folder;
    List<String> filePath2 = [];
    List<String> fileNames2 = []; // /display;
    for (var file in files) {
      if (file is File) {
        fileNames.add(file.path.split('/').last);
        filePath.add(file.path);
      }
    }
    for (var file in files2) {
      if (file is File) {
        fileNames2.add(file.path.split('/').last);
        filePath2.add(file.path);
      }
    }
    var header = {'Content-Type': 'application/json'};
    print(files);
    print(url);

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
        if (fileNames[i].startsWith('F')) {
          floor += 'F';
        } else if (fileNames[i].startsWith('B')) {
          floor += 'B';
        } else if (fileNames[i].startsWith('ALL')) {
          floor += 'ALL';
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
              "values": {
                "parking_name": fileNames[i],
                "file_address": filePath[i],
                "floor": floor
              }
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
            var body = {
              "transaction": [
                {
                  "statement": "#I_TbLots",
                  "values": {
                    "tag": tag,
                    "lot_type": lotType,
                    "point": point,
                    "asset": asset,
                    "floor": floor
                  }
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
      for (final file in files2) {
        if (file is File) {
          final content = await file.readAsString();
          final jsonData = jsonDecode(content);
          for (final item in jsonData['tb_lots'].values) {
            String tag = item['tag'];
            int lotType = item['lot_type'];
            String point = item['point'];
            String asset = item['asset'];
            String floor = item['floor'];
            var body = {
              "transaction": [
                {
                  "statement": "#I_display",
                  "values": {
                    "tag": tag,
                    "lot_type": lotType,
                    "point": point,
                    "asset": asset,
                    "floor": floor
                  }
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

    // RTSP 캡처 설정 초기화
    final rtspFolderPath = 'rtsp/';
    final rtspDirectory = Directory(rtspFolderPath);

    if (rtspDirectory.existsSync()) {
      print('📸 RTSP 캡처 설정 초기화 시작...');

      final rtspFiles = rtspDirectory.listSync();
      int rtspInsertCount = 0;

      for (var file in rtspFiles) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final jsonData = jsonDecode(content);

            // rtsp 키 확인
            if (jsonData['rtsp'] != null) {
              final rtspData = jsonData['rtsp'] as Map<String, dynamic>;

              for (var entry in rtspData.values) {
                final tag = entry['tag'] as String;
                final rtspAddress = entry['rtsp_address'] as String;

                // last_image_path는 rtsp_address로부터 생성
                // 호스트와 포트만 추출하여 파일명 생성
                String imagePath;
                try {
                  final uri = Uri.parse(rtspAddress);
                  final host =
                      uri.host.replaceAll('.', '_').replaceAll('-', '_');
                  final port = uri.hasPort ? '_${uri.port}' : '';
                  imagePath = 'camera/captures/cam_${host}${port}.jpg';
                } catch (e) {
                  // 파싱 실패 시 fallback
                  imagePath =
                      'camera/captures/cam_${rtspAddress.hashCode.abs()}.jpg';
                }

                var body = {
                  "transaction": [
                    {
                      "statement": "#I_RtspCapture",
                      "values": {
                        "tag": tag,
                        "rtsp_address": rtspAddress,
                        "last_image_path": imagePath,
                      }
                    }
                  ]
                };

                await http.post(
                  Uri.parse(url!),
                  headers: header,
                  body: jsonEncode(body),
                );

                rtspInsertCount++;
              }

              print(
                  '✅ ${file.path.split('/').last} 처리 완료 (${rtspData.length}개 항목)');
            }
          } catch (e) {
            print('❌ ${file.path} 처리 중 오류 발생: $e');
          }
        }
      }

      print('✅ RTSP 캡처 설정 초기화 완료 (총 $rtspInsertCount개 항목)');
    } else {
      print('ℹ️  RTSP 디렉토리가 존재하지 않습니다: $rtspFolderPath');
    }

    //
  } catch (e) {
    print('최초 세팅 문제 발생: $e');
  }
}
