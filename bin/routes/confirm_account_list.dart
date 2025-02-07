import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';

class ConfirmAccountList {
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        // 쿼리 키 "S_AccountList"에 해당하는 계정 목록 조회
        List<Map<String, dynamic>> resultSet =
            await db.query("S_AccountList");
        String confirmResult = resultSet.isNotEmpty ? "1" : "0";
        return Response.ok(confirmResult,
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in ConfirmAccountList: $e');
        return Response.internalServerError(
            body: 'Error in ConfirmAccountList');
      }
    });
    return router;
  }
}
