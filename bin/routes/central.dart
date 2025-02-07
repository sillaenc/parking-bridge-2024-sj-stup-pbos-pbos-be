import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';

class Central {
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();

        // 중앙 주차 현황: 사용 중인 구역 (쿼리 키 "central_usedLot")
        List<Map<String, dynamic>> lotResults =
            await db.query("central_usedLot");
        List<int> uids = [];
        for (var item in lotResults) {
          if (item['uid'] != null) {
            uids.add(item['uid']);
          }
        }

        // 전체 주차 구역 수 ("allParkingLot")
        List<Map<String, dynamic>> allLotResult =
            await db.query("allParkingLot");
        int allCount =
            allLotResult.isNotEmpty ? (allLotResult.first['count'] ?? 0) : 0;

        // 사용 중인 주차 구역 수 ("usedParkingLot")
        List<Map<String, dynamic>> usedLotResult =
            await db.query("usedParkingLot");
        int usedCount =
            usedLotResult.isNotEmpty ? (usedLotResult.first['count'] ?? 0) : 0;

        // 사용중인 층(플로어) 정보 ("central_usedfloor")
        List<Map<String, dynamic>> floorResult =
            await db.query("central_usedfloor");
        List<String> floors = [];
        for (var item in floorResult) {
          floors.add(item['floor']);
        }

        List<dynamic> allResults = [];
        // 각 층과 주차 구역 uid별 데이터 (쿼리 키 "count" – 파라미터: lot_type, floor)
        for (var floor in floors) {
          for (var uid in uids) {
            List<Map<String, dynamic>> countResult =
                await db.query("count", {"lot_type": uid, "floor": floor});
            allResults.add({'lot_type': uid, 'floor': floor, 'data': countResult});
          }
        }
        var plus = {
          'all': allCount,
          'use': usedCount,
          'floors': floors,
          'lots': uids,
          'parked': allResults
        };
        return Response.ok(
          jsonEncode(plus),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e, st) {
        print('Error in Central: $e');
        return Response.internalServerError(body: 'Error in Central: $e');
      }
    });
    return router;
  }
}
