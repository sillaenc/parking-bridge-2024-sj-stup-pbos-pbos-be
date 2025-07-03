import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_models.dart';

/// 비밀번호 해싱 및 검증을 담당하는 유틸리티 클래스
class PasswordHasher {
  /// 비밀번호를 이중 해싱합니다 (기존 방식 유지)
  static String hashPassword(String password) {
    final firstHash = sha256.convert(utf8.encode(password)).toString();
    final secondHash = sha256.convert(utf8.encode(firstHash)).toString();
    return secondHash;
  }

  /// 해시된 비밀번호와 입력된 비밀번호가 같은지 확인합니다
  static bool verifyPassword(String inputPassword, String hashedPassword) {
    final hashedInput = hashPassword(inputPassword);
    return hashedInput == hashedPassword;
  }

  /// 기본 비밀번호(0000)의 해시값을 반환합니다
  static String getDefaultPasswordHash() {
    return hashPassword(UserConstants.defaultPassword);
  }
}

/// 사용자 입력값 유효성을 검사하는 클래스
class UserValidator {
  /// 계정명 유효성 검사
  static bool isValidAccount(String account) {
    if (account.isEmpty) return false;
    if (account.length > 50) return false;
    // 기본적인 문자열 검사 (추가 규칙이 필요하면 여기서 확장)
    return account.trim().isNotEmpty;
  }

  /// 사용자명 유효성 검사
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    if (username.length > UserConstants.maxUsernameLength) return false;
    return username.trim().isNotEmpty;
  }

  /// 비밀번호 유효성 검사
  static bool isValidPassword(String password) {
    if (password.length < UserConstants.minPasswordLength) return false;
    if (password.length > UserConstants.maxPasswordLength) return false;
    return true;
  }

  /// 사용자 레벨 유효성 검사
  static bool isValidUserLevel(int userLevel) {
    return userLevel >= UserConstants.userLevelAdmin &&
        userLevel <= UserConstants.userLevelGuest;
  }

  /// 활성화 상태 유효성 검사
  static bool isValidActivationStatus(int isActivated) {
    return isActivated == UserConstants.userActivated ||
        isActivated == UserConstants.userDeactivated;
  }

  /// 비밀번호 확인 검사
  static bool isPasswordConfirmed(String password, String passwordCheck) {
    return password == passwordCheck;
  }

  /// 사용자 생성 요청 유효성 검사
  static ValidationResult validateCreateUserRequest(CreateUserRequest request) {
    final errors = <String>[];

    if (!isValidAccount(request.account)) {
      errors.add('Invalid account format');
    }

    if (!isValidPassword(request.passwd)) {
      errors.add(
          'Password must be between ${UserConstants.minPasswordLength} and ${UserConstants.maxPasswordLength} characters');
    }

    if (!isPasswordConfirmed(request.passwd, request.passwdCheck)) {
      errors.add('Password confirmation does not match');
    }

    if (!isValidUsername(request.username)) {
      errors.add('Invalid username format');
    }

    if (!isValidUserLevel(request.userlevel)) {
      errors.add('Invalid user level');
    }

    if (!isValidActivationStatus(request.isActivated)) {
      errors.add('Invalid activation status');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 사용자 업데이트 요청 유효성 검사
  static ValidationResult validateUpdateUserRequest(UpdateUserRequest request) {
    final errors = <String>[];

    if (!isValidAccount(request.account)) {
      errors.add('Invalid account format');
    }

    if (!isValidUsername(request.username)) {
      errors.add('Invalid username format');
    }

    if (!isValidUserLevel(request.userlevel)) {
      errors.add('Invalid user level');
    }

    if (!isValidActivationStatus(request.isActivated)) {
      errors.add('Invalid activation status');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 비밀번호 변경 요청 유효성 검사
  static ValidationResult validateChangePasswordRequest(
      ChangePasswordRequest request) {
    final errors = <String>[];

    if (!isValidAccount(request.account)) {
      errors.add('Invalid account format');
    }

    if (!isValidPassword(request.newpasswd)) {
      errors.add(
          'New password must be between ${UserConstants.minPasswordLength} and ${UserConstants.maxPasswordLength} characters');
    }

    if (!isPasswordConfirmed(request.passwd, request.passwdCheck)) {
      errors.add('Current password confirmation does not match');
    }

    if (request.passwd == request.newpasswd) {
      errors.add('New password cannot be the same as current password');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 사용자 삭제 요청 유효성 검사
  static ValidationResult validateDeleteUserRequest(DeleteUserRequest request) {
    final errors = <String>[];

    if (!isValidAccount(request.account)) {
      errors.add('Invalid account format');
    }

    if (request.passwd.isEmpty) {
      errors.add('Password is required for user deletion');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 유효성 검사 결과를 담는 클래스
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// 첫 번째 에러 메시지를 반환합니다
  String get firstError => errors.isNotEmpty ? errors.first : '';

  /// 모든 에러 메시지를 하나의 문자열로 합칩니다
  String get allErrors => errors.join(', ');
}
