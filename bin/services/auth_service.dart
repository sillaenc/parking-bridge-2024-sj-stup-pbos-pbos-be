import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/auth_models.dart';
import '../services/database_client.dart';
import '../services/jwt_service.dart';

/// 인증 및 로그인 관리 서비스
class AuthService {
  final DatabaseClient _databaseClient;
  final JwtService _jwtService;

  /// 인증 서비스 생성자
  AuthService(this._databaseClient, this._jwtService);

  /// 사용자 로그인 처리
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [loginRequest] 로그인 요청 정보
  /// Returns: 로그인 성공 시 사용자 정보 및 JWT 토큰
  Future<AuthServiceResponse<LoginResponse>> login(
      String databaseUrl, LoginRequest loginRequest) async {
    try {
      // 입력값 유효성 검사
      if (loginRequest.account.trim().isEmpty ||
          loginRequest.passwd.trim().isEmpty) {
        return AuthServiceResponse.error(
          AuthConstants.messageValidationFailed,
          AuthConstants.errorValidationFailed,
        );
      }

      // 비밀번호 이중 해싱 (기존 시스템과의 호환성 유지)
      final hashedPassword = _hashPassword(loginRequest.passwd);

      // 로그인 검증 쿼리 실행
      final loginCheckResult = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_ReqLogin",
        values: {
          "account": loginRequest.account,
          "passwd": hashedPassword,
        },
      );

      // 사용자 정보 조회 쿼리 실행
      final userInfoResult = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_ReqLogin2",
        values: {
          "account": loginRequest.account,
          "passwd": hashedPassword,
        },
      );

      // 로그인 검증 결과 확인
      if (loginCheckResult.isEmpty) {
        return AuthServiceResponse.error(
          AuthConstants.messageInvalidCredentials,
          AuthConstants.errorInvalidCredentials,
        );
      }

      // 계정 확인
      final accountExists = loginCheckResult
          .any((entry) => entry['account'] == loginRequest.account);

      if (!accountExists) {
        return AuthServiceResponse.error(
          AuthConstants.messageUserNotFound,
          AuthConstants.errorUserNotFound,
        );
      }

      // 비밀번호 확인
      final passwordValid = loginCheckResult.any((entry) =>
          entry['account'] == loginRequest.account &&
          entry['passwd'] == hashedPassword);

      if (!passwordValid) {
        return AuthServiceResponse.error(
          AuthConstants.messageInvalidCredentials,
          AuthConstants.errorInvalidCredentials,
        );
      }

      // 사용자 정보 확인
      if (userInfoResult.isEmpty) {
        return AuthServiceResponse.error(
          AuthConstants.messageUserNotFound,
          AuthConstants.errorUserNotFound,
        );
      }

      final userInfo = UserInfo.fromJson(userInfoResult.first);

      // 계정 활성화 상태 확인
      if (!userInfo.isActivated) {
        return AuthServiceResponse.error(
          AuthConstants.messageAccountDisabled,
          AuthConstants.errorAccountDisabled,
        );
      }

      // JWT 토큰 생성
      final tokenInfo = _jwtService.createToken(userInfo.account);

      final loginResponse = LoginResponse(
        userInfo: userInfo,
        tokenInfo: tokenInfo,
      );

