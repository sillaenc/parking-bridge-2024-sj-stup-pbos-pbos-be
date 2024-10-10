import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

//사용자 관리 setting backend part.
// 사용자 관리 설정
// 사용자 생성 기능(기존 활용 가능)
// password new_password 형식으로 update함.(기존 활용 가능)
// username update하는 기능
// userlevel, isActivated update하는 기능.
// 마지막으로 시작할때, tb_users 전부 response하게 하자.
class SettingsAccount {
  final ManageAddress manageAddress;
  SettingsAccount({required this.manageAddress});
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};
    //base_return router
    router.get('/', (Request request) async {
      try {
        //var headers = {'Content-Type': 'application/json'};
        Map<String, dynamic> body = {
          "transaction": [
            {"query": "#S_TbUsers"},
          ]
        };
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var tableMain = jsonDecode(user.body);
        var resultSet = tableMain['results'][0]['resultSet'];
        
        print('resultSet : $resultSet');
        var send = jsonEncode(resultSet);
        print(send);
        return Response.ok(send);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/updateUser', (Request request) async {
      try {
        // 프런트의 요청의 body를 JSON 형식으로 디코딩하여 데이터 추출
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        // print(requestData);
        var account = requestData['account'];
        var passwd = requestData['passwd'];
        var newpasswd = requestData['passwdCheck'];
        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];

        var passwdcheck ={"transaction": [
            {
              "query": "#S_TbNowUsers",
              "values": {"account": account}
            }
          ]
        };
        var pwcorrect = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(passwdcheck),
        );
        // print(pwcorrect.body);
        var dcpwcoreect = jsonDecode(pwcorrect.body);
        var pwcorrectcheck = dcpwcoreect['results'][0]['resultSet'][0];
        print(pwcorrectcheck);
        if(passwd != pwcorrectcheck['passwd']){
          return Response.unauthorized("password wrong");
        }//비번 통과해야지 아래 코드가 실행가능.
        var body = {
          "transaction": [
            {
              "statement": "#U_TbUsers",
              "values": {"passwd": newpasswd, "username": username, "userlevel": userlevel, "isActivated": isActivated, "account": account}
            },
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("update success");
      } catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/changePassword', (Request request) async {
      try {
        // 프런트의 요청의 body를 JSON 형식으로 디코딩하여 데이터 추출
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        // print(requestData);
        var account = requestData['account'];
        var newpasswd = requestData['newpasswd'];
        var passwd = requestData['passwd'];
        var passwdCheck = requestData['passwdCheck'];

        if(passwd != passwdCheck){
          return Response.badRequest();
        }
        var passwdcheck ={"transaction": [
            {
              "query": "#S_UserCheck",
              "values": {"account": account}
            }
          ]
        };
        var pwcorrect = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(passwdcheck),
        );
        // print(pwcorrect.body);
        var dcpwcoreect = jsonDecode(pwcorrect.body);
        var pwcorrectcheck = dcpwcoreect['results'][0]['resultSet'][0];
        print(pwcorrectcheck);
        print(newpasswd);
        if(pwcorrectcheck.isEmpty){
          return Response.unauthorized("id가 없다고 뜸. 오류 발생. 앱에서는 생기면 안되는 문제");
        }else if(pwcorrectcheck["passwd"] == newpasswd){
          return Response.unauthorized("기존 비밀번호와 새 비밀번호가 동일합니다.");
        }else{
          var body = {
            "transaction": [
              {
                "statement": "#U_ChangePassword",
                "values": {"passwd": newpasswd, "account": account}
              },
            ]
          };
          await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          );
          return Response.ok("update success");
        }

      // } catch (e, stackTrace) {
      } catch (e) {
        // 예외 처리
        // print('Error: $e');
        // print('StackTrace: $stackTrace');
        // return Response.internalServerError(body: 'Error: $e');
        return Response.unauthorized("account는 앱에서는 정상적인 상황에서 틀릴 방법이 없음. 오류임");
      }
    });

    router.post('/insertUser', (Request request) async {
      try{
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        var account = requestData['account'];
        var passwd = requestData['passwd'];
        var newpasswd = requestData['passwdCheck'];
        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];

        if(passwd !=newpasswd){
          return Response.unauthorized("비밀번호 확인 요망");
        }
        var body = {
          "transaction": [
            { 
              "statement": "#I_UserAdd",
              "values": {"account": account ,"passwd": newpasswd, "username": username, "userlevel": userlevel, "isActivated": isActivated }
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("create success");
      }catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/deleteUser', (Request request) async {
      try{
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        var passwd = requestData['passwd'];

        var passwdcheck ={"transaction": [
            {
              "query": "#S_TbNowUsers",
              "values": {"account": account}
            }
          ]
        };
        var pwcorrect = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(passwdcheck),
        );
        var dcpwcoreect = jsonDecode(pwcorrect.body);
        var pwcorrectcheck = dcpwcoreect['results'][0]['resultSet'][0];
        print(pwcorrectcheck);
        if(passwd != pwcorrectcheck['passwd']){
          return Response.unauthorized("password wrong");
        }//비번 통과해야지 아래 코드가 실행가능.
        var body = {
          "transaction": [
            { 
              "statement": "#D_TbUsers",
              "values": {"account": account }
            },
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("delete success");
      }catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }
}
