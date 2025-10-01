/// 중앙 대시보드 RESTful API
///
/// 주차장 전체 현황 및 통계 정보를 제공하는 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/central_dashboard_service.dart';
import '../data/manage_address.dart';

class CentralDashboardApi {
  final CentralDashboardService _centralDashboardService;

  CentralDashboardApi({required ManageAddress manageAddress})
      : _centralDashboardService =
            CentralDashboardService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/central/dashboard - 중앙 대시보드 데이터 조회
    router.get('/dashboard', _getDashboardData);

    // GET /api/v1/central/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    // GET /api/v1/central/info - 서비스 정보 조회
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 중앙 대시보드 데이터 조회
  ///
  /// 주차장 전체 통계, 층별 정보, 타입별 정보, 점유율 데이터를 종합적으로 제공
  Future<Response> _getDashboardData(Request request) async {
    try {
      final serviceResponse = await _centralDashboardService.getDashboardData();

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': serviceResponse.message,
            'error': serviceResponse.error,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e, stackTrace) {
      print('CentralDashboardApi._getDashboardData 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '중앙 대시보드 데이터 조회 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  ///
  /// 중앙 대시보드 서비스의 건강 상태를 확인
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final isHealthy = await _centralDashboardService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'central_dashboard',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'central_dashboard',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 정보 조회
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'success': true,
        'service': 'Central Dashboard API',
        'version': '1.0.0',
        'description': '주차장 전체 현황 및 통계 정보를 제공하는 API',
        'endpoints': {
          'GET /dashboard': '중앙 대시보드 데이터 조회',
          'GET /health': '서비스 상태 확인',
          'GET /info': '서비스 정보 조회'
        },
        'features': [
          '실시간 주차 통계',
          '층별 점유율 분석',
          '주차 공간 타입별 현황',
          '전체 시스템 모니터링'
        ],
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
