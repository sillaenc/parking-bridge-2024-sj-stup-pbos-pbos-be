import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';

class GraphData {
  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        var day = requestData['day'];
        String dayPattern = '$day%';

        final db = await Database.getInstance();
        // 사용 중인 주차 구역 (쿼리 키 "usedLot")
        List<Map<String, dynamic>> lotResult = await db.query("usedLot");
        List<int> uids = [];
        for (var item in lotResult) {
          if (item['uid'] != null) {
            uids.add(item['uid']);
          }
        }

        // 사용중인 층 정보 (쿼리 키 "usedfloor")
        List<Map<String, dynamic>> floorResult = await db.query("usedfloor");
        List<String> floors = [];
        for (var item in floorResult) {
          floors.add(item['floor']);
        }

        List<dynamic> allResults = [];
        for (var floor in floors) {
          for (var uid in uids) {
            // 쿼리 키 "graphData" – 파라미터: day, lot_type, floor
            List<Map<String, dynamic>> graphResult = await db.query("graphData", {
              "day": dayPattern,
              "lot_type": uid,
              "floor": floor
            });
            allResults.add({'lot_type': uid, 'floor': floor, 'data': graphResult});
          }
        }
        return Response.ok(jsonEncode(allResults),
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in GraphData: $e');
        return Response.internalServerError(body: 'Error in GraphData: $e');
      }
    });

    router.get('/test', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("usedfloor");
        return Response.ok(jsonEncode(resultSet),
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in GraphData test: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}
