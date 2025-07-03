/// LED 계산 RESTful API
///
/// LED 표시등 계산 및 카메라별 상태 조회 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/led_calculation_service.dart';
import '../data/manage_address.dart';

class LedCalculationApi {
  final LedCalculationService _ledCalculationService;

  LedCalculationApi({required ManageAddress manageAddress})
      : _ledCalculationService =
            LedCalculationService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/led/calculation - LED 계산 수행
    router.get('/calculation', _calculateLedStatus);

    // GET /api/v1/led/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    return router;
  }

  /// LED 계산 수행
  Future<Response> _calculateLedStatus(Request request) async {
    try {
      final serviceResponse = await _ledCalculationService.calculateLedStatus();

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
      print('LedCalculationApi._calculateLedStatus 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'LED 계산 중 서버 오류가 발생했습니다.',
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
      final isHealthy = await _ledCalculationService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'led_calculation',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'led_calculation',
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
      case 'NO_CALCULATION_DATA':
        return 404;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
