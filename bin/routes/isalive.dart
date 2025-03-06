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

    // 새로운 URL 추가 (upsert)하는 POST 엔드포인트
    router.post('/', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var key = input['key'];
        // 새로운 URL을 문자열로 받음 (예: "http://localhost:8890")
        String newUrl = input['value'];

        // 기존 데이터 조회를 위해 GET 쿼리 실행
        var getBody = {
          "transaction": [
            {
              "query": "#get_alive"
            }
          ]
        };
        var getResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(getBody),
        );
        var decodedGet = jsonDecode(getResponse.body);
        // 기존 데이터의 value 필드 추출 (예: "{'http://localhost:8888','http://localhost:8889'}")
        String currentValue = decodedGet['results'][0]['resultSet'][0]['value'] ?? "{}";
        currentValue = currentValue.trim();
        String inner = "";
        if (currentValue.startsWith("{") && currentValue.endsWith("}")) {
          inner = currentValue.substring(1, currentValue.length - 1).trim();
        } else {
          inner = currentValue;
        }

        // 기존 값이 비어있으면 새로운 URL만 넣고,
        // 그렇지 않으면 기존 내용 뒤에 쉼표와 새로운 URL을 추가
        String newValue;
        if (inner.isEmpty) {
          newValue = "{'$newUrl'}";
        } else {
          newValue = "{$inner,'$newUrl'}";
        }

        // upsert 쿼리로 새로운 값 저장
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
        return Response(upsertResponse.statusCode);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    // 기존 URL 목록에 대해 '/isalive' GET 요청을 수행하는 GET 엔드포인트
    router.get('/get', (Request request) async {
      try {
        var body = {
          "transaction": [
            {
              "query": "#get_alive"
            }
          ]
        };
        var result = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decodedresult = jsonDecode(result.body);
        var resultSet = decodedresult['results'][0]['resultSet'][0];
        print(resultSet);

        // resultSet의 value 필드에서 URL 목록 추출
        var valueField = resultSet['value'];
        String valueString;
        if (valueField is String) {
          valueString = valueField;
        } else {
          valueString = valueField.toString();
        }
        valueString = valueString.trim();
        if (valueString.startsWith("{") && valueString.endsWith("}")) {
          valueString = valueString.substring(1, valueString.length - 1);
        }
        List<String> urlParts = valueString.split(",");
        Map<String, int> responses = {};

        // 각 URL에 대해 '/isalive' GET 요청
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
        return Response.ok(
          jsonEncode(responses),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    return router;
  }
}
