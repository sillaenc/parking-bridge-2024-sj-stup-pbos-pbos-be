/// 디스플레이 RESTful API
///
/// 디스플레이 정보 조회 및 대량 업데이트 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/display_service.dart';
import '../models/display_models.dart';
import '../data/manage_address.dart';

class DisplayApi {
  final DisplayService _displayService;

  DisplayApi({required ManageAddress manageAddress})
      : _displayService = DisplayService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/display/info?floors={floors} - 층별 디스플레이 정보 조회
    router.get('/info', _getDisplayInfo);

    // POST /api/v1/display/info - 층별 디스플레이 정보 조회 (POST 방식, 레거시 호환)
    router.post('/info', _postDisplayInfo);

    // POST /api/v1/display/bulk-update - 대량 디스플레이 업데이트
    router.post('/bulk-update', _bulkUpdateDisplay);

    // GET /api/v1/display/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    return router;
  }

  /// GET 방식으로 디스플레이 정보 조회
  Future<Response> _getDisplayInfo(Request request) async {
    try {
      final floors = request.url.queryParameters['floors'] ??
          request.url.queryParameters['floor'];
      if (floors == null || floors.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'floors 또는 floor 파라미터가 필요합니다.',
            'error': 'MISSING_FLOORS_PARAMETER',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final requestModel = DisplayInfoRequest(floors: floors);
      final serviceResponse =
          await _displayService.getDisplayInfo(requestModel);

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
      print('DisplayApi._getDisplayInfo 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '디스플레이 정보 조회 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST 방식으로 디스플레이 정보 조회 (레거시 호환)
  Future<Response> _postDisplayInfo(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = DisplayInfoRequest.fromJson(requestData);
      final serviceResponse =
          await _displayService.getDisplayInfo(requestModel);

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
      print('DisplayApi._postDisplayInfo 오류: $e');
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

  /// 대량 디스플레이 업데이트
  Future<Response> _bulkUpdateDisplay(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = BulkDisplayUpdateRequest.fromJson(requestData);
      final serviceResponse =
          await _displayService.bulkUpdateDisplay(requestModel);

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
      print('DisplayApi._bulkUpdateDisplay 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': '잘못된 요청 형식입니다. JSON 형식으로 tb_lots를 제공해주세요.',
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
      final isHealthy = await _displayService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'display',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'display',
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
      case 'MISSING_FLOORS':
      case 'MISSING_TB_LOTS_DATA':
        return 400;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
