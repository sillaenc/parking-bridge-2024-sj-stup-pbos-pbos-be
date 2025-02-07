import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';

class LedCal {
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        // 쿼리 키 "cal_get"로 LED 관련 데이터를 조회
        List<Map<String, dynamic>> resultSet = await db.query("cal_get");
        // 각 행에 대해 tag_count와 isUsed_count 비교하여 색상 결정
        var formattedResult = resultSet.map((entry) {
          String color = (entry['tag_count'] == entry['isUsed_count'])
              ? "green"
              : "red";
          String camera = "";
          if (entry['camera'] != null && entry['camera'] is String) {
            String camStr = entry['camera'];
            camera = camStr.substring(camStr.length - 3);
          }
          return {"camera": camera, "color": color};
        }).toList();
        return Response.ok(jsonEncode(formattedResult),
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in LedCal: $e');
        return Response.badRequest(body: 'Error in LedCal: $e');
      }
    });
    return router;
  }
}
