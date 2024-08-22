import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../data/manage_address.dart';

class StatisticsCamParkingArea {
  final ManageAddress manageAddress;
  StatisticsCamParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    router.get('/oneDayAll', (Request request) async {
      try {
        var url = manageAddress.displayDbAddr;
        // var now = DateTime.now();
        // var yesterday = now.subtract(Duration(days: 1));
        // var today = DateFormat('yyyy-mm-dd').format(now);
        // var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1" }
            // {"query": "SELECT count(recorded_hour) FROM processed_db where hour_parking = 1" }
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
    router.get('/oneDay', (Request request) async {
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        // String today = '${DateFormat('yyyy-M-d').format(now)} 23';
        String today = '${DateFormat('yyyy-M-d').format(now)} 9';
        DateTime onedayBefore = now.subtract(Duration(days: 1));
        String yesterday = '${DateFormat('yyyy-M-d').format(onedayBefore)} 0';
        print(today);
        print(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            // {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour = :today OR recorded_hour = :yesterday)" },
            {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour >= :yesterday AND recorded_hour <= :today)" ,
            "values" : {'today': today , 'yesterday': yesterday}}
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
        print("resultSet : $user3");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    router.get('/oneWeek', (Request request) async {
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        // String today = '${DateFormat('yyyy-M-d').format(now)} 23';
        String thisWeek = '${DateFormat('yyyy-M-d').format(now)} 9';
        // DateTime oneWeekBefore = now.subtract(Duration(days: 7));
        DateTime lastWeekStart = now.subtract(Duration(days: now.weekday + 7));
        print(lastWeekStart);
        String lastWeek = '${DateFormat('yyyy-M-d').format(lastWeekStart)} 0';
        print(thisWeek);
        print(lastWeek);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            // {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour = :today OR recorded_hour = :yesterday)" },
            {"query": "SELECT day_parking, recorded_day FROM perday where day_parking = 1 AND (recorded_day >= :last_month AND recorded_day < :today)" ,
            "values" : {'today': thisWeek , 'last_month': lastWeek}}
          ]};
        var user = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );
        var user2 = jsonDecode(user.body);
        // print(user2);
        var resultSet = user2['results'][0]['resultSet'];
        var user3 = jsonEncode(resultSet);
        // print("resultSet : $user3");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.get('/oneMonthAll', (Request request) async {
      // String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        // var now = DateTime.now();
        // var last_month = now.subtract(Duration(days: 30));//추후 수정 필요. 달 단위로 수정해야함
        // var strYesterday = DateFormat('yyyy-mm-dd').format(last_month);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT uid, car_type, month_parking, recorded_month FROM permonth" }
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

    router.get('/oneMonth', (Request request) async {
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        String thisMotnh = DateFormat('yyyy-M-d').format(now);
        DateTime onemonthBefore = now.subtract(Duration(days: 30));
        String lastMonth = DateFormat('yyyy-M-d').format(onemonthBefore);
        print(thisMotnh);
        print(lastMonth);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            // {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour = :today OR recorded_hour = :yesterday)" },
            {"query": "SELECT day_parking, recorded_day FROM perday where day_parking = 1 AND (recorded_day >= :last_month AND recorded_day < :today)" ,
            "values" : {'today': thisMotnh , 'last_month': lastMonth}}
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
        print("resultSet : $user3");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.get('/oneYearAll', (Request request) async {
      // String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        // var now = DateTime.now();
        // var yesterday = now.subtract(Duration(days: 365));
        // var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT uid, car_type, month_parking, recorded_month FROM permonth" }
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

    router.get('/oneYear', (Request request) async {
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        String thisYear = DateFormat('yyyy-M').format(now);
        DateTime onemonthBefore = now.subtract(Duration(days: 365));
        String lastYear = DateFormat('yyyy-M').format(onemonthBefore);
        print(thisYear);
        print(lastYear);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            // {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour = :today OR recorded_hour = :yesterday)" },
            {"query": "SELECT month_parking, recorded_month FROM permonth where month_parking = 1 AND (recorded_month >= :lastYear AND recorded_month < :today)" ,
            "values" : {'today': thisYear , 'lastYear': lastYear}}
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
        print("resultSet : $user3");
        return Response.ok(user3);
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.badRequest(body: 'Error: $e');
      }
    });

    router.get('/severalYearsAll', (Request request) async {
      // String? displayurl = manageAddress.displayDbAddr;
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        // var now = DateTime.now();
        // var yesterday = now.subtract(Duration(days: 365));
        // var strYesterday = DateFormat('yyyy-mm-dd').format(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "SELECT uid, car_type, year_parking, recorded_year FROM peryear" }
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

    router.get('/severalYears', (Request request) async {
      // print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        String thisMotnh = DateFormat('yyyy-M-d').format(now);
        DateTime onemonthBefore = now.subtract(Duration(days: 30));
        String lastMonth = DateFormat('yyyy-M-d').format(onemonthBefore);
        print(thisMotnh);
        print(lastMonth);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            // {"query": "SELECT hour_parking, recorded_hour FROM processed_db where hour_parking = 1 AND (recorded_hour = :today OR recorded_hour = :yesterday)" },
            {"query": "SELECT day_parking, recorded_day FROM perday where day_parking = 1 AND (recorded_day >= :last_month AND recorded_day < :today)" ,
            "values" : {'today': thisMotnh , 'last_month': lastMonth}}
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
