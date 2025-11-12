/// 로그인 요청 모델
class LoginRequest {
  final String account;
  final String passwd;

  const LoginRequest({
    required this.account,
    required this.passwd,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
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

/// 사용자 정보 모델
class UserInfo {
  final int uid;
  final String account;
  final String username;
  final int userlevel;
  final bool isActivated;

  const UserInfo({
    required this.uid,
    required this.account,
    required this.username,
    required this.userlevel,
    required this.isActivated,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      uid: json['uid'] as int,
      account: json['account'] as String,
      username: json['username'] as String,
      userlevel: json['userlevel'] as int,
      isActivated: json['isActivated'] == 1 || json['isActivated'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'account': account,
      'username': username,
      'userlevel': userlevel,
      'isActivated': isActivated,
    };
  }
}

/// JWT 토큰 정보 모델
class JwtTokenInfo {
  final String token;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String account;

  const JwtTokenInfo({
    required this.token,
    required this.issuedAt,
    required this.expiresAt,
    required this.account,
  });

  factory JwtTokenInfo.fromClaims(String token, Map<String, dynamic> claims) {
    return JwtTokenInfo(
      token: token,
      issuedAt:
          DateTime.fromMillisecondsSinceEpoch((claims['iat'] as int) * 1000),
      expiresAt:
          DateTime.fromMillisecondsSinceEpoch((claims['exp'] as int) * 1000),
      account: claims['account'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'account': account,
    };
  }

  /// 토큰이 만료되었는지 확인
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 토큰 만료까지 남은 시간 (초)
  int get timeToExpiry => expiresAt.difference(DateTime.now()).inSeconds;
}

/// 로그인 응답 모델
class LoginResponse {
  final UserInfo userInfo;
  final JwtTokenInfo tokenInfo;

  const LoginResponse({
    required this.userInfo,
    required this.tokenInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      ...userInfo.toJson(),
      'token': tokenInfo.token,
    };
  }

  /// 레거시 형식 (기존 클라이언트 호환용)
  List<Map<String, dynamic>> toLegacyJson() {
    return [
      userInfo.toJson(),
      {'token': tokenInfo.token},
    ];
  }
}

/// 픽셀 정보 모델
class PixelInfo {
  final double xBottomRight;
  final double yBottomRight;

  const PixelInfo({
    required this.xBottomRight,
    required this.yBottomRight,
  });

  factory PixelInfo.fromJson(Map<String, dynamic> json) {
    return PixelInfo(
      xBottomRight: (json['xbottomright'] as num).toDouble(),
      yBottomRight: (json['ybottomright'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xbottomright': xBottomRight,
      'ybottomright': yBottomRight,
    };
  }
}

/// 로트 타입 정보 모델
class LotTypeInfo {
  final int uid;
  final String lotType;
  final String tag;
  final String codeFormat;
  final bool isUsed;

  const LotTypeInfo({
    required this.uid,
    required this.lotType,
    required this.tag,
    required this.codeFormat,
    required this.isUsed,
  });

  factory LotTypeInfo.fromJson(Map<String, dynamic> json) {
    return LotTypeInfo(
      uid: json['uid'] as int,
      lotType: json['lot_type'] as String,
      tag: json['tag'] as String,
      codeFormat: json['code_format'] as String,
      isUsed: json['isUsed'] == 1 || json['isUsed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'lot_type': lotType,
      'tag': tag,
      'code_format': codeFormat,
      'isUsed': isUsed,
    };
  }
}

/// 로트 상세 정보 모델
class LotDetailInfo {
  final int uid;
  final String? tag;
  final String point;
  final int lotType;
  final String asset;
  final bool isUsed;
  final String floor;
  final String? plate;
  final String? startTime;

  const LotDetailInfo({
    required this.uid,
    this.tag,
    required this.point,
    required this.lotType,
    required this.asset,
    required this.isUsed,
    required this.floor,
    this.plate,
    this.startTime,
  });

  factory LotDetailInfo.fromJson(Map<String, dynamic> json) {
    return LotDetailInfo(
      uid: json['uid'] as int,
      tag: json['tag'] as String?,
      point: json['point'] as String,
      lotType: json['lot_type'] as int,
      asset: json['asset'] as String,
      isUsed: json['isUsed'] == 1 || json['isUsed'] == true,
      floor: json['floor'] as String,
      plate: json['plate'] as String?,
      startTime: json['startTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      if (tag != null) 'tag': tag,
      'point': point,
      'lot_type': lotType,
      'asset': asset,
      'isUsed': isUsed,
      'floor': floor,
      if (plate != null) 'plate': plate,
      if (startTime != null) 'startTime': startTime,
    };
  }
}

/// 기본 정보 응답 모델
class BaseInfoResponse {
  final List<int> lotTypeCounts; // check 배열
  final List<PixelInfo> pixelInfo; // resultSet1
  final List<LotTypeInfo> lotTypes; // resultSet7
  final List<LotDetailInfo> lotDetails; // resultSet3

  const BaseInfoResponse({
    required this.lotTypeCounts,
    required this.pixelInfo,
    required this.lotTypes,
    required this.lotDetails,
  });

  /// 레거시 형식으로 반환 (기존 클라이언트 호환용)
  List<dynamic> toLegacyJson() {
    final result = <dynamic>[];
    result.addAll(lotTypeCounts);
    result.addAll(pixelInfo.map((p) => p.toJson()));
    result.addAll(lotTypes.map((lt) => lt.toJson()));
    result.addAll(lotDetails.map((ld) => ld.toJson()));
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'lotTypeCounts': lotTypeCounts,
      'pixelInfo': pixelInfo.map((p) => p.toJson()).toList(),
      'lotTypes': lotTypes.map((lt) => lt.toJson()).toList(),
      'lotDetails': lotDetails.map((ld) => ld.toJson()).toList(),
    };
  }
}

/// 인증 서비스 응답 모델
class AuthServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const AuthServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory AuthServiceResponse.success(String message, [T? data]) {
    return AuthServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory AuthServiceResponse.error(String message, [String? errorCode]) {
    return AuthServiceResponse<T>(
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
      if (data is LoginResponse) {
        result['data'] = (data as LoginResponse).toJson();
      } else if (data is BaseInfoResponse) {
        result['data'] = (data as BaseInfoResponse).toJson();
      } else if (data is JwtTokenInfo) {
        result['data'] = (data as JwtTokenInfo).toJson();
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

/// 인증 서비스 예외 클래스
class AuthServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const AuthServiceException(this.message, this.errorCode, [this.statusCode]);

  @override
  String toString() => 'AuthServiceException: $message (Code: $errorCode)';
}

/// 인증 관련 상수들
class AuthConstants {
  // 기본 JWT 토큰 유효 시간 (시간)
  static const int defaultTokenExpiryHours = 24;

  // 에러 코드
  static const String errorInvalidCredentials = 'INVALID_CREDENTIALS';
  static const String errorUserNotFound = 'USER_NOT_FOUND';
  static const String errorAccountDisabled = 'ACCOUNT_DISABLED';
  static const String errorInvalidToken = 'INVALID_TOKEN';
  static const String errorTokenExpired = 'TOKEN_EXPIRED';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_ERROR';
  static const String errorValidationFailed = 'VALIDATION_FAILED';
  static const String errorUnauthorized = 'UNAUTHORIZED';
  static const String errorMissingAuthHeader = 'MISSING_AUTH_HEADER';

  // 성공 메시지
  static const String messageLoginSuccess = 'Login successful';
  static const String messageTokenGenerated = 'Token generated successfully';
  static const String messageAccessGranted =
      'Access granted to protected resource';
  static const String messageBaseInfoRetrieved =
      'Base information retrieved successfully';

  // 에러 메시지
  static const String messageInvalidCredentials = 'Invalid account or password';
  static const String messageUserNotFound = 'User not found';
  static const String messageAccountDisabled = 'Account is disabled';
  static const String messageInvalidToken = 'Invalid token';
  static const String messageTokenExpired = 'Token has expired';
  static const String messageDatabaseError = 'Database operation failed';
  static const String messageValidationFailed = 'Input validation failed';
  static const String messageUnauthorized = 'Unauthorized access';
  static const String messageMissingAuthHeader = 'Authorization header missing';

  // JWT 관련
  static const String jwtSecretKeyEnvName = 'JWT_SECRET_KEY';
  static const String defaultJwtSecretKey =
      'secret_key_hahaha_bjs'; // 개발용 (운영에서는 환경변수 사용)
  static const String bearerPrefix = 'Bearer ';
}
