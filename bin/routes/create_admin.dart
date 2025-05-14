// bin/routes/create_admin.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';//암호화 라이브러리, 이걸로 
import 'dart:async'; // 타이머 사용을 위한 import 문 추가 // json 파일

import '../routes/confirm_account_list.dart';

class CreateAdmin {
  final ConfirmAccountList confirmAccountList;

  CreateAdmin({
    required this.confirmAccountList,
  });

  Router get router {
    final router = Router();
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // POST /api/v1/accounts/admin - 관리자 계정 생성
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        
        // 필수 필드 검증
        if (!requestData.containsKey('account') || 
            !requestData.containsKey('username') || 
            !requestData.containsKey('passwd')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['account', 'username', 'passwd']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var account = requestData['account'];
        var username = requestData['username'];
        var passwd = requestData['passwd'];

        // 비밀번호 해싱
        String firstHash = sha256.convert(utf8.encode(passwd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        // 계정 중복 확인
        var rowLot = {
          'transaction': [
            {"query": "#S_userList"}
          ]
        };
        var url = confirmAccountList.manageAddress.displayDbAddr;
        var rowResponse2 = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(rowLot),
        );
        var rowResult2 = jsonDecode(rowResponse2.body);
        var rowDb2 = rowResult2['results'][0]['resultSet'];

        for (var item in rowDb2) {
          if (item['account'] == account) {
            return Response(409,
              body: json.encode({
                'error': '이미 존재하는 계정입니다',
                'account': account
              }),
              headers: {'content-type': 'application/json'}
            );
          }
        }

        // 계정 생성
        var response = await reqAccInfo(account, secondHash, username, confirmAccountList.manageAddress.displayDbAddr);

        if (response.statusCode == 200) {
          return Response(201,
            body: json.encode({
              'message': '관리자 계정이 성공적으로 생성되었습니다',
              'account': account,
              'username': username
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(500,
            body: json.encode({
              'error': '계정 생성에 실패했습니다',
              'details': '서버 내부 오류가 발생했습니다'
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

  // 서버로 요청 보내는 함수
  Future<http.Response> reqAccInfo(var account, var passwd, var username, var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {
          "statement": "#I_AdminAccount",
          "valuesBatch": [
            {"account": account, "passwd": passwd, "username": username, "userlevel": 0}
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
