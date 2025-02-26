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
    router.post('/F1/v2', (Request request) async {
      var payload = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(payload);
      final String lotType = data['lot_type'];
      final List<int> numbers = lotType.split('+').map((s) => int.parse(s.trim())).toList();
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        int totalCount = 0;
        for (final number in numbers) {
        var body = {
          "transaction": [
            {
              "query": "#F1/v2",
              "values": {"lot_type": number}
            }
          ]
        };
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decoded = jsonDecode(response.body);
        int resultSet = decoded['results'][0]['resultSet'][0]['count'];
        // print("resultSet = $resultSet");
        totalCount += resultSet;
      }
        return Response.ok(jsonEncode(totalCount));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.post('/F2/v2', (Request request) async {
      var payload = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(payload);
      final String lotType = data['lot_type'];
      final List<int> numbers = lotType.split('+').map((s) => int.parse(s.trim())).toList();
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        int totalCount = 0;
        for (final number in numbers) {
        var body = {
          "transaction": [
            {
              "query": "#F2/v2",
              "values": {"lot_type": number}
            }
          ]
        };
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decoded = jsonDecode(response.body);
        int resultSet = decoded['results'][0]['resultSet'][0]['count'];
        print("resultSet = $resultSet");
        totalCount += resultSet;
      }
        return Response.ok(jsonEncode(totalCount));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.post('/B1/v2', (Request request) async {
      var payload = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(payload);
      final String lotType = data['lot_type'];
      final List<int> numbers = lotType.split('+').map((s) => int.parse(s.trim())).toList();
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        int totalCount = 0;
        for (final number in numbers) {
        var body = {
          "transaction": [
            {
              "query": "#B1/v2",
              "values": {"lot_type": number}
            }
          ]
        };
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var decoded = jsonDecode(response.body);
        int resultSet = decoded['results'][0]['resultSet'][0]['count'];
        print("resultSet = $resultSet");
        totalCount += resultSet;
      }
        return Response.ok(jsonEncode(totalCount));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.get('/F1', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#F1"}
          ]
        };
        var count = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var get = jsonDecode(count.body);
        var resultSet = get['results'][0]['resultSet'];
        return Response.ok(jsonEncode(resultSet));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.get('/B1', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#B1"}
          ]
        };
        var count = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var get = jsonDecode(count.body);
        // print(get);
        var resultSet = get['results'][0]['resultSet'];
        // print(resultSet);
        return Response.ok(jsonEncode(resultSet));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.get('/F2', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#F2"}
          ]
        };
        var count = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var get = jsonDecode(count.body);
        // print(get);
        var resultSet = get['results'][0]['resultSet'];
        // print(resultSet);
        return Response.ok(jsonEncode(resultSet));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    router.post('/F1/lotType', (Request request) async {
      try {
        // POST 본문에서 lot_type 값을 문자열로 강제 캐스팅하여 읽어옵니다.
        var payload = await request.readAsString();
        var input = jsonDecode(payload);
        String lotTypeInput =
            input['lot_type'].toString(); // "1" 또는 "1+4" 등의 문자열

        // '+' 기호를 기준으로 분리하고, 공백 제거 후 int 리스트로 변환합니다.
        List<int> selectedLotTypes = lotTypeInput
            .split('+')
            .map<int>((s) => int.parse(s.trim()))
            .toList();
        print(selectedLotTypes);
        // 기존 F1 데이터를 가져오기 위한 설정
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {"query": "#F1"}
          ]
        };

        // ws4sqlite 서버에 POST 요청하여 F1 관련 전체 데이터 조회
        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        // 결과는 [{"lot_type":1,"count":13}, {"lot_type":3,"count":3}, {"lot_type":4,"count":2}]와 같은 형태라고 가정합니다.
        List<dynamic> resultList = jsonDecode(response.body) as List<dynamic>;

        // 선택한 lot_type들에 해당하는 count 값을 합산합니다.
        int totalCount = 0;
        for (var item in resultList) {
          // item['lot_type']는 int 타입이어야 합니다.
          if (selectedLotTypes.contains(item['lot_type'])) {
            totalCount += (item['count'] as num).toInt();
          }
        }

        // 선택된 lot_type 리스트와 합산된 count를 반환합니다.
        return Response.ok(jsonEncode({
          "lot_types": selectedLotTypes,
          "total_count": totalCount,
        }));
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}
