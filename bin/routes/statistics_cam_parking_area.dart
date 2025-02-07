import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:intl/intl.dart';
import '../data/db.dart';
import '../data/manage_address.dart';

class StatisticsCamParkingArea {
  final ManageAddress manageAddress;
  StatisticsCamParkingArea({required this.manageAddress});
  
  Router get router {
    final router = Router();
    
    // GET /oneDayAll: (쿼리 "S_OneDayAll")
    router.get('/oneDayAll', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_OneDayAll");
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneDayAll: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneDay: (쿼리 "S_OneDay" with parameters)
    router.get('/oneDay', (Request request) async {
      try {
        final db = await Database.getInstance();
        DateTime now = DateTime.now();
        String hourago = '${DateFormat('yyyy-MM-dd').format(now)} 9';
        String today  = '${DateFormat('yyyy-MM-dd').format(now)} 0';
        DateTime onedayBefore = now.subtract(Duration(days: 1));
        String yesterday = '${DateFormat('yyyy-MM-dd').format(onedayBefore)}%';
        print(hourago);
        print(today);
        print(yesterday);
        List<Map<String, dynamic>> resultSet = await db.query("S_OneDay", {
          'hourago': hourago,
          'today': today,
          'yesterday': yesterday
        });
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneDay: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneWeek: (쿼리 "S_OneWeek")
    router.get('/oneWeek', (Request request) async {
      try {
        final db = await Database.getInstance();
        DateTime now = DateTime.now();
        String thisWeek = DateFormat('yyyy-MM-dd').format(now);
        DateTime lastWeekStart = now.subtract(Duration(days: now.weekday + 7));
        String lastWeek = DateFormat('yyyy-MM-dd').format(lastWeekStart);
        print(thisWeek);
        print(lastWeek);
        List<Map<String, dynamic>> resultSet = await db.query("S_OneWeek", {
          'today': thisWeek,
          'last_month': lastWeek
        });
        String user3 = jsonEncode(resultSet);
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneWeek: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // POST /searchDay: (쿼리 "S_Search")
    router.post('/searchDay', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var startDay = requestData['startDay'];
        var endDay = requestData['endDay'];
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_Search", {
          'startDay': startDay,
          'endDay': endDay
        });
        String user3 = jsonEncode(resultSet);
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /searchDay: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // POST /searchgraph: (쿼리 "S_graph")
    router.post('/searchgraph', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var startDay = requestData['startDay'];
        var endDay = requestData['endDay'];
        startDay = '$startDay 00';
        endDay = '$endDay 23';
        print(startDay);
        print(endDay);
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_graph", {
          'startDay': startDay,
          'endDay': endDay
        });
        print("resultSet : ${jsonEncode(resultSet)}");
        return Response.ok(jsonEncode(resultSet), headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /searchgraph: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneMonthAll: (쿼리 "S_OneMonthAll")
    router.get('/oneMonthAll', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_OneMonthAll");
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneMonthAll: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneMonth: (쿼리 "S_OneMonth")
    router.get('/oneMonth', (Request request) async {
      try {
        final db = await Database.getInstance();
        DateTime now = DateTime.now();
        DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        String lastMonthStart = DateFormat('yyyy-MM-dd').format(firstDayOfLastMonth);
        String todayFormat = DateFormat('yyyy-MM-dd').format(now);
        print(todayFormat);
        print(lastMonthStart);
        List<Map<String, dynamic>> resultSet = await db.query("S_OneMonth", {
          'today': todayFormat,
          'last_month': lastMonthStart
        });
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneMonth: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneYearAll: (쿼리 "S_OneYearAll")
    router.get('/oneYearAll', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_OneYearAll");
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneYearAll: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /oneYear: (쿼리 "S_OneYear")
    router.get('/oneYear', (Request request) async {
      try {
        final db = await Database.getInstance();
        DateTime now = DateTime.now();
        String thisYear = DateFormat('yyyy').format(now);
        String lastYear = (now.year - 1).toString();
        print(thisYear);
        print(lastYear);
        List<Map<String, dynamic>> resultSet = await db.query("S_OneYear", {
          'today': thisYear,
          'lastYear': lastYear
        });
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /oneYear: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /severalYearsAll: (쿼리 "SeveralYearsAll")
    router.get('/severalYearsAll', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("SeveralYearsAll");
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /severalYearsAll: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    // GET /severalYears: (쿼리 "SeveralYears")
    router.get('/severalYears', (Request request) async {
      try {
        final db = await Database.getInstance();
        DateTime now = DateTime.now();
        String thisMotnh = DateFormat('yyyy-M-d').format(now);
        DateTime onemonthBefore = now.subtract(Duration(days: 30));
        String lastMonth = DateFormat('yyyy-M-d').format(onemonthBefore);
        print(thisMotnh);
        print(lastMonth);
        List<Map<String, dynamic>> resultSet = await db.query("SeveralYears", {
          'today': thisMotnh,
          'last_month': lastMonth
        });
        String user3 = jsonEncode(resultSet);
        print("resultSet : $user3");
        return Response.ok(user3, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in /severalYears: $e');
        return Response.badRequest(body: 'Error: $e');
      }
    });
    
    return router;
  }
}
