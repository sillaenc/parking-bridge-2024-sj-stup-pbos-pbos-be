/// Parking Area Vehicle Information.dart
/// 
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Ping {
  final ManageAddress manageAddress;
  Ping({required this.manageAddress});
  
  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/ping - 서버 상태 확인
    router.get('/', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#check_alive"}
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
              'error': '서버 상태 확인에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        if (resultSet.isNotEmpty) {
          return Response(200,
            body: json.encode({
              'status': 'active',
              'server_info': resultSet,
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(503,
            body: json.encode({
              'error': '서버가 응답하지 않습니다',
              'status': 'inactive'
            }),
            headers: {'content-type': 'application/json'}
          );
        }
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
