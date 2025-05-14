import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

class SettingsDbManagement {
  final ManageAddress manageAddress;
  SettingsDbManagement({required this.manageAddress});

  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/db-settings - DB 설정 정보 조회
    router.get('/', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_TbDbSetting"}
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
              'error': 'DB 설정 정보 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'][0];

        return Response(200,
          body: json.encode({
            'db_settings': resultSet,
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

    // PUT /api/v1/db-settings/engine - 엔진 DB 설정 업데이트
    router.put('/engine', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('engineDb')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['engineDb']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var changeEngine = requestData['engineDb'];
        var body = {
          "transaction": [
            {
              "statement": "#U_TbDbSetting",
              "values": {"changeEngine": changeEngine}
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
              'error': '엔진 DB 설정 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '엔진 DB 설정이 성공적으로 업데이트되었습니다',
            'engine_db': changeEngine,
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

    // PUT /api/v1/db-settings/display - 디스플레이 DB 설정 업데이트
    router.put('/display', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('displayDb')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['displayDb']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var changeDisplay = requestData['displayDb'];
        var body = {
          "transaction": [
            {
              "statement": "#U_TbDbSetting",
              "values": {"changeDisplay": changeDisplay}
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
              'error': '디스플레이 DB 설정 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '디스플레이 DB 설정이 성공적으로 업데이트되었습니다',
            'display_db': changeDisplay,
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
