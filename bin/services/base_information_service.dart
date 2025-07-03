import 'dart:convert';

import '../models/base_information_models.dart';
import '../services/database_client.dart';

/// 주차장 기본 정보 관리 서비스
class BaseInformationService {
  final DatabaseClient _databaseClient;

  /// 기본 정보 서비스 생성자
  BaseInformationService(this._databaseClient);

  /// 주차장 기본 정보 생성 또는 업데이트
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [request] 기본 정보 요청 데이터
  /// Returns: 생성/업데이트 결과
  Future<BaseInformationServiceResponse<BaseInformation>>
      createOrUpdateBaseInformation(
          String databaseUrl, BaseInformationRequest request) async {
    try {
      // 입력값 유효성 검사
      final validationResult = _validateRequest(request);
      if (!validationResult.success) {
        return validationResult
            as BaseInformationServiceResponse<BaseInformation>;
      }

      // 기존 정보 존재 여부 확인
      final existsCount = await _checkIfInformationExists(databaseUrl);

      if (existsCount == 0) {
        // 새로운 정보 생성
        return await _createBaseInformation(databaseUrl, request);
      } else {
        // 기존 정보 업데이트
        return await _updateBaseInformation(databaseUrl, request);
      }
    } catch (e) {
      print('Error in createOrUpdateBaseInformation: $e');
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageDatabaseError,
        BaseInformationConstants.errorDatabaseOperation,
      );
    }
  }

  /// 주차장 기본 정보 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 기본 정보
  Future<BaseInformationServiceResponse<BaseInformation>> getBaseInformation(
      String databaseUrl) async {
    try {
      final result = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: BaseInformationConstants.queryGetInformation,
      );

      if (result.isEmpty) {
        return BaseInformationServiceResponse.error(
          BaseInformationConstants.messageInformationNotFound,
          BaseInformationConstants.errorInformationNotFound,
        );
      }

      final baseInfo = BaseInformation.fromJson(result.first);

      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageInformationRetrieved,
        baseInfo,
      );
    } catch (e) {
      print('Error in getBaseInformation: $e');
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageDatabaseError,
        BaseInformationConstants.errorDatabaseOperation,
      );
    }
  }

  /// 주차장 통계 정보 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 주차장 통계 정보
  Future<BaseInformationServiceResponse<ParkingLotStatistics>>
      getParkingStatistics(String databaseUrl) async {
    try {
      // 병렬로 총 주차장 수와 사용 중인 주차장 수 조회
      final totalLotsFuture = _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: BaseInformationConstants.queryAllParkingLot,
      );

      final usedLotsFuture = _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: BaseInformationConstants.queryUsedParkingLot,
      );

      final results = await Future.wait([totalLotsFuture, usedLotsFuture]);
      final totalLotsData = results[0];
      final usedLotsData = results[1];

      final totalLots =
          totalLotsData.isNotEmpty ? totalLotsData.first['count'] as int : 0;
      final usedLots =
          usedLotsData.isNotEmpty ? usedLotsData.first['count'] as int : 0;

      final statistics = ParkingLotStatistics.fromCounts(totalLots, usedLots);

      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageStatisticsRetrieved,
        statistics,
      );
    } catch (e) {
      print('Error in getParkingStatistics: $e');
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageDatabaseError,
        BaseInformationConstants.errorDatabaseOperation,
      );
    }
  }

  /// 주차장 기본 정보와 통계를 함께 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 기본 정보 + 통계
  Future<BaseInformationServiceResponse<BaseInformationWithStats>>
      getBaseInformationWithStats(String databaseUrl) async {
    try {
      // 병렬로 기본 정보와 통계 조회
      final baseInfoFuture = getBaseInformation(databaseUrl);
      final statisticsFuture = getParkingStatistics(databaseUrl);

      final results = await Future.wait([baseInfoFuture, statisticsFuture]);
      final baseInfoResult =
          results[0] as BaseInformationServiceResponse<BaseInformation>;
      final statisticsResult =
          results[1] as BaseInformationServiceResponse<ParkingLotStatistics>;

      if (!baseInfoResult.success) {
        return BaseInformationServiceResponse.error(
          baseInfoResult.message,
          baseInfoResult.errorCode,
        );
      }

      if (!statisticsResult.success) {
        return BaseInformationServiceResponse.error(
          statisticsResult.message,
          statisticsResult.errorCode,
        );
      }

      final combined = BaseInformationWithStats(
        baseInfo: baseInfoResult.data!,
        statistics: statisticsResult.data!,
      );

      return BaseInformationServiceResponse.success(
        'Base information and statistics retrieved successfully',
        combined,
      );
    } catch (e) {
      print('Error in getBaseInformationWithStats: $e');
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageDatabaseError,
        BaseInformationConstants.errorDatabaseOperation,
      );
    }
  }

  /// 입력값 유효성 검사
  BaseInformationServiceResponse<dynamic> _validateRequest(
      BaseInformationRequest request) {
    // 필수 필드 검사
    if (!request.isValid()) {
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageMissingFields,
        BaseInformationConstants.errorMissingFields,
      );
    }

    // 좌표 유효성 검사
    if (!request.hasValidCoordinates()) {
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageInvalidCoordinates,
        BaseInformationConstants.errorInvalidCoordinates,
      );
    }

    // 전화번호 형식 검사
    if (!request.hasValidPhoneNumber()) {
      return BaseInformationServiceResponse.error(
        BaseInformationConstants.messageInvalidPhoneNumber,
        BaseInformationConstants.errorInvalidPhoneNumber,
      );
    }

    return BaseInformationServiceResponse.success('Validation passed');
  }

  /// 기존 정보 존재 여부 확인
  Future<int> _checkIfInformationExists(String databaseUrl) async {
    final result = await _databaseClient.executeQuery(
      url: databaseUrl,
      queryId: BaseInformationConstants.queryCheckingExists,
    );

    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  /// 새로운 기본 정보 생성
  Future<BaseInformationServiceResponse<BaseInformation>>
      _createBaseInformation(
          String databaseUrl, BaseInformationRequest request) async {
    await _databaseClient.executeStatement(
      url: databaseUrl,
      statementId: BaseInformationConstants.statementInsertBase,
      values: request.toDatabaseJson(),
    );

    // 생성된 정보 조회하여 반환
    final createdResult = await getBaseInformation(databaseUrl);

    if (createdResult.success) {
      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageInformationCreated,
        createdResult.data!,
      );
    } else {
      // 생성은 성공했지만 조회 실패 시, 생성 성공 메시지 반환
      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageInformationCreated,
      );
    }
  }

  /// 기존 정보 업데이트
  Future<BaseInformationServiceResponse<BaseInformation>>
      _updateBaseInformation(
          String databaseUrl, BaseInformationRequest request) async {
    await _databaseClient.executeStatement(
      url: databaseUrl,
      statementId: BaseInformationConstants.statementUpdateBase,
      values: request.toDatabaseJson(),
    );

    // 업데이트된 정보 조회하여 반환
    final updatedResult = await getBaseInformation(databaseUrl);

    if (updatedResult.success) {
      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageInformationUpdated,
        updatedResult.data!,
      );
    } else {
      // 업데이트는 성공했지만 조회 실패 시, 업데이트 성공 메시지 반환
      return BaseInformationServiceResponse.success(
        BaseInformationConstants.messageInformationUpdated,
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
        queryId: BaseInformationConstants.queryCheckingExists,
      );

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'healthy',
        'database': 'connected',
        'responseTimeMs': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'BaseInformationService',
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'database': 'disconnected',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'BaseInformationService',
      };
    }
  }

  /// 서비스 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'BaseInformationService',
      'version': '1.0.0',
      'description': 'Parking lot base information management service',
      'endpoints': {
        'createOrUpdate': 'Create or update base information',
        'getBaseInformation': 'Retrieve base information',
        'getParkingStatistics': 'Retrieve parking lot statistics',
        'getBaseInformationWithStats':
            'Retrieve base information with statistics',
      },
      'validationFeatures': [
        'Required fields validation',
        'Coordinate format validation',
        'Phone number format validation',
        'Korean region coordinate validation',
      ],
      'supportedOperations': [
        'createOrUpdateBaseInformation',
        'getBaseInformation',
        'getParkingStatistics',
        'getBaseInformationWithStats',
        'getServiceHealth',
      ],
    };
  }

  /// 좌표 유효성 검사 (서비스 레벨)
  ///
  /// [latitude] 위도
  /// [longitude] 경도
  /// Returns: 유효성 검사 결과
  bool validateCoordinates(String latitude, String longitude) {
    final lat = double.tryParse(latitude);
    final lng = double.tryParse(longitude);

    if (lat == null || lng == null) return false;

    // 유효한 위도/경도 범위 확인
    return lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
  }

  /// 한국 영역 내 좌표인지 확인
  ///
  /// [latitude] 위도
  /// [longitude] 경도
  /// Returns: 한국 영역 내 여부
  bool isWithinKoreaRegion(String latitude, String longitude) {
    final lat = double.tryParse(latitude);
    final lng = double.tryParse(longitude);

    if (lat == null || lng == null) return false;

    // 대한민국 영역 (대략적)
    return lat >= 33.0 && lat <= 38.5 && lng >= 124.0 && lng <= 132.0;
  }

  /// 전화번호 포맷팅
  ///
  /// [phoneNumber] 원본 전화번호
  /// Returns: 포맷팅된 전화번호
  String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }

    return phoneNumber; // 포맷팅할 수 없는 경우 원본 반환
  }

  /// 입력 데이터 정리 (트림 및 정규화)
  ///
  /// [request] 원본 요청
  /// Returns: 정리된 요청
  BaseInformationRequest sanitizeRequest(BaseInformationRequest request) {
    return BaseInformationRequest(
      name: request.name.trim(),
      address: request.address.trim(),
      latitude: request.latitude.trim(),
      longitude: request.longitude.trim(),
      manager: request.manager.trim(),
      phoneNumber: request.phoneNumber.trim(),
    );
  }
}
