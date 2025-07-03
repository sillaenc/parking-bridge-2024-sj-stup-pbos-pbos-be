/// 시스템 상태 확인 RESTful API
///
/// 시스템 생존 확인 및 네트워크 상태 모니터링 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/system_health_service.dart';
import '../data/manage_address.dart';

class SystemHealthApi {
  final SystemHealthService _systemHealthService;

  SystemHealthApi({required ManageAddress manageAddress})
      : _systemHealthService =
            SystemHealthService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/system/health - 전체 시스템 상태 확인
    router.get('/health', _checkSystemHealth);

    // GET /api/v1/system/health/{systemName} - 특정 시스템 상태 확인
    router.get('/health/<systemName>', _checkSpecificSystemHealth);

    // GET /api/v1/system/ping - 간단한 생존 확인 (레거시 호환)
    router.get('/ping', _ping);

    // GET /api/v1/system/status - 서비스 상태 확인
    router.get('/status', _getServiceStatus);

    return router;
  }

  /// 전체 시스템 상태 확인
  Future<Response> _checkSystemHealth(Request request) async {
    try {
      final serviceResponse = await _systemHealthService.checkSystemHealth();

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
    } catch (e, stackTrace) {
      print('SystemHealthApi._checkSystemHealth 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '시스템 상태 확인 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 특정 시스템 상태 확인
  Future<Response> _checkSpecificSystemHealth(
      Request request, String systemName) async {
    try {
      if (systemName.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': '시스템 이름이 필요합니다.',
            'error': 'MISSING_SYSTEM_NAME',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final serviceResponse =
          await _systemHealthService.checkSpecificSystemHealth(systemName);

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
    } catch (e, stackTrace) {
      print('SystemHealthApi._checkSpecificSystemHealth 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '특정 시스템 상태 확인 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 간단한 생존 확인 (레거시 호환)
  Future<Response> _ping(Request request) async {
    try {
      final serviceResponse = await _systemHealthService.checkSystemHealth();

      // 간단한 ping 응답 형식
      if (serviceResponse.success && serviceResponse.data != null) {
        final data = serviceResponse.data!;
        return Response.ok(
          jsonEncode({
            'ping': 'pong',
            'status': data.offlineSystems == 0 ? 'healthy' : 'warning',
            'online_systems': data.onlineSystems,
            'total_systems': data.totalSystems,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.ok(
          jsonEncode({
            'ping': 'pong',
            'status': 'error',
            'message': serviceResponse.message,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response.ok(
        jsonEncode({
          'ping': 'pong',
          'status': 'error',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _getServiceStatus(Request request) async {
    try {
      final isHealthy = await _systemHealthService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'system_health',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'system_health',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 에러 타입에 따른 HTTP 상태 코드 반환
  int _getStatusCodeFromError(String? error) {
    if (error == null) return 500;

    switch (error) {
      case 'MISSING_SYSTEM_NAME':
        return 400;
      case 'SYSTEM_NOT_FOUND':
        return 404;
      case 'NO_SYSTEMS_REGISTERED':
        return 404;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
