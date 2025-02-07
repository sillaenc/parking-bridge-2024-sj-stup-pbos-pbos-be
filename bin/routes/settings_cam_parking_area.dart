import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

class SettingsCamParkingArea {
  final ManageAddress manageAddress;
  SettingsCamParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    
    // GET: 조회 (쿼리 키 "S_TbParkingSurface")
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_TbParkingSurface");
        if (resultSet == null) {
          return Response.ok('정보 없음');
        }
        String send = jsonEncode(resultSet);
        print(send);
        return Response.ok(send, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in SettingsCamParkingArea GET: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /updateZone: 수정 (쿼리 "S_TbParkingSurfaceTag" → get uid, then "U_TbParkingSurface")
    router.post('/updateZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var beforetag = requestData['beforetag'];
        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];
        final db = await Database.getInstance();
        List<Map<String, dynamic>> tagResult =
            await db.query("S_TbParkingSurfaceTag", {"tag": beforetag});
        if (tagResult.isEmpty) {
          return Response.internalServerError(body: 'No matching tag found');
        }
        var uid = tagResult.first['uid'].toString();
        await db.query("U_TbParkingSurface", {"tag": tag, "engine_code": engineCode, "uri": uri, "uid": uid});
        return Response.ok("update success");
      } catch (e, st) {
        print('Error in SettingsCamParkingArea updateZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /insertZone: 삽입 (쿼리 "I_TbParkingSurface")
    router.post('/insertZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];
        final db = await Database.getInstance();
        await db.query("I_TbParkingSurface", {"tag": tag, "engine_code": engineCode, "uri": uri});
        return Response.ok("create success");
      } catch (e, st) {
        print('Error in SettingsCamParkingArea insertZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /deleteZone: 삭제 (쿼리 "D_TbParkingSurface")
    router.post('/deleteZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var tag = requestData['tag'];
        final db = await Database.getInstance();
        await db.query("D_TbParkingSurface", {"tag": tag});
        return Response.ok("delete success");
      } catch (e, st) {
        print('Error in SettingsCamParkingArea deleteZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    return router;
  }
}
