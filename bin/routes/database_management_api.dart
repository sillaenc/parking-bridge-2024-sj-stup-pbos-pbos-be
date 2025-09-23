/// 데이터베이스 관리 RESTful API
///
/// 엔진 DB 및 디스플레이 DB 설정 관리 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_management_service.dart';
import '../data/manage_address.dart';

class DatabaseManagementApi {
  final DatabaseManagementService _databaseManagementService;

  DatabaseManagementApi({required ManageAddress manageAddress})
      : _databaseManagementService =
            DatabaseManagementService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/settings/database/config - 현재 데이터베이스 설정 조회
    router.get('/config', _getDatabaseConfig);

    // PUT /api/v1/settings/database/engine - 엔진 DB 설정 업데이트
    router.put('/engine', _updateEngineDatabase);

    // PUT /api/v1/settings/database/display - 디스플레이 DB 설정 업데이트
    router.put('/display', _updateDisplayDatabase);

    // PUT /api/v1/settings/database/config - 전체 데이터베이스 설정 업데이트
    router.put('/config', _updateDatabaseConfig);

    // POST /api/v1/settings/database/test-connection - 데이터베이스 연결 테스트
    router.post('/test-connection', _testDatabaseConnection);

    // GET /api/v1/settings/database/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    // GET /api/v1/settings/database/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 현재 데이터베이스 설정 조회
  Future<Response> _getDatabaseConfig(Request request) async {
    try {
      final serviceResponse =
          await _databaseManagementService.getDatabaseConfig();

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
          'message': '데이터베이스 설정 조회 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 엔진 DB 설정 업데이트
  Future<Response> _updateEngineDatabase(Request request) async {
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
      final engineDb = requestData['engineDb'] as String?;

      if (engineDb == null || engineDb.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'engineDb 필드가 필요합니다.',
            'error': 'MISSING_ENGINE_DB',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final serviceResponse =
          await _databaseManagementService.updateEngineDatabase(engineDb);

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
          'message': '엔진 DB 설정 업데이트 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 디스플레이 DB 설정 업데이트
  Future<Response> _updateDisplayDatabase(Request request) async {
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
      final displayDb = requestData['displayDb'] as String?;

      if (displayDb == null || displayDb.trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'displayDb 필드가 필요합니다.',
            'error': 'MISSING_DISPLAY_DB',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final serviceResponse =
          await _databaseManagementService.updateDisplayDatabase(displayDb);

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
          'message': '디스플레이 DB 설정 업데이트 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 전체 데이터베이스 설정 업데이트
  Future<Response> _updateDatabaseConfig(Request request) async {
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
      final serviceResponse =
          await _databaseManagementService.updateDatabaseConfig(requestData);

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
          'message': '데이터베이스 설정 업데이트 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 데이터베이스 연결 테스트
  Future<Response> _testDatabaseConnection(Request request) async {
    try {
      final requestBody = await request.readAsString();
      Map<String, dynamic>? testConfig;

      if (requestBody.isNotEmpty) {
        testConfig = jsonDecode(requestBody) as Map<String, dynamic>;
      }

      final serviceResponse =
          await _databaseManagementService.testDatabaseConnection(testConfig);

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
          'message': '데이터베이스 연결 테스트 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final isHealthy = await _databaseManagementService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'database_management',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'database_management',
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
        'service': 'Database Management API',
        'version': '1.0.0',
        'description': 'RESTful API for database configuration management',
        'endpoints': {
          'GET /config': 'Get current database configuration',
          'PUT /engine': 'Update engine database settings',
          'PUT /display': 'Update display database settings',
          'PUT /config': 'Update complete database configuration',
          'POST /test-connection': 'Test database connection',
          'GET /health': 'Service health check',
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
      case 'MISSING_ENGINE_DB':
      case 'MISSING_DISPLAY_DB':
      case 'INVALID_DATABASE_URL':
        return 400;
      case 'DATABASE_CONNECTION_FAILED':
        return 503;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
