import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class graphData {
  final ManageAddress manageAddress;
  graphData({required this.manageAddress});
  
  Router get router {
    final router = Router();
    router.post('/', (Request request) async {
      var requestBody = await request.readAsString();
      var requestData = jsonDecode(requestBody);

      var day = requestData['day'];
      String day1 = '$day%';
      print(day1);

      var url = manageAddress.displayDbAddr;
      var headers = {'Content-Type': 'application/json'};
      var body = { "transaction": [
          { "query": "#usedLot" }
        ]};
      var lot = await http.post(
        Uri.parse(url!),
        headers: headers,
        body: jsonEncode(body),
      );
      var lot2 = jsonDecode(lot.body);
      var lot3 = lot2['results'][0]['resultSet'];

      List<int> uids = [];
      for (var item in lot3) {
        if (item['uid'] != null) {
          uids.add(item['uid']);
        }
      }

      var body2 = { "transaction": [
          { "query": "#usedfloor" }
        ]};
      var floor = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body2),
      );
      var floor2 = jsonDecode(floor.body);
      var floor3 = floor2['results'][0]['resultSet'];

      List<String> floors = [];
      for (var item in floor3) {
        floors.add(item['floor']);
      }
      print(floors);

      print(uids);
      List<dynamic> allResults = [];
      
      for (var floor in floors) {
        for (var uid in uids) {
          var body2 = {
            "transaction": [
              {
                "query": "#graphData",
                "values": {'day': day1, 'lot_type': uid, 'floor': floor}
              }
            ]
          };
          var response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body2),
          );
          var lot2 = jsonDecode(response.body);
          var lot3 = lot2['results'][0]['resultSet'];
          print('lot3 = $lot3');
          allResults.add({'lot_type': uid, 'floor': floor, 'data': lot3});
          print('allResults = $allResults');
        }
      }
      var combinedData = jsonEncode(allResults);
      return Response.ok(combinedData);
    });
    router.get('/test', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        print(url);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#usedfloor" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        print(user2);
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        print("resultSet : $resultSet");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    return router;
  }
}