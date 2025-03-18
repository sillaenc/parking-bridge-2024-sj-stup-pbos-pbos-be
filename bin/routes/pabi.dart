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

    // 새로운 URL 추가 (upsert)하는 POST 엔드포인트
    router.post('/tag', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        print(input);
        var key = input['tag'];

        // 기존 데이터 조회를 위해 GET 쿼리 실행
        var getBody = {
          "transaction": [
            {
              "query": "#get_area",
              "values": {"slot_name":key}
            }
          ]
        };
        var getResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(getBody),
        );
        var decodedGet = jsonDecode(getResponse.body);
        print('decodedGet : $decodedGet');
        /// 해당 구역(tag)에서 추출.
        var currentValue = decodedGet['results'][0]['resultSet'][0];

        return Response(currentValue);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.post('/car', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var key = input['car_num'];

        // 기존 데이터 조회를 위해 GET 쿼리 실행
        var getBody = {
          "transaction": [
            {
              "query": "#get_car_num",
              "values":{"car_num":key}
            }
          ]
        };
        var getResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(getBody),
        );
        var decodedGet = jsonDecode(getResponse.body);
        /// 해당 구역(tag)에서 추출.
        var currentValue = decodedGet['results'][0]['resultSet'][0];

        return Response(currentValue);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    return router;
  }
}
