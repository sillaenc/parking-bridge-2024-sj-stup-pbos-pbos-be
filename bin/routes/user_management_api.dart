import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/user_models.dart';
import '../services/user_service.dart';
import '../data/manage_address.dart';

/// RESTful 사용자 관리 API
class UserManagementApi {
  final UserService _userService;

  UserManagementApi({required ManageAddress manageAddress})
      : _userService = UserService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/users - 모든 사용자 조회
    router.get('/', _getAllUsers);

    // GET /api/v1/users/health - 서비스 상태 확인 (account 경로보다 먼저 정의)
    router.get('/health', _getServiceHealth);

    // GET /api/v1/users/info - 서비스 정보 (account 경로보다 먼저 정의)
    router.get('/info', _getServiceInfo);

    // POST /api/v1/users - 사용자 생성
    router.post('/', _createUser);

    // GET /api/v1/users/{account} - 특정 사용자 조회
    router.get('/<account>', _getUserByAccount);

    // PUT /api/v1/users/{account} - 사용자 정보 업데이트
    router.put('/<account>', _updateUser);

    // PATCH /api/v1/users/{account}/password - 비밀번호 변경
    router.patch('/<account>/password', _changePassword);

    // PATCH /api/v1/users/{account}/password/reset - 비밀번호 리셋
    router.patch('/<account>/password/reset', _resetPassword);

    // DELETE /api/v1/users/{account} - 사용자 삭제
    router.delete('/<account>', _deleteUser);

