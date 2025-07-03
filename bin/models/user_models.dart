/// 사용자 관리를 위한 모델 클래스들
class User {
  final String account;
  final String username;
  final int userlevel;
  final int isActivated;
  final String? passwd; // 선택적 필드 (보안상 민감)

  const User({
    required this.account,
    required this.username,
    required this.userlevel,
    required this.isActivated,
    this.passwd,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      account: json['account'] as String,
      username: json['username'] as String,
      userlevel: json['userlevel'] as int,
      isActivated: json['isActivated'] as int,
      passwd: json['passwd'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'account': account,
      'username': username,
      'userlevel': userlevel,
      'isActivated': isActivated,
    };
    if (passwd != null) {
      data['passwd'] = passwd;
    }
    return data;
  }

  User copyWith({
    String? account,
    String? username,
    int? userlevel,
    int? isActivated,
    String? passwd,
  }) {
    return User(
      account: account ?? this.account,
      username: username ?? this.username,
      userlevel: userlevel ?? this.userlevel,
      isActivated: isActivated ?? this.isActivated,
      passwd: passwd ?? this.passwd,
    );
  }
}

/// 사용자 생성 요청 모델
class CreateUserRequest {
  final String account;
  final String passwd;
  final String passwdCheck;
  final String username;
  final int userlevel;
  final int isActivated;

  const CreateUserRequest({
    required this.account,
    required this.passwd,
    required this.passwdCheck,
    required this.username,
    required this.userlevel,
    required this.isActivated,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserRequest(
      account: json['account'] as String,
      passwd: json['passwd'] as String,
      passwdCheck: json['passwdCheck'] as String,
      username: json['username'] as String,
      userlevel: json['userlevel'] as int,
      isActivated: json['isActivated'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'passwd': passwd,
      'passwdCheck': passwdCheck,
      'username': username,
      'userlevel': userlevel,
      'isActivated': isActivated,
    };
  }
}

/// 사용자 업데이트 요청 모델
class UpdateUserRequest {
  final String account;
  final String username;
  final int userlevel;
  final int isActivated;

  const UpdateUserRequest({
    required this.account,
    required this.username,
    required this.userlevel,
    required this.isActivated,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRequest(
      account: json['account'] as String,
      username: json['username'] as String,
      userlevel: json['userlevel'] as int,
      isActivated: json['isActivated'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'username': username,
      'userlevel': userlevel,
      'isActivated': isActivated,
    };
  }
}

/// 비밀번호 변경 요청 모델
class ChangePasswordRequest {
  final String account;
  final String passwd;
  final String passwdCheck;
  final String newpasswd;

  const ChangePasswordRequest({
    required this.account,
    required this.passwd,
    required this.passwdCheck,
    required this.newpasswd,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      account: json['account'] as String,
      passwd: json['passwd'] as String,
      passwdCheck: json['passwdCheck'] as String,
      newpasswd: json['newpasswd'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'passwd': passwd,
      'passwdCheck': passwdCheck,
      'newpasswd': newpasswd,
    };
  }
}

/// 비밀번호 리셋 요청 모델
class ResetPasswordRequest {
  final String account;

  const ResetPasswordRequest({
    required this.account,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      account: json['account'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
    };
  }
}

/// 사용자 삭제 요청 모델
class DeleteUserRequest {
  final String account;
  final String passwd;

  const DeleteUserRequest({
    required this.account,
    required this.passwd,
  });

  factory DeleteUserRequest.fromJson(Map<String, dynamic> json) {
    return DeleteUserRequest(
      account: json['account'] as String,
      passwd: json['passwd'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'passwd': passwd,
    };
  }
}

/// 사용자 서비스 응답 모델
class UserServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const UserServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory UserServiceResponse.success(String message, [T? data]) {
    return UserServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory UserServiceResponse.error(String message, [String? errorCode]) {
    return UserServiceResponse<T>(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'success': success,
      'message': message,
    };

    if (data != null) {
      if (data is List) {
        result['data'] = (data as List).map((item) {
          if (item is User) return item.toJson();
          return item;
        }).toList();
      } else if (data is User) {
        result['data'] = (data as User).toJson();
      } else {
        result['data'] = data;
      }
    }

    if (errorCode != null) {
      result['errorCode'] = errorCode;
    }

    return result;
  }
}

/// 사용자 서비스 예외 클래스
class UserServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const UserServiceException(this.message, this.errorCode, [this.statusCode]);

  @override
  String toString() => 'UserServiceException: $message (Code: $errorCode)';
}

/// 사용자 관리 상수들
class UserConstants {
  static const String defaultPassword = '0000';
  static const int maxUsernameLength = 50;
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 100;

  // 사용자 레벨 상수
  static const int userLevelAdmin = 1;
  static const int userLevelUser = 2;
  static const int userLevelGuest = 3;

  // 활성화 상태
  static const int userActivated = 1;
  static const int userDeactivated = 0;

  // 에러 코드
  static const String errorDuplicateAccount = 'DUPLICATE_ACCOUNT';
  static const String errorUserNotFound = 'USER_NOT_FOUND';
  static const String errorPasswordMismatch = 'PASSWORD_MISMATCH';
  static const String errorInvalidPassword = 'INVALID_PASSWORD';
  static const String errorSamePassword = 'SAME_PASSWORD';
  static const String errorUnauthorized = 'UNAUTHORIZED';
  static const String errorValidationFailed = 'VALIDATION_FAILED';

  // 성공 메시지
  static const String messageCreateSuccess = 'User created successfully';
  static const String messageUpdateSuccess = 'User updated successfully';
  static const String messageDeleteSuccess = 'User deleted successfully';
  static const String messagePasswordChanged = 'Password changed successfully';
  static const String messagePasswordReset = 'Password reset successfully';

  // 에러 메시지
  static const String messageUserExists = 'User account already exists';
  static const String messageUserNotExists = 'User account does not exist';
  static const String messagePasswordWrong = 'Current password is incorrect';
  static const String messagePasswordSame =
      'New password cannot be the same as current password';
  static const String messagePasswordConfirmFailed =
      'Password confirmation failed';
  static const String messageValidationFailed = 'Input validation failed';
}
