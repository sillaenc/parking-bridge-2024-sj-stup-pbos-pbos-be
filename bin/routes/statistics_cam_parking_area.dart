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
    var url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};

    // GET /api/v1/statistics/one-day-all - 전체 일일 통계
    router.get('/one-day-all', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_OneDayAll"}
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '일일 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-day - 특정 일자 통계
    router.get('/one-day', (Request request) async {
      try {
        DateTime now = DateTime.now();
        String hourago = '${DateFormat('yyyy-MM-dd').format(now)} ${now.hour}';
        String today = '${DateFormat('yyyy-MM-dd').format(now)} 0';
        DateTime onedayBefore = now.subtract(Duration(days: 1));
        String yesterday = '${DateFormat('yyyy-MM-dd').format(onedayBefore)}%';

        var body = {
          "transaction": [
            {
              "query": "#S_OneDay",
              "values": {
                'hourago': hourago,
                'today': today,
                'yesterday': yesterday
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '일일 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'date': today,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-week - 주간 통계
    router.get('/one-week', (Request request) async {
      try {
        DateTime now = DateTime.now();
        String thisWeek = DateFormat('yyyy-MM-dd').format(now);
        DateTime lastWeekStart = now.subtract(Duration(days: now.weekday + 7));
        String lastWeek = DateFormat('yyyy-MM-dd').format(lastWeekStart);

        var body = {
          "transaction": [
            {
              "query": "#S_OneWeek",
              "values": {
                'today': thisWeek,
                'last_month': lastWeek
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '주간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'start_date': lastWeek,
            'end_date': thisWeek,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // POST /api/v1/statistics/search - 기간별 통계 검색
    router.post('/search', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('startDay') || !requestData.containsKey('endDay')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['startDay', 'endDay']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var startDay = requestData['startDay'];
        var endDay = requestData['endDay'];

        var body = {
          "transaction": [
            {
              "query": "#S_Search",
              "values": {
                'startDay': startDay,
                'endDay': endDay
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '기간별 통계 검색에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'start_date': startDay,
            'end_date': endDay,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // POST /api/v1/statistics/search-graph - 기간별 그래프 데이터 검색
    router.post('/search-graph', (Request request) async {
      try {
        var requestBody = await request.readAsString();
        var requestData = jsonDecode(requestBody);

        if (!requestData.containsKey('startDay') || !requestData.containsKey('endDay')) {
          return Response(400,
            body: json.encode({
              'error': '필수 필드가 누락되었습니다',
              'required_fields': ['startDay', 'endDay']
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var startDay = '${requestData['startDay']} 00';
        var endDay = '${requestData['endDay']} 23';

        var body = {
          "transaction": [
            {
              "query": "#S_graph",
              "values": {
                'startDay': startDay,
                'endDay': endDay
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '그래프 데이터 검색에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'graph_data': resultSet,
            'start_date': startDay,
            'end_date': endDay,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-month-all - 전체 월간 통계
    router.get('/one-month-all', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_OneMonthAll"}
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '월간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-month - 특정 월 통계
    router.get('/one-month', (Request request) async {
      try {
        DateTime now = DateTime.now();
        DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        String lastMonthStart = DateFormat('yyyy-MM-dd').format(firstDayOfLastMonth);
        String todayFormat = DateFormat('yyyy-MM-dd').format(now);

        var body = {
          "transaction": [
            {
              "query": "#S_OneMonth",
              "values": {
                'today': todayFormat,
                'last_month': lastMonthStart
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '월간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'start_date': lastMonthStart,
            'end_date': todayFormat,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-year-all - 전체 연간 통계
    router.get('/one-year-all', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#S_OneYearAll"}
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '연간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/one-year - 특정 연도 통계
    router.get('/one-year', (Request request) async {
      try {
        DateTime now = DateTime.now();
        String thisYear = DateFormat('yyyy-MM').format(now);
        DateTime oneYearBefore = now.subtract(Duration(days: 365));
        String lastYear = DateFormat('yyyy-MM').format(oneYearBefore);

        var body = {
          "transaction": [
            {
              "query": "#S_OneYear",
              "values": {
                'today': thisYear,
                'lastYear': lastYear
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '연간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'start_date': lastYear,
            'end_date': thisYear,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/several-years-all - 전체 다년간 통계
    router.get('/several-years-all', (Request request) async {
      try {
        var body = {
          "transaction": [
            {"query": "#SeveralYearsAll"}
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '다년간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    // GET /api/v1/statistics/several-years - 특정 기간 다년간 통계
    router.get('/several-years', (Request request) async {
      try {
        DateTime now = DateTime.now();
        String thisMonth = DateFormat('yyyy-M-d').format(now);
        DateTime oneMonthBefore = now.subtract(Duration(days: 30));
        String lastMonth = DateFormat('yyyy-M-d').format(oneMonthBefore);

        var body = {
          "transaction": [
            {
              "query": "#SeveralYears",
              "values": {
                'today': thisMonth,
                'last_month': lastMonth
              }
            }
          ]
        };

        var response = await http.post(
          Uri.parse(url!),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          return Response(500,
            body: json.encode({
              'error': '다년간 통계 조회에 실패했습니다',
              'status_code': response.statusCode
            }),
            headers: {'content-type': 'application/json'}
          );
        }

        var data = jsonDecode(response.body);
        var resultSet = data['results'][0]['resultSet'];

        return Response(200,
          body: json.encode({
            'statistics': resultSet,
            'start_date': lastMonth,
            'end_date': thisMonth,
            'timestamp': DateTime.now().toIso8601String()
          }),
          headers: {'content-type': 'application/json'}
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response(500,
          body: json.encode({
            'error': '서버 내부 오류가 발생했습니다',
            'details': e.toString()
          }),
          headers: {'content-type': 'application/json'}
        );
      }
    });

    return router;
  }
}
