import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/database_client.dart';
import '../services/jwt_service.dart';
import '../data/manage_address.dart';

/// 인증 관련 RESTful API
class AuthApi {
  final AuthService _authService;
  final ManageAddress _manageAddress;

  /// AuthApi 생성자
  AuthApi({required ManageAddress manageAddress})
      : _manageAddress = manageAddress,
        _authService = AuthService(
          DatabaseClient(),
          JwtService(),
        );

  /// 인증 API 라우터 생성
  Router get router {
    final router = Router();

    // POST /api/v1/auth/login - 사용자 로그인
    router.post('/login', _handleLogin);

    // GET /api/v1/auth/base-info - 주차장 기본 정보 조회
    router.get('/base-info', _handleGetBaseInfo);

    // GET /api/v1/auth/token - 현재 토큰 정보 조회 (레거시 호환)
    router.get('/token', _handleGetToken);

    // GET /api/v1/auth/protected - 보호된 리소스 접근 테스트
    router.get('/protected', _handleProtectedAccess);

    // POST /api/v1/auth/refresh - 토큰 갱신
    router.post('/refresh', _handleRefreshToken);

    // GET /api/v1/auth/health - 서비스 상태 확인
    router.get('/health', _handleHealthCheck);

    // GET /api/v1/auth/info - 서비스 정보 조회
    router.get('/info', _handleServiceInfo);

    return router;
  }

  /// 레거시 API 라우터 (기존 클라이언트 호환용)
  Router get legacyRouter {
    final router = Router();

    // POST / - 기존 로그인 API (login_setting.dart 호환)
    router.post('/', _handleLegacyLogin);

    // GET /base - 기존 기본 정보 API
    router.get('/base', _handleLegacyBaseInfo);

    // GET /jwt - 기존 JWT 조회 API
    router.get('/jwt', _handleLegacyJwtInfo);

    // GET /protected - 기존 보호된 리소스 API
    router.get('/protected', _handleLegacyProtectedAccess);

    return router;
  }

  /// 사용자 로그인 처리
  Future<Response> _handleLogin(Request request) async {
    try {
      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final loginData = jsonDecode(requestBody) as Map<String, dynamic>;
      final loginRequest = LoginRequest.fromJson(loginData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result = await _authService.login(databaseUrl, loginRequest);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data!.toJson(),
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
      print('Error in login handler: $e');
      return _createErrorResponse(
        'Invalid request format',
        errorCode: AuthConstants.errorValidationFailed,
        statusCode: 400,
      );
    }
  }

  /// 주차장 기본 정보 조회
  Future<Response> _handleGetBaseInfo(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final result = await _authService.getBaseInfo(databaseUrl);

      if (result.success) {
        return _createSuccessResponse(
          message: result.message,
          data: result.data!.toJson(),
        );
      } else {
        return _createErrorResponse(
          result.message,
          errorCode: result.errorCode,
          statusCode: 500,
        );
      }
    } catch (e) {
      print('Error in base info handler: $e');
      return _createErrorResponse(
        'Failed to retrieve base information',
        statusCode: 500,
      );
    }
  }

  /// 현재 토큰 정보 조회
  Future<Response> _handleGetToken(Request request) async {
    final authHeader = request.headers['Authorization'];
    final validationResult = _authService.validateAccess(authHeader);

    if (validationResult.success) {
      return _createSuccessResponse(
        message: 'Token information retrieved',
        data: validationResult.data!.toJson(),
      );
    } else {
      final statusCode = _getStatusCodeFromError(validationResult.errorCode);
      return _createErrorResponse(
        validationResult.message,
        errorCode: validationResult.errorCode,
        statusCode: statusCode,
      );
    }
  }

  /// 보호된 리소스 접근 테스트
  Future<Response> _handleProtectedAccess(Request request) async {
    final authHeader = request.headers['Authorization'];
    final validationResult = _authService.validateAccess(authHeader);

    if (validationResult.success) {
      return _createSuccessResponse(
        message: validationResult.message,
        data: {
          'accessGranted': true,
          'user': validationResult.data!.account,
          'tokenInfo': validationResult.data!.toJson(),
        },
      );
    } else {
      final statusCode = _getStatusCodeFromError(validationResult.errorCode);
      return _createErrorResponse(
        validationResult.message,
        errorCode: validationResult.errorCode,
        statusCode: statusCode,
      );
    }
  }

