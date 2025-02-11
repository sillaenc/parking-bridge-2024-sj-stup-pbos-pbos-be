import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;

class Central {
  final ManageAddress manageAddress;
  Central({required this.manageAddress});
  
  Router get router {
    final router = Router();
    router.get('/', (Request request) async {

      var url = manageAddress.displayDbAddr;
      var headers = {'Content-Type': 'application/json'};
      var body = {"transaction": [{ "query": "#usedLot" }]};
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

      var body3 = { "transaction": [
          { "query": "#allParkingLot" }
        ]};
      var all = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body3),
      );
      var all2 = jsonDecode(all.body);
      var all3 = all2['results'][0]['resultSet'];
      var all4 = all3[0]['count'];

      var body4 = { "transaction": [
          { "query": "#usedParkingLot" }
        ]};
      var use = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body4),
      );
      var use2 = jsonDecode(use.body);
      var use3 = use2['results'][0]['resultSet'];
      var use4 = use3[0]['count'];

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
      print(all4);
      print(use4);
      print(floors);

      print(uids);
      List<dynamic> allResults = [];
      for (var floor in floors) {
        for (var uid in uids) {
          var body2 = {
            "transaction": [
              {
                "query": "#count",
                "values": {'lot_type': uid, 'floor': floor}
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
          // print('lot3 = $lot3');
          allResults.add({'lot_type': uid, 'floor': floor, 'data': lot3});
          // print('allResults = $allResults');
        }
      }
      // allResults.add(floors);
      print(allResults);
      var plus = {'all': all4, 'use': use4,'floors': floors, 'lots': uids, 'parked':allResults};
      var combinedData = jsonEncode(plus);
      // var 
      // return Response.ok(jsonEncode(combinedData + floors), );
      return Response.ok(combinedData);
    });
    return router;
  }
}