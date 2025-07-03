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
    router.post('/get', (Request request) async{
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var check = input['key'];
        var body = {
          "transaction": [
            {
              "query": "#get_settings",
                "values": {"key": check}
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
        print(resultSet);
        return Response.ok(jsonEncode(resultSet), headers: {'Content-Type': 'application/json'});
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
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