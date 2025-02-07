import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import '../data/db.dart';
import 'confirm_account_list.dart';

class CreateAdmin {
  final ConfirmAccountList confirmAccountList;
  CreateAdmin({required this.confirmAccountList});

  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var username = requestData['username'];
        var passwd = requestData['passwd'];
        String firstHash = sha256.convert(utf8.encode(passwd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        final db = await Database.getInstance();
        // 중복 계정 확인: 쿼리 키 "S_userList"
        List<Map<String, dynamic>> userList = await db.query("S_userList");
        for (var item in userList) {
          if (item['account'] == account) {
            return Response.forbidden('id 중복났숑');
          }
        }
        // 관리자 계정 생성: 쿼리 키 "I_AdminAccount"
        await db.query("I_AdminAccount", {
          "account": account,
          "passwd": secondHash,
          "username": username,
          "userlevel": 0
        });
        return Response.ok('1', headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in CreateAdmin: $e');
        return Response.internalServerError(body: 'Error in CreateAdmin: $e');
      }
    });
    return router;
  }
}
