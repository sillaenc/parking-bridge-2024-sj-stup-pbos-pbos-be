/// 리소스 관리 RESTful API
///
/// 주차장 리소스 정보 조회 및 관리 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/resource_management_service.dart';
import '../data/manage_address.dart';

class ResourceManagementApi {
  final ResourceManagementService _resourceManagementService;

  ResourceManagementApi({required ManageAddress manageAddress})
      : _resourceManagementService =
            ResourceManagementService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/resources - 주차장 리소스 정보 조회
    router.get('/', _getParkingResources);

    // GET /api/v1/resources/parking-lots - 주차장 목록 조회
    router.get('/parking-lots', _getParkingLotList);

    // GET /api/v1/resources/parking-lots/raw - 원시 데이터 형태로 주차장 목록 조회 (레거시 호환)
    router.get('/parking-lots/raw', _getParkingLotListRaw);

    // POST /api/v1/resources/refresh - 리소스 정보 새로고침
    router.post('/refresh', _refreshResources);

    // GET /api/v1/resources/status - 리소스 상태 조회
    router.get('/status', _getResourceStatus);

    // GET /api/v1/resources/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    // GET /api/v1/resources/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 주차장 리소스 정보 조회
  Future<Response> _getParkingResources(Request request) async {
    try {
      final includeDetails =
          request.url.queryParameters['include_details'] == 'true';
      final serviceResponse =
          await _resourceManagementService.getParkingResources(includeDetails);

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
          'message': '리소스 정보 조회 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 주차장 목록 조회
  Future<Response> _getParkingLotList(Request request) async {
    try {
      final forceRefresh =
          request.url.queryParameters['force_refresh'] == 'true';
      final serviceResponse =
          await _resourceManagementService.getParkingLotList(forceRefresh);

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
          'message': '주차장 목록 조회 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 원시 데이터 형태로 주차장 목록 조회 (레거시 호환)
  Future<Response> _getParkingLotListRaw(Request request) async {
    try {
      final serviceResponse =
          await _resourceManagementService.getParkingLotListRaw();

      if (serviceResponse.success) {
        // 레거시 형식: "start,data1,data2,data3..."
        return Response.ok(
          serviceResponse.data ?? '',
          headers: {'Content-Type': 'text/plain'},
        );
      } else {
        return Response.internalServerError(
          body: 'An error occurred: ${serviceResponse.message}',
        );
      }
    } catch (e) {
      return Response.internalServerError(
        body: 'An error occurred: $e',
      );
    }
  }

  /// 리소스 정보 새로고침
  Future<Response> _refreshResources(Request request) async {
    try {
      final requestBody = await request.readAsString();
      Map<String, dynamic>? refreshConfig;

      if (requestBody.isNotEmpty) {
        refreshConfig = jsonDecode(requestBody) as Map<String, dynamic>;
      }

      final serviceResponse =
          await _resourceManagementService.refreshResources(refreshConfig);

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
          'message': '리소스 새로고침 중 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 리소스 상태 조회
  Future<Response> _getResourceStatus(Request request) async {
    try {
      final serviceResponse =
          await _resourceManagementService.getResourceStatus();

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
          'message': '리소스 상태 조회 중 오류가 발생했습니다.',
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
      final isHealthy = await _resourceManagementService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'resource_management',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'resource_management',
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
        'service': 'Resource Management API',
        'version': '1.0.0',
        'description': 'RESTful API for parking resource management',
        'endpoints': {
          'GET /': 'Get parking resources information',
          'GET /parking-lots': 'Get parking lot list',
          'GET /parking-lots/raw':
              'Get parking lot list in raw format (legacy)',
          'POST /refresh': 'Refresh resource information',
          'GET /status': 'Get resource status',
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
      case 'DATABASE_ADDRESS_NOT_SET':
      case 'ENGINE_DB_ADDRESS_NOT_SET':
      case 'DISPLAY_DB_ADDRESS_NOT_SET':
        return 503;
      case 'INVALID_REFRESH_CONFIG':
        return 400;
      case 'RESOURCE_FETCH_FAILED':
      case 'ENGINE_DATA_PROCESSING_FAILED':
        return 503;
      default:
        return 500;
    }
  }
}
