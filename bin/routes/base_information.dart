import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import '../data/db.dart';

class BaseInformation {
  final ManageAddress manageAddress;
  BaseInformation({required this.manageAddress});

  Router get router {
    final router = Router();

    // POST: 기본정보 등록/업데이트
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        if (requestData == null) {
          print('Error: Request body is null or invalid JSON.');
          return Response(
            400,
            body: jsonEncode({'error': 'Invalid JSON in request body'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        var name = requestData['name'];
        var address = requestData['address'];
        var latitude = requestData['latitude'];
        var longitude = requestData['longitude'];
        var manager = requestData['manager'];
        var phoneNumber = requestData['phonenumber'];

        // 필수 필드 확인
        if (name == null ||
            address == null ||
            latitude == null ||
            longitude == null ||
            manager == null ||
            phoneNumber == null) {
          print('Error: Missing required fields in the request data.');
          return Response(
            400,
            body: jsonEncode({'error': 'Missing required fields'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final db = await Database.getInstance();

        // 먼저, 해당 기본정보가 존재하는지 확인하는 쿼리(예: "checking")
        List<Map<String, dynamic>> checkResult =
            await db.query("checking", {"name": name, "address": address});
        int checkCount = (checkResult.isNotEmpty && checkResult.first['count'] != null)
            ? checkResult.first['count']
            : 0;

        if (checkCount == 0) {
          // 등록: 쿼리 키 "base"
          await db.query("base", {
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude,
            "manager": manager,
            "phoneNumber": phoneNumber
          });
          return Response.ok(
            jsonEncode({'message': 'Request processed successfully'}),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          // 업데이트: 쿼리 키 "get_base"
          await db.query("get_base", {
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude,
            "manager": manager,
            "phoneNumber": phoneNumber
          });
          return Response.ok(
            jsonEncode({'message': '업데이트 완료'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e, stacktrace) {
        print('Exception occurred: $e');
        print('Stacktrace: $stacktrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'An unexpected error occurred'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // GET: 기본정보 및 주차현황 조회
    router.get('/get', (Request request) async {
      try {
        final db = await Database.getInstance();
        // 기본정보 조회 (쿼리 키 "get_information")
        List<Map<String, dynamic>> infoResult = await db.query("get_information");
        var cleanDb = infoResult.isNotEmpty ? infoResult.first : {};

        // 전체 주차 구역 수 (쿼리 키 "allParkingLot")
        List<Map<String, dynamic>> allLotResult = await db.query("allParkingLot");
        int allCount =
            allLotResult.isNotEmpty ? (allLotResult.first['count'] ?? 0) : 0;

        // 사용 중인 주차 구역 수 (쿼리 키 "usedParkingLot")
        List<Map<String, dynamic>> usedLotResult = await db.query("usedParkingLot");
        int usedCount =
            usedLotResult.isNotEmpty ? (usedLotResult.first['count'] ?? 0) : 0;

        var used = {"all": allCount, "use": usedCount, "db": cleanDb};
        return Response.ok(
          jsonEncode(used),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, stacktrace) {
        print('Exception occurred: $e');
        print('Stacktrace: $stacktrace');
        return Response.internalServerError(
            body: 'Internal Server Error: $e');
      }
    });

    return router;
  }
}