  /// 토큰 갱신
  Future<Response> _handleRefreshToken(Request request) async {
    try {
      final authHeader = request.headers['Authorization'];
      final jwtService = JwtService();
      final token = jwtService.extractBearerToken(authHeader);

      if (token == null) {
        return _createErrorResponse(
          AuthConstants.messageMissingAuthHeader,
          errorCode: AuthConstants.errorMissingAuthHeader,
          statusCode: 401,
        );
      }

      final refreshedToken = jwtService.refreshToken(token);
      if (refreshedToken == null) {
        return _createErrorResponse(
          'Failed to refresh token',
          errorCode: AuthConstants.errorInvalidToken,
          statusCode: 401,
        );
      }

      return _createSuccessResponse(
        message: 'Token refreshed successfully',
        data: refreshedToken.toJson(),
      );
    } catch (e) {
      print('Error in refresh token handler: $e');
      return _createErrorResponse(
        'Token refresh failed',
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

      final healthInfo = await _authService.getServiceHealth(databaseUrl);

      final isHealthy = healthInfo['status'] == 'healthy';
      final statusCode = isHealthy ? 200 : 503;

      return Response(
        statusCode,
        body: jsonEncode(healthInfo),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in health check handler: $e');
      return _createErrorResponse(
        'Health check failed',
        statusCode: 500,
      );
    }
  }

  /// 서비스 정보 조회
  Future<Response> _handleServiceInfo(Request request) async {
    final serviceInfo = _authService.getServiceInfo();

    return _createSuccessResponse(
      message: 'Service information retrieved',
      data: serviceInfo,
    );
  }

  // === 레거시 API 핸들러들 (기존 클라이언트 호환용) ===

  /// 레거시 로그인 API (기존 형식 응답)
  Future<Response> _handleLegacyLogin(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final loginData = jsonDecode(requestBody) as Map<String, dynamic>;
      final loginRequest = LoginRequest.fromJson(loginData);

      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
          body: 'Database configuration not available',
        );
      }

      final result = await _authService.login(databaseUrl, loginRequest);

      if (result.success) {
        // 기존 형식으로 응답 (배열 형태)
        return Response.ok(
          jsonEncode(result.data!.toLegacyJson()),
          headers: _getCorsHeaders(),
        );
      } else {
        return Response.internalServerError(
          body: result.message,
        );
      }
    } catch (e) {
      print('Error in legacy login handler: $e');
      return Response.internalServerError(
        body: 'Invalid request format',
      );
    }
  }

  /// 레거시 기본 정보 API (기존 형식 응답)
  Future<Response> _handleLegacyBaseInfo(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return Response.internalServerError(
          body: 'Database configuration not available',
        );
      }

      final result = await _authService.getBaseInfo(databaseUrl);

      if (result.success) {
        // 기존 형식으로 응답 (단순 배열)
        return Response.ok(
          jsonEncode(result.data!.toLegacyJson()),
          headers: _getCorsHeaders(),
        );
      } else {
        return Response.internalServerError(
          body: result.message,
        );
      }
    } catch (e) {
      print('Error in legacy base info handler: $e');
      return Response.internalServerError(
        body: 'Failed to retrieve base information',
      );
    }
  }

  /// 레거시 JWT 정보 API
  Future<Response> _handleLegacyJwtInfo(Request request) async {
    final authHeader = request.headers['Authorization'];
    final validationResult = _authService.validateAccess(authHeader);

    if (validationResult.success) {
      return Response.ok(
        jsonEncode({'token': validationResult.data!.token}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.forbidden('Invalid or missing token');
    }
  }

  /// 레거시 보호된 리소스 API
  Future<Response> _handleLegacyProtectedAccess(Request request) async {
    final authHeader = request.headers['Authorization'];
    final validationResult = _authService.validateAccess(authHeader);

    if (validationResult.success) {
      return Response.ok('Access granted to protected resource.');
    } else {
      return Response.forbidden(validationResult.message);
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
      case AuthConstants.errorInvalidCredentials:
      case AuthConstants.errorUserNotFound:
      case AuthConstants.errorInvalidToken:
      case AuthConstants.errorTokenExpired:
      case AuthConstants.errorUnauthorized:
      case AuthConstants.errorMissingAuthHeader:
        return 401;
      case AuthConstants.errorAccountDisabled:
        return 403;
      case AuthConstants.errorValidationFailed:
        return 400;
      case AuthConstants.errorDatabaseOperation:
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
