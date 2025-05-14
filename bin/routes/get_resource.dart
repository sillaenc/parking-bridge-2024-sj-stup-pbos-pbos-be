import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import './receive_enginedata_send_to_dartserver.dart';
import 'dart:convert';

class GetResource {
  final ManageAddress manageAddress;
  GetResource({required this.manageAddress});
  
  Future<List<dynamic>> getParkingLotList(var engineDbaddr, var displayDbAddr, var displayDbLPR, DateTime check) async {
    if ((engineDbaddr == null || engineDbaddr.toString().trim().isEmpty) && 
        (manageAddress.engineDbAddr == null || manageAddress.engineDbAddr!.trim().isEmpty)) {
      throw ArgumentError('Engine DB 주소가 설정되지 않았습니다');
    }
    if (displayDbAddr == null || displayDbAddr.toString().trim().isEmpty) {
      throw ArgumentError('Display DB 주소가 설정되지 않았습니다');
    }

    List<dynamic> parkingLotList = await receiveEnginedataSendToDartserver(
      engineDbaddr, 
      displayDbAddr, 
      displayDbLPR, 
      check
    );
    return parkingLotList;
  }

  Router get router {
    final router = Router();
    // GET /api/v1/system/resource/parking-lots - 주차장 리소스 조회
    router.get('/parking-lots', (Request request) async {
      try {
        List<dynamic> parkingLotList = await getParkingLotList(
          manageAddress.engineDbAddr,
          manageAddress.displayDbAddr,
          manageAddress.displayDbLPR,
          DateTime.now()
        );

        return Response(200,
          body: json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'parking_lots': parkingLotList
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stack) {
        print('Error in GetResource router: $e');
        print(stack);
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
