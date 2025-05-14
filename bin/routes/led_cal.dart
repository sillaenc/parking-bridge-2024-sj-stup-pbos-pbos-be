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

    // GET /api/v1/led-cal/status - LED 상태 조회
    router.get('/status', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            { "query": "#cal_get" }
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
              'error': 'LED 상태 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        var formattedResult = resultSet.map((entry) {
          String color = entry['tag_count'] == entry['isUsed_count'] ? "red" : "green";
          String camera = entry['camera'].substring(entry['camera'].length - 3);
          return {
            "camera": camera,
            "color": color,
          };
        }).toList();

        return Response(200,
          body: json.encode({
            'led_status': formattedResult,
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