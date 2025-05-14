/// Parking Area Vehicle Information.dart
/// 
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Pabi {
  final ManageAddress manageAddress;
  Pabi({required this.manageAddress});
  
  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/pabi/tag/{tag} - 태그로 차량 정보 조회
    router.get('/tag/<tag>', (Request request, String tag) async {
      try {
        var body = {
          "transaction": [
            {
              "query": "#get_plate",
              "values": {"tag": tag}
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
              'error': '차량 정보 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var utf8decodebody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(utf8decodebody);
        var resultSet = data['results'][0]['resultSet'][0];

        if (resultSet.isNotEmpty) {
          return Response(200,
            body: json.encode({
              'vehicle_info': resultSet,
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(404,
            body: json.encode({
              'error': '해당 태그의 차량 정보를 찾을 수 없습니다',
              'tag': tag
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

    // GET /api/v1/pabi/plate/{plate} - 차량번호로 태그 정보 조회
    router.get('/plate/<plate>', (Request request, String plate) async {
      try {
        var body = {
          "transaction": [
            {
              "query": "#get_tag",
              "values": {"plate": '%$plate'}
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
              'error': '태그 정보 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var utf8decodebody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(utf8decodebody);
        var resultSet = data['results'][0]['resultSet'];

        if (resultSet.isNotEmpty) {
          return Response(200,
            body: json.encode({
              'tag_info': resultSet,
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(404,
            body: json.encode({
              'error': '해당 차량번호의 태그 정보를 찾을 수 없습니다',
              'plate': plate
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
}
