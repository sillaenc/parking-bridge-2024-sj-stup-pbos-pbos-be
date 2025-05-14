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

    // POST /api/v1/base-information - 기본 정보 생성/업데이트
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('name') || 
            !requestData.containsKey('address') || 
            !requestData.containsKey('latitude') || 
            !requestData.containsKey('longitude') || 
            !requestData.containsKey('manager') || 
            !requestData.containsKey('phonenumber')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['name', 'address', 'latitude', 'longitude', 'manager', 'phonenumber']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var name = requestData['name'];
        var address = requestData['address'];
        var latitude = requestData['latitude'];
        var longitude = requestData['longitude'];
        var manager = requestData['manager'];
        var phoneNumber = requestData['phonenumber'];

        var headers = {'Content-Type': 'application/json'};
        
        // 기존 데이터 확인
        var checkBody = {
          "transaction": [
            {"query": "#checking"}
          ]
        };
        var checkResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(checkBody),
        );
        var checkData = jsonDecode(checkResponse.body);
        var count = checkData['results'][0]['resultSet'][0]['count'];

        if (count == 0) {
          // 새 데이터 생성
          var createBody = {
            "transaction": [
              {
                "statement": "#base",
                "values": {
                  "name": name,
                  "address": address,
                  "latitude": latitude,
                  "longitude": longitude,
                  "manager": manager,
                  "phoneNumber": phoneNumber
                }
              }
            ]
          };
          var createResponse = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(createBody),
          );

          if (createResponse.statusCode != 200) {
            return Response(500,
              body: json.encode({
                'error': '기본 정보 생성에 실패했습니다',
                'status_code': createResponse.statusCode
              }),
              headers: {'content-type': 'application/json'}
            );
          }

          return Response(201,
            body: json.encode({
              'message': '기본 정보가 성공적으로 생성되었습니다',
              'name': name,
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
              'manager': manager,
              'phoneNumber': phoneNumber
            }),
            headers: {'content-type': 'application/json'}
          );
        } else {
          // 기존 데이터 업데이트
          var updateBody = {
            "transaction": [
              {
                "statement": "#get_base",
                "values": {
                  "name": name,
                  "address": address,
                  "latitude": latitude,
                  "longitude": longitude,
                  "manager": manager,
                  "phoneNumber": phoneNumber
                }
              }
            ]
          };
          var updateResponse = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(updateBody),
          );

          if (updateResponse.statusCode != 200) {
            return Response(500,
              body: json.encode({
                'error': '기본 정보 업데이트에 실패했습니다',
                'status_code': updateResponse.statusCode
              }),
              headers: {'content-type': 'application/json'}
            );
          }

          return Response(200,
            body: json.encode({
              'message': '기본 정보가 성공적으로 업데이트되었습니다',
              'name': name,
              'address': address,
              'latitude': latitude,
              'longitude': longitude,
              'manager': manager,
              'phoneNumber': phoneNumber
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

    // GET /api/v1/base-information - 기본 정보 조회
    router.get('/', (Request request) async {
      try {
        var headers = {'Content-Type': 'application/json'};
        
        // 기본 정보 조회
        var infoBody = {
          "transaction": [
            {"query": "#get_information"}
          ]
        };
        var infoResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(infoBody),
        );
        var infoData = jsonDecode(utf8.decode(infoResponse.bodyBytes));
        var baseInfoList = infoData['results'][0]['resultSet'];
        if (baseInfoList.isEmpty) {
          return Response(200,
            body: json.encode({
              'message': '기본 정보가 없습니다',
              'base_information': null
            }),
            headers: {'content-type': 'application/json'}
          );
        }
        var baseInfo = baseInfoList[0];

        // 전체 주차장 수 조회
        var allBody = {
          "transaction": [
            {"query": "#allParkingLot"}
          ]
        };
        var allResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(allBody),
        );
        var allData = jsonDecode(allResponse.body);
        var totalLots = allData['results'][0]['resultSet'][0]['count'];

        // 사용 중인 주차장 수 조회
        var usedBody = {
          "transaction": [
            {"query": "#usedParkingLot"}
          ]
        };
        var usedResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(usedBody),
        );
        var usedData = jsonDecode(usedResponse.body);
        var usedLots = usedData['results'][0]['resultSet'][0]['count'];

        return Response(200,
          body: json.encode({
            'base_information': baseInfo,
            'parking_statistics': {
              'total_lots': totalLots,
              'used_lots': usedLots
            }
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
