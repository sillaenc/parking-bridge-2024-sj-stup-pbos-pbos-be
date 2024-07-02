import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import './receive_enginedata_send_to_dartserver.dart';

class GetResource {
  final ManageAddress manageAddress;
  GetResource({required this.manageAddress});

  Future<List<dynamic>> getParkingLotList(var engineDbaddr, var displayDbAddr, DateTime check) async {
    List<dynamic> parkingLotList = await receiveEnginedataSendToDartserver(engineDbaddr, displayDbAddr, check);
    return parkingLotList;
  }

  Router get router {
    final router = Router();
    String strRawData;
    router.get('/', (Request request) async {
      List<dynamic> parkingLotList = await getParkingLotList(manageAddress.engineDbAddr, manageAddress.displayDbAddr, DateTime.now());
      strRawData = 'start,${parkingLotList.join(',')}';
      return Response.ok(strRawData);
    });
    strRawData = '';
    return router;
  }
}