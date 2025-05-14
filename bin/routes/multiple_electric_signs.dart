import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import '../data/manage_address.dart';

class MultipleElectricSigns {
  final ManageAddress manageAddress;
  MultipleElectricSigns({required this.manageAddress});
  
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/displays/electric-signs - 전광판 목록 조회
    router.get('/', (Request request) async {
      try {
        var body = {
          "transaction": [
            { "query": "#S_Multi" }
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
              'error': '전광판 목록 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'electric_signs': resultSet,
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

    // PUT /api/v1/electric-signs/{uid} - 전광판 정보 업데이트
    router.put('/:uid', (Request request) async {
      try {
        var uid = request.params['uid'];
        if (uid == null) {
          return Response(400,
            body: json.encode({
              'error': '전광판 ID가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('parking_lot')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['parking_lot']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var parkingLot = requestData['parking_lot'];
        var body = {
          "transaction": [
            {
              "statement": "#U_Multi",
              "values": {
                "uid": int.parse(uid),
                "parking_lot": parkingLot
              }
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
              'error': '전광판 정보 업데이트에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '전광판 정보가 성공적으로 업데이트되었습니다',
            'uid': uid,
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

    // POST /api/v1/electric-signs - 새로운 전광판 추가
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('uid') || !requestData.containsKey('parking_lot')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['uid', 'parking_lot']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var uid = requestData['uid'];
        var parkingLot = requestData['parking_lot'];

        var body = {
          "transaction": [
            {
              "statement": "#I_Multi",
              "values": {
                "uid": uid,
                "parking_lot": parkingLot
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          return Response(201,
            body: json.encode({
              'message': '새로운 전광판이 성공적으로 추가되었습니다',
              'uid': uid,
              'timestamp': DateTime.now().toIso8601String()
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          return Response(409,
            body: json.encode({
              'error': '이미 존재하는 전광판 ID입니다',
              'uid': uid
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

    // DELETE /api/v1/electric-signs/{uid} - 전광판 삭제
    router.delete('/:uid', (Request request) async {
      try {
        var uid = request.params['uid'];
        if (uid == null) {
          return Response(400,
            body: json.encode({
              'error': '전광판 ID가 누락되었습니다'
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var body = {
          "transaction": [
            {
              "statement": "#D_Multi",
              "values": {
                "uid": int.parse(uid)
              }
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
              'error': '전광판 삭제에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        return Response(200,
          body: json.encode({
            'message': '전광판이 성공적으로 삭제되었습니다',
            'uid': uid,
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