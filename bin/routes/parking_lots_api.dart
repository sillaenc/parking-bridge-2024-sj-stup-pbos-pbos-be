import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/parking_zone_models.dart';
import '../services/parking_zone_service.dart';
import '../data/manage_address.dart';

/// 주차 공간 관리 전용 RESTful API
/// 경로: /api/v1/parking-lots/*
class ParkingLotsApi {
  final ParkingZoneService _parkingZoneService;

  /// ParkingLotsApi 생성자
  ParkingLotsApi({required ManageAddress manageAddress})
      : _parkingZoneService = ParkingZoneService(manageAddress: manageAddress);

  /// 주차 공간 API 라우터 생성
  Router get router {
    final router = Router();

    // PATCH /api/v1/parking-lots/{tag}/type - 주차 공간 유형 변경
    router.patch('/<tag>/type', _changeLotType);

    // PATCH /api/v1/parking-lots/{tag}/status - 주차 상태 변경
    router.patch('/<tag>/status', _changeParkingStatus);

    // GET /api/v1/parking-lots/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    // GET /api/v1/parking-lots/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 주차 공간 유형 변경
  Future<Response> _changeLotType(Request request) async {
    try {
      final tag = request.params['tag']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 tag를 requestData에 추가
      requestData['tag'] = tag;

      final lotTypeRequest = LotTypeChangeRequest.fromJson(requestData);
      final result = await _parkingZoneService.changeLotType(lotTypeRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': 'Invalid JSON format',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 주차 상태 변경
  Future<Response> _changeParkingStatus(Request request) async {
    try {
      final tag = request.params['tag']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 tag를 requestData에 추가
      requestData['tag'] = tag;

      final statusRequest = ParkingStatusChangeRequest.fromJson(requestData);
      final result =
          await _parkingZoneService.changeParkingStatus(statusRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': 'Invalid JSON format',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final status = await _parkingZoneService.getServiceStatus();

      return Response.ok(
        jsonEncode(status),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'unhealthy',
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
        'service': 'Parking Lots Management API',
        'version': '1.0.0',
        'description': 'RESTful API for individual parking lot management',
        'endpoints': {
          'PATCH /{tag}/type':
              'Change parking lot type (normal, disabled, electric, etc.)',
          'PATCH /{tag}/status': 'Change parking status (occupied, available)',
          'GET /health': 'Service health check',
          'GET /info': 'Service information'
        },
        'supportedTypes': [
          'normal (일반)',
          'disabled (장애인)',
          'electric (전기차)',
          'compact (경차)',
          'pregnant (임산부)',
          'senior (고령자)'
        ],
        'supportedStatuses': [
          'available (이용 가능)',
          'occupied (사용 중)',
          'reserved (예약)',
          'maintenance (정비 중)',
          'blocked (차단됨)'
        ],
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// ParkingZoneServiceException 처리
  Response _handleParkingZoneServiceException(ParkingZoneServiceException e) {
    int statusCode;
    switch (e.errorCode) {
      case ParkingZoneConstants.errorZoneNotFound:
        statusCode = 404;
        break;
      case ParkingZoneConstants.errorZoneExists:
        statusCode = 409;
        break;
      case ParkingZoneConstants.errorValidationFailed:
        statusCode = 400;
        break;
      default:
        statusCode = 500;
    }

    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}





