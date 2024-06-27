import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../data/manage_address.dart';


class MultipleElectricSigns {
  ManageAddress manageAddress = ManageAddress();
  MultipleElectricSigns(this.manageAddress);
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};
    //base_return router
    router.get('/', (Request request) async {
      var body = {
        "transaction": [
          {"query": "SELECT * FROM multiple_signs"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: headers,
        body: jsonEncode(body),
      );
      //var db = jsonDecode(utf8.decode(response.bodyBytes));
      var db = jsonDecode(response.body);
      var dbSet = db['results'][0]['resultSet'];
      var info = jsonEncode(dbSet);
      print(info);
      return Response.ok(info);
    });

    router.post('/update', (Request request) async {
      try {
        // 프런트의 요청의 body를 JSON 형식으로 디코딩하여 데이터 추출
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);
        // print(requestData);
        int uid = requestData['uid'];
        var parkingLot = requestData['parking_lot'];

        var body = {
          "transaction": [
            {"query": "UPDATE tb_parking_surface SET (parking_lot) = (:parking_lot) WHERE uid = :uid",
              "values": {"uid": uid ,"parking_lot": parkingLot}
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
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

    router.post('/insert', (Request request) async {
      try{
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        int uid = requestData['uid'];
        var parkingLot = requestData['parking_lot'];
        var body = {
          "transaction": [
            { "query": "INSERT INTO multiple_signs (uid, parking_lot) VALUES (:uid, :parking_lot)",
              "values": {"uid": uid ,"parking_lot": parkingLot}
            },
          ]
        };
        var response =await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        if (response.statusCode == 200) {
          return Response(200, body: 'Inserted successfully');
        } else {
          return Response(409, body: 'UID already exists');
        }
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

        var uid = requestData['uid'];

        var body = {
          "transaction": [
            { "query": "DELETE FROM multiple_signs WHERE uid = :uid",
              "values": {"uid": uid }
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