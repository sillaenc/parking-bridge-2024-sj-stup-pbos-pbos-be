/// 통계 조회 RESTful API 라우트
/// 기존 statistics_cam_parking_area.dart를 RESTful API로 리팩토링

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/statistics_service.dart';
import '../services/database_client.dart';
import '../data/manage_address.dart';

/// 통계 API 라우터 클래스
class StatisticsApi {
  final StatisticsService _statisticsService;

  StatisticsApi({required ManageAddress manageAddress})
      : _statisticsService = StatisticsService(
          databaseClient: DatabaseClient(),
          databaseUrl: manageAddress.displayDbAddr!,
        );

  /// 라우터 설정
  Router get router {
    final router = Router();

    // 일별 통계 API
    router.get('/daily', _handleDailyStatistics);
    router.get('/daily/all', _handleDailyAllStatistics);

    // 주별 통계 API
    router.get('/weekly', _handleWeeklyStatistics);

    // 월별 통계 API
    router.get('/monthly', _handleMonthlyStatistics);
    router.get('/monthly/all', _handleMonthlyAllStatistics);

    // 연별 통계 API
    router.get('/yearly', _handleYearlyStatistics);
    router.get('/yearly/all', _handleYearlyAllStatistics);

    // 다년도 통계 API
    router.get('/several-years', _handleSeveralYearsStatistics);
    router.get('/several-years/all', _handleSeveralYearsAllStatistics);

    // 사용자 정의 기간 통계 API
    router.post('/custom-period', _handleCustomPeriodStatistics);

    // 그래프용 통계 API
    router.post('/graph', _handleGraphStatistics);

    // 헬스 체크 API
    router.get('/health', _handleHealthCheck);

    // 통계 정보 API
    router.get('/info', _handleStatisticsInfo);

    return router;
  }

