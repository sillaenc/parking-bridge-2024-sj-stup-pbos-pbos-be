import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import './receive_enginedata_send_to_dartserver.dart';

class GetResource {
  Router get router {
    final router = Router();
    
    router.get('/', (Request request) async {
      try {
        // PostgreSQL 방식으로 처리하는 receiveEnginedataSendToDartserver() 함수 호출
        // (엔진 DB, 디스플레이 DB 모두 PostgreSQL로 전환되었다고 가정)
        List<dynamic> parkingLotList =
            await receiveEnginedataSendToDartserver("engineDbKey", "displayDbKey", DateTime.now());
        String strRawData = 'start,${parkingLotList.join(',')}';
        return Response.ok(strRawData,
            headers: {'Content-Type': 'application/json'});
      } catch (e, stack) {
        print('Error in GetResource router: $e');
        return Response.internalServerError(body: 'An error occurred: $e');
      }
    });
    return router;
  }
}
