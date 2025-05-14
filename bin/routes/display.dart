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

    // POST /api/v1/display/status - 주차장 상태 조회
    router.post('/status', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('floor')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['floor']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var floorInput = requestData['floor'];
        List<String> floors = floorInput.contains(',')
            ? floorInput.split(',').map((f) => f.trim()).toList()
            : [floorInput];

        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        List<dynamic> combinedResults = [];

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

          if (response.statusCode != 200) {
            return Response(500,
              body: json.encode({
                'error': '주차장 상태 조회에 실패했습니다',
                'floor': floor,
                'status_code': response.statusCode
              }),
              headers: {'content-type': 'application/json'}
            );
          }

          var responseData = jsonDecode(response.body);
          var resultSet = responseData['results'][0]['resultSet'];
          
          if (resultSet is List) {
            combinedResults.addAll(resultSet);
          } else {
            combinedResults.add(resultSet);
          }
        }

        return Response(200,
          body: json.encode({
            'floors': floors,
            'parking_status': combinedResults
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

    // POST /api/v1/display/update-locations - 주차장 위치 정보 업데이트
    router.post('/update-locations', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('tb_lots')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['tb_lots']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        Map<String, dynamic> tbLots = requestData['tb_lots'];
        List<Map<String, dynamic>> transactions = [];
        
        tbLots.forEach((key, value) {
          if (!value.containsKey('tag') || 
              !value.containsKey('lot_type') || 
              !value.containsKey('point') || 
              !value.containsKey('asset') || 
              !value.containsKey('floor')) {
            throw FormatException('주차장 정보에 필수 필드가 누락되었습니다');
          }

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

        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": transactions
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차장 위치 정보 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '주차장 위치 정보가 성공적으로 업데이트되었습니다',
            'updated_locations': tbLots.length
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
