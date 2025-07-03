import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_zone_models.dart';
import '../utils/file_utils.dart';
import '../data/manage_address.dart';

/// 주차 구역 관리 서비스 클래스
class ParkingZoneService {
  final ManageAddress manageAddress;
  final FileSystemManager _fileManager;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  ParkingZoneService({
    required this.manageAddress,
    FileSystemManager? fileManager,
  }) : _fileManager = fileManager ?? FileSystemManager();

  String? get _dbUrl => manageAddress.displayDbAddr;

  /// 모든 주차 구역 조회
  Future<ParkingZoneServiceResponse<List<ParkingZone>>>
      getAllParkingZones() async {
    try {
      if (_dbUrl == null) {
        throw ParkingZoneServiceException(
          'Database URL not configured',
          ParkingZoneConstants.errorDatabaseOperation,
          500,
        );
      }

      final body = {
        "transaction": [
          {"query": "#S_TbParkingZone"}
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final resultSet = responseData['results'][0]['resultSet'] as List;

      final zones = resultSet
          .map((zoneJson) =>
              ParkingZone.fromJson(zoneJson as Map<String, dynamic>))
          .toList();

      return ParkingZoneServiceResponse.success(
        'Parking zones retrieved successfully',
        zones,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to retrieve parking zones: ${e.toString()}',
        ParkingZoneConstants.errorDatabaseOperation,
        500,
      );
    }
  }

  /// 특정 주차 구역 조회 (파일명으로)
  Future<ParkingZone?> getParkingZoneByName(String parkingName) async {
    try {
      if (_dbUrl == null) {
        throw ParkingZoneServiceException(
          'Database URL not configured',
          ParkingZoneConstants.errorDatabaseOperation,
          500,
        );
      }

      final body = {
        "transaction": [
          {
            "query": "#S_TbPakringZoneName",
            "values": {"parking_name": parkingName}
          }
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      final resultSet = responseData['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return null;
      }

      return ParkingZone.fromJson(resultSet[0] as Map<String, dynamic>);
    } catch (e) {
      throw ParkingZoneServiceException(
        'Failed to get parking zone: ${e.toString()}',
        ParkingZoneConstants.errorDatabaseOperation,
        500,
      );
    }
  }

  /// 파일 업로드 및 주차 구역 생성
  Future<ParkingZoneServiceResponse<ParkingZone>> uploadFile(
      FileUploadRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = ParkingZoneValidator.validateFileUpload(request);
      if (!validation.isValid) {
        throw ParkingZoneServiceException(
          validation.allErrors,
          ParkingZoneConstants.errorValidationFailed,
          400,
        );
      }

      // 동일한 이름의 주차 구역이 이미 존재하는지 확인
      final existingZone = await getParkingZoneByName(request.filename);
      if (existingZone != null) {
        throw ParkingZoneServiceException(
          ParkingZoneConstants.messageZoneAlreadyExists,
          ParkingZoneConstants.errorZoneExists,
          409,
        );
      }

      // 파일 저장
      final fileInfo = await _fileManager.saveFile(
        request.filename,
        request.extension,
        request.content,
      );

      // 데이터베이스에 주차 구역 정보 저장
      final body = {
        "transaction": [
          {
            "statement": "#I_TbPakringZone",
            "values": {
              "parking_name": request.filename,
              "file_address": fileInfo.fullPath,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final newZone = ParkingZone(
        parkingName: request.filename,
        fileAddress: fileInfo.fullPath,
        createdAt: DateTime.now(),
      );

      return ParkingZoneServiceResponse.success(
        ParkingZoneConstants.messageZoneCreated,
        newZone,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to upload file: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
        500,
      );
    }
  }

  /// 파일 삭제 및 주차 구역 삭제
  Future<ParkingZoneServiceResponse<String>> deleteFile(
      FileDeleteRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = ParkingZoneValidator.validateFileDelete(request);
      if (!validation.isValid) {
        throw ParkingZoneServiceException(
          validation.allErrors,
          ParkingZoneConstants.errorValidationFailed,
          400,
        );
      }

      // 주차 구역 정보 조회
      final existingZone = await getParkingZoneByName(request.filename);
      if (existingZone == null) {
        throw ParkingZoneServiceException(
          ParkingZoneConstants.messageZoneNotExists,
          ParkingZoneConstants.errorZoneNotFound,
          404,
        );
      }

      // 파일 삭제
      final fileDeleted =
          await _fileManager.deleteFile(existingZone.fileAddress);
      if (!fileDeleted) {
        print(
            'Warning: File ${existingZone.fileAddress} was not found on disk');
      }

      // 데이터베이스에서 주차 구역 정보 삭제
      final body = {
        "transaction": [
          {
            "statement": "#D_TbPakringZoneName",
            "values": {"parking_name": request.filename}
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return ParkingZoneServiceResponse.success(
        ParkingZoneConstants.messageZoneDeleted,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to delete file: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
        500,
      );
    }
  }

  /// 파일 업데이트 및 주차 구역 업데이트
  Future<ParkingZoneServiceResponse<ParkingZone>> updateFile(
      FileUpdateRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = ParkingZoneValidator.validateFileUpdate(request);
      if (!validation.isValid) {
        throw ParkingZoneServiceException(
          validation.allErrors,
          ParkingZoneConstants.errorValidationFailed,
          400,
        );
      }

      // 기존 주차 구역 정보 조회
      final existingZone = await getParkingZoneByName(request.oldFilename);
      if (existingZone == null) {
        throw ParkingZoneServiceException(
          ParkingZoneConstants.messageZoneNotExists,
          ParkingZoneConstants.errorZoneNotFound,
          404,
        );
      }

      // 새 파일명으로 이미 존재하는 주차 구역이 있는지 확인 (같은 이름이 아닌 경우)
      if (request.newFilename != request.oldFilename) {
        final existingNewZone = await getParkingZoneByName(request.newFilename);
        if (existingNewZone != null) {
          throw ParkingZoneServiceException(
            ParkingZoneConstants.messageZoneAlreadyExists,
            ParkingZoneConstants.errorZoneExists,
            409,
          );
        }
      }

      // 파일 업데이트 (기존 파일 삭제 후 새 파일 저장)
      final fileInfo = await _fileManager.updateFile(
        existingZone.fileAddress,
        request.newFilename,
        request.extension,
        request.content,
      );

      // 데이터베이스 업데이트 (트랜잭션으로 처리)
      final transactions = <Map<String, dynamic>>[];

      // 새 레코드 추가
      transactions.add({
        "statement": "#I_TbPakringZone",
        "values": {
          "parking_name": request.newFilename,
          "file_address": fileInfo.fullPath,
        }
      });

      // 기존 레코드 삭제 (이름이 다른 경우에만)
      if (request.newFilename != request.oldFilename) {
        transactions.add({
          "statement": "#D_TbPakringZoneName",
          "values": {"parking_name": request.oldFilename}
        });
      }

      final body = {
        "transaction": transactions,
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      final updatedZone = ParkingZone(
        parkingName: request.newFilename,
        fileAddress: fileInfo.fullPath,
        updatedAt: DateTime.now(),
      );

      return ParkingZoneServiceResponse.success(
        ParkingZoneConstants.messageZoneUpdated,
        updatedZone,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to update file: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
        500,
      );
    }
  }

  /// 주차 공간 유형 변경
  Future<ParkingZoneServiceResponse<String>> changeLotType(
      LotTypeChangeRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation = ParkingZoneValidator.validateLotTypeChange(request);
      if (!validation.isValid) {
        throw ParkingZoneServiceException(
          validation.allErrors,
          ParkingZoneConstants.errorValidationFailed,
          400,
        );
      }

      // 데이터베이스 업데이트
      final body = {
        "transaction": [
          {
            "statement": "#U_LotType",
            "values": {
              "changed_tag": request.changedTag,
              "tag": request.tag,
              "lot_type": request.lotType,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return ParkingZoneServiceResponse.success(
        ParkingZoneConstants.messageLotTypeChanged,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to change lot type: ${e.toString()}',
        ParkingZoneConstants.errorDatabaseOperation,
        500,
      );
    }
  }

  /// 주차 상태 변경
  Future<ParkingZoneServiceResponse<String>> changeParkingStatus(
      ParkingStatusChangeRequest request) async {
    try {
      // 입력값 유효성 검사
      final validation =
          ParkingZoneValidator.validateParkingStatusChange(request);
      if (!validation.isValid) {
        throw ParkingZoneServiceException(
          validation.allErrors,
          ParkingZoneConstants.errorValidationFailed,
          400,
        );
      }

      // 데이터베이스 업데이트
      final body = {
        "transaction": [
          {
            "statement": "#U_Parked",
            "values": {
              "parked": request.parked,
              "tag": request.tag,
            }
          },
        ]
      };

      await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      return ParkingZoneServiceResponse.success(
        ParkingZoneConstants.messageParkingStatusChanged,
      );
    } catch (e) {
      if (e is ParkingZoneServiceException) rethrow;

      throw ParkingZoneServiceException(
        'Failed to change parking status: ${e.toString()}',
        ParkingZoneConstants.errorDatabaseOperation,
        500,
      );
    }
  }

  /// 주차 구역 존재 여부 확인
  Future<bool> parkingZoneExists(String parkingName) async {
    try {
      final zone = await getParkingZoneByName(parkingName);
      return zone != null;
    } catch (e) {
      return false;
    }
  }

  /// 파일 시스템의 모든 파일 목록 조회
  Future<List<FileInfo>> getAllFiles() async {
    try {
      return await _fileManager.listFiles();
    } catch (e) {
      throw ParkingZoneServiceException(
        'Failed to list files: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
        500,
      );
    }
  }

  /// 서비스 상태 확인
  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final zonesResponse = await getAllParkingZones();
      final zoneCount = zonesResponse.data?.length ?? 0;

      final files = await getAllFiles();
      final fileCount = files.length;

      return {
        'status': 'healthy',
        'dbUrl': _dbUrl != null ? 'configured' : 'not_configured',
        'zoneCount': zoneCount,
        'fileCount': fileCount,
        'fileDirectory': _fileManager.baseDirectory,
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

  /// 리소스 정리
  void dispose() {
    // 필요한 경우 여기서 리소스 정리
  }
}
