
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

class ConfirmAccountList {
  final ManageAddress manageAddress;

  ConfirmAccountList({
    required this.manageAddress,
  });
  var userDB;

  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      var confirmResult = "0";
      try {
        var response = await _ReqToWs4ConfirmAccList(manageAddress.displayDbAddr);
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          print('responseData: $responseData');
          var resultSet = responseData['results'][0]['resultSet'];
          userDB=resultSet;
          print(resultSet);
          var results = responseData['results'];
          if(resultSet.isNotEmpty){
            var resultSet = results[0]['resultSet'];
            if(resultSet.isNotEmpty){
              userDB = resultSet;
              confirmResult="1";
            }
          }else{
            confirmResult="0";
          }
          print(confirmResult);
          return Response.ok(confirmResult);
        } else {
          return Response.internalServerError(
              body: '내부 서버 오류입니다. Status code: ${response.statusCode}');
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.notFound(confirmResult);
      }
    });
    return router;
  }
  Future<http.Response> _ReqToWs4ConfirmAccList(var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {"query": "#S_AccountList"}
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}