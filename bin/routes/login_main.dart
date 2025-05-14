import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

class LoginMain {
  final ManageAddress manageAddress;
  LoginMain({required this.manageAddress});

  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/login/information - 로그인 정보 조회
    router.get('/information', (Request request) async {
      try {
        var body = {
          "transaction": [
            { "query": "#S_Information" }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '로그인 정보 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'information': resultSet,
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

    // GET /api/v1/login/profile - 사용자 프로필 조회
    router.get('/profile', (Request request) async {
      try {
        var account = request.url.queryParameters['account'];
        
        if (account == null || account.isEmpty) {
          return Response(400,
            body: json.encode({
              'error': '필수 파라미터가 누락되었습니다',
              'required_parameters': ['account']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var body = {
          "transaction": [
            {
              "query": "#S_Profile",
              "values": {"account": account}
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '프로필 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'profile': resultSet,
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

    return router;
  }
}