      return AuthServiceResponse.success(
        AuthConstants.messageLoginSuccess,
        loginResponse,
      );
    } catch (e) {
      print('Error during login: $e');
      return AuthServiceResponse.error(
        AuthConstants.messageDatabaseError,
        AuthConstants.errorDatabaseOperation,
      );
    }
  }

  /// 주차장 기본 정보 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 주차장 기본 정보 (픽셀 정보, 로트 타입, 로트 상세 정보)
  Future<AuthServiceResponse<BaseInfoResponse>> getBaseInfo(
      String databaseUrl) async {
    try {
      // 병렬로 여러 쿼리 실행
      final pixelInfoFuture = _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_TotalPixel",
      );

      final lotInfoFuture = _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_LotInfo",
      );

      final lotTypeFuture = _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_LotType",
      );

      // 모든 쿼리 완료 대기
      final results = await Future.wait([
        pixelInfoFuture,
        lotInfoFuture,
        lotTypeFuture,
      ]);

      final pixelInfoData = results[0];
      final lotInfoData = results[1];
      final lotTypeData = results[2];

      // 데이터 파싱
      final pixelInfo =
          pixelInfoData.map((data) => PixelInfo.fromJson(data)).toList();
      final lotDetails =
          lotInfoData.map((data) => LotDetailInfo.fromJson(data)).toList();
      final lotTypes =
          lotTypeData.map((data) => LotTypeInfo.fromJson(data)).toList();

      // 로트 타입별 사용 개수 계산
      final lotTypeCounts = _calculateLotTypeCounts(lotDetails, lotTypes);

      // 로트 타입 사용 여부 업데이트
      await _updateLotTypeUsage(databaseUrl, lotTypeCounts);

      // 업데이트된 로트 타입 정보 다시 조회
      final updatedLotTypeData = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_LotType",
      );

      final updatedLotTypes =
          updatedLotTypeData.map((data) => LotTypeInfo.fromJson(data)).toList();

      final baseInfoResponse = BaseInfoResponse(
        lotTypeCounts: lotTypeCounts,
        pixelInfo: pixelInfo,
        lotTypes: updatedLotTypes,
        lotDetails: lotDetails,
      );

      return AuthServiceResponse.success(
        AuthConstants.messageBaseInfoRetrieved,
        baseInfoResponse,
      );
    } catch (e) {
      print('Error getting base info: $e');
      return AuthServiceResponse.error(
        AuthConstants.messageDatabaseError,
        AuthConstants.errorDatabaseOperation,
      );
    }
  }

  /// 토큰 검증 및 보호된 리소스 접근 권한 확인
  ///
  /// [authorizationHeader] Authorization 헤더 값
  /// Returns: 토큰 유효성 검증 결과
  AuthServiceResponse<JwtTokenInfo> validateAccess(
      String? authorizationHeader) {
    try {
      // Authorization 헤더에서 토큰 추출
      final token = _jwtService.extractBearerToken(authorizationHeader);

      if (token == null) {
        return AuthServiceResponse.error(
          AuthConstants.messageMissingAuthHeader,
          AuthConstants.errorMissingAuthHeader,
        );
      }

      // 토큰 유효성 검증
      final validationResult = _jwtService.validateToken(token);

      if (!validationResult.isValid) {
        return AuthServiceResponse.error(
          validationResult.message,
          validationResult.errorCode ?? AuthConstants.errorInvalidToken,
        );
      }

      return AuthServiceResponse.success(
        AuthConstants.messageAccessGranted,
        validationResult.tokenInfo!,
      );
    } catch (e) {
      print('Error validating access: $e');
      return AuthServiceResponse.error(
        AuthConstants.messageUnauthorized,
        AuthConstants.errorUnauthorized,
      );
    }
  }

  /// 비밀번호 이중 해싱 (기존 시스템 호환성 유지)
  ///
  /// [password] 원본 비밀번호
  /// Returns: 이중 해싱된 비밀번호
  String _hashPassword(String password) {
    final firstHash = sha256.convert(utf8.encode(password)).toString();
    final secondHash = sha256.convert(utf8.encode(firstHash)).toString();
    return secondHash;
  }

  /// 로트 타입별 사용 개수 계산
  ///
  /// [lotDetails] 로트 상세 정보 목록
  /// [lotTypes] 로트 타입 정보 목록
  /// Returns: 로트 타입별 사용 개수 배열
  List<int> _calculateLotTypeCounts(
      List<LotDetailInfo> lotDetails, List<LotTypeInfo> lotTypes) {
    final counts = List<int>.filled(lotTypes.length, 0);

    for (final detail in lotDetails) {
      if (detail.lotType > 0 && detail.lotType <= lotTypes.length) {
        counts[detail.lotType - 1]++;
      }
    }

    return counts;
  }

  /// 로트 타입 사용 여부 업데이트
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [counts] 로트 타입별 사용 개수
  Future<void> _updateLotTypeUsage(String databaseUrl, List<int> counts) async {
    for (int i = 0; i < counts.length; i++) {
      final uid = i + 1;
      final isUsed = counts[i] > 0 ? 1 : 0;

      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: "#U_IsUsed",
        values: {
          "isUsed": isUsed,
          "uid": uid,
        },
      );
    }
  }

  /// 서비스 상태 확인
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 서비스 상태 정보
  Future<Map<String, dynamic>> getServiceHealth(String databaseUrl) async {
    try {
      final startTime = DateTime.now();

      // 간단한 쿼리로 데이터베이스 연결 테스트
      await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_LotType",
      );

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'healthy',
        'database': 'connected',
        'responseTimeMs': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'AuthService',
        'jwtService': _jwtService.getServiceInfo(),
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'database': 'disconnected',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'AuthService',
        'jwtService': _jwtService.getServiceInfo(),
      };
    }
  }

  /// 서비스 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'AuthService',
      'version': '1.0.0',
      'description': 'Authentication and authorization service',
      'endpoints': {
        'login': 'User authentication with JWT token generation',
        'getBaseInfo': 'Retrieve parking lot base information',
        'validateAccess': 'Validate JWT token for protected resources',
      },
      'passwordHashing': 'Double SHA256 (legacy compatibility)',
      'tokenManagement': _jwtService.getServiceInfo(),
      'supportedOperations': [
        'login',
        'getBaseInfo',
        'validateAccess',
        'getServiceHealth',
      ],
    };
  }

  /// 사용자 계정으로 기본 정보 조회 (인증된 요청)
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [account] 사용자 계정
  /// Returns: 해당 사용자를 위한 기본 정보
  Future<AuthServiceResponse<BaseInfoResponse>> getAuthenticatedBaseInfo(
      String databaseUrl, String account) async {
    try {
      // 기본 정보 조회는 동일하지만, 사용자별 커스터마이징 가능
      final baseInfoResult = await getBaseInfo(databaseUrl);

      if (!baseInfoResult.success) {
        return baseInfoResult;
      }

      // 향후 사용자별 권한이나 커스터마이징이 필요한 경우 여기에 추가
      // 예: 사용자 레벨에 따른 정보 필터링, 개인화된 설정 등

      return AuthServiceResponse.success(
        'Authenticated base information retrieved for user: $account',
        baseInfoResult.data!,
      );
    } catch (e) {
      print('Error getting authenticated base info: $e');
      return AuthServiceResponse.error(
        AuthConstants.messageDatabaseError,
        AuthConstants.errorDatabaseOperation,
      );
    }
  }
}
