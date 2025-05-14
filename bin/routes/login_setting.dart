import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import '../routes/confirm_account_list.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:crypto/crypto.dart';

const String _secretKey = 'secret_key_hahaha_bjs';

class LoginSetting {
  final ConfirmAccountList confirmAccountList;

  LoginSetting({required this.confirmAccountList});
  //var account="";var passwd="";

  Router get router {
    final router = Router();
    var token;
    var listtoken;
    String? url = confirmAccountList.manageAddress.displayDbAddr;
    var headers = { 'Content-Type': 'application/json' };

    // POST /api/v1/login/auth - 로그인 인증
    router.post('/auth', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var loginData = jsonDecode(requestBody);

        if (!loginData.containsKey('account') || !loginData.containsKey('passwd')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['account', 'passwd']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var account = loginData['account'];
        var passwd = loginData['passwd'];
        String firstHash = sha256.convert(utf8.encode(passwd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        var loginDataResult = reqLogin(account, secondHash, url);
        var loginDataResult2 = reqLogin2(account, secondHash, url);
        var responseLogin = await loginDataResult;
        var responseLogin2 = await loginDataResult2;

        if (responseLogin.statusCode != 200 || responseLogin2.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '로그인 처리 중 오류가 발생했습니다',
              'status_code': responseLogin.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var responseLoginData = jsonDecode(responseLogin.body);
        var responseLoginData2 = jsonDecode(responseLogin2.body);
        var resultSet4 = responseLoginData['results'][0]['resultSet'];
        var resultSet7 = responseLoginData2['results'][0]['resultSet'];

        var loginCheck = 0;
        for (var entry in resultSet4) {
          if (entry['account'] == account) {
            loginCheck = 1;
            if (entry['passwd'] == secondHash) {
              loginCheck = 2;
              token = createJwt(account, 1);
            }
          }
        }

        if (loginCheck == 2) {
          var responseHeaders = {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
          };

          return Response(200,
            body: json.encode({
              'user_info': resultSet7,
              'token': token,
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: responseHeaders
          );
        } else {
          return Response(401,
            body: json.encode({
              'error': '아이디 또는 비밀번호가 일치하지 않습니다'
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

    // GET /api/v1/login/base-info - 기본 정보 조회
    router.get('/base-info', (Request request) async {
      try {
        var response1Future = reqToPixel(url);
        var response3Future = reqLotInfo(url);
        var response2Future = reqLotType(url);

        var response1 = await response1Future;
        var response3 = await response3Future;
        var response2 = await response2Future;

        if (response1.statusCode != 200 || response2.statusCode != 200 || response3.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '기본 정보 조회에 실패했습니다',
              'status_code': response1.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var utf8decodebody = utf8.decode(response3.bodyBytes);
        var responseData3 = jsonDecode(utf8decodebody);
        var resultSet3 = responseData3['results'][0]['resultSet'];
        var responseData2 = jsonDecode(response2.body);
        var resultSet2 = responseData2['results'][0]['resultSet'];

        var check = List<dynamic>.filled(resultSet2.length, 0);
        for (int i = 0; i < resultSet3.length; i++) {
          check[resultSet3[i]['lot_type'] - 1]++;
        }

        var responseData1 = jsonDecode(response1.body);
        var resultSet1 = responseData1['results'][0]['resultSet'];

        // 주차장 사용 상태 업데이트
        for (int i = 1; i <= check.length; i++) {
          var body6 = {
            "transaction": [
              {
                "statement": "#U_IsUsed",
                "values": {
                  "isUsed": check[i-1] > 0 ? 1 : 0,
                  "uid": i
                }
              }
            ]
          };
          await http.post(
            Uri.parse(url!),
            headers: headers,
            body: jsonEncode(body6),
          );
        }

        var body7 = {
          "transaction": [
            {"query": "#S_LotType"}
          ]
        };
        var lotType = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body7),
        );
        var dcLotType = jsonDecode(utf8.decode(lotType.bodyBytes));
        var resultSet7 = dcLotType['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'usage_status': check,
            'pixel_info': resultSet1,
            'lot_types': resultSet7,
            'lot_info': resultSet3,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
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

    // GET /api/v1/login/verify - JWT 토큰 검증
    router.get('/verify', (Request request) async {
      try {
        final authorizationHeader = request.headers['Authorization'];
        if (authorizationHeader == null || !authorizationHeader.startsWith('Bearer ')) {
          return Response(401,
            body: json.encode({
              'error': '인증 헤더가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        final token = authorizationHeader.substring('Bearer '.length);
        if (verifyJwt(token)) {
          return Response(200,
            body: json.encode({
              'message': '유효한 토큰입니다',
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(401,
            body: json.encode({
              'error': '유효하지 않은 토큰입니다'
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

  String createJwt(String username, int hours) {
    final jwt = JWT(
      {
        'account': username,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(Duration(hours: hours)).millisecondsSinceEpoch ~/ 1000,
      },
    );
    return jwt.sign(SecretKey(_secretKey));
  }
  
  bool verifyJwt(String token) {
    try {
      JWT.verify(token, SecretKey(_secretKey));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<http.Response> reqToPixel(var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {"query": "#S_TotalPixel"}
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> reqLotInfo(var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {"query": "#S_LotInfo"}
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> reqLotType(var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {"query": "#S_LotType"}
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> reqLogin(var account, var passwd, var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {
          "query": "#S_ReqLogin",
          "values": {"account": account, "passwd": passwd}
        }
      ]
    };
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> reqLogin2(var account, var passwd, var displayDbAddr) async {
    String url = displayDbAddr;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      "transaction": [
        {
          "query": "#S_ReqLogin2",
          "values": {"account": account, "passwd": passwd}
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
