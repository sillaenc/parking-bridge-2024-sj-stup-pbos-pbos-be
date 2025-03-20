import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Display {
  final ManageAddress manageAddress;
  Display({required this.manageAddress});
  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      try {
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        var floorInput = input['floor'];
        // 쉼표로 구분되어 있다면 분리, 아니면 단일 값으로 리스트 생성
        List<String> floors = floorInput.contains(',')
            ? floorInput.split(',').map((f) => f.trim()).toList()
            : [floorInput];

        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        List<dynamic> combinedResults = [];

        // 각 층마다 쿼리 실행
        for (var floor in floors) {
          var body = {
            "transaction": [
              {
                "query": "#display",
                "values": {"floor": floor}
              }
            ]
          };

          var response = await http.post(
            Uri.parse(url!),
            headers: headers,
            body: jsonEncode(body),
          );
          var decodedResponse = jsonDecode(response.body);
          var resultSet = decodedResponse['results'][0]['resultSet'];
          // resultSet이 리스트라면 합치고, 아니라면 단일 값 추가
          if (resultSet is List) {
            combinedResults.addAll(resultSet);
          } else {
            combinedResults.add(resultSet);
          }
        }
        return Response.ok(jsonEncode(combinedResults));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    // 이 router는 임시로 만든 코드로, json 수정할때마다 db를 삭제 및 재생성 방지를 위해 전체 upsert 하기 위해 제작한 코드입니다.
    router.post('/dlatl', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        Map<String, dynamic> tbLots = requestData['tb_lots'];
        List<Map<String, dynamic>> transactions = [];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        tbLots.forEach((key, value) {
          transactions.add({
            "statement": "#display_dlatl",
            "values": {
              "tag": value['tag'],
              "lot_type": value['lot_type'],
              "point": value['point'],
              "asset": value['asset'],
              "floor": value['floor'],
            }
          });
        });
        var body = {
          "transaction": transactions
        };
        await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("display 업데이트 성공");
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }
}
