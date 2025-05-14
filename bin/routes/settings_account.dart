import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
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

    // GET /api/v1/accounts/settings - 모든 사용자 목록 조회
    router.get('/', (Request request) async {
      try {
        Map<String, dynamic> body = {
          "transaction": [
            {"query": "#S_TbUsers"},
          ]
        };
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        
        if (response.statusCode == 200) {
          var tableMain = jsonDecode(response.body);
          var resultSet = tableMain['results'][0]['resultSet'];
          return Response(200,
            body: json.encode({
              'users': resultSet,
              'total': resultSet.length
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(500,
            body: json.encode({
              'error': '사용자 목록을 가져오는데 실패했습니다',
              'status_code': response.statusCode
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

    // PUT /api/v1/accounts/settings/{account} - 사용자 정보 업데이트
    router.put('/<account>', (Request request, String account) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('username') || 
            !requestData.containsKey('userlevel') || 
            !requestData.containsKey('isActivated')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['username', 'userlevel', 'isActivated']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];

        // 사용자 존재 여부 확인
        var checkUser = {
          "transaction": [
            {
              "query": "#S_TbNowUsers",
              "values": {"account": account}
            }
          ]
        };
        var userResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkUser),
        );
        
        var userData = jsonDecode(userResponse.body);
        var userResultSet = userData['results'][0]['resultSet'];
        if (userResultSet.isEmpty) {
          return Response.notFound(
            json.encode({
              'error': '사용자를 찾을 수 없습니다',
              'account': account
            }),
            headers: {'content-type': 'application/json'}
          );
        }
        var userCheck = userResultSet[0];

        // 사용자 정보 업데이트
        var updateBody = {
          "transaction": [
            {
              "statement": "#U_TbUsers",
              "values": {
                "username": username,
                "userlevel": userlevel,
                "isActivated": isActivated,
                "account": account
              }
            },
          ]
        };

        var updateResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(updateBody),
        );

        if (updateResponse.statusCode == 200) {
          return Response(200,
            body: json.encode({
              'message': '사용자 정보가 성공적으로 업데이트되었습니다',
              'account': account,
              'username': username,
              'userlevel': userlevel,
              'isActivated': isActivated
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(500,
            body: json.encode({
              'error': '사용자 정보 업데이트에 실패했습니다',
              'status_code': updateResponse.statusCode
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

    // PUT /api/v1/accounts/settings/{account}/password - 비밀번호 변경
    router.put('/<account>/password', (Request request, String account) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('newpasswd') || 
            !requestData.containsKey('passwd') || 
            !requestData.containsKey('passwdCheck')) {
          return Response.badRequest(
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['newpasswd', 'passwd', 'passwdCheck']
            })
          );
        }

        var newpasswd = requestData['newpasswd'];
        var passwd = requestData['passwd'];
        var passwdCheck = requestData['passwdCheck'];

        if (passwd != passwdCheck) {
          return Response(400, 
            body: json.encode({
              'error': '비밀번호 확인이 일치하지 않습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        String newfirstHash = sha256.convert(utf8.encode(newpasswd)).toString();
        String newsecondHash = sha256.convert(utf8.encode(newfirstHash)).toString();

        // 현재 비밀번호 확인
        var checkPassword = {
          "transaction": [
            {
              "query": "#S_UserCheck",
              "values": {"account": account}
            }
          ]
        };
        var passwordResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkPassword),
        );

        var passwordData = jsonDecode(passwordResponse.body);
        var passwordResultSet = passwordData['results'][0]['resultSet'];
        if (passwordResultSet.isEmpty) {
          return Response.notFound(
            json.encode({
              'error': '사용자를 찾을 수 없습니다',
              'account': account
            }),
            headers: {'content-type': 'application/json'}
          );
        }
        var currentPassword = passwordResultSet[0];

        if (currentPassword["passwd"] == newsecondHash) {
          return Response(400,
            body: json.encode({
              'error': '새 비밀번호는 현재 비밀번호와 달라야 합니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        // 비밀번호 업데이트
        var updateBody = {
          "transaction": [
            {
              "statement": "#U_ChangePassword",
              "values": {
                "passwd": newsecondHash,
                "account": account
              }
            },
          ]
        };

        var updateResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(updateBody),
        );

        if (updateResponse.statusCode == 200) {
          return Response.ok(
            json.encode({
              'message': '비밀번호가 성공적으로 변경되었습니다',
              'account': account
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response.internalServerError(
            body: json.encode({
              'error': '비밀번호 변경에 실패했습니다',
              'status_code': updateResponse.statusCode
            })
          );
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          })
        );
      }
    });

    // POST /api/v1/accounts/settings/{account}/reset-password - 비밀번호 초기화
    router.post('/<account>/reset-password', (Request request, String account) async {
      try {
        var newpasswd = "0000";
        String firstHash = sha256.convert(utf8.encode(newpasswd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        // 사용자 존재 여부 확인
        var checkUser = {
          "transaction": [
            {
              "query": "#S_UserCheck",
              "values": {"account": account}
            }
          ]
        };
        var userResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkUser),
        );

        var userData = jsonDecode(userResponse.body);
        var userResultSet = userData['results'][0]['resultSet'];
        if (userResultSet.isEmpty) {
          return Response.notFound(
            json.encode({
              'error': '사용자를 찾을 수 없습니다',
              'account': account
            }),
            headers: {'content-type': 'application/json'}
          );
        }
        var userCheck = userResultSet[0];

        // 비밀번호 초기화
        var resetBody = {
          "transaction": [
            {
              "statement": "#U_ChangePassword",
              "values": {
                "passwd": secondHash,
                "account": account
              }
            },
          ]
        };

        var resetResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(resetBody),
        );

        if (resetResponse.statusCode == 200) {
          return Response.ok(
            json.encode({
              'message': '비밀번호가 초기화되었습니다',
              'account': account,
              'new_password': newpasswd
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response.internalServerError(
            body: json.encode({
              'error': '비밀번호 초기화에 실패했습니다',
              'status_code': resetResponse.statusCode
            })
          );
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          })
        );
      }
    });

    // POST /api/v1/accounts/settings - 새 사용자 생성
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('account') || 
            !requestData.containsKey('passwd') || 
            !requestData.containsKey('passwdCheck') || 
            !requestData.containsKey('username') || 
            !requestData.containsKey('userlevel') || 
            !requestData.containsKey('isActivated')) {
          return Response.badRequest(
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['account', 'passwd', 'passwdCheck', 'username', 'userlevel', 'isActivated']
            })
          );
        }

        var account = requestData['account'];
        var passwd = requestData['passwd'];
        var passwdCheck = requestData['passwdCheck'];
        var username = requestData['username'];
        int userlevel = requestData['userlevel'];
        int isActivated = requestData['isActivated'];

        if (passwd != passwdCheck) {
          return Response(400,
            body: json.encode({
              'error': '비밀번호 확인이 일치하지 않습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        String firstHash = sha256.convert(utf8.encode(passwdCheck)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        // 계정 중복 확인
        var checkAccount = {
          "transaction": [
            {
              "query": "#S_UserCheck",
              "values": {"account": account}
            }
          ]
        };
        var accountResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkAccount),
        );

        var accountData = jsonDecode(accountResponse.body);
        var accountResultSet = accountData['results'][0]['resultSet'];
        if (accountResultSet.isNotEmpty) {
          return Response.forbidden(
            json.encode({
              'error': '이미 존재하는 계정입니다',
              'account': account
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        // 새 사용자 생성
        var createBody = {
          "transaction": [
            {
              "statement": "#I_AdminAccount",
              "valuesBatch": [
                {
                  "account": account,
                  "passwd": secondHash,
                  "username": username,
                  "userlevel": userlevel,
                  "isActivated": isActivated
                }
              ]
            }
          ]
        };

        var createResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(createBody),
        );

        if (createResponse.statusCode == 200) {
          return Response.ok(
            json.encode({
              'message': '사용자가 성공적으로 생성되었습니다',
              'account': account,
              'username': username,
              'userlevel': userlevel,
              'isActivated': isActivated
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response.internalServerError(
            body: json.encode({
              'error': '사용자 생성에 실패했습니다',
              'status_code': createResponse.statusCode
            })
          );
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          })
        );
      }
    });

    return router;
  }
}
