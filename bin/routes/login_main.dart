import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';

class LoginMain {
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        // 쿼리 키 "S_Information"로 로그인 관련 정보를 조회
        List<Map<String, dynamic>> resultSet =
            await db.query("S_Information");
        return Response.ok(jsonEncode(resultSet),
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in LoginMain: $e');
        return Response.internalServerError(body: 'Error in LoginMain: $e');
      }
    });

    router.post('/profile', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        var account = requestData['account'];
        final db = await Database.getInstance();
        // 쿼리 키 "S_Profile" – 파라미터: account
        List<Map<String, dynamic>> resultSet =
            await db.query("S_Profile", {"account": account});
        return Response.ok(jsonEncode(resultSet),
            headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in LoginMain profile: $e');
        return Response.internalServerError(
            body: 'Error in LoginMain profile: $e');
      }
    });

    return router;
  }
}
