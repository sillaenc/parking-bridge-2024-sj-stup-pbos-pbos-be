// /bin/routes/login_setting.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

const String _secretKey = 'secret_key_hahaha_bjs';

class LoginSetting {
  final ManageAddress manageAddress;

  LoginSetting({required this.manageAddress});

  Router get router {
    final router = Router();

    // POST: 로그인 처리
    router.post('/', (Request request) async {
      try {
        // 요청 본문 읽기 및 파싱
        var requestBody = await request.readAsString();
        var loginData = jsonDecode(requestBody);
        int loginCheck = 0;
        var account = loginData['account'];
        var passwd = loginData['passwd'];
        String firstHash = sha256.convert(utf8.encode(passwd)).toString();
        String secondHash = sha256.convert(utf8.encode(firstHash)).toString();

        // PostgreSQL DB 연결 및 로그인 쿼리 실행
        final db = await Database.getInstance();
        List<Map<String, dynamic>> loginResult1 =
            await db.query("S_ReqLogin", {"account": account, "passwd": secondHash});
        List<Map<String, dynamic>> loginResult2 =
            await db.query("S_ReqLogin2", {"account": account, "passwd": secondHash});

        String token = "";
        for (var entry in loginResult1) {
          if (entry['account'] == account) {
            loginCheck = 1;
            if (entry['passwd'] == secondHash) {
              loginCheck = 2;
              token = createJwt(account, 1);
              print('Generated Token: $token');
            }
          }
        }
        // token 정보를 담은 리스트를 List<Map<String, dynamic>>로 선언 (타입 일치)
        List<Map<String, dynamic>> tokenList = [{'token': token}];

        if (loginCheck == 2) {
          return Response.ok(
            jsonEncode(loginResult2 + tokenList),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
              'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
            },
          );
        } else if (loginCheck == 0) {
          print('아이디 틀렸습니다.');
          return Response.internalServerError(
              body: '아이디 혹은 비밀번호가 틀렸습니다.');
        } else if (loginCheck == 1) {
          print('비밀번호? 틀렸습니다.');
          return Response.internalServerError(
              body: '아이디 혹은 비밀번호가 틀렸습니다');
        }
      } catch (e, st) {
        print('Error in LoginSetting POST: $e');
        return Response.internalServerError(body: 'Error in LoginSetting POST: $e');
      }
    });

    // GET /base: 로그인 시 추가 정보(픽셀, 좌표, lot type 등)를 집계하여 반환
    router.get('/base', (Request request) async {
      try {
        final db = await Database.getInstance();
        // 각각의 쿼리 실행 (쿼리 키: "S_TotalPixel", "S_LotInfo", "S_LotType")
        List<Map<String, dynamic>> pixelResult = await db.query("S_TotalPixel");
        List<Map<String, dynamic>> lotInfoResult = await db.query("S_LotInfo");
        List<Map<String, dynamic>> lotTypeResult = await db.query("S_LotType");

        // lotTypeResult의 길이에 맞게 check 배열 생성
        List<int> check = List<int>.filled(lotTypeResult.length, 0);

        // pixelResult의 각 행에서 'lot_type' 값을 이용해 check 배열의 해당 인덱스 값을 증가
        for (var row in pixelResult) {
          if (row['lot_type'] != null) {
            int lotType = row['lot_type'];
            if (lotType - 1 < check.length && lotType - 1 >= 0) {
              check[lotType - 1] = check[lotType - 1] + 1;
            }
          }
        }

        // 각 lot type별로 isUsed 값을 업데이트 (쿼리 키 "U_IsUsed")
        for (int i = 1; i <= check.length; i++) {
          if (check[i - 1] == 0) {
            await db.query("U_IsUsed", {"isUsed": 0, "uid": i});
          } else {
            await db.query("U_IsUsed", {"isUsed": 1, "uid": i});
          }
        }

        // 업데이트 후, lot type 정보를 다시 조회 (쿼리 키 "S_LotType")
        List<Map<String, dynamic>> lotTypeQuery = await db.query("S_LotType");

        // 서로 다른 타입의 리스트(check: List<int>, lotInfoResult, lotTypeQuery, pixelResult: List<Map<String, dynamic>>)
        // 직접 '+' 연산자로 합칠 수 없으므로 빈 List<dynamic>에 addAll()으로 합침
        List<dynamic> combined = [];
        combined.addAll(check);
        combined.addAll(lotInfoResult);
        combined.addAll(lotTypeQuery);
        combined.addAll(pixelResult);

        return Response.ok(
          jsonEncode(combined),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
          },
        );
      } catch (e, st) {
        print('Error in LoginSetting GET /base: $e');
        return Response.internalServerError(body: 'Error in LoginSetting GET /base: $e');
      }
    });

    // GET /jwt: (임시) 토큰 정보를 반환 (POST에서 생성한 토큰 사용)
    router.get('/jwt', (Request request) async {
      return Response.ok(
        jsonEncode({'token': 'Not implemented'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // GET /protected: JWT 토큰 검증 후 보호된 리소스 접근 허용
    router.get('/protected', (Request request) async {
      final authorizationHeader = request.headers['Authorization'];
      if (authorizationHeader != null && authorizationHeader.startsWith('Bearer ')) {
        final token = authorizationHeader.substring('Bearer '.length);
        if (verifyJwt(token)) {
          return Response.ok('Access granted to protected resource.');
        } else {
          return Response.forbidden('Invalid token.');
        }
      } else {
        return Response.forbidden('Authorization header missing.');
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
}
