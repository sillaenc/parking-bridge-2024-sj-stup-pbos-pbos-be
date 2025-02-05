import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class LedCal {
  final ManageAddress manageAddress;
  LedCal({required this.manageAddress});
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#cal_get"}
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
        print(resultSet);
        var formattedResult = resultSet.map((entry) {
          String color = entry['tag_count'] == entry['isUsed_count'] ? "green" : "red";
          String camera = entry['camera'].substring(entry['camera'].length - 3); // 뒤쪽 3자리 추출
          return {
            "camera": camera,
            "color": color,
          };
        }).toList();

        // 처리 결과 출력 (디버깅 용도)
        print("Formatted Result: $formattedResult");

        // JSON 형식으로 변환하여 반환
        return Response.ok(jsonEncode(formattedResult));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}
