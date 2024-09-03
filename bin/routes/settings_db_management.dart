import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

class SettingsDbManagement {
  final ManageAddress manageAddress;
  SettingsDbManagement({required this.manageAddress});

  Router get router {
    final router = Router();

    router.post('/engine', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var dbData = jsonDecode(requestBody);
        var changeEngine = dbData['engineDb'];

        String? url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {"transaction": [
          { "query": "#S_TbDbSetting" }
        ]};    
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var dbSave=jsonDecode(response.body);
        var dbSet=dbSave['results'][0]['resultSet'][0];
        print(dbSet);

        var body2 = {"transaction": [
          {
            "statement": "#U_TbDbSetting",
            "values": {"changeEngine": changeEngine}
          }
        ]};
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body2),
        );
        return Response.ok('변경 완료!');
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    router.post('/display', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var dbData = jsonDecode(requestBody);
        var changeDisplay = dbData['displayDb'];
        print(changeDisplay);

        String? url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {"transaction": [
          { "query": "#S_TbDbSetting" }
        ]};    
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var dbSave=jsonDecode(response.body);
        var dbSet=dbSave['results'][0]['resultSet'][0];
        print(dbSet);

        var body2 = {"transaction": [
          { "statement": "#U_TbDbSetting" 
          , "values": {"changeDisplay": changeDisplay} }
        ]};
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body2),
        );
        return Response.ok('변경 완료!');
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }

}
