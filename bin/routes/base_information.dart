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
        var name = requestData['name'];
        var address = requestData['address'];
        var latitude = requestData['latitude'];
        var longitude = requestData['longitude'];
        var manager = requestData['manager'];
        var phoneNumber = requestData['phonenumber'];

        // 필수 필드가 모두 존재하는지 확인
        if (name == null || address == null || latitude == null || longitude == null || manager == null || phoneNumber == null) {
          print('Error: Missing required fields in the request data.');
          return Response( 400, body: jsonEncode({'error': '뭐 하나 빠드려서 보냈음. 다시 확인 ㄱㄱ'}),
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
                "name": name, "address": address, "latitude": latitude, "longitude": longitude, "manager": manager, "phoneNumber": phoneNumber
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
    router.get('/get', (Request request) async {
      try{
        var headers = {'Content-Type': 'application/json'};
        var body = {
          "transaction": [
            {
              "query": "#get_information"
            }
          ]
        };
        var responses = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var responseBody = utf8.decode(responses.bodyBytes);
        var rowResult = jsonDecode(responseBody);
        var rowDb = rowResult['results'][0]['resultSet'][0];
        var returndb = jsonEncode(rowDb); 
        var cleanDb = jsonDecode(returndb);
        // var returndb = jsonEncode(rowDb);
        var body3 = { "transaction": [
          { "query": "#allParkingLot" }
        ]};
        var all = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body3),
        );
        var all2 = jsonDecode(all.body);
        var all3 = all2['results'][0]['resultSet'];
        var all4 = all3[0]['count'];

        var body4 = { "transaction": [
            { "query": "#usedParkingLot" }
          ]};
        var use = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body4),
        );
        var use2 = jsonDecode(use.body);
        var use3 = use2['results'][0]['resultSet'];
        var use4 = use3[0]['count'];
        var used = {"all": all4, "use": use4, "db":cleanDb};
        var usedJson = jsonEncode(used);
        return Response.ok(usedJson, headers: {'content-type': 'application/json'});
      }catch (e, stacktrace){
        print('Exception occurred: $e');
        print('Stacktrace: $stacktrace');
        return Response.internalServerError(body: 'Internal Server Error: $e');
      }
    });
    return router;
  }
}
