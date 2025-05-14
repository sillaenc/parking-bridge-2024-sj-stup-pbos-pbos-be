import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Central {
  final ManageAddress manageAddress;
  Central({required this.manageAddress});
  
  Router get router {
    final router = Router();

    // GET /api/v1/central - 중앙 제어 시스템 상태 조회
    router.get('/', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};

        // 사용 중인 주차장 정보 조회
        var usedLotBody = {
          "transaction": [
            { "query": "#usedLot" }
          ]
        };
        var usedLotResponse = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(usedLotBody),
        );

        if (usedLotResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주차장 사용 정보 조회에 실패했습니다',
              'status_code': usedLotResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var usedLotData = jsonDecode(usedLotResponse.body);
        var usedLotResult = usedLotData['results'][0]['resultSet'];
        List<int> uids = usedLotResult
            .where((item) => item['uid'] != null)
            .map((item) => item['uid'] as int)
            .toList();

        // 전체 주차장 수 조회
        var allLotBody = {
          "transaction": [
            { "query": "#allParkingLot" }
          ]
        };
        var allLotResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(allLotBody),
        );

        if (allLotResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '전체 주차장 수 조회에 실패했습니다',
              'status_code': allLotResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var allLotData = jsonDecode(allLotResponse.body);
        var totalLots = allLotData['results'][0]['resultSet'][0]['count'];

        // 사용 중인 주차장 수 조회
        var usedParkingBody = {
          "transaction": [
            { "query": "#usedParkingLot" }
          ]
        };
        var usedParkingResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(usedParkingBody),
        );

        if (usedParkingResponse.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '사용 중인 주차장 수 조회에 실패했습니다',
              'status_code': usedParkingResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var usedParkingData = jsonDecode(usedParkingResponse.body);
        var usedLots = usedParkingData['results'][0]['resultSet'][0]['count'];

        // 층별 정보 조회
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
              'error': '층별 정보 조회에 실패했습니다',
              'status_code': floorResponse.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var floorData = jsonDecode(floorResponse.body);
        var floors = floorData['results'][0]['resultSet']
            .map((item) => item['floor'] as String)
            .toList();

        // 층별 주차장 상태 조회
        List<Map<String, dynamic>> parkingStatus = [];
        for (var floor in floors) {
          for (var uid in uids) {
            var statusBody = {
              "transaction": [
                {
                  "query": "#count",
                  "values": {'lot_type': uid, 'floor': floor}
                }
              ]
            };
            var statusResponse = await http.post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(statusBody),
            );

            if (statusResponse.statusCode == 200) {
              var statusData = jsonDecode(statusResponse.body);
              var statusResult = statusData['results'][0]['resultSet'];
              parkingStatus.add({
                'lot_type': uid,
                'floor': floor,
                'data': statusResult
              });
            }
          }
        }

        return Response(200,
          body: json.encode({
            'parking_statistics': {
              'total_lots': totalLots,
              'used_lots': usedLots
            },
            'floors': floors,
            'lot_types': uids,
            'parking_status': parkingStatus
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