    return router;
  }

  /// 모든 사용자 조회
  Future<Response> _getAllUsers(Request request) async {
    try {
      final result = await _userService.getAllUsers();

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 특정 사용자 조회
  Future<Response> _getUserByAccount(Request request) async {
    try {
      final account = request.params['account']!;
      final user = await _userService.getUserByAccount(account);

      if (user == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': UserConstants.messageUserNotExists,
            'errorCode': UserConstants.errorUserNotFound,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = UserServiceResponse.success(
        'User retrieved successfully',
        user,
      );

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 사용자 생성
  Future<Response> _createUser(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final createRequest = CreateUserRequest.fromJson(requestData);
      final result = await _userService.createUser(createRequest);

      return Response(
        201,
        body: jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 사용자 정보 업데이트
  Future<Response> _updateUser(Request request) async {
    try {
      final account = request.params['account']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 account를 requestData에 추가
      requestData['account'] = account;

      final updateRequest = UpdateUserRequest.fromJson(requestData);
      final result = await _userService.updateUser(updateRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 비밀번호 변경
  Future<Response> _changePassword(Request request) async {
    try {
      final account = request.params['account']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 account를 requestData에 추가
      requestData['account'] = account;

      final changePasswordRequest = ChangePasswordRequest.fromJson(requestData);
      final result = await _userService.changePassword(changePasswordRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 비밀번호 리셋
  Future<Response> _resetPassword(Request request) async {
    try {
      final account = request.params['account']!;

      final resetRequest = ResetPasswordRequest(account: account);
      final result = await _userService.resetPassword(resetRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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

  /// 사용자 삭제
  Future<Response> _deleteUser(Request request) async {
    try {
      final account = request.params['account']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 account를 requestData에 추가
      requestData['account'] = account;

      final deleteRequest = DeleteUserRequest.fromJson(requestData);
      final result = await _userService.deleteUser(deleteRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on UserServiceException catch (e) {
      return _handleUserServiceException(e);
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
      final status = await _userService.getServiceStatus();

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

  /// 서비스 정보
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'User Management API',
        'version': '1.0.0',
        'description': 'RESTful API for user account management',
        'endpoints': {
          'GET /': 'Get all users',
          'GET /{account}': 'Get user by account',
          'POST /': 'Create new user',
          'PUT /{account}': 'Update user information',
          'PATCH /{account}/password': 'Change user password',
          'PATCH /{account}/password/reset': 'Reset user password to default',
          'DELETE /{account}': 'Delete user account',
          'GET /health': 'Service health check',
          'GET /info': 'Service information',
        },
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// UserServiceException을 적절한 HTTP Response로 변환
  Response _handleUserServiceException(UserServiceException e) {
    final errorResponse = {
      'success': false,
      'message': e.message,
      'errorCode': e.errorCode,
    };

    final statusCode = e.statusCode ?? 500;

    switch (statusCode) {
      case 400:
        return Response.badRequest(
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 401:
        return Response.unauthorized(
          jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 404:
        return Response.notFound(
          jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 409:
        return Response(
          409,
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      default:
        return Response.internalServerError(
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
    }
  }
}

/// 레거시 호환성을 위한 기존 API 래퍼
class LegacyUserApi {
  final UserService _userService;

  LegacyUserApi({required ManageAddress manageAddress})
      : _userService = UserService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // 기존 API 엔드포인트들 (하위 호환성 유지)
    router.get('/', _legacyGetAllUsers);
    router.post('/updateUser', _legacyUpdateUser);
    router.post('/changePassword', _legacyChangePassword);
    router.post('/resetPassword', _legacyResetPassword);
    router.post('/insertUser', _legacyInsertUser);
    router.post('/deleteUser', _legacyDeleteUser);

    return router;
  }

  /// 레거시: 모든 사용자 조회
  Future<Response> _legacyGetAllUsers(Request request) async {
    try {
      final result = await _userService.getAllUsers();
      // 기존 형식으로 변환 (resultSet 직접 반환)
      final users = result.data ?? [];
      final resultSet = users.map((user) => user.toJson()).toList();

      return Response.ok(jsonEncode(resultSet));
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 사용자 정보 업데이트
  Future<Response> _legacyUpdateUser(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final updateRequest = UpdateUserRequest.fromJson(requestData);
      await _userService.updateUser(updateRequest);

      return Response.ok("update success");
    } catch (e) {
      if (e is UserServiceException) {
        return Response.internalServerError(body: 'Error: ${e.message}');
      }
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 비밀번호 변경
  Future<Response> _legacyChangePassword(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final changePasswordRequest = ChangePasswordRequest.fromJson(requestData);
      await _userService.changePassword(changePasswordRequest);

      return Response.ok("update success");
    } catch (e) {
      if (e is UserServiceException) {
        if (e.errorCode == UserConstants.errorUserNotFound) {
          return Response.unauthorized("id가 없다고 뜸. 오류 발생. 앱에서는 생기면 안되는 문제");
        } else if (e.errorCode == UserConstants.errorSamePassword) {
          return Response.unauthorized("기존 비밀번호와 새 비밀번호가 동일합니다.");
        }
        return Response.unauthorized("account는 앱에서는 정상적인 상황에서 틀릴 방법이 없음. 오류임");
      }
      return Response.unauthorized("account는 앱에서는 정상적인 상황에서 틀릴 방법이 없음. 오류임");
    }
  }

  /// 레거시: 비밀번호 리셋
  Future<Response> _legacyResetPassword(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final resetRequest = ResetPasswordRequest.fromJson(requestData);
      await _userService.resetPassword(resetRequest);

      return Response.ok("reset success");
    } catch (e) {
      if (e is UserServiceException &&
          e.errorCode == UserConstants.errorUserNotFound) {
        return Response.unauthorized("id가 없다고 뜸. 오류 발생. 앱에서는 생기면 안되는 문제");
      }
      return Response.unauthorized("account는 앱에서는 정상적인 상황에서 틀릴 방법이 없음. 오류임");
    }
  }

  /// 레거시: 사용자 생성
  Future<Response> _legacyInsertUser(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final createRequest = CreateUserRequest.fromJson(requestData);
      await _userService.createUser(createRequest);

      return Response.ok("create success");
    } catch (e) {
      if (e is UserServiceException) {
        if (e.errorCode == UserConstants.errorDuplicateAccount) {
          return Response.unauthorized("id 중복");
        } else if (e.errorCode == UserConstants.errorValidationFailed) {
          return Response.unauthorized("비밀번호 확인 요망");
        }
      }
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 사용자 삭제
  Future<Response> _legacyDeleteUser(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final deleteRequest = DeleteUserRequest.fromJson(requestData);
      await _userService.deleteUser(deleteRequest);

      return Response.ok("delete success");
    } catch (e) {
      if (e is UserServiceException &&
          e.errorCode == UserConstants.errorPasswordMismatch) {
        return Response.unauthorized("password wrong");
      }
      return Response.internalServerError(body: 'Error: $e');
    }
  }
}
