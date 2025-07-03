import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import './receive_enginedata_send_to_dartserver.dart';

class GetResource {
  final ManageAddress manageAddress;
  GetResource({required this.manageAddress});
  
  Future<List<dynamic>> getParkingLotList(var engineDbaddr, var displayDbAddr, var displayDbLPR, DateTime check) async {
    
    // engineDbaddr 또는 displayDbAddr가 null 이거나 빈 문자열이라면 에러 처리
    if ((engineDbaddr == null || engineDbaddr.toString().trim().isEmpty) && (manageAddress.engineDbAddr == null || manageAddress.engineDbAddr!.trim().isEmpty)) {
      throw ArgumentError('engineDbaddr is null or empty');
    }
    if (displayDbAddr == null || displayDbAddr.toString().trim().isEmpty) {
      throw ArgumentError('displayDbAddr is null or empty');
    }

    // 두 값이 유효하다고 가정하고 receiveEnginedataSendToDartserver 호출
    List<dynamic> parkingLotList = await receiveEnginedataSendToDartserver(engineDbaddr, displayDbAddr, displayDbLPR, check);
    return parkingLotList;
  }

  Router get router {
    final router = Router();
    
    router.get('/', (Request request) async {
      try {
        // manageAddress의 값이 설정되어 있는지 점검
        // if (manageAddress.engineDbAddr == null || manageAddress.engineDbAddr!.trim().isEmpty) {
        //   return Response.internalServerError(body: 'Engine DB Address is not set properly.');
        // }
        // if (manageAddress.displayDbAddr == null || manageAddress.displayDbAddr!.trim().isEmpty) {
        //   return Response.internalServerError(body: 'Display DB Address is not set properly.');
        // }

        // 정상 값이 있다면 함수 호출
        List<dynamic> parkingLotList = await getParkingLotList(manageAddress.engineDbAddr, manageAddress.displayDbAddr, manageAddress.displayDbLPR, DateTime.now());
        String strRawData = 'start,${parkingLotList.join(',')}';
        return Response.ok(strRawData);
      } catch (e, stack) {
        print('Error in GetResource router: $e');
        print(stack);
        return Response.internalServerError(body: 'An error occurred: $e');
      }
    });
    return router;
  }
}
