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
    // 노 터치.. v2 는 실험용
    router.post('/F1/v2', (Request request) async {
      var payload = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(payload);
      final String lotType = data['lot_type'];
      final List<int> numbers = lotType.split('+').map((s) => int.parse(s.trim())).toList();
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        int totalCount = 0;
        for (final number in numbers) {
        var body = {
          "transaction": [
            {
              "query": "#F1/v2",
              "values": {"lot_type": number}
            }
          ]
        };
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decoded = jsonDecode(response.body);
        int resultSet = decoded['results'][0]['resultSet'][0]['count'];
        // print("resultSet = $resultSet");
        totalCount += resultSet;
      }
        return Response.ok(jsonEncode(totalCount));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
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
              "values" : {"floor" : floor}
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
    return router;
  }
}
