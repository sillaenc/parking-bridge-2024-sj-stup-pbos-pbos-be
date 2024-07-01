import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // json 처리

import '../data/manage_address.dart';

class SettingsDbManagement {
  final ManageAddress manageAddress;
  SettingsDbManagement({required this.manageAddress});

  Router get router {
    final router = Router();

    router.post('/engine', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var DBData = jsonDecode(requestBody);
        var changeEngine = DBData['engineDb'];

        String? url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {"transaction": [
          { "query": "SELECT * FROM tb_db_setting" }
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
          { "query": "UPDATE tb_db_setting SET 'engine_db_addr' = :changeEngine WHERE uid = 1" 
          , "values": {"changeEngine": changeEngine} }
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
        var DBData = jsonDecode(requestBody);
        var changeDisplay = DBData['displayDb'];
        print(changeDisplay);

        String? url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {"transaction": [
          { "query": "SELECT * FROM tb_db_setting" }
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
          { "query": "UPDATE tb_db_setting SET 'display_db_id' = :changeDisplay WHERE uid = 1" 
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
