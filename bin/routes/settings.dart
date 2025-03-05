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
        var response = await http.post(
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
    router.get('/get', (Request request) async{
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
        var decodedresult = jsonDecode(result.body);
        var resultSet = decodedresult['results'][0]['resultSet'][0];
        print(resultSet);
        return Response.ok(jsonEncode(resultSet), headers: {'Content-Type': 'application/json'});
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}