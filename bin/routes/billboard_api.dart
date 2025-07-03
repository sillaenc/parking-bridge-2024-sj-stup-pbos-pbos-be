/// 전광판 RESTful API
///
/// 전광판 표시 정보 조회 및 부분 시스템 제어 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/billboard_service.dart';
import '../models/billboard_models.dart';
import '../data/manage_address.dart';

class BillboardApi {
  final BillboardService _billboardService;

  BillboardApi({required ManageAddress manageAddress})
      : _billboardService = BillboardService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/billboard/floor/{floor} - 층별 주차 정보 조회
    router.get('/floor/<floor>', _getFloorParkingInfo);

    // POST /api/v1/billboard/floor - 층별 주차 정보 조회 (POST 방식, 레거시 호환)
    router.post('/floor', _postFloorParkingInfo);

    // POST /api/v1/billboard/part-system/control - 부분 시스템 제어
    router.post('/part-system/control', _controlPartSystem);

    // GET /api/v1/billboard/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    return router;
  }

  /// GET 방식으로 층별 주차 정보 조회
  Future<Response> _getFloorParkingInfo(Request request, String floor) async {
    try {
      if (floor.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': '층 정보가 필요합니다.',
            'error': 'MISSING_FLOOR_PARAMETER',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final requestModel = FloorParkingInfoRequest(floor: floor);
      final serviceResponse =
          await _billboardService.getFloorParkingInfo(requestModel);

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
      print('BillboardApi._getFloorParkingInfo 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '층별 주차 정보 조회 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST 방식으로 층별 주차 정보 조회 (레거시 호환)
  Future<Response> _postFloorParkingInfo(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = FloorParkingInfoRequest.fromJson(requestData);
      final serviceResponse =
          await _billboardService.getFloorParkingInfo(requestModel);

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
      print('BillboardApi._postFloorParkingInfo 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': '잘못된 요청 형식입니다. JSON 형식으로 floor를 제공해주세요.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 부분 시스템 제어
  Future<Response> _controlPartSystem(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = PartSystemControlRequest.fromJson(requestData);
      final serviceResponse =
          await _billboardService.controlPartSystem(requestModel);

      if (serviceResponse.success) {
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // 부분적 성공도 200으로 처리하되, 성공률 정보 포함
        return Response.ok(
          jsonEncode(serviceResponse.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e, stackTrace) {
      print('BillboardApi._controlPartSystem 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': '잘못된 요청 형식입니다. JSON 형식으로 value를 제공해주세요.',
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
      final isHealthy = await _billboardService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'billboard',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'billboard',
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
      case 'MISSING_FLOOR':
      case 'MISSING_VALUE':
        return 400;
      case 'FLOOR_NOT_FOUND':
      case 'NO_ACTIVE_ENDPOINTS':
        return 404;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
