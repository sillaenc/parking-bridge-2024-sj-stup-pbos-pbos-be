// bin/routes/create_admin.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import 'dart:async'; // 타이머 사용을 위한 import 문 추가 // json 파일

import '../routes/confirm_account_list.dart';

class CreateAdmin {
  final ConfirmAccountList confirmAccountList;

  CreateAdmin({
    required this.confirmAccountList,
  });

  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var passwd = requestData['passwd'];

        var responseFuture = reqAccInfo(account, passwd, confirmAccountList.manageAddress.displayDbAddr);

        var response = await responseFuture;

        if (response.statusCode == 200) {
          print('request completed successfully');
          var headers = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*', // 허용할 오리진 설정
            'Access-Control-Allow-Methods':
                'GET, POST, PUT, DELETE, OPTIONS', // 허용할 메서드 설정
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, X-Auth-Token' // 허용할 헤더 설정
          };
          return Response.ok('1', headers: headers);
        } else {
          print('코딩 실패');
          return Response.internalServerError(
              body: '코딩 실패. 오타 확인');
        }
      } catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }

  // 서버로 요청 보내는 함수
  Future<http.Response> reqAccInfo(
      var account, var passwd, var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {
          "statement": "#I_AdminAccount",
          "valuesBatch": [
            {"account": account, "passwd": passwd, "userlevel": 0}
          ]
        }
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
