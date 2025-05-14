import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class BillBoard {
  final ManageAddress manageAddress;
  BillBoard({required this.manageAddress});

  Router get router {
    final router = Router();

    // POST /api/v1/billboard/floor - 특정 층의 주차장 정보 조회
    router.post('/floor', (Request request) async {
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

        var floor = requestData['floor'];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {
              "query": "#floor",
              "values": {"floor": floor}
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          var resultSet = responseData['results'][0]['resultSet'];
          return Response(200,
            body: json.encode({
              'floor': floor,
              'parking_lots': resultSet
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(500,
            body: json.encode({
              'error': '주차장 정보 조회에 실패했습니다',
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

    // POST /api/v1/billboard/part-system - 부분 시스템 제어
    router.post('/part-system', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('value')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['value']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var floor = requestData['value'];
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};

        // 활성화된 엔드포인트 조회
        var body = {
          "transaction": [
            {"query": "#get_alive"}
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
              'error': '엔드포인트 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var responseData = jsonDecode(response.body);
        var resultSet = responseData['results'][0]['resultSet'][0]['value'];

        // 엔드포인트 파싱
        List<String> endpoints = [];
        if (resultSet is String) {
          var trimmed = resultSet.substring(1, resultSet.length - 1);
          endpoints = trimmed
              .split(',')
              .map((e) => e.trim().replaceAll("'", ""))
              .toList();
        } else if (resultSet is Iterable) {
          endpoints = resultSet.map((e) => e.toString()).toList();
        } else {
          return Response(500,
            body: json.encode({
              'error': '잘못된 엔드포인트 형식입니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        // 각 엔드포인트에 제어 명령 전송
        List<String> successEndpoints = [];
        List<String> failedEndpoints = [];

        for (var endpoint in endpoints) {
          try {
            var overrideUrl = "$endpoint/setOverride";
            var overrideBody = jsonEncode({"value": floor});
            var overrideResponse = await http.post(
              Uri.parse(overrideUrl),
              headers: headers,
              body: overrideBody,
            );

            if (overrideResponse.statusCode == 200) {
              successEndpoints.add(endpoint);
            } else {
              failedEndpoints.add(endpoint);
            }
          } catch (e) {
            failedEndpoints.add(endpoint);
          }
        }

        return Response(200,
          body: json.encode({
            'message': '부분 시스템 제어가 완료되었습니다',
            'floor': floor,
            'success_endpoints': successEndpoints,
            'failed_endpoints': failedEndpoints
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
