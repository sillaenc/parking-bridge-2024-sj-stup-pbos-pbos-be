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

  Router get router {
    final router = Router();

    // GET /api/v1/accounts - 계정 목록 조회
    router.get('/', (Request request) async {
      try {
        var response = await reqConfirmList(manageAddress.displayDbAddr);
        if (response.statusCode == 200) {
          var responseData = jsonDecode(utf8.decode(response.bodyBytes));
          var resultSet = responseData['results'][0]['resultSet'];
          
          if (resultSet.isEmpty) {
            return Response(200,
              body: utf8.encode(json.encode({
                'accounts': [],
                'total': 0
              })),
              headers: {'content-type': 'application/json; charset=utf-8'}
            );
          }

          return Response(200,
            body: utf8.encode(json.encode({
              'accounts': resultSet,
              'total': resultSet.length
            })),
            headers: {'content-type': 'application/json; charset=utf-8'}
          );
        } else {
          return Response(500,
            body: utf8.encode(json.encode({
              'error': '내부 서버 오류입니다',
              'status_code': response.statusCode
            })),
            headers: {'content-type': 'application/json; charset=utf-8'}
          );
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: utf8.encode(json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          })),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
    });

    // GET /api/v1/accounts/{id} - 특정 계정 조회
    router.get('/<id>', (Request request, String id) async {
      try {
        var response = await reqConfirmList(manageAddress.displayDbAddr);
        if (response.statusCode == 200) {
          var responseData = jsonDecode(utf8.decode(response.bodyBytes));
          var resultSet = responseData['results'][0]['resultSet'];
          
          var account = resultSet.firstWhere(
            (account) => account['account'].toString() == id,
            orElse: () => null
          );

          if (account == null) {
            return Response(404,
              body: json.encode({
                'error': '계정을 찾을 수 없습니다',
                'id': id
              }),
              headers: {'content-type': 'application/json'}
            );
          }

          return Response(200,
            body: json.encode(account),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(500,
            body: json.encode({
              'error': '내부 서버 오류입니다',
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

    return router;
  }

  Future<http.Response> reqConfirmList(var displayDbAddr) async {
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