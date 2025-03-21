/// Parking Area Vehicle Information.dart
/// 
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Ping {
  final ManageAddress manageAddress;
  Ping({required this.manageAddress});
  Router get router {
    final router = Router();
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    router.get('/', (Request request) async {
      try {
        // 기존 데이터 조회를 위해 GET 쿼리 실행
        var getBody = {
          "transaction": [
            {"query": "#check_alive"}
          ]
        };
        var getResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(getBody),
        );
        var utf8decodebody = utf8.decode(getResponse.bodyBytes);
        var decodedGet = jsonDecode(utf8decodebody);
        print(decodedGet);
        /// 해당 구역(tag)에서 추출.
        var resultSet = decodedGet['results'][0]['resultSet'];
        if(resultSet.isNotEmpty){
          // var currentValue = resultSet[0];
          return Response.ok(
            jsonEncode(resultSet),  // JSON 문자열로 변환
            headers: {'Content-Type': 'application/json'},  // JSON 응답 설정
          );
        }else{
          return Response.ok('없어');
        }
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    return router;
  }
}
