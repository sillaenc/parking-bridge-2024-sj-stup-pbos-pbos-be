import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class BaseInformation {
  final ManageAddress manageAddress;
  BaseInformation({required this.manageAddress});

  Router get router {
    var url = manageAddress.displayDbAddr;
    final router = Router();
    router.post('/', (Request request) async {
      try {
        // 요청 본문 읽기
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        if (requestData == null) {
          print('Error: Request body is null or invalid JSON.');
          return Response(400, body: jsonEncode({'error': 'Invalid JSON in request body'}),  headers: {'Content-Type': 'application/json'});
        }
        var name = requestData['account'];
        var address = requestData['username'];
        var latitude = requestData['latitude'];
        var longitude = requestData['longitude'];
        var manager = requestData['manager'];
        var phoneNumber = requestData['phoneNumber'];

        // 필수 필드가 모두 존재하는지 확인
        if (name == null || address == null || latitude == null || longitude == null || manager == null || phoneNumber == null) {
          print('Error: Missing required fields in the request data.');
          return Response( 400, body: jsonEncode({'error': 'Missing required fields'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 요청 바디 구성
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {
              "statement": "#base",
              "values": {
                "name": name, "timestamp": address, "latitude": latitude, "longitude": longitude, "manager": manager, "phoneNumber": phoneNumber
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
          print('Error: /base query 실행 실패 failed with status code ${response.statusCode}.');
          print('Response body: ${response.body}');
          return Response(502, body: jsonEncode({'error': 'Failed to process external request'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.ok(
          jsonEncode({'message': 'Request processed successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stacktrace) {
        print('Exception occurred: $e');
        print('Stacktrace: $stacktrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'An unexpected error occurred'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });
    return router;
  }
}
