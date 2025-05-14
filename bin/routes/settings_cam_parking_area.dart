import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

/// 사용자 관리 setting backend part.
/// 사용자 관리 설정
/// 사용자 생성 기능(기존 활용 가능)
/// password new_password 형식으로 update함.(기존 활용 가능)
/// username update하는 기능
/// userlevel, isActivated update하는 기능.
/// 마지막으로 시작할때, tb_users 전부 response하게 하자.
class SettingsCamParkingArea {
  final ManageAddress manageAddress;
  SettingsCamParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    print(url);
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/cam-parking-areas - 주차 구역 목록 조회
    router.get('/', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_TbParkingSurface"}
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
              'error': '주차 구역 목록 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        if (resultSet.isEmpty) {
          return Response(404,
            body: json.encode({
              'error': '주차 구역 정보가 없습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

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

    // PUT /api/v1/cam-parking-areas/{tag} - 주차 구역 정보 업데이트
    router.put('/:tag', (Request request) async {
      try {
        var beforeTag = request.params['tag'];
        if (beforeTag == null) {
          return Response(400,
            body: json.encode({
              'error': '주차 구역 태그가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('tag') || !requestData.containsKey('engine_code') || !requestData.containsKey('uri')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['tag', 'engine_code', 'uri']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];

        // 기존 태그 정보 조회
        var checkBody = {
          "transaction": [
            {
              "query": "#S_TbParkingSurfaceTag",
              "values": {"tag": beforeTag}
            }
          ]
        };

        var checkResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkBody),
        );

        if (checkResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 조회에 실패했습니다',
              'status_code': checkResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var checkData = jsonDecode(checkResponse.body);
        var uid = checkData['results'][0]['resultSet'][0]['uid'].toString();

        // 주차 구역 정보 업데이트
        var updateBody = {
          "transaction": [
            {
              "statement": "U_TbParkingSurface",
              "values": {
                "tag": tag,
                "engine_code": engineCode,
                "uri": uri,
                "uid": uid
              }
            }
          ]
        };

        var updateResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(updateBody),
        );

        if (updateResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차 구역 정보 업데이트에 실패했습니다',
              'status_code': updateResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역 정보가 성공적으로 업데이트되었습니다',
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

    // POST /api/v1/cam-parking-areas - 새로운 주차 구역 추가
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('tag') || !requestData.containsKey('engine_code') || !requestData.containsKey('uri')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['tag', 'engine_code', 'uri']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];

        var body = {
          "transaction": [
            {
              "statement": "#I_TbParkingSurface",
              "values": {
                "tag": tag,
                "engine_code": engineCode,
                "uri": uri
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
              'error': '주차 구역 추가에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(201,
          body: json.encode({
            'message': '새로운 주차 구역이 성공적으로 추가되었습니다',
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

    // DELETE /api/v1/cam-parking-areas/{tag} - 주차 구역 삭제
    router.delete('/:tag', (Request request) async {
      try {
        var tag = request.params['tag'];
        if (tag == null) {
          return Response(400,
            body: json.encode({
              'error': '주차 구역 태그가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var body = {
          "transaction": [
            {
              "statement": "#D_TbParkingSurface",
              "values": {"tag": tag}
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
              'error': '주차 구역 삭제에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차 구역이 성공적으로 삭제되었습니다',
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
