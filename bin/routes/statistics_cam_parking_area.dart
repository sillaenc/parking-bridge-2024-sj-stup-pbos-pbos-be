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
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneDayAll" }
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
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        String today = '${DateFormat('yyyy-M-d').format(now)} 9';
        DateTime onedayBefore = now.subtract(Duration(days: 1));
        String yesterday = '${DateFormat('yyyy-M-d').format(onedayBefore)} 0';
        print(today);
        print(yesterday);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneDay" ,
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
      try {
        var url = manageAddress.displayDbAddr;
        DateTime now = DateTime.now();
        String thisWeek = '${DateFormat('yyyy-M-d').format(now)} 9';
        DateTime lastWeekStart = now.subtract(Duration(days: now.weekday + 7));
        print(lastWeekStart);
        String lastWeek = '${DateFormat('yyyy-M-d').format(lastWeekStart)} 0';
        print(thisWeek);
        print(lastWeek);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneWeek" ,
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
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneMonthAll" }
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
      try {
        var url = manageAddress.displayDbAddr;
        // DateTime now = DateTime.now();
        // String thisMotnh = DateFormat('yyyy-M-d').format(now);
        // DateTime onemonthBefore = now.subtract(Duration(days: 30));
        // String lastMonth = DateFormat('yyyy-M-d').format(onemonthBefore);
        DateTime now = DateTime.now();
        // DateTime yesterday = now.subtract(Duration(days: 1));
        DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        String lastMonthStart = DateFormat('yyyy-M-d').format(firstDayOfLastMonth);
        String todayFormat = DateFormat('yyyy-M-d').format(now);
        print(todayFormat);
        print(lastMonthStart);
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneMonth" ,
            "values" : {'today': todayFormat , 'last_month': lastMonthStart}}
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
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#S_OneYearAll" }
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
            {"query": "#S_OneYear" ,
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
      String? engineurl = manageAddress.engineDbAddr;
      print(engineurl);
      try {
        var url = manageAddress.displayDbAddr;
        var headers = {'Content-Type': 'application/json'};
        var body = { "transaction": [
            {"query": "#SeveralYearsAll" }
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
            {"query": "#SeveralYears" ,
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
