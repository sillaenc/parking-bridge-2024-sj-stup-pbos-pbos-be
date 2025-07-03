import 'dart:convert';

import '../models/electric_sign_models.dart';
import '../services/database_client.dart';

/// 다중 전광판 관리 서비스
class ElectricSignService {
  final DatabaseClient _databaseClient;

  /// 전광판 서비스 생성자
  ElectricSignService(this._databaseClient);

  /// 모든 전광판 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 전광판 목록
  Future<ElectricSignServiceResponse<List<ElectricSign>>> getAllElectricSigns(
      String databaseUrl) async {
    try {
      final result = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: ElectricSignConstants.querySelectAll,
      );

      final signs = result.map((data) => ElectricSign.fromJson(data)).toList();

      return ElectricSignServiceResponse.success(
        ElectricSignConstants.messageSignsRetrieved,
        signs,
      );
    } catch (e) {
      print('Error in getAllElectricSigns: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 특정 UID의 전광판 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [uid] 전광판 UID
  /// Returns: 전광판 정보
  Future<ElectricSignServiceResponse<ElectricSign>> getElectricSignByUid(
      String databaseUrl, int uid) async {
    try {
      // UID 유효성 검사
      if (!ElectricSignConstants.isValidUid(uid)) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.getUidRangeErrorMessage(),
          ElectricSignConstants.errorInvalidUid,
        );
      }

      // 모든 전광판을 조회한 후 필터링 (단일 조회 쿼리가 없는 경우)
      final allSignsResult = await getAllElectricSigns(databaseUrl);

      if (!allSignsResult.success) {
        return ElectricSignServiceResponse.error(
          allSignsResult.message,
          allSignsResult.errorCode,
        );
      }

      final sign = allSignsResult.data!.firstWhere(
        (sign) => sign.uid == uid,
        orElse: () => throw StateError('Sign not found'),
      );

      return ElectricSignServiceResponse.success(
        ElectricSignConstants.messageSignRetrieved,
        sign,
      );
    } catch (e) {
      if (e is StateError) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageSignNotFound,
          ElectricSignConstants.errorSignNotFound,
        );
      }

      print('Error in getElectricSignByUid: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 새 전광판 생성
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [request] 전광판 생성 요청
  /// Returns: 생성된 전광판 정보
  Future<ElectricSignServiceResponse<ElectricSign>> createElectricSign(
      String databaseUrl, CreateElectricSignRequest request) async {
    try {
      // 입력값 유효성 검사
      final validationResult = _validateCreateRequest(request);
      if (!validationResult.isValid) {
        return ElectricSignServiceResponse.error(
          validationResult.allErrors,
          ElectricSignConstants.errorValidationFailed,
        );
      }

      // 중복 UID 확인
      final existingSign = await getElectricSignByUid(databaseUrl, request.uid);
      if (existingSign.success) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageSignExists,
          ElectricSignConstants.errorSignExists,
        );
      }

      // 전광판 생성
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: ElectricSignConstants.statementInsert,
        values: request.toDatabaseJson(),
      );

      // 생성된 전광판 조회하여 반환
      final createdSign = await getElectricSignByUid(databaseUrl, request.uid);

