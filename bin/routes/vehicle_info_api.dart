/// 차량 정보 조회 RESTful API
///
/// 주차 구역별 차량 정보 및 번호판 기반 차량 위치 조회 API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/vehicle_info_service.dart';
import '../models/vehicle_info_models.dart';
import '../data/manage_address.dart';

class VehicleInfoApi {
  final VehicleInfoService _vehicleInfoService;

  VehicleInfoApi({required ManageAddress manageAddress})
      : _vehicleInfoService = VehicleInfoService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/vehicle/by-tag?tag={tag} - 태그로 차량 정보 조회
    router.get('/by-tag', _getVehicleInfoByTag);

    // GET /api/v1/vehicle/by-plate?plate={plate} - 번호판으로 차량 위치 조회
    router.get('/by-plate', _getVehicleLocationByPlate);

    // POST /api/v1/vehicle/by-tag - 태그로 차량 정보 조회 (POST 방식, 레거시 호환)
    router.post('/by-tag', _postVehicleInfoByTag);

    // POST /api/v1/vehicle/by-plate - 번호판으로 차량 위치 조회 (POST 방식, 레거시 호환)
    router.post('/by-plate', _postVehicleLocationByPlate);

    // GET /api/v1/vehicle/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    return router;
  }

  /// GET 방식으로 태그로 차량 정보 조회
  Future<Response> _getVehicleInfoByTag(Request request) async {
    try {
      final tag = request.url.queryParameters['tag'];
      if (tag == null || tag.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'tag 파라미터가 필요합니다.',
            'error': 'MISSING_TAG_PARAMETER',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final requestModel = VehicleInfoByTagRequest(tag: tag);
      final serviceResponse =
          await _vehicleInfoService.getVehicleInfoByTag(requestModel);

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
      print('VehicleInfoApi._getVehicleInfoByTag 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '차량 정보 조회 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// GET 방식으로 번호판으로 차량 위치 조회
  Future<Response> _getVehicleLocationByPlate(Request request) async {
    try {
      final plate = request.url.queryParameters['plate'];
      if (plate == null || plate.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'plate 파라미터가 필요합니다.',
            'error': 'MISSING_PLATE_PARAMETER',
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final requestModel = VehicleInfoByPlateRequest(plate: plate);
      final serviceResponse =
          await _vehicleInfoService.getVehicleLocationByPlate(requestModel);

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
      print('VehicleInfoApi._getVehicleLocationByPlate 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': '차량 위치 조회 중 서버 오류가 발생했습니다.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST 방식으로 태그로 차량 정보 조회 (레거시 호환)
  Future<Response> _postVehicleInfoByTag(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = VehicleInfoByTagRequest.fromJson(requestData);
      final serviceResponse =
          await _vehicleInfoService.getVehicleInfoByTag(requestModel);

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
      print('VehicleInfoApi._postVehicleInfoByTag 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': '잘못된 요청 형식입니다. JSON 형식으로 tag를 제공해주세요.',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST 방식으로 번호판으로 차량 위치 조회 (레거시 호환)
  Future<Response> _postVehicleLocationByPlate(Request request) async {
    try {
      final payload = await request.readAsString();
      final requestData = jsonDecode(payload);

      final requestModel = VehicleInfoByPlateRequest.fromJson(requestData);
      final serviceResponse =
          await _vehicleInfoService.getVehicleLocationByPlate(requestModel);

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
      print('VehicleInfoApi._postVehicleLocationByPlate 오류: $e');
      print('스택 트레이스: $stackTrace');

      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': '잘못된 요청 형식입니다. JSON 형식으로 plate를 제공해주세요.',
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
      final isHealthy = await _vehicleInfoService.isServiceHealthy();

      return Response.ok(
        jsonEncode({
          'success': true,
          'healthy': isHealthy,
          'service': 'vehicle_info',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'healthy': false,
          'service': 'vehicle_info',
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
      case 'MISSING_TAG':
      case 'MISSING_PLATE':
      case 'INVALID_PLATE_FORMAT':
        return 400;
      case 'TAG_NOT_FOUND':
      case 'VEHICLE_NOT_FOUND':
        return 404;
      case 'DATABASE_ADDRESS_NOT_SET':
        return 503;
      default:
        return 500;
    }
  }
}
