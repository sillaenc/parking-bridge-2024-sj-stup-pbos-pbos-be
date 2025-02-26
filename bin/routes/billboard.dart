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
    router.get('/F1', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#F1"}
          ]
        };
        var count = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var get = jsonDecode(count.body);
        var resultSet = get['results'][0]['resultSet'];

        var body2 = {
          "transaction": [
            {"query": "#F2_ALL"}
          ]
        };
        var count2 = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body2),
        );
        var get2 = jsonDecode(count2.body);
        var resultSet2 = get2['results'][0]['resultSet'];

        // {"F2": 0} 형식의 데이터를 {"lot_type": "F2", "count": 0}로 변환
        if (resultSet2 is List) {
          resultSet2 = resultSet2.map((e) {
            if (e.containsKey("F2")) {
              return {"lot_type": "F2", "count": e["F2"]};
            }
            return e;
          }).toList();
        }

        return Response.ok(jsonEncode(resultSet + resultSet2));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.get('/B1', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#F2"}
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
    return router;
  }
}
