import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Isalive {
  final ManageAddress manageAddress;
  Isalive({required this.manageAddress});
  
  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // POST /api/v1/isalive/endpoints - 새로운 엔드포인트 추가
    router.post('/endpoints', (Request request) async {
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
        String newUrl = input['value'];

        // 기존 엔드포인트 목록 조회
        var getBody = {
          "transaction": [
            { "query": "#get_alive" }
          ]
        };
        var getResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(getBody),
        );

        if (getResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '엔드포인트 목록 조회에 실패했습니다',
              'status_code': getResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var decodedGet = jsonDecode(getResponse.body);
        String currentValue = decodedGet['results'][0]['resultSet'][0]['value'] ?? "{}";
        currentValue = currentValue.trim();
        
        String inner = "";
        if (currentValue.startsWith("{") && currentValue.endsWith("}")) {
          inner = currentValue.substring(1, currentValue.length - 1).trim();
        } else {
          inner = currentValue;
        }

        String newValue = inner.isEmpty ? "{'$newUrl'}" : "{$inner,'$newUrl'}";

        // 새로운 엔드포인트 추가
        var upsertBody = {
          "transaction": [
            {
              "query": "#upsert_isalive",
              "values": {"key": key, "value": newValue}
            }
          ]
        };
        var upsertResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(upsertBody),
        );

        if (upsertResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '엔드포인트 추가에 실패했습니다',
              'status_code': upsertResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(201,
          body: json.encode({
            'message': '새로운 엔드포인트가 성공적으로 추가되었습니다',
            'endpoint': newUrl
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

    // GET /api/v1/isalive/endpoints - 엔드포인트 상태 조회
    router.get('/endpoints', (Request request) async {
      try {
        var body = {
          "transaction": [
            { "query": "#get_alive" }
          ]
        };
        var result = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (result.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '엔드포인트 목록 조회에 실패했습니다',
              'status_code': result.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var decodedresult = jsonDecode(result.body);
        var resultSet = decodedresult['results'][0]['resultSet'][0];
        var valueField = resultSet['value'];
        
        String valueString = valueField is String ? valueField : valueField.toString();
        valueString = valueString.trim();
        
        if (valueString.startsWith("{") && valueString.endsWith("}")) {
          valueString = valueString.substring(1, valueString.length - 1);
        }
        
        List<String> urlParts = valueString.split(",");
        Map<String, int> responses = {};

        for (var part in urlParts) {
          String urlItem = part.trim();
          if (urlItem.startsWith("'") && urlItem.endsWith("'")) {
            urlItem = urlItem.substring(1, urlItem.length - 1);
          }
          var fullUrl = "$urlItem/isalive";
          try {
            var aliveResponse = await http.get(Uri.parse(fullUrl));
            responses[urlItem] = (aliveResponse.statusCode == 200) ? 1 : 0;
          } catch (err) {
            responses[urlItem] = 0;
          }
        }

        return Response(200,
          body: json.encode({
            'endpoints': responses
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

    // GET /api/v1/isalive - 서버 상태 확인
    router.get('/', (Request request) async {
      return Response(200,
        body: json.encode({
          'status': 'alive',
          'timestamp': DateTime.now().toIso8601String()
        }),
        headers: {'content-type': 'application/json'}
      );
    });

    return router;
  }
}
