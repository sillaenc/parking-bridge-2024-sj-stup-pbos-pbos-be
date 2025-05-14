import 'dart:convert';
import 'dart:typed_data';
// import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as p;

import '../data/manage_address.dart'; // json 처리

String fileDirectory = 'file';

String getExtensionFromContentDisposition(String contentDisposition) {
  final regex = RegExp(r'filename="[^"]+\.(\w+)"');
  final match = regex.firstMatch(contentDisposition);
  return match?.group(1) ?? '';
}

class SettingsParkingArea {
  final ManageAddress manageAddress;
  SettingsParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/parking-areas - 주차 구역 목록 조회
    router.get('/', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_TbParkingZone"}
          ]
        };
        print(url);
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 목록 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(utf8.decode(response.bodyBytes));
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'parking_areas': resultSet,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // POST /api/v1/parking-areas - 새로운 주차 구역 파일 업로드
    router.post('/', (Request request) async {
      try {
        if (!request.isMultipart) {
          return Response(400,
            body: json.encode({
              'error': '멀티파트 요청이 필요합니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        String? fileName;
        String? filePath;
        Uint8List? content;
        String? extension;

        await for (final part in request.parts) {
          final headers = part.headers['content-disposition'] ?? '';
          if (headers.contains('name="filename"')) {
            fileName = await part.readString();
            fileName = p.basename(fileName);
          } else if (headers.contains('name="file"')) {
            content = await part.readBytes();
            extension = getExtensionFromContentDisposition(headers);
          }
        }

        if (fileName == null || content == null || extension == null) {
          return Response(400,
            body: json.encode({
              'error': '필수 파일 정보가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        filePath = '$fileDirectory/$fileName.$extension';
        var file = File(filePath);
        await file.create();
        await file.writeAsBytes(content);

        var body = {
          "transaction": [
            {
              "statement": "#I_TbPakringZone",
              "values": {
                "parking_name": fileName,
                "file_address": filePath
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          await file.delete();
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 저장에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(201,
          body: json.encode({
            'message': '주차 구역 파일이 성공적으로 업로드되었습니다',
            'file_name': fileName,
            'file_path': filePath,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // PUT /api/v1/parking-areas/{filename} - 주차 구역 파일 업데이트
    router.put('/:filename', (Request request) async {
      try {
        var beforeName = request.params['filename'];
        if (beforeName == null) {
          return Response(400,
            body: json.encode({
              'error': '파일명이 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        if (!request.isMultipart) {
          return Response(400,
            body: json.encode({
              'error': '멀티파트 요청이 필요합니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        String? fileName;
        String? filePath;
        Uint8List? content;
        String? extension;

        await for (final part in request.parts) {
          final headers = part.headers['content-disposition'] ?? '';
          if (headers.contains('name="filename"')) {
            fileName = await part.readString();
            fileName = p.basename(fileName);
          } else if (headers.contains('name="file"')) {
            content = await part.readBytes();
            extension = getExtensionFromContentDisposition(headers);
          }
        }

        if (fileName == null || content == null || extension == null) {
          return Response(400,
            body: json.encode({
              'error': '필수 파일 정보가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        filePath = '$fileDirectory/$fileName.$extension';
        var beforePath = '$fileDirectory/$beforeName.$extension';
        
        var file = File(filePath);
        var beforeFile = File(beforePath);

        await file.create();
        await file.writeAsBytes(content);

        if (await beforeFile.exists()) {
          await beforeFile.delete();
        }

        var body = {
          "transaction": [
            {
              "statement": "#I_TbPakringZone",
              "values": {
                "parking_name": fileName,
                "file_address": filePath
              }
            },
            {
              "statement": "#D_TbPakringZoneName",
              "values": {"parking_name": beforeName}
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          await file.delete();
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역 파일이 성공적으로 업데이트되었습니다',
            'file_name': fileName,
            'file_path': filePath,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // DELETE /api/v1/parking-areas/{filename} - 주차 구역 파일 삭제
    router.delete('/:filename', (Request request) async {
      try {
        var filename = request.params['filename'];
        if (filename == null) {
          return Response(400,
            body: json.encode({
              'error': '파일명이 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var findBody = {
          "transaction": [
            {
              "query": "#S_TbPakringZoneName",
              "values": {"parking_name": filename}
            }
          ]
        };

        var findResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(findBody),
        );

        if (findResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 조회에 실패했습니다',
              'status_code': findResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var findData = jsonDecode(utf8.decode(findResponse.bodyBytes));
        var resultSet = findData['results'][0]['resultSet'];

        if (resultSet.isEmpty) {
          return Response(404,
            body: json.encode({
              'error': '해당 주차 구역 파일을 찾을 수 없습니다',
              'filename': filename
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var filePath = resultSet[0]['file_address'];
        var file = File(filePath);

        if (await file.exists()) {
          await file.delete();
        }

        var deleteBody = {
          "transaction": [
            {
              "statement": "#D_TbPakringZoneName",
              "values": {"parking_name": filename}
            }
          ]
        };

        var deleteResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(deleteBody),
        );

        if (deleteResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 삭제에 실패했습니다',
              'status_code': deleteResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역 파일이 성공적으로 삭제되었습니다',
            'filename': filename,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // PUT /api/v1/parking-areas/lot-type - 주차 구역 차종 변경
    router.put('/lot-type', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('lot_type') || !requestData.containsKey('changed_tag') || !requestData.containsKey('tag')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['lot_type', 'changed_tag', 'tag']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var lotType = requestData['lot_type'];
        var changedTag = requestData['changed_tag'];
        var tag = requestData['tag'];

        var body = {
          "transaction": [
            {
              "statement": "#U_LotType",
              "values": {
                "changed_tag": changedTag,
                "tag": tag,
                "lot_type": lotType
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 차종 변경에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역 차종이 성공적으로 변경되었습니다',
            'lot_type': lotType,
            'changed_tag': changedTag,
            'tag': tag,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // PUT /api/v1/parking-areas/parked - 주차 구역 사용 여부 변경
    router.put('/parked', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('parked') || !requestData.containsKey('tag')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['parked', 'tag']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var parked = requestData['parked'];
        var tag = requestData['tag'];

        var body = {
          "transaction": [
            {
              "statement": "#U_Parked",
              "values": {
                "parked": parked,
                "tag": tag
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 사용 여부 변경에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역 사용 여부가 성공적으로 변경되었습니다',
            'parked': parked,
            'tag': tag,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    return router;
  }
}
