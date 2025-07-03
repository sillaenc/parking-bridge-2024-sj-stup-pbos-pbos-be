import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/electric_sign_models.dart';
import '../services/electric_sign_service.dart';
import '../services/database_client.dart';
import '../data/manage_address.dart';

/// 다중 전광판 관련 RESTful API
class ElectricSignApi {
  final ElectricSignService _electricSignService;
  final ManageAddress _manageAddress;

  /// ElectricSignApi 생성자
  ElectricSignApi({required ManageAddress manageAddress})
      : _manageAddress = manageAddress,
        _electricSignService = ElectricSignService(DatabaseClient());

  /// 전광판 API 라우터 생성
  Router get router {
    final router = Router();

    // GET /api/v1/parking/electric-signs - 모든 전광판 조회
    router.get('/', _handleGetAllElectricSigns);

    // GET /api/v1/parking/electric-signs/{uid} - 특정 전광판 조회
    router.get('/<uid>', _handleGetElectricSignByUid);

    // POST /api/v1/parking/electric-signs - 새 전광판 생성
    router.post('/', _handleCreateElectricSign);

    // PUT /api/v1/parking/electric-signs/{uid} - 전광판 업데이트
    router.put('/<uid>', _handleUpdateElectricSign);

    // DELETE /api/v1/parking/electric-signs/{uid} - 전광판 삭제
    router.delete('/<uid>', _handleDeleteElectricSign);

    // GET /api/v1/parking/electric-signs/statistics - 전광판 통계 조회
    router.get('/statistics', _handleGetElectricSignStatistics);

    // GET /api/v1/parking/electric-signs/parking-lot/{parkingLot} - 주차장별 전광판 조회
    router.get(
        '/parking-lot/<parkingLot>', _handleGetElectricSignsByParkingLot);

    // GET /api/v1/parking/electric-signs/health - 서비스 상태 확인
    router.get('/health', _handleHealthCheck);

    // GET /api/v1/parking/electric-signs/info - 서비스 정보 조회
    router.get('/info', _handleServiceInfo);

    return router;
  }

  /// 레거시 API 라우터 (기존 클라이언트 호환용)
  Router get legacyRouter {
    final router = Router();

    // GET / - 기존 모든 전광판 조회 API
    router.get('/', _handleLegacyGetAll);

    // POST /update - 기존 전광판 업데이트 API
    router.post('/update', _handleLegacyUpdate);

    // POST /insert - 기존 전광판 생성 API
    router.post('/insert', _handleLegacyInsert);

    // POST /deleteZone - 기존 전광판 삭제 API
    router.post('/deleteZone', _handleLegacyDelete);

    return router;
  }

  /// 모든 전광판 조회
  Future<Response> _handleGetAllElectricSigns(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _electricSignService.getAllElectricSigns(databaseUrl);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.map((sign) => sign.toJson()).toList(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in get all electric signs: $e');
      return _createErrorResponse(
        'Failed to retrieve electric signs',
        statusCode: 500,
      );
    }
  }

