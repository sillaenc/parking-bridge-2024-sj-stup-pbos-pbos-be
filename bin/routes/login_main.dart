import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:test/expect.dart';
import 'dart:async';
import 'dart:io'; 

import '../data/manage_address.dart';

class LoginMain {
  final ManageAddress manageAddress;
  LoginMain({required this.manageAddress});

  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      var url = manageAddress.displayDbAddr;
      var headers = {'Content-Type': 'application/json'};
      var body = { "transaction": [
            {"query": "SELECT uid, tag, lot_type, isUsed, asset FROM tb_lots" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var dcuser = jsonDecode(user.body);
        var resultSet = dcuser['results'][0]['resultSet'];
        // print(resultSet);
        var info = jsonEncode(resultSet);
      return Response.ok(info);
    });

    return router;
  }
}