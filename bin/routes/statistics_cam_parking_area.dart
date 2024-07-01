import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:intl/intl.dart';

import '../data/manage_address.dart';

class StatisticsCamParkingArea {
  final ManageAddress manageAddress;
  StatisticsCamParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    router.post('/oneDay', (Request request) async {
      String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var now = DateTime.now();
        var yesterday = now.subtract(Duration(days: 1));
        var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT car_type, hour_parking, recorded_hour FROM processed_db" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.post('/oneMonth', (Request request) async {
      String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var now = DateTime.now();
        var yesterday = now.subtract(Duration(days: 1));
        var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT car_type, day_parking, recorded_day FROM perday" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        print("resultSet : $user3");

        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.post('/oneYear', (Request request) async {
      String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var now = DateTime.now();
        var yesterday = now.subtract(Duration(days: 1));
        var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT car_type, month_parking, recorded_month FROM permonth" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        print("resultSet : $user3");

        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.post('/sevealYears', (Request request) async {
      String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var now = DateTime.now();
        var yesterday = now.subtract(Duration(days: 1));
        var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT car_type, year_parking, recorded_year FROM peryear" }
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        print("resultSet : $user3");

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
