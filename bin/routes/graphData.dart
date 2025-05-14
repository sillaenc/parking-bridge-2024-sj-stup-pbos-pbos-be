import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class GraphData {
  final ManageAddress manageAddress;
  GraphData({required this.manageAddress});
  
  Router get router {
    final router = Router();

    // POST /api/v1/graph-data - 그래프 데이터 조회
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('day')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['day']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var day = requestData['day'];
        String dayPattern = '$day%';
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};

        // 주차장 유형 조회
        var lotBody = {
          "transaction": [
            { "query": "#usedLot" }
          ]
        };
        var lotResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(lotBody),
        );

        if (lotResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차장 유형 조회에 실패했습니다',
              'status_code': lotResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var lotData = jsonDecode(lotResponse.body);
        var lotResult = lotData['results'][0]['resultSet'];
        List<int> uids = lotResult
            .where((item) => item['uid'] != null)
            .map((item) => item['uid'] as int)
            .toList();

        // 층 정보 조회
        var floorBody = {
          "transaction": [
            { "query": "#usedfloor" }
          ]
        };
        var floorResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(floorBody),
        );

        if (floorResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '층 정보 조회에 실패했습니다',
              'status_code': floorResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var floorData = jsonDecode(floorResponse.body);
        var floors = floorData['results'][0]['resultSet']
            .map((item) => item['floor'] as String)
            .toList();

        // 그래프 데이터 조회
        List<Map<String, dynamic>> graphData = [];
        for (var floor in floors) {
          for (var uid in uids) {
            var dataBody = {
              "transaction": [
                {
                  "query": "#graphData",
                  "values": {
                    'day': dayPattern,
                    'lot_type': uid,
                    'floor': floor
                  }
                }
              ]
            };
            var dataResponse = await http.post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(dataBody),
            );

            if (dataResponse.statusCode == 200) {
              var dataResult = jsonDecode(dataResponse.body);
              var resultSet = dataResult['results'][0]['resultSet'];
              graphData.add({
                'lot_type': uid,
                'floor': floor,
                'data': resultSet
              });
            }
          }
        }

        return Response(200,
          body: json.encode({
            'day': day,
            'graph_data': graphData
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

    // GET /api/v1/graph-data/floors - 층 정보 조회
    router.get('/floors', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#usedfloor"}
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
              'error': '층 정보 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var responseData = jsonDecode(response.body);
        var floors = responseData['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'floors': floors
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