import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class BillBoard {
  final ManageAddress manageAddress;
  BillBoard({required this.manageAddress});
  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var floor = input['floor'];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {
              "query": "#floor",
              "values": {"floor": floor}
            }
          ]
        };
        var count = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var get = jsonDecode(count.body);
        // print(get);
        var resultSet = get['results'][0]['resultSet'];
        // print(resultSet);
        return Response.ok(jsonEncode(resultSet));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.post('/part_system', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var floor = input['value'];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#get_alive"}
          ]
        };

        // 첫 번째 POST 요청: resultSet 받아오기
        var result = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decodedresult = jsonDecode(result.body);
        var resultSet = decodedresult['results'][0]['resultSet'][0]['value'];
        print(
            resultSet); // 예: "{'http://localhost:8888','http://localhost:8889'}"

        // resultSet이 String인 경우 파싱 처리
        List<String> endpoints = [];
        if (resultSet is String) {
          // 중괄호 제거
          var trimmed = resultSet.substring(1, resultSet.length - 1);
          // 콤마로 분리한 후, 각 요소의 따옴표와 공백 제거
          endpoints = trimmed
              .split(',')
              .map((e) => e.trim().replaceAll("'", ""))
              .toList();
        } else if (resultSet is Iterable) {
          endpoints = resultSet.map((e) => e.toString()).toList();
        } else {
          throw Exception("Unexpected type for resultSet");
        }

        // 각 URL에 대해 /setOverride를 붙여 POST 요청 보내기
        for (var endpoint in endpoints) {
          var overrideUrl = "$endpoint/setOverride";
          var overrideBody = jsonEncode({"value": floor});
          await http.post(
            Uri.parse(overrideUrl),
            headers: headers,
            body: overrideBody,
          );
        }

        return Response.ok(jsonEncode(endpoints));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}
