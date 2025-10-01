import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/base_information_models.dart';
import '../services/base_information_service.dart';
import '../services/database_client.dart';
import '../data/manage_address.dart';

/// 주차장 기본 정보 관련 RESTful API
class BaseInformationApi {
  final BaseInformationService _baseInformationService;
  final ManageAddress _manageAddress;

  /// BaseInformationApi 생성자
  BaseInformationApi({required ManageAddress manageAddress})
      : _manageAddress = manageAddress,
        _baseInformationService = BaseInformationService(DatabaseClient());

  /// 주차장 기본 정보 API 라우터 생성
  Router get router {
    final router = Router();

    // POST /api/v1/parking/information - 주차장 기본 정보 등록
    router.post('/', _handleCreateBaseInformation);

    // PUT /api/v1/parking/information - 주차장 기본 정보 업데이트
    router.put('/', _handleUpdateBaseInformation);

    // GET /api/v1/parking/information - 주차장 기본 정보 조회
    router.get('/', _handleGetBaseInformation);

    // GET /api/v1/parking/information/statistics - 주차장 통계 정보 조회
    router.get('/statistics', _handleGetParkingStatistics);

    // GET /api/v1/parking/information/full - 기본 정보 + 통계 조회
    router.get('/full', _handleGetBaseInformationWithStats);

    // GET /api/v1/parking/information/health - 서비스 상태 확인
    router.get('/health', _handleHealthCheck);

    // GET /api/v1/parking/information/info - 서비스 정보 조회
    router.get('/info', _handleServiceInfo);

    return router;
  }

  /// 레거시 API 라우터 (기존 클라이언트 호환용)
  Router get legacyRouter {
    final router = Router();

    // POST / - 기존 정보 등록/업데이트 API (base_information.dart 호환)
    router.post('/', _handleLegacyCreateOrUpdate);

    // GET /get - 기존 정보 조회 API
    router.get('/get', _handleLegacyGetWithStats);

    return router;
  }

  /// 주차장 기본 정보 등록 처리
  Future<Response> _handleCreateBaseInformation(Request request) async {
    return await _processBaseInformationRequest(request, isUpdate: false);
  }

  /// 주차장 기본 정보 업데이트 처리
  Future<Response> _handleUpdateBaseInformation(Request request) async {
    return await _processBaseInformationRequest(request, isUpdate: true);
  }

  /// 주차장 기본 정보 등록/업데이트 공통 처리
  Future<Response> _processBaseInformationRequest(Request request,
      {required bool isUpdate}) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final baseInfoRequest = BaseInformationRequest.fromJson(requestData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      // 입력 데이터 정리
      final sanitizedRequest =
          _baseInformationService.sanitizeRequest(baseInfoRequest);

      final result = await _baseInformationService
          .createOrUpdateBaseInformation(databaseUrl, sanitizedRequest);

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
      print('Error in base information ${isUpdate ? "update" : "create"}: $e');
      return _createErrorResponse(
        'Invalid request format',
        errorCode: BaseInformationConstants.errorValidationFailed,
        statusCode: 400,
      );
    }
  }

  /// 주차장 기본 정보 조회
  Future<Response> _handleGetBaseInformation(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _baseInformationService.getBaseInformation(databaseUrl);

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
      print('Error in get base information: $e');
      return _createErrorResponse(
        'Failed to retrieve base information',
        statusCode: 500,
      );
    }
  }

  /// 주차장 통계 정보 조회
  Future<Response> _handleGetParkingStatistics(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result =
          await _baseInformationService.getParkingStatistics(databaseUrl);

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
      print('Error in get parking statistics: $e');
      return _createErrorResponse(
        'Failed to retrieve parking statistics',
        statusCode: 500,
      );
    }
  }

  /// 주차장 기본 정보 + 통계 조회
  Future<Response> _handleGetBaseInformationWithStats(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result = await _baseInformationService
          .getBaseInformationWithStats(databaseUrl);

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
      print('Error in get base information with stats: $e');
      return _createErrorResponse(
        'Failed to retrieve base information with statistics',
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
          await _baseInformationService.getServiceHealth(databaseUrl);

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
    final serviceInfo = _baseInformationService.getServiceInfo();

    return _createSuccessResponse(
      message: 'Service information retrieved',
      data: serviceInfo,
    );
  }

  // === 레거시 API 핸들러들 (기존 클라이언트 호환용) ===

  /// 레거시 정보 등록/업데이트 API (기존 형식 응답)
  Future<Response> _handleLegacyCreateOrUpdate(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final baseInfoRequest = BaseInformationRequest.fromJson(requestData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response(400,
            body: jsonEncode({'error': 'Database configuration not available'}),
            headers: {'Content-Type': 'application/json'});
      }

      // 입력 데이터 정리
      final sanitizedRequest =
          _baseInformationService.sanitizeRequest(baseInfoRequest);

      final result = await _baseInformationService
          .createOrUpdateBaseInformation(databaseUrl, sanitizedRequest);

      if (result.success) {
        // 기존 형식으로 응답
        if (result.message.contains('created')) {
          return Response.ok(
            jsonEncode({'message': 'Request processed successfully'}),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.ok("업데이트 완료");
        }
      } else {
        if (result.errorCode == BaseInformationConstants.errorMissingFields) {
          return Response(400,
              body: jsonEncode({'error': '뭐 하나 빠드려서 보냈음. 다시 확인 ㄱㄱ'}),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response(502,
              body: jsonEncode({'error': 'Failed to process external request'}),
              headers: {'Content-Type': 'application/json'});
        }
      }
    } catch (e) {
      print('Error in legacy create or update: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'An unexpected error occurred'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 레거시 정보 + 통계 조회 API (기존 형식 응답)
  Future<Response> _handleLegacyGetWithStats(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
            body: 'Database configuration not available');
      }

      final result = await _baseInformationService
          .getBaseInformationWithStats(databaseUrl);

      if (result.success) {
        // 기존 형식으로 응답 (레거시 JSON 형식)
        return Response.ok(jsonEncode(result.data!.toLegacyJson()),
            headers: {'content-type': 'application/json'});
      } else {
        return Response.internalServerError(
            body: 'Internal Server Error: ${result.message}');
      }
    } catch (e) {
      print('Error in legacy get with stats: $e');
      return Response.internalServerError(body: 'Internal Server Error: $e');
    }
  }

  // === 유틸리티 메서드들 ===

  /// 성공 응답 생성
  Response _createSuccessResponse({
    required String message,
    Map<String, dynamic>? data,
  }) {
    final responseBody = <String, dynamic>{
      'success': true,
      'message': message,
    };

    if (data != null) {
      responseBody['data'] = data;
    }

    return Response.ok(
      jsonEncode(responseBody),
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
      case BaseInformationConstants.errorValidationFailed:
      case BaseInformationConstants.errorMissingFields:
      case BaseInformationConstants.errorInvalidCoordinates:
      case BaseInformationConstants.errorInvalidPhoneNumber:
        return 400;
      case BaseInformationConstants.errorInformationNotFound:
        return 404;
      case BaseInformationConstants.errorInformationExists:
        return 409;
      case BaseInformationConstants.errorDatabaseOperation:
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
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };
  }
}
