import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../models/auth_models.dart';

/// JWT 토큰 생성 및 검증을 담당하는 서비스
class JwtService {
  late final String _secretKey;

  /// JWT 서비스 생성자
  /// 환경변수에서 시크릿 키를 읽어오거나 기본값 사용
  JwtService() {
    _secretKey = Platform.environment[AuthConstants.jwtSecretKeyEnvName] ??
        AuthConstants.defaultJwtSecretKey;

    // 운영 환경에서 기본 키를 사용하는 경우 경고
    if (_secretKey == AuthConstants.defaultJwtSecretKey) {
      print(
          '⚠️  Warning: Using default JWT secret key. Set ${AuthConstants.jwtSecretKeyEnvName} environment variable for production.');
    }
  }

  /// 사용자 계정으로 JWT 토큰 생성
  ///
  /// [account] 사용자 계정명
  /// [hours] 토큰 유효 시간 (시간 단위, 기본값: 24시간)
  /// Returns: JWT 토큰 정보
  JwtTokenInfo createToken(String account, {int? hours}) {
    final expiryHours = hours ?? AuthConstants.defaultTokenExpiryHours;
    final now = DateTime.now();
    final issuedAt = now;
    final expiresAt = now.add(Duration(hours: expiryHours));

    final jwt = JWT({
      'account': account,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
    });

    final token = jwt.sign(SecretKey(_secretKey));

    return JwtTokenInfo(
      token: token,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      account: account,
    );
  }

  /// JWT 토큰 검증
  ///
  /// [token] 검증할 JWT 토큰
  /// Returns: 검증 성공 시 토큰 정보, 실패 시 null
  JwtTokenInfo? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final payload = jwt.payload as Map<String, dynamic>;

      // 만료 시간 확인
      final exp = payload['exp'] as int;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      if (DateTime.now().isAfter(expiresAt)) {
        print('JWT token has expired');
        return null;
      }

      return JwtTokenInfo.fromClaims(token, payload);
    } catch (e) {
      print('JWT verification failed: $e');
      return null;
    }
  }

  /// Authorization 헤더에서 Bearer 토큰 추출
  ///
  /// [authorizationHeader] Authorization 헤더 값
  /// Returns: 추출된 토큰, 없으면 null
  String? extractBearerToken(String? authorizationHeader) {
    if (authorizationHeader == null) return null;

    if (authorizationHeader.startsWith(AuthConstants.bearerPrefix)) {
      return authorizationHeader.substring(AuthConstants.bearerPrefix.length);
    }

    return null;
  }

  /// 토큰의 유효성 및 만료 여부 검사
  ///
  /// [token] 검사할 JWT 토큰
  /// Returns: 유효한 토큰 정보 또는 에러 정보
  TokenValidationResult validateToken(String token) {
    try {
      final tokenInfo = verifyToken(token);

      if (tokenInfo == null) {
        return TokenValidationResult.error(
          AuthConstants.messageInvalidToken,
          AuthConstants.errorInvalidToken,
        );
      }

      if (tokenInfo.isExpired) {
        return TokenValidationResult.error(
          AuthConstants.messageTokenExpired,
          AuthConstants.errorTokenExpired,
        );
      }

      return TokenValidationResult.success(tokenInfo);
    } catch (e) {
      return TokenValidationResult.error(
        'Token validation failed: $e',
        AuthConstants.errorInvalidToken,
      );
    }
  }

  /// 토큰에서 사용자 계정 추출
  ///
  /// [token] JWT 토큰
  /// Returns: 사용자 계정명 또는 null
  String? getAccountFromToken(String token) {
    final tokenInfo = verifyToken(token);
    return tokenInfo?.account;
  }

  /// 토큰 갱신 (새로운 토큰 생성)
  ///
  /// [token] 기존 토큰
  /// [hours] 새 토큰의 유효 시간
  /// Returns: 새로운 토큰 정보 또는 null
  JwtTokenInfo? refreshToken(String token, {int? hours}) {
    final account = getAccountFromToken(token);
    if (account == null) return null;

    return createToken(account, hours: hours);
  }

  /// 토큰의 남은 유효 시간 (초) 계산
  ///
  /// [token] JWT 토큰
  /// Returns: 남은 시간(초), 유효하지 않으면 -1
  int getTimeToExpiry(String token) {
    final tokenInfo = verifyToken(token);
    if (tokenInfo == null) return -1;

    return tokenInfo.timeToExpiry;
  }

  /// 다중 토큰 검증 (배치 처리)
  ///
  /// [tokens] 검증할 토큰 목록
  /// Returns: 각 토큰의 검증 결과
  Map<String, TokenValidationResult> validateMultipleTokens(
      List<String> tokens) {
    final results = <String, TokenValidationResult>{};

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final key = 'token_$i';
      results[key] = validateToken(token);
    }

    return results;
  }

  /// JWT 서비스 상태 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'JwtService',
      'version': '1.0.0',
      'description': 'JWT token management service',
      'secretKeySource': _secretKey == AuthConstants.defaultJwtSecretKey
          ? 'default'
          : 'environment',
      'defaultExpiryHours': AuthConstants.defaultTokenExpiryHours,
      'supportedOperations': [
        'createToken',
        'verifyToken',
        'validateToken',
        'refreshToken',
        'extractBearerToken',
        'getAccountFromToken',
      ],
    };
  }
}

/// 토큰 검증 결과 클래스
class TokenValidationResult {
  final bool isValid;
  final String message;
  final String? errorCode;
  final JwtTokenInfo? tokenInfo;

  const TokenValidationResult({
    required this.isValid,
    required this.message,
    this.errorCode,
    this.tokenInfo,
  });

  factory TokenValidationResult.success(JwtTokenInfo tokenInfo) {
    return TokenValidationResult(
      isValid: true,
      message: 'Token is valid',
      tokenInfo: tokenInfo,
    );
  }

  factory TokenValidationResult.error(String message, String errorCode) {
    return TokenValidationResult(
      isValid: false,
      message: message,
      errorCode: errorCode,
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'isValid': isValid,
      'message': message,
    };

    if (errorCode != null) {
      result['errorCode'] = errorCode!;
    }

    if (tokenInfo != null) {
      result['tokenInfo'] = tokenInfo!.toJson();
    }

    return result;
  }
}
