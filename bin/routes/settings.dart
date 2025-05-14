import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Settings {
  final ManageAddress manageAddress;
  Settings({required this.manageAddress});
  
  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // PUT /api/v1/settings - 설정 업데이트
    router.put('/', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);

        if (!input.containsKey('key') || !input.containsKey('value')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['key', 'value']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var key = input['key'];
        var value = jsonEncode(input['value']);
        
        var body = {
          "transaction": [
            {
              "query": "#upsert_settings",
              "values": {"key": key, "value": value}
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
              'error': '설정 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '설정이 성공적으로 업데이트되었습니다',
            'key': key,
            'value': input['value'],
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

    // GET /api/v1/settings/{key} - 특정 설정 조회
    router.get('/:key', (Request request) async {
      try {
        var key = request.params['key'];
        if (key == null) {
          return Response(400,
            body: json.encode({
              'error': '설정 키가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var body = {
          "transaction": [
            {
              "query": "#get_settings",
              "values": {"key": key}
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
              'error': '설정 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(utf8.decode(response.bodyBytes));
        var resultSet = data['results'][0]['resultSet'][0];

        return Response(200,
          body: json.encode({
            'settings': resultSet,
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

    // PUT /api/v1/settings/lots - 주차 구역 정보 일괄 업데이트
    router.put('/lots', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('tb_lots')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['tb_lots']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        Map<String, dynamic> tbLots = requestData['tb_lots'];
        List<Map<String, dynamic>> transactions = [];

        tbLots.forEach((key, value) {
          transactions.add({
            "statement": "#tblos_dlatl",
            "values": {
              "tag": value['tag'],
              "lot_type": value['lot_type'],
              "point": value['point'],
              "asset": value['asset'],
              "floor": value['floor'],
            }
          });
        });

        var body = {
          "transaction": transactions
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
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
            'message': '주차 구역 정보가 성공적으로 업데이트되었습니다',
            'updated_lots': tbLots.length,
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