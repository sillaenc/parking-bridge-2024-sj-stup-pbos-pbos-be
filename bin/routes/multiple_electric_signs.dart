import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

class MultipleElectricSigns {
  final ManageAddress manageAddress;
  MultipleElectricSigns({required this.manageAddress});
  
  Router get router {
    final router = Router();
    
    // GET: 조회 (쿼리 키 "S_Multi")
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_Multi");
        String info = jsonEncode(resultSet);
        return Response.ok(info, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in MultipleElectricSigns GET: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /update: 수정 (쿼리 키 "U_Multi")
    router.post('/update', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        int uid = requestData['uid'];
        var parkingLot = requestData['parking_lot'];
        final db = await Database.getInstance();
        await db.query("U_Multi", {"uid": uid, "parking_lot": parkingLot});
        return Response.ok("update success");
      } catch (e, st) {
        print('Error in MultipleElectricSigns update: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /insert: 삽입 (쿼리 키 "I_Multi")
    router.post('/insert', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        int uid = requestData['uid'];
        var parkingLot = requestData['parking_lot'];
        final db = await Database.getInstance();
        await db.query("I_Multi", {"uid": uid, "parking_lot": parkingLot});
        return Response.ok("Inserted successfully");
      } catch (e, st) {
        print('Error in MultipleElectricSigns insert: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /deleteZone: 삭제 (쿼리 키 "D_Multi")
    router.post('/deleteZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var uid = requestData['uid'];
        final db = await Database.getInstance();
        await db.query("D_Multi", {"uid": uid});
        return Response.ok("delete success");
      } catch (e, st) {
        print('Error in MultipleElectricSigns deleteZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    return router;
  }
}
