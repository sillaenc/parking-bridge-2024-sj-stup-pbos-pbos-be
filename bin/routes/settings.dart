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
    router.post('/', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
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

        // DB 서버에 POST 요청
        final response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var code = response.statusCode;
        return Response(code);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    /// GET 요청으로 설정값 조회
    /// Query parameter로 key를 받음: GET /api/v1/settings/general/get?key=somekey
    router.get('/get', (Request request) async{
      try {
        // Query parameter에서 key 추출
        final key = request.url.queryParameters['key'];
        
        // key가 없는 경우 400 에러 반환
        if (key == null || key.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': 'key 파라미터가 필요합니다.',
              'error': 'MISSING_KEY_PARAMETER',
              'timestamp': DateTime.now().toIso8601String(),
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        // DB 쿼리 실행
        var body = {
          "transaction": [
            {
              "query": "#get_settings",
              "values": {"key": key}
            }
          ]
        };
        
        var result = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        
        var decodedresult = jsonDecode(utf8.decode(result.bodyBytes));
        var resultSet = decodedresult['results'][0]['resultSet'][0];
        print('Settings.get - key: $key, result: $resultSet');
        
        return Response.ok(
          jsonEncode(resultSet), 
          headers: {'Content-Type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Settings.get 오류: $e');
        print('스택 트레이스: $stackTrace');
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': '설정 조회 중 오류가 발생했습니다.',
            'error': e.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    router.post('/dlatl', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        Map<String, dynamic> tbLots = requestData['tb_lots'];
        List<Map<String, dynamic>> transactions = [];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
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
        await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("tb_lots 업데이트 성공");
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }
}