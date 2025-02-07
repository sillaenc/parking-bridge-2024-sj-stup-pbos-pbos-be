import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

class SettingsAccount {
  final ManageAddress manageAddress;
  SettingsAccount({required this.manageAddress});
  
  Router get router {
    final router = Router();
    
    // GET: tb_users 조회 (쿼리 키 "S_TbUsers")
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_TbUsers");
        String send = jsonEncode(resultSet);
        return Response.ok(send, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in SettingsAccount GET: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /updateUser: 사용자 정보 수정 (쿼리 키 "U_TbUsers")
    router.post('/updateUser', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];
        final db = await Database.getInstance();
        await db.query("U_TbUsers", {
          "username": username,
          "userlevel": userlevel,
          "isActivated": isActivated,
          "account": account
        });
        return Response.ok("update success");
      } catch (e, st) {
        print('Error in SettingsAccount updateUser: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /changePassword: 비밀번호 변경 (쿼리 키 "S_UserCheck" 후 "U_ChangePassword")
    router.post('/changePassword', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var newpasswd = requestData['newpasswd'];
        var passwd = requestData['passwd'];
        var passwdCheck = requestData['passwdCheck'];
        if (passwd != passwdCheck) {
          return Response.badRequest(body: "Password confirmation does not match");
        }
        String newfirstHash = sha256.convert(utf8.encode(newpasswd)).toString();
        String newsecondHash = sha256.convert(utf8.encode(newfirstHash)).toString();
        
        final db = await Database.getInstance();
        List<Map<String, dynamic>> checkResult = await db.query("S_UserCheck", {"account": account});
        if (checkResult.isEmpty || checkResult.first.isEmpty) {
          return Response.unauthorized("Account does not exist");
        }
        var currentUser = checkResult.first;
        if (currentUser["passwd"] == newsecondHash) {
          return Response.unauthorized("New password is same as the old password");
        } else {
          await db.query("U_ChangePassword", {"passwd": newsecondHash, "account": account});
          return Response.ok("update success");
        }
      } catch (e, st) {
        print('Error in SettingsAccount changePassword: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /resetPassword: 비밀번호 초기화 (쿼리 키 "S_UserCheck" 후 "U_ChangePassword")
    router.post('/resetPassword', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var newpasswd = "0000";
        String firstHash = sha256.convert(utf8.encode(newpasswd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();
        
        final db = await Database.getInstance();
        List<Map<String, dynamic>> checkResult = await db.query("S_UserCheck", {"account": account});
        if (checkResult.isEmpty || checkResult.first.isEmpty) {
          return Response.unauthorized("Account does not exist");
        } else {
          await db.query("U_ChangePassword", {"passwd": secondHash, "account": account});
          return Response.ok("reset success");
        }
      } catch (e, st) {
        print('Error in SettingsAccount resetPassword: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /insertUser: 사용자 등록 (쿼리 키 "S_UserCheck" 후 "I_UserAdd")
    router.post('/insertUser', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var passwd = requestData['passwd'];
        var passwdCheck = requestData['passwdCheck'];
        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];
        if (passwd != passwdCheck) {
          return Response.unauthorized("Password confirmation does not match");
        }
        String firstHash = sha256.convert(utf8.encode(passwdCheck)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();
        
        final db = await Database.getInstance();
        List<Map<String, dynamic>> checkResult = await db.query("S_UserCheck", {"account": account});
        if (checkResult.isNotEmpty && checkResult.first.isNotEmpty) {
          return Response.unauthorized("ID already exists");
        } else {
          await db.query("I_UserAdd", {
            "account": account,
            "passwd": secondHash,
            "username": username,
            "userlevel": userlevel,
            "isActivated": isActivated
          });
          return Response.ok("create success");
        }
      } catch (e, st) {
        print('Error in SettingsAccount insertUser: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /deleteUser: 사용자 삭제 (쿼리 키 "S_TbNowUsers" 후 "D_TbUsers")
    router.post('/deleteUser', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var passwd = requestData['passwd'];
        String firstHash = sha256.convert(utf8.encode(passwd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();
        
        final db = await Database.getInstance();
        List<Map<String, dynamic>> nowUser = await db.query("S_TbNowUsers", {"account": account});
        if (nowUser.isEmpty ||
            nowUser.first.isEmpty ||
            secondHash != nowUser.first['passwd']) {
          return Response.unauthorized("password wrong");
        }
        await db.query("D_TbUsers", {"account": account});
        return Response.ok("delete success");
      } catch (e, st) {
        print('Error in SettingsAccount deleteUser: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    return router;
  }
}
