import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

class SettingsDbManagement {
  final ManageAddress manageAddress;
  SettingsDbManagement({required this.manageAddress});
  
  Router get router {
    final router = Router();
    
    // POST /engine: 엔진 DB 설정 변경 (쿼리 "U_TbDbSetting" with changeEngine)
    router.post('/engine', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final dbData = jsonDecode(requestBody);
        var changeEngine = dbData['engineDb'];
        final db = await Database.getInstance();
        // (필요 시 현재 설정 조회: "S_TbDbSetting")
        List<Map<String, dynamic>> currentSetting = await db.query("S_TbDbSetting");
        print(currentSetting);
        await db.query("U_TbDbSetting", {"changeEngine": changeEngine});
        return Response.ok('변경 완료!');
      } catch (e, st) {
        print('Error in SettingsDbManagement /engine: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /display: 디스플레이 DB 설정 변경 (쿼리 "U_TbDbSetting" with changeDisplay)
    router.post('/display', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final dbData = jsonDecode(requestBody);
        var changeDisplay = dbData['displayDb'];
        print(changeDisplay);
        final db = await Database.getInstance();
        List<Map<String, dynamic>> currentSetting = await db.query("S_TbDbSetting");
        print(currentSetting);
        await db.query("U_TbDbSetting", {"changeDisplay": changeDisplay});
        return Response.ok('변경 완료!');
      } catch (e, st) {
        print('Error in SettingsDbManagement /display: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    return router;
  }
}