  /// 특정 UID의 전광판 조회
  Future<Response> _handleGetElectricSignByUid(Request request) async {
    try {
      final uidStr = request.params['uid'];
      if (uidStr == null) {
        return _createErrorResponse(
          'UID parameter is required',
          statusCode: 400,
        );
      }

      final uid = int.tryParse(uidStr);
      if (uid == null) {
        return _createErrorResponse(
          'Invalid UID format: must be an integer',
          errorCode: ElectricSignConstants.errorInvalidUid,
          statusCode: 400,
        );
      }

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _electricSignService.getElectricSignByUid(databaseUrl, uid);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.toJson(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in get electric sign by UID: $e');
      return _createErrorResponse(
        'Failed to retrieve electric sign',
        statusCode: 500,
      );
    }
  }

  /// 새 전광판 생성
  Future<Response> _handleCreateElectricSign(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final createRequest = CreateElectricSignRequest.fromJson(requestData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      // 입력 데이터 정리
      final sanitizedRequest =
          _electricSignService.sanitizeCreateRequest(createRequest);

      final result = await _electricSignService.createElectricSign(
          databaseUrl, sanitizedRequest);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.toJson(),
          statusCode: 201,
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in create electric sign: $e');
      return _createErrorResponse(
        'Invalid request format',
        errorCode: ElectricSignConstants.errorValidationFailed,
        statusCode: 400,
      );
    }
  }

  /// 전광판 업데이트
  Future<Response> _handleUpdateElectricSign(Request request) async {
    try {
      final uidStr = request.params['uid'];
      if (uidStr == null) {
        return _createErrorResponse(
          'UID parameter is required',
          statusCode: 400,
        );
      }

      final uid = int.tryParse(uidStr);
      if (uid == null) {
        return _createErrorResponse(
          'Invalid UID format: must be an integer',
          errorCode: ElectricSignConstants.errorInvalidUid,
          statusCode: 400,
        );
      }

      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final updateRequest = UpdateElectricSignRequest.fromJson(requestData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      // 입력 데이터 정리
      final sanitizedRequest =
          _electricSignService.sanitizeUpdateRequest(updateRequest);

      final result = await _electricSignService.updateElectricSign(
          databaseUrl, uid, sanitizedRequest);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.toJson(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in update electric sign: $e');
      return _createErrorResponse(
        'Invalid request format',
        errorCode: ElectricSignConstants.errorValidationFailed,
        statusCode: 400,
      );
    }
  }

  /// 전광판 삭제
  Future<Response> _handleDeleteElectricSign(Request request) async {
    try {
      final uidStr = request.params['uid'];
      if (uidStr == null) {
        return _createErrorResponse(
          'UID parameter is required',
          statusCode: 400,
        );
      }

      final uid = int.tryParse(uidStr);
      if (uid == null) {
        return _createErrorResponse(
          'Invalid UID format: must be an integer',
          errorCode: ElectricSignConstants.errorInvalidUid,
          statusCode: 400,
        );
      }

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _electricSignService.deleteElectricSign(databaseUrl, uid);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in delete electric sign: $e');
      return _createErrorResponse(
        'Failed to delete electric sign',
        statusCode: 500,
      );
    }
  }

  /// 전광판 통계 조회
  Future<Response> _handleGetElectricSignStatistics(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _electricSignService.getElectricSignStatistics(databaseUrl);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.toJson(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in get electric sign statistics: $e');
      return _createErrorResponse(
        'Failed to retrieve electric sign statistics',
        statusCode: 500,
      );
    }
  }

  /// 주차장별 전광판 조회
  Future<Response> _handleGetElectricSignsByParkingLot(Request request) async {
    try {
      final parkingLot = request.params['parkingLot'];
      if (parkingLot == null || parkingLot.trim().isEmpty) {
        return _createErrorResponse(
          'Parking lot parameter is required',
          statusCode: 400,
        );
      }

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result = await _electricSignService.getElectricSignsByParkingLot(
          databaseUrl, Uri.decodeComponent(parkingLot));

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data?.map((sign) => sign.toJson()).toList(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('Error in get electric signs by parking lot: $e');
      return _createErrorResponse(
        'Failed to retrieve electric signs by parking lot',
        statusCode: 500,
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _handleHealthCheck(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final healthInfo =
          await _electricSignService.getServiceHealth(databaseUrl);

      final isHealthy = healthInfo['status'] == 'healthy';
      final statusCode = isHealthy ? 200 : 503;

      return Response(
        statusCode,
        body: jsonEncode(healthInfo),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in health check: $e');
      return _createErrorResponse(
        'Health check failed',
        statusCode: 500,
      );
    }
  }

  /// 서비스 정보 조회
  Future<Response> _handleServiceInfo(Request request) async {
    final serviceInfo = _electricSignService.getServiceInfo();

    return _createSuccessResponse(
      message: 'Service information retrieved',
      data: serviceInfo,
    );
  }

  // === 레거시 API 핸들러들 (기존 클라이언트 호환용) ===

  /// 레거시 모든 전광판 조회 API (기존 형식 응답)
  Future<Response> _handleLegacyGetAll(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
            body: 'Database configuration not available');
      }

      final result =
          await _electricSignService.getAllElectricSigns(databaseUrl);

      if (result.success) {
        // 기존 형식으로 응답 (배열을 직접 JSON으로)
        final signsList =
            result.data!.map((sign) => sign.toDatabaseJson()).toList();
        return Response.ok(jsonEncode(signsList));
      } else {
        return Response.internalServerError(body: 'Error: ${result.message}');
      }
    } catch (e) {
      print('Error in legacy get all: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시 전광판 업데이트 API (기존 형식 응답)
  Future<Response> _handleLegacyUpdate(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final uid = requestData['uid'] as int;
      final parkingLot = requestData['parking_lot'] as String;

      final updateRequest = UpdateElectricSignRequest(parkingLot: parkingLot);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
            body: 'Database configuration not available');
      }

      final result = await _electricSignService.updateElectricSign(
          databaseUrl, uid, updateRequest);

      if (result.success) {
        return Response.ok("update success");
      } else {
        return Response.internalServerError(body: 'Error: ${result.message}');
      }
    } catch (e) {
      print('Error in legacy update: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시 전광판 생성 API (기존 형식 응답)
  Future<Response> _handleLegacyInsert(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final uid = requestData['uid'] as int;
      final parkingLot = requestData['parking_lot'] as String;

      final createRequest =
          CreateElectricSignRequest(uid: uid, parkingLot: parkingLot);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
            body: 'Database configuration not available');
      }

      final result = await _electricSignService.createElectricSign(
          databaseUrl, createRequest);

      if (result.success) {
        return Response(200, body: 'Inserted successfully');
      } else {
        if (result.errorCode == ElectricSignConstants.errorSignExists) {
          return Response(409, body: 'UID already exists');
        } else {
          return Response.internalServerError(body: 'Error: ${result.message}');
        }
      }
    } catch (e) {
      print('Error in legacy insert: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시 전광판 삭제 API (기존 형식 응답)
  Future<Response> _handleLegacyDelete(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final uid = requestData['uid'] as int;

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
            body: 'Database configuration not available');
      }

      final result =
          await _electricSignService.deleteElectricSign(databaseUrl, uid);

      if (result.success) {
        return Response.ok("delete success");
      } else {
        return Response.internalServerError(body: 'Error: ${result.message}');
      }
    } catch (e) {
      print('Error in legacy delete: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  // === 유틸리티 메서드들 ===

  /// 성공 응답 생성
  Response _createSuccessResponse({
    required String message,
    dynamic data,
    int statusCode = 200,
  }) {
    final responseBody = <String, dynamic>{
      'success': true,
      'message': message,
    };

    if (data != null) {
      responseBody['data'] = data;
    }

    return Response(
      statusCode,
      body: jsonEncode(responseBody),
      headers: _getCorsHeaders(),
    );
  }

  /// 에러 응답 생성
  Response _createErrorResponse(
    String message, {
    String? errorCode,
    int statusCode = 500,
  }) {
    final responseBody = <String, dynamic>{
      'success': false,
      'message': message,
    };

    if (errorCode != null) {
      responseBody['errorCode'] = errorCode;
    }

    return Response(
      statusCode,
      body: jsonEncode(responseBody),
      headers: _getCorsHeaders(),
    );
  }

  /// 에러 코드에 따른 HTTP 상태 코드 결정
  int _getStatusCodeFromError(String? errorCode) {
    switch (errorCode) {
      case ElectricSignConstants.errorValidationFailed:
      case ElectricSignConstants.errorInvalidUid:
      case ElectricSignConstants.errorEmptyParkingLot:
        return 400;
      case ElectricSignConstants.errorSignNotFound:
        return 404;
      case ElectricSignConstants.errorSignExists:
        return 409;
      case ElectricSignConstants.errorDatabaseOperation:
        return 500;
      default:
        return 500;
    }
  }

  /// CORS 헤더 생성
  Map<String, String> _getCorsHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };
  }
}
