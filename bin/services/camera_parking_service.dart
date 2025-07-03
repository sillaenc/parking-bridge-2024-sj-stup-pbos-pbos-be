import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/camera_parking_models.dart';
import '../utils/camera_parking_validator.dart';
import '../services/database_client.dart';

/// 카메라 주차 표면 관리 서비스
class CameraParkingSurfaceService {
  final DatabaseClient _databaseClient;

  /// 서비스 생성자
  CameraParkingSurfaceService(this._databaseClient);

  /// 모든 카메라 주차 표면 조회
  Future<CameraParkingSurfaceServiceResponse<List<CameraParkingSurface>>>
      getAllSurfaces(String databaseUrl) async {
    try {
      final resultSet = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_TbParkingSurface",
      );

      if (resultSet.isEmpty) {
        return CameraParkingSurfaceServiceResponse.success(
          CameraParkingSurfaceConstants.messageSurfacesRetrieved,
          <CameraParkingSurface>[],
        );
      }

      final surfaces = resultSet
          .map<CameraParkingSurface>(
              (data) => CameraParkingSurface.fromJson(data))
          .toList();

      return CameraParkingSurfaceServiceResponse.success(
        CameraParkingSurfaceConstants.messageSurfacesRetrieved,
        surfaces,
      );
    } catch (e) {
      print('Error getting all surfaces: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }

  /// 태그로 특정 카메라 주차 표면 조회
  Future<CameraParkingSurfaceServiceResponse<CameraParkingSurface?>>
      getSurfaceByTag(String databaseUrl, String tag) async {
    try {
      // 태그 유효성 검사
      if (!CameraParkingSurfaceValidator.isValidTag(tag)) {
        return CameraParkingSurfaceServiceResponse.error(
          CameraParkingSurfaceConstants.messageInvalidTag,
          CameraParkingSurfaceConstants.errorInvalidTag,
        );
      }

      final resultSet = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_TbParkingSurfaceTag",
        values: {"tag": tag},
      );

      if (resultSet.isEmpty) {
        return CameraParkingSurfaceServiceResponse.error(
          CameraParkingSurfaceConstants.messageSurfaceNotExists,
          CameraParkingSurfaceConstants.errorSurfaceNotFound,
        );
      }

      final surface = CameraParkingSurface.fromJson(resultSet.first);
      return CameraParkingSurfaceServiceResponse.success(
        CameraParkingSurfaceConstants.messageSurfaceRetrieved,
        surface,
      );
    } catch (e) {
      print('Error getting surface by tag: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }

  /// 새 카메라 주차 표면 생성
  Future<CameraParkingSurfaceServiceResponse<CameraParkingSurface>>
      createSurface(
          String databaseUrl, CreateCameraParkingSurfaceRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation =
          CameraParkingSurfaceValidator.validateCreateRequest(request);
      if (!validation.isValid) {
        return CameraParkingSurfaceServiceResponse.error(
          validation.firstError,
          CameraParkingSurfaceConstants.errorValidationFailed,
        );
      }

      // 태그 중복 검사
      final existingCheck = await getSurfaceByTag(databaseUrl, request.tag);
      if (existingCheck.success) {
        return CameraParkingSurfaceServiceResponse.error(
          CameraParkingSurfaceConstants.messageSurfaceAlreadyExists,
          CameraParkingSurfaceConstants.errorSurfaceExists,
        );
      }

      // 새 표면 생성
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: "#I_TbParkingSurface",
        values: {
          "tag": request.tag,
          "engine_code": request.engineCode,
          "uri": request.uri
        },
      );

      // 생성된 표면 조회하여 반환
      final createdSurface = await getSurfaceByTag(databaseUrl, request.tag);
      if (createdSurface.success && createdSurface.data != null) {
        return CameraParkingSurfaceServiceResponse.success(
          CameraParkingSurfaceConstants.messageSurfaceCreated,
          createdSurface.data!,
        );
      } else {
        // 생성은 성공했지만 조회 실패한 경우
        final surface = CameraParkingSurface(
          tag: request.tag,
          engineCode: request.engineCode,
          uri: request.uri,
        );

        return CameraParkingSurfaceServiceResponse.success(
          CameraParkingSurfaceConstants.messageSurfaceCreated,
          surface,
        );
      }
    } catch (e) {
      print('Error creating surface: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }

  /// 카메라 주차 표면 정보 업데이트
  Future<CameraParkingSurfaceServiceResponse<CameraParkingSurface>>
      updateSurface(String databaseUrl, String targetTag,
          UpdateCameraParkingSurfaceRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation =
          CameraParkingSurfaceValidator.validateUpdateRequest(request);
      if (!validation.isValid) {
        return CameraParkingSurfaceServiceResponse.error(
          validation.firstError,
          CameraParkingSurfaceConstants.errorValidationFailed,
        );
      }

      // 대상 표면이 존재하는지 확인
      final beforeTag = request.beforeTag ?? targetTag;
      final existingResponse = await getSurfaceByTag(databaseUrl, beforeTag);
      if (!existingResponse.success || existingResponse.data == null) {
        return CameraParkingSurfaceServiceResponse.error(
          CameraParkingSurfaceConstants.messageSurfaceNotExists,
          CameraParkingSurfaceConstants.errorSurfaceNotFound,
        );
      }

      final existingSurface = existingResponse.data!;

      // 태그가 변경되는 경우 중복 검사
      if (request.tag != beforeTag) {
        final duplicateCheck = await getSurfaceByTag(databaseUrl, request.tag);
        if (duplicateCheck.success) {
          return CameraParkingSurfaceServiceResponse.error(
            CameraParkingSurfaceConstants.messageSurfaceAlreadyExists,
            CameraParkingSurfaceConstants.errorSurfaceExists,
          );
        }
      }

      // 업데이트 실행
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: "#U_TbParkingSurface",
        values: {
          "tag": request.tag,
          "engine_code": request.engineCode,
          "uri": request.uri,
          "uid": existingSurface.uid!,
        },
      );

      // 업데이트된 표면 정보 반환
      final updatedSurface = existingSurface.copyWith(
        tag: request.tag,
        engineCode: request.engineCode,
        uri: request.uri,
        updatedAt: DateTime.now(),
      );

      return CameraParkingSurfaceServiceResponse.success(
        CameraParkingSurfaceConstants.messageSurfaceUpdated,
        updatedSurface,
      );
    } catch (e) {
      print('Error updating surface: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }

  /// 카메라 주차 표면 삭제
  Future<CameraParkingSurfaceServiceResponse<void>> deleteSurface(
      String databaseUrl, String tag) async {
    try {
      // 입력값 유효성 검사
      final deleteRequest = DeleteCameraParkingSurfaceRequest(tag: tag);
      final validation =
          CameraParkingSurfaceValidator.validateDeleteRequest(deleteRequest);
      if (!validation.isValid) {
        return CameraParkingSurfaceServiceResponse.error(
          validation.firstError,
          CameraParkingSurfaceConstants.errorValidationFailed,
        );
      }

      // 대상 표면이 존재하는지 확인
      final existingResponse = await getSurfaceByTag(databaseUrl, tag);
      if (!existingResponse.success) {
        return CameraParkingSurfaceServiceResponse.error(
          CameraParkingSurfaceConstants.messageSurfaceNotExists,
          CameraParkingSurfaceConstants.errorSurfaceNotFound,
        );
      }

      // 삭제 실행
      await _databaseClient.executeStatement(
        url: databaseUrl,
        statementId: "#D_TbParkingSurface",
        values: {"tag": tag},
      );

      return CameraParkingSurfaceServiceResponse.success(
        CameraParkingSurfaceConstants.messageSurfaceDeleted,
      );
    } catch (e) {
      print('Error deleting surface: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }

  /// 서비스 상태 확인
  Future<Map<String, dynamic>> getServiceHealth(String databaseUrl) async {
    try {
      final startTime = DateTime.now();

      // 간단한 쿼리로 데이터베이스 연결 테스트
      await getAllSurfaces(databaseUrl);

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'status': 'healthy',
        'database': 'connected',
        'responseTimeMs': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'CameraParkingSurfaceService',
      };
    } catch (e) {
      return {
        'status': 'unhealthy',
        'database': 'disconnected',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'service': 'CameraParkingSurfaceService',
      };
    }
  }

  /// 서비스 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'CameraParkingSurfaceService',
      'version': '1.0.0',
      'description': 'Camera parking surface management service',
      'endpoints': {
        'getAllSurfaces': 'Retrieve all camera parking surfaces',
        'getSurfaceByTag': 'Retrieve specific surface by tag',
        'createSurface': 'Create new camera parking surface',
        'updateSurface': 'Update existing surface information',
        'deleteSurface': 'Delete camera parking surface',
      },
      'validationRules': {
        'tag':
            'Alphanumeric, underscore, hyphen only (max ${CameraParkingSurfaceConstants.maxTagLength} chars)',
        'engineCode':
            'Alphanumeric only (max ${CameraParkingSurfaceConstants.maxEngineCodeLength} chars)',
        'uri':
            'Valid HTTP/HTTPS URL (max ${CameraParkingSurfaceConstants.maxUriLength} chars)',
      },
    };
  }

  /// 일괄 표면 생성
  Future<CameraParkingSurfaceServiceResponse<List<CameraParkingSurface>>>
      createMultipleSurfaces(String databaseUrl,
          List<CreateCameraParkingSurfaceRequest> requests) async {
    try {
      // 일괄 유효성 검사
      final validationResults =
          CameraParkingSurfaceValidator.validateMultipleSurfaces(requests);
      final invalidResults =
          validationResults.entries.where((entry) => !entry.value.isValid);

      if (invalidResults.isNotEmpty) {
        final errors = invalidResults
            .map((entry) => '${entry.key}: ${entry.value.allErrors}')
            .join('; ');
        return CameraParkingSurfaceServiceResponse.error(
          'Validation failed: $errors',
          CameraParkingSurfaceConstants.errorValidationFailed,
        );
      }

      final createdSurfaces = <CameraParkingSurface>[];
      final errors = <String>[];

      // 순차적으로 표면 생성 (트랜잭션 제한으로 인해)
      for (final request in requests) {
        final result = await createSurface(databaseUrl, request);
        if (result.success && result.data != null) {
          createdSurfaces.add(result.data!);
        } else {
          errors.add(
              'Failed to create surface ${request.tag}: ${result.message}');
        }
      }

      if (errors.isNotEmpty) {
        return CameraParkingSurfaceServiceResponse.error(
          'Partial failure: ${errors.join('; ')}',
          CameraParkingSurfaceConstants.errorDatabaseOperation,
        );
      }

      return CameraParkingSurfaceServiceResponse.success(
        'Successfully created ${createdSurfaces.length} camera parking surfaces',
        createdSurfaces,
      );
    } catch (e) {
      print('Error creating multiple surfaces: $e');
      return CameraParkingSurfaceServiceResponse.error(
        CameraParkingSurfaceConstants.messageDatabaseError,
        CameraParkingSurfaceConstants.errorDatabaseOperation,
      );
    }
  }
}
