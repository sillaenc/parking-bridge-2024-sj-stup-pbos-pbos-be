/// 모니터링 RESTful API
///
/// 시스템 생존 확인, 서비스 등록, 오류 상태 모니터링 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/monitoring_service.dart';
import '../data/manage_address.dart';

class MonitoringApi {
  final MonitoringService _monitoringService;

  MonitoringApi({required ManageAddress manageAddress})
      : _monitoringService = MonitoringService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/monitoring/health - 전체 시스템 생존 상태 확인
    router.get('/health', _getSystemHealth);

    // POST /api/v1/monitoring/health - 새로운 서비스 URL 등록
    router.post('/health', _registerService);

    // GET /api/v1/monitoring/health/services - 등록된 서비스들의 생존 상태 확인
    router.get('/health/services', _checkRegisteredServices);

    // GET /api/v1/monitoring/health/isalive - 서버 생존 확인 (레거시 호환)
    router.get('/health/isalive', _isAlive);

    // GET /api/v1/monitoring/ping - 데이터베이스 생존 확인
    router.get('/ping', _pingDatabase);

    // GET /api/v1/monitoring/ping/database - 데이터베이스 상세 상태 확인
    router.get('/ping/database', _pingDatabaseDetailed);

    // GET /api/v1/monitoring/errors - 현재 오류 상태 조회
    router.get('/errors', _getErrors);

    // POST /api/v1/monitoring/errors - 오류 보고
    router.post('/errors', _reportError);

    // DELETE /api/v1/monitoring/errors - 오류 목록 초기화
    router.delete('/errors', _clearErrors);

    // GET /api/v1/monitoring/status - 전체 모니터링 상태 요약
    router.get('/status', _getMonitoringStatus);

    // GET /api/v1/monitoring/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 전체 시스템 생존 상태 확인
  Future<Response> _getSystemHealth(Request request) async {
    try {
      final includeDetails =
          request.url.queryParameters['include_details'] == 'true';
      final serviceResponse =
          await _monitoringService.getSystemHealth(includeDetails);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '시스템 생존 상태 확인 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 새로운 서비스 URL 등록
  Future<Response> _registerService(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': '요청 본문이 필요합니다.',
            'error': 'MISSING_REQUEST_BODY',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final key = requestData['key'] as String?;
      final value = requestData['value'] as String?;

      if (key == null || value == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'key와 value 필드가 필요합니다.',
            'error': 'MISSING_REQUIRED_FIELDS',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final serviceResponse =
          await _monitoringService.registerService(key, value);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '서비스 등록 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 등록된 서비스들의 생존 상태 확인
  Future<Response> _checkRegisteredServices(Request request) async {
    try {
      final timeout =
          int.tryParse(request.url.queryParameters['timeout'] ?? '10') ?? 10;
      final serviceResponse =
          await _monitoringService.checkRegisteredServices(timeout);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '등록된 서비스 상태 확인 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서버 생존 확인 (레거시 호환)
  Future<Response> _isAlive(Request request) async {
    return Response.ok(
      jsonEncode({
        'alive': true,
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'server': 'parking_system_api',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 데이터베이스 생존 확인
  Future<Response> _pingDatabase(Request request) async {
    try {
      final serviceResponse = await _monitoringService.pingDatabase();

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '데이터베이스 생존 확인 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 데이터베이스 상세 상태 확인
  Future<Response> _pingDatabaseDetailed(Request request) async {
    try {
      final serviceResponse = await _monitoringService.pingDatabaseDetailed();

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '데이터베이스 상세 상태 확인 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 현재 오류 상태 조회
  Future<Response> _getErrors(Request request) async {
    try {
      final includeResolved =
          request.url.queryParameters['include_resolved'] == 'true';
      final serviceResponse =
          await _monitoringService.getErrors(includeResolved);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '오류 상태 조회 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 오류 보고
  Future<Response> _reportError(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': '요청 본문이 필요합니다.',
            'error': 'MISSING_REQUEST_BODY',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final errorData = jsonDecode(requestBody) as Map<String, dynamic>;
      final serviceResponse = await _monitoringService.reportError(errorData);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '오류 보고 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 오류 목록 초기화
  Future<Response> _clearErrors(Request request) async {
    try {
      final serviceResponse = await _monitoringService.clearErrors();

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '오류 목록 초기화 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 전체 모니터링 상태 요약
  Future<Response> _getMonitoringStatus(Request request) async {
    try {
      final serviceResponse = await _monitoringService.getMonitoringStatus();

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        final statusCode = _getStatusCodeFromError(serviceResponse.error);
        return Response(
          statusCode,
          body: jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '모니터링 상태 조회 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 정보
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'Monitoring API',
        'version': '1.0.0',
        'description': 'RESTful API for system monitoring and health checks',
        'endpoints': {
          'GET /health': 'Get system health status',
          'POST /health': 'Register new service URL',
          'GET /health/services': 'Check registered services status',
          'GET /health/isalive': 'Server alive check (legacy)',
          'GET /ping': 'Database ping check',
          'GET /ping/database': 'Detailed database status',
          'GET /errors': 'Get current errors',
          'POST /errors': 'Report new error',
          'DELETE /errors': 'Clear error list',
          'GET /status': 'Get monitoring status summary',
          'GET /info': 'Service information',
        },
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 에러 타입에 따른 HTTP 상태 코드 반환
  int _getStatusCodeFromError(String? error) {
    if (error == null) return 500;

    switch (error) {
      case 'MISSING_REQUEST_BODY':
      case 'MISSING_REQUIRED_FIELDS':
      case 'INVALID_ERROR_DATA':
        return 400;
      case 'DATABASE_ADDRESS_NOT_SET':
      case 'SERVICE_REGISTRATION_FAILED':
      case 'DATABASE_PING_FAILED':
        return 503;
      case 'NO_SERVICES_REGISTERED':
        return 404;
      default:
        return 500;
    }
  }
}