      if (createdSign.success) {
        return ElectricSignServiceResponse.success(
          ElectricSignConstants.messageSignCreated,
          createdSign.data!,
        );
      } else {
        // 생성은 성공했지만 조회 실패 시, 생성 성공 메시지 반환
        return ElectricSignServiceResponse.success(
          ElectricSignConstants.messageSignCreated,
          request.toElectricSign(),
        );
      }
    } catch (e) {
      print('Error in createElectricSign: $e');

      // HTTP 409 상태 코드 관련 에러인지 확인
      if (e.toString().contains('409') ||
          e.toString().toLowerCase().contains('exists')) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageSignExists,
          ElectricSignConstants.errorSignExists,
        );
      }

      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 전광판 정보 업데이트
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [uid] 업데이트할 전광판 UID
  /// [request] 업데이트 요청
  /// Returns: 업데이트된 전광판 정보
  Future<ElectricSignServiceResponse<ElectricSign>> updateElectricSign(
      String databaseUrl, int uid, UpdateElectricSignRequest request) async {
    try {
      // UID 유효성 검사
      if (!ElectricSignConstants.isValidUid(uid)) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.getUidRangeErrorMessage(),
          ElectricSignConstants.errorInvalidUid,
        );
      }

      // 입력값 유효성 검사
      final validationResult = _validateUpdateRequest(request);
      if (!validationResult.isValid) {
        return ElectricSignServiceResponse.error(
          validationResult.allErrors,
          ElectricSignConstants.errorValidationFailed,
        );
      }

      // 기존 전광판 존재 확인
      final existingSign = await getElectricSignByUid(databaseUrl, uid);
      if (!existingSign.success) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageSignNotFound,
          ElectricSignConstants.errorSignNotFound,
        );
      }

      // 전광판 업데이트
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: ElectricSignConstants.statementUpdate,
        values: request.toDatabaseJson(uid),
      );

      // 업데이트된 전광판 조회하여 반환
      final updatedSign = await getElectricSignByUid(databaseUrl, uid);

      if (updatedSign.success) {
        return ElectricSignServiceResponse.success(
          ElectricSignConstants.messageSignUpdated,
          updatedSign.data!,
        );
      } else {
        // 업데이트는 성공했지만 조회 실패 시, 업데이트 성공 메시지 반환
        return ElectricSignServiceResponse.success(
          ElectricSignConstants.messageSignUpdated,
          existingSign.data!.copyWith(parkingLot: request.parkingLot),
        );
      }
    } catch (e) {
      print('Error in updateElectricSign: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 전광판 삭제
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [uid] 삭제할 전광판 UID
  /// Returns: 삭제 결과
  Future<ElectricSignServiceResponse<void>> deleteElectricSign(
      String databaseUrl, int uid) async {
    try {
      // UID 유효성 검사
      if (!ElectricSignConstants.isValidUid(uid)) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.getUidRangeErrorMessage(),
          ElectricSignConstants.errorInvalidUid,
        );
      }

      // 기존 전광판 존재 확인
      final existingSign = await getElectricSignByUid(databaseUrl, uid);
      if (!existingSign.success) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageSignNotFound,
          ElectricSignConstants.errorSignNotFound,
        );
      }

      // 전광판 삭제
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: ElectricSignConstants.statementDelete,
        values: {'uid': uid},
      );

      return ElectricSignServiceResponse.success(
        ElectricSignConstants.messageSignDeleted,
      );
    } catch (e) {
      print('Error in deleteElectricSign: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 전광판 통계 정보 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// Returns: 전광판 통계 정보
  Future<ElectricSignServiceResponse<ElectricSignStatistics>>
      getElectricSignStatistics(String databaseUrl) async {
    try {
      final allSignsResult = await getAllElectricSigns(databaseUrl);

      if (!allSignsResult.success) {
        return ElectricSignServiceResponse.error(
          allSignsResult.message,
          allSignsResult.errorCode,
        );
      }

      final signs = allSignsResult.data!;
      final signsByParkingLot = <String, int>{};

      for (final sign in signs) {
        signsByParkingLot[sign.parkingLot] =
            (signsByParkingLot[sign.parkingLot] ?? 0) + 1;
      }

      final statistics = ElectricSignStatistics(
        totalSigns: signs.length,
        lastUpdated: DateTime.now(),
        signsByParkingLot: signsByParkingLot,
      );

      return ElectricSignServiceResponse.success(
        'Electric sign statistics retrieved successfully',
        statistics,
      );
    } catch (e) {
      print('Error in getElectricSignStatistics: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 생성 요청 유효성 검사
  ElectricSignValidationResult _validateCreateRequest(
      CreateElectricSignRequest request) {
    final errors = <String>[];

    // UID 유효성 검사
    if (!ElectricSignConstants.isValidUid(request.uid)) {
      errors.add(ElectricSignConstants.getUidRangeErrorMessage());
    }

    // 주차장 정보 유효성 검사
    if (!ElectricSignConstants.isValidParkingLot(request.parkingLot)) {
      if (request.parkingLot.trim().isEmpty) {
        errors.add(ElectricSignConstants.messageEmptyParkingLot);
      } else {
        errors.add(ElectricSignConstants.getParkingLotLengthErrorMessage());
      }
    }

    return errors.isEmpty
        ? ElectricSignValidationResult.valid()
        : ElectricSignValidationResult.invalid(errors);
  }

  /// 업데이트 요청 유효성 검사
  ElectricSignValidationResult _validateUpdateRequest(
      UpdateElectricSignRequest request) {
    final errors = <String>[];

    // 주차장 정보 유효성 검사
    if (!ElectricSignConstants.isValidParkingLot(request.parkingLot)) {
      if (request.parkingLot.trim().isEmpty) {
        errors.add(ElectricSignConstants.messageEmptyParkingLot);
      } else {
        errors.add(ElectricSignConstants.getParkingLotLengthErrorMessage());
      }
    }

    return errors.isEmpty
        ? ElectricSignValidationResult.valid()
        : ElectricSignValidationResult.invalid(errors);
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
        queryId: ElectricSignConstants.querySelectAll,
      );

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'healthy',
        'database': 'connected',
        'responseTimeMs': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'ElectricSignService',
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'database': 'disconnected',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'ElectricSignService',
      };
    }
  }

  /// 서비스 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'ElectricSignService',
      'version': '1.0.0',
      'description': 'Multiple electric signs management service',
      'endpoints': {
        'getAllElectricSigns': 'Retrieve all electric signs',
        'getElectricSignByUid': 'Retrieve electric sign by UID',
        'createElectricSign': 'Create new electric sign',
        'updateElectricSign': 'Update electric sign information',
        'deleteElectricSign': 'Delete electric sign',
        'getElectricSignStatistics': 'Retrieve electric sign statistics',
      },
      'validationFeatures': [
        'UID range validation (1-999999)',
        'Parking lot information validation',
        'Duplicate UID prevention',
        'Input sanitization',
      ],
      'supportedOperations': [
        'getAllElectricSigns',
        'getElectricSignByUid',
        'createElectricSign',
        'updateElectricSign',
        'deleteElectricSign',
        'getElectricSignStatistics',
        'getServiceHealth',
      ],
    };
  }

  /// 주차장별 전광판 조회
  ///
  /// [databaseUrl] 데이터베이스 서버 URL
  /// [parkingLot] 주차장 정보
  /// Returns: 해당 주차장의 전광판 목록
  Future<ElectricSignServiceResponse<List<ElectricSign>>>
      getElectricSignsByParkingLot(
          String databaseUrl, String parkingLot) async {
    try {
      if (parkingLot.trim().isEmpty) {
        return ElectricSignServiceResponse.error(
          ElectricSignConstants.messageEmptyParkingLot,
          ElectricSignConstants.errorEmptyParkingLot,
        );
      }

      final allSignsResult = await getAllElectricSigns(databaseUrl);

      if (!allSignsResult.success) {
        return ElectricSignServiceResponse.error(
          allSignsResult.message,
          allSignsResult.errorCode,
        );
      }

      final filteredSigns = allSignsResult.data!
          .where((sign) => sign.parkingLot == parkingLot.trim())
          .toList();

      return ElectricSignServiceResponse.success(
        'Electric signs for parking lot "$parkingLot" retrieved successfully',
        filteredSigns,
      );
    } catch (e) {
      print('Error in getElectricSignsByParkingLot: $e');
      return ElectricSignServiceResponse.error(
        ElectricSignConstants.messageDatabaseError,
        ElectricSignConstants.errorDatabaseOperation,
      );
    }
  }

  /// 입력 데이터 정리 (트림 및 정규화)
  ///
  /// [request] 원본 생성 요청
  /// Returns: 정리된 요청
  CreateElectricSignRequest sanitizeCreateRequest(
      CreateElectricSignRequest request) {
    return CreateElectricSignRequest(
      uid: request.uid,
      parkingLot: request.parkingLot.trim(),
    );
  }

  /// 업데이트 요청 데이터 정리
  ///
  /// [request] 원본 업데이트 요청
  /// Returns: 정리된 요청
  UpdateElectricSignRequest sanitizeUpdateRequest(
      UpdateElectricSignRequest request) {
    return UpdateElectricSignRequest(
      parkingLot: request.parkingLot.trim(),
    );
  }

  /// UID 범위 유효성 검사
  ///
  /// [uid] 검사할 UID
  /// Returns: 유효성 검사 결과
  bool isValidUidRange(int uid) {
    return ElectricSignConstants.isValidUid(uid);
  }

  /// 주차장 정보 유효성 검사
  ///
  /// [parkingLot] 검사할 주차장 정보
  /// Returns: 유효성 검사 결과
  bool isValidParkingLotInfo(String parkingLot) {
    return ElectricSignConstants.isValidParkingLot(parkingLot);
  }
}
