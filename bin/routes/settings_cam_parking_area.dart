import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import '../data/manage_address.dart';

//사용자 관리 setting backend part.
// 사용자 관리 설정
// 사용자 생성 기능(기존 활용 가능)
// password new_password 형식으로 update함.(기존 활용 가능)
// username update하는 기능
// userlevel, isActivated update하는 기능.
// 마지막으로 시작할때, tb_users 전부 response하게 하자.
class SettingsCamParkingArea {
  final ManageAddress manageAddress;
  SettingsCamParkingArea({required this.manageAddress});
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};
    //base_return router
    router.get('/', (Request request) async {
      try {
        //var headers = {'Content-Type': 'application/json'};
        Map<String, dynamic> body = {
          "transaction": [
            {"statement": "#S_TbParkingSurface"},
          ]
        };
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var tableMain = jsonDecode(user.body);
        var resultSet = tableMain['results'][0]['resultSet'];
        
        if(tableMain==null){
          return Response.ok('정보 없음');
        }
        var send = jsonEncode(resultSet);
        print(send);
        return Response.ok(send);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/updateZone', (Request request) async {
      try {
        // 프런트의 요청의 body를 JSON 형식으로 디코딩하여 데이터 추출
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        // print(requestData);
        var beforetag = requestData['beforetag'];
        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];

        var passwdcheck ={"transaction": [
            {
              "statement": "#S_TbParkingSurfaceTag",
              "values": {"tag": beforetag}
            }
          ]
        };
        var pwcorrect = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(passwdcheck),
        );
        // print(pwcorrect.body);
        var dcpwcoreect = jsonDecode(pwcorrect.body);
        var uid = dcpwcoreect['results'][0]['resultSet'][0]['uid'].toString();

        var body = {
          "transaction": [
            {
              "statement": "U_TbParkingSurface",
              "values": {"tag": tag, "engine_code": engineCode, "uri": uri, "uid": uid}
            },
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("update success");
      } catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/insertZone', (Request request) async {
      try{
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        var tag = requestData['tag'];
        var engineCode = requestData['engine_code'];
        var uri = requestData['uri'];
        var body = {
          "transaction": [
            { "statement": "#I_TbParkingSurface",
              "values": {"tag": tag ,"engine_code": engineCode, "uri": uri}
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("create success");
      }catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/deleteZone', (Request request) async {
      try{
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        var tag = requestData['tag'];
        //var engineCode = requestData['engine_code'];

        var body = {
          "transaction": [
            { "statement": "#D_TbParkingSurface",
              "values": {"tag": tag }
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        return Response.ok("delete success");
      }catch (e, stackTrace) {
        // 예외 처리
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    return router;
  }
}