  /// 일별 통계 조회 (전일 대비)
  Future<Response> _handleDailyStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneDayStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '일별 통계 조회');
    }
  }

  /// 일별 전체 통계 조회
  Future<Response> _handleDailyAllStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneDayAllStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '일별 전체 통계 조회');
    }
  }

  /// 주별 통계 조회
  Future<Response> _handleWeeklyStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneWeekStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '주별 통계 조회');
    }
  }

  /// 월별 통계 조회 (전월 대비)
  Future<Response> _handleMonthlyStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneMonthStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '월별 통계 조회');
    }
  }

  /// 월별 전체 통계 조회
  Future<Response> _handleMonthlyAllStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneMonthAllStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '월별 전체 통계 조회');
    }
  }

  /// 연별 통계 조회 (전년 대비)
  Future<Response> _handleYearlyStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneYearStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '연별 통계 조회');
    }
  }

  /// 연별 전체 통계 조회
  Future<Response> _handleYearlyAllStatistics(Request request) async {
    try {
      final result = await _statisticsService.getOneYearAllStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '연별 전체 통계 조회');
    }
  }

  /// 다년도 통계 조회
  Future<Response> _handleSeveralYearsStatistics(Request request) async {
    try {
      final result = await _statisticsService.getSeveralYearsStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '다년도 통계 조회');
    }
  }

  /// 다년도 전체 통계 조회
  Future<Response> _handleSeveralYearsAllStatistics(Request request) async {
    try {
      final result = await _statisticsService.getSeveralYearsAllStatistics();

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '다년도 전체 통계 조회');
    }
  }

  /// 사용자 정의 기간 통계 조회
  Future<Response> _handleCustomPeriodStatistics(Request request) async {
    try {
      final requestBody = await request.readAsString();
      print('[Statistics] Custom Period Request Body: $requestBody');
      
      final requestData = jsonDecode(requestBody);

      // startDate/endDate 파라미터 지원 (권장) + 레거시 startDay/endDay도 지원
      final startDate = requestData['startDate'] as String? ?? requestData['startDay'] as String?;
      final endDate = requestData['endDate'] as String? ?? requestData['endDay'] as String?;

      if (startDate == null || endDate == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'startDate와 endDate는 필수 파라미터입니다.',
            'code': 'MISSING_PARAMETERS',
            'hint': '예시: {"startDate": "2025-11-04", "endDate": "2025-11-05"}'
          }),
          headers: _getDefaultHeaders(),
        );
      }

      print('[Statistics] Custom Period - startDate: $startDate, endDate: $endDate');

      final result = await _statisticsService.getCustomPeriodStatistics(
        startDate,
        endDate,
      );

      print('[Statistics] Custom Period - Result count: ${result.data.length}');

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '사용자 정의 기간 통계 조회');
    }
  }

  /// 그래프용 통계 조회
  Future<Response> _handleGraphStatistics(Request request) async {
    try {
      final requestBody = await request.readAsString();
      print('[Statistics] Graph Request Body: $requestBody');
      
      final requestData = jsonDecode(requestBody);

      // startDate/endDate 파라미터 지원 (권장) + 레거시 startDay/endDay도 지원
      final startDate = requestData['startDate'] as String? ?? requestData['startDay'] as String?;
      final endDate = requestData['endDate'] as String? ?? requestData['endDay'] as String?;

      if (startDate == null || endDate == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'startDate와 endDate는 필수 파라미터입니다.',
            'code': 'MISSING_PARAMETERS',
            'hint': '예시: {"startDate": "2025-11-04", "endDate": "2025-11-05"}'
          }),
          headers: _getDefaultHeaders(),
        );
      }

      // 레거시 API와 동일하게 시간 추가 (00시 ~ 23시)
      final startDateWithTime = '$startDate 00';
      final endDateWithTime = '$endDate 23';
      
      print('[Statistics] Graph - startDate: $startDateWithTime, endDate: $endDateWithTime');

      final result = await _statisticsService.getGraphStatistics(
        startDateWithTime,
        endDateWithTime,
      );

      print('[Statistics] Graph - Result count: ${result.data.length}');

      return Response.ok(
        jsonEncode(result.data),
        headers: _getDefaultHeaders(),
      );
    } on StatisticsServiceException catch (e) {
      return _handleServiceError(e);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(e, stackTrace, '그래프 통계 조회');
    }
  }

  /// 헬스 체크
  Future<Response> _handleHealthCheck(Request request) async {
    try {
      final isHealthy = await _statisticsService.isHealthy();

      return Response.ok(
        jsonEncode({
          'status': isHealthy ? 'healthy' : 'unhealthy',
          'timestamp': DateTime.now().toIso8601String(),
          'service': 'statistics',
        }),
        headers: _getDefaultHeaders(),
      );
    } catch (e, stackTrace) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'unhealthy',
          'timestamp': DateTime.now().toIso8601String(),
          'service': 'statistics',
          'error': e.toString(),
        }),
        headers: _getDefaultHeaders(),
      );
    }
  }

  /// 통계 서비스 정보
  Future<Response> _handleStatisticsInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'Statistics API',
        'version': '1.0.0',
        'description': '주차장 통계 조회 서비스',
        'endpoints': {
          'GET /daily': '일별 통계 (전일 대비)',
          'GET /daily/all': '일별 전체 통계',
          'GET /weekly': '주별 통계',
          'GET /monthly': '월별 통계 (전월 대비)',
          'GET /monthly/all': '월별 전체 통계',
          'GET /yearly': '연별 통계 (전년 대비)',
          'GET /yearly/all': '연별 전체 통계',
          'GET /several-years': '다년도 통계',
          'GET /several-years/all': '다년도 전체 통계',
          'POST /custom-period': '사용자 정의 기간 통계',
          'POST /graph': '그래프용 통계',
          'GET /health': '서비스 상태 확인',
          'GET /info': '서비스 정보'
        },
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: _getDefaultHeaders(),
    );
  }

  /// 기본 응답 헤더 설정
  Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
    };
  }

  /// 서비스 에러 처리
  Response _handleServiceError(StatisticsServiceException e) {
    print('StatisticsServiceException: ${e.message}');
    if (e.details != null) {
      print('Details: ${e.details}');
    }

    return Response.internalServerError(
      body: jsonEncode({
        'error': e.message,
        'code': 'SERVICE_ERROR',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: _getDefaultHeaders(),
    );
  }

  /// 예상치 못한 에러 처리
  Response _handleUnexpectedError(
      dynamic error, StackTrace stackTrace, String operation) {
    print('Unexpected error in $operation: $error');
    print('StackTrace: $stackTrace');

    return Response.internalServerError(
      body: jsonEncode({
        'error': '$operation 중 오류가 발생했습니다.',
        'code': 'INTERNAL_ERROR',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: _getDefaultHeaders(),
    );
  }

  /// 리소스 정리
  void dispose() {
    _statisticsService.dispose();
  }
}
