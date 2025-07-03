import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_models.dart';
import '../utils/password_utils.dart';
import '../data/manage_address.dart';

/// 사용자 관리 서비스 클래스
class UserService {
  final ManageAddress manageAddress;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  UserService({required this.manageAddress});

  String? get _dbUrl => manageAddress.displayDbAddr;

  /// 모든 사용자 조회
  Future<UserServiceResponse<List<User>>> getAllUsers() async {
    try {
      if (_dbUrl == null) {
        throw UserServiceException(
          'Database URL not configured',
          UserConstants.errorValidationFailed,
          500,
        );
      }

      final body = {
        "transaction": [
          {"query": "#S_TbUsers"},
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      final resultSet = responseData['results'][0]['resultSet'] as List;

      final users = resultSet
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList();

      return UserServiceResponse.success('Users retrieved successfully', users);
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to retrieve users: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 특정 사용자 조회
  Future<User?> getUserByAccount(String account) async {
    try {
      if (_dbUrl == null) {
        throw UserServiceException(
          'Database URL not configured',
          UserConstants.errorValidationFailed,
          500,
        );
      }

      final body = {
        "transaction": [
          {
            "query": "#S_UserCheck",
            "values": {"account": account}
          }
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      final resultSet = responseData['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return null;
      }

      return User.fromJson(resultSet[0] as Map<String, dynamic>);
    } catch (e) {
      throw UserServiceException(
        'Failed to get user: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 사용자 생성
  Future<UserServiceResponse<User>> createUser(
      CreateUserRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = UserValidator.validateCreateUserRequest(request);
      if (!validation.isValid) {
        throw UserServiceException(
          validation.allErrors,
          UserConstants.errorValidationFailed,
          400,
        );
      }

      // 계정 중복 확인
      final existingUser = await getUserByAccount(request.account);
      if (existingUser != null) {
        throw UserServiceException(
          UserConstants.messageUserExists,
          UserConstants.errorDuplicateAccount,
          409,
        );
      }

      // 비밀번호 해싱
      final hashedPassword = PasswordHasher.hashPassword(request.passwdCheck);

      // 사용자 생성
      final body = {
        "transaction": [
          {
            "statement": "#I_UserAdd",
            "values": {
              "account": request.account,
              "passwd": hashedPassword,
              "username": request.username,
              "userlevel": request.userlevel,
              "isActivated": request.isActivated,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final newUser = User(
        account: request.account,
        username: request.username,
        userlevel: request.userlevel,
        isActivated: request.isActivated,
      );

      return UserServiceResponse.success(
        UserConstants.messageCreateSuccess,
        newUser,
      );
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to create user: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 사용자 정보 업데이트
  Future<UserServiceResponse<User>> updateUser(
      UpdateUserRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = UserValidator.validateUpdateUserRequest(request);
      if (!validation.isValid) {
        throw UserServiceException(
          validation.allErrors,
          UserConstants.errorValidationFailed,
          400,
        );
      }

      // 사용자 존재 확인
      final existingUser = await getUserByAccount(request.account);
      if (existingUser == null) {
        throw UserServiceException(
          UserConstants.messageUserNotExists,
          UserConstants.errorUserNotFound,
          404,
        );
      }

      // 사용자 정보 업데이트
      final body = {
        "transaction": [
          {
            "statement": "#U_TbUsers",
            "values": {
              "username": request.username,
              "userlevel": request.userlevel,
              "isActivated": request.isActivated,
              "account": request.account,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final updatedUser = User(
        account: request.account,
        username: request.username,
        userlevel: request.userlevel,
        isActivated: request.isActivated,
      );

      return UserServiceResponse.success(
        UserConstants.messageUpdateSuccess,
        updatedUser,
      );
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to update user: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 비밀번호 변경
  Future<UserServiceResponse<String>> changePassword(
      ChangePasswordRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = UserValidator.validateChangePasswordRequest(request);
      if (!validation.isValid) {
        throw UserServiceException(
          validation.allErrors,
          UserConstants.errorValidationFailed,
          400,
        );
      }

      // 사용자 존재 및 현재 비밀번호 확인
      final existingUser = await getUserByAccount(request.account);
      if (existingUser == null) {
        throw UserServiceException(
          UserConstants.messageUserNotExists,
          UserConstants.errorUserNotFound,
          404,
        );
      }

      // 새 비밀번호 해싱
      final newHashedPassword = PasswordHasher.hashPassword(request.newpasswd);

      // 현재 비밀번호와 새 비밀번호가 같은지 확인
      if (existingUser.passwd == newHashedPassword) {
        throw UserServiceException(
          UserConstants.messagePasswordSame,
          UserConstants.errorSamePassword,
          400,
        );
      }

      // 비밀번호 업데이트
      final body = {
        "transaction": [
          {
            "statement": "#U_ChangePassword",
            "values": {
              "passwd": newHashedPassword,
              "account": request.account,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return UserServiceResponse.success(UserConstants.messagePasswordChanged);
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to change password: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 비밀번호 리셋 (기본값 0000으로)
  Future<UserServiceResponse<String>> resetPassword(
      ResetPasswordRequest request) async {
    try {
      // 사용자 존재 확인
      final existingUser = await getUserByAccount(request.account);
      if (existingUser == null) {
        throw UserServiceException(
          UserConstants.messageUserNotExists,
          UserConstants.errorUserNotFound,
          404,
        );
      }

      // 기본 비밀번호로 리셋
      final defaultPasswordHash = PasswordHasher.getDefaultPasswordHash();

      final body = {
        "transaction": [
          {
            "statement": "#U_ChangePassword",
            "values": {
              "passwd": defaultPasswordHash,
              "account": request.account,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return UserServiceResponse.success(UserConstants.messagePasswordReset);
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to reset password: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 사용자 삭제
  Future<UserServiceResponse<String>> deleteUser(
      DeleteUserRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = UserValidator.validateDeleteUserRequest(request);
      if (!validation.isValid) {
        throw UserServiceException(
          validation.allErrors,
          UserConstants.errorValidationFailed,
          400,
        );
      }

      // 사용자 존재 및 비밀번호 확인
      final existingUser = await getUserByAccount(request.account);
      if (existingUser == null) {
        throw UserServiceException(
          UserConstants.messageUserNotExists,
          UserConstants.errorUserNotFound,
          404,
        );
      }

      // 비밀번호 확인
      final inputPasswordHash = PasswordHasher.hashPassword(request.passwd);
      if (existingUser.passwd != inputPasswordHash) {
        throw UserServiceException(
          UserConstants.messagePasswordWrong,
          UserConstants.errorPasswordMismatch,
          401,
        );
      }

      // 사용자 삭제
      final body = {
        "transaction": [
          {
            "statement": "#D_TbUsers",
            "values": {"account": request.account}
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return UserServiceResponse.success(UserConstants.messageDeleteSuccess);
    } catch (e) {
      if (e is UserServiceException) rethrow;

      throw UserServiceException(
        'Failed to delete user: ${e.toString()}',
        UserConstants.errorUnauthorized,
        500,
      );
    }
  }

  /// 사용자 존재 여부 확인
  Future<bool> userExists(String account) async {
    try {
      final user = await getUserByAccount(account);
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// 서비스 상태 확인
  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final usersResponse = await getAllUsers();
      final userCount = usersResponse.data?.length ?? 0;

      return {
        'status': 'healthy',
        'dbUrl': _dbUrl != null ? 'configured' : 'not_configured',
        'userCount': userCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
