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
      // 디렉토리 존재 확인 및 생성
      await _fileManager.ensureDirectoryExists();

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

      // 1. 파일 메타데이터 저장을 위한 정보 준비
      final fileExtension = fileInfo.extension.toLowerCase();
      final fileCategory = _determineFileCategory(fileExtension);
      final mimeType = _determineMimeType(fileExtension);

      // 2. 새로운 파일 관리 시스템과 기존 시스템 동시 저장
      final body = {
        "transaction": [
          // 새로운 파일 관리 테이블에 파일 정보 저장
          {
            "statement": "#I_File",
            "values": {
              "filename": request.filename,
              "original_filename": request.filename,
              "file_path": fileInfo.fullPath,
              "file_type": fileExtension,
              "file_category": fileCategory,
              "file_size": fileInfo.sizeBytes,
              "mime_type": mimeType,
              "description": '주차구역 파일: ${request.filename}',
            }
          },
          // 기존 주차구역 테이블에 저장 (하위 호환성)
          {
            "statement": "#I_TbPakringZone",
            "values": {
              "parking_name": request.filename,
              "file_address": fileInfo.fullPath,
            }
          },
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        // 데이터베이스 저장 실패 시 파일 삭제
        await _fileManager.deleteFile(request.filename);
        throw ParkingZoneServiceException(
          'Database operation failed: ${response.body}',
          ParkingZoneConstants.errorFileOperation,
          500,
        );
      }

      final newZone = ParkingZone(
        parkingName: request.filename,
        fileAddress: fileInfo.fullPath,
        createdAt: DateTime.now(),
      );

      // 파일시스템 동기화 수행
      await _syncFileSystem();

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

      // 새로운 파일 관리 시스템과 기존 시스템에서 동시 삭제
      final body = {
        "transaction": [
          // 파일 메타데이터를 소프트 삭제 (is_active = 0)
          {
            "statement": "#D_File_Soft",
            "values": {"filename": request.filename}
          },
          // 기존 주차구역 테이블에서 삭제 (하위 호환성)
          {
            "statement": "#D_TbPakringZoneName",
            "values": {"parking_name": request.filename}
          },
        ]
      };

      final response = await http.post(
        Uri.parse(_dbUrl!),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print('⚠️ 데이터베이스 삭제 중 오류 발생: ${response.body}');
        // 파일은 이미 삭제되었으므로 경고만 출력
      }

      // 파일시스템 동기화 수행
      await _syncFileSystem();

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

      // 파일시스템 동기화 수행
      await _syncFileSystem();

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

  /// 파일시스템과 데이터베이스 동기화
  /// 파일 업로드/업데이트/삭제 시 자동으로 호출되어 일관성 유지
  Future<void> _syncFileSystem() async {
    try {
      print('🔄 파일시스템 동기화를 시작합니다...');

      // 1. 파일시스템에서 고아 파일이 된 DB 레코드 정리
      await _cleanupOrphanedDbRecords();

      // 2. 파일시스템에 있지만 DB에 없는 파일들을 DB에 추가
      await _addMissingFilesToDb();

      // 3. DB에서 모든 등록된 파일 경로 조회 (기존 로직 유지)
      final allZones = await getAllParkingZones();
      final validFilePaths = <String>[];

      if (allZones.success && allZones.data != null) {
        for (final zone in allZones.data!) {
          validFilePaths.add(zone.fileAddress);
        }
      }

      // 4. 파일시스템에서 고아 파일 정리
      final deletedCount =
          await _fileManager.cleanupOrphanedFiles(validFilePaths);

      if (deletedCount > 0) {
        print('🗑️  $deletedCount개의 고아 파일이 정리되었습니다.');
      }

      // 3. 파일시스템 상태 보고서 생성
      final report = await _fileManager.getFileSystemReport();
      print('📊 파일시스템 상태:');
      print('   • 전체 파일: ${report['totalFiles']}개');
      print('   • 전체 크기: ${report['totalSizeMB']}MB');
      print('   • 지원 파일: ${report['supportedFiles']}개');
      print('   • 미지원 파일: ${report['unsupportedFiles']}개');
    } catch (e) {
      print('❌ 파일시스템 동기화 중 오류: $e');
      // 동기화 실패해도 메인 작업은 계속 진행
    }
  }

  /// 수동 파일시스템 동기화 (관리자용)
  Future<ParkingZoneServiceResponse<Map<String, dynamic>>>
      syncFileSystemManually() async {
    try {
      final startTime = DateTime.now();

      // 동기화 실행
      await _syncFileSystem();

      // 상세 보고서 생성
      final report = await _fileManager.getFileSystemReport();
      final allZones = await getAllParkingZones();

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      final syncReport = {
        ...report,
        'syncDurationMs': duration,
        'syncedAt': endTime.toIso8601String(),
        'totalParkingZones': allZones.data?.length ?? 0,
        'status': 'completed',
      };

      return ParkingZoneServiceResponse.success(
        '파일시스템 동기화가 완료되었습니다.',
        syncReport,
      );
    } catch (e) {
      return ParkingZoneServiceResponse.error(
        '파일시스템 동기화 실패: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
      );
    }
  }

  /// 파일시스템 상태 확인 (진단용)
  Future<ParkingZoneServiceResponse<Map<String, dynamic>>>
      checkFileSystemHealth() async {
    try {
      // 파일시스템 보고서 생성
      final report = await _fileManager.getFileSystemReport();

      // DB 정보 추가
      final allZones = await getAllParkingZones();
      final dbFileCount = allZones.data?.length ?? 0;

      // 고아 파일 찾기 (정리하지는 않고 찾기만)
      final orphanedFiles = await _fileManager.getOrphanedFiles();

      final healthReport = {
        ...report,
        'databaseRecords': dbFileCount,
        'orphanedFiles': orphanedFiles.length,
        'orphanedFilesList': orphanedFiles
            .map((f) => {
                  'filename': f.filename,
                  'path': f.fullPath,
                  'size': f.sizeBytes,
                  'extension': f.extension,
                })
            .toList(),
        'isHealthy': report['unsupportedFiles'] == 0 && orphanedFiles.isEmpty,
        'checkedAt': DateTime.now().toIso8601String(),
      };

      return ParkingZoneServiceResponse.success(
        '파일시스템 상태 확인이 완료되었습니다.',
        healthReport,
      );
    } catch (e) {
      return ParkingZoneServiceResponse.error(
        '파일시스템 상태 확인 실패: ${e.toString()}',
        ParkingZoneConstants.errorFileOperation,
      );
    }
  }

  /// 파일 확장자를 기반으로 파일 카테고리 결정
  String _determineFileCategory(String extension) {
    const imageExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'tiff',
      'ico'
    ];
    const videoExtensions = [
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'webm',
      'mkv',
      'mpg',
      'mpeg',
      'm4v',
      '3gp'
    ];
    const documentExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx'
    ];
    const dataExtensions = ['json', 'xml', 'txt', 'csv', 'yaml', 'yml'];
    const archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];

    if (imageExtensions.contains(extension)) return 'image';
    if (videoExtensions.contains(extension)) return 'video';
    if (documentExtensions.contains(extension)) return 'document';
    if (dataExtensions.contains(extension)) return 'data';
    if (archiveExtensions.contains(extension)) return 'archive';

    return 'other';
  }

  /// 파일 확장자를 기반으로 MIME 타입 결정
  String _determineMimeType(String extension) {
    const mimeTypes = {
      // 이미지
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'bmp': 'image/bmp',
      'webp': 'image/webp',
      'tiff': 'image/tiff',
      'ico': 'image/x-icon',

      // 영상
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
      'wmv': 'video/x-ms-wmv',
      'flv': 'video/x-flv',
      'webm': 'video/webm',
      'mkv': 'video/x-matroska',
      'mpg': 'video/mpeg',
      'mpeg': 'video/mpeg',
      'm4v': 'video/x-m4v',
      '3gp': 'video/3gpp',

      // 문서
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',

      // 데이터
      'json': 'application/json',
      'xml': 'application/xml',
      'txt': 'text/plain',
      'csv': 'text/csv',
      'yaml': 'application/x-yaml',
      'yml': 'application/x-yaml',

      // 압축
      'zip': 'application/zip',
      'rar': 'application/vnd.rar',
      '7z': 'application/x-7z-compressed',
      'tar': 'application/x-tar',
      'gz': 'application/gzip',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  /// 파일시스템에서 고아 파일이 된 DB 레코드 정리
  Future<void> _cleanupOrphanedDbRecords() async {
    try {
      print('🔍 고아 DB 레코드 정리 중...');

      // DB에서 파일 경로가 파일시스템에 존재하지 않는 레코드들을 소프트 삭제
      final allZones = await getAllParkingZones();
      if (allZones.success && allZones.data != null) {
        int cleanedCount = 0;

        for (final zone in allZones.data!) {
          final fileExists = await _fileManager.fileExists(zone.fileAddress);
          if (!fileExists) {
            print('📝 고아 레코드 발견: ${zone.parkingName} (${zone.fileAddress})');

            // 해당 파일의 DB 레코드를 소프트 삭제
            final body = {
              "transaction": [
                {
                  "statement": "#D_File_Soft",
                  "values": {"filename": zone.parkingName}
                },
                {
                  "statement": "#D_TbPakringZoneName",
                  "values": {"parking_name": zone.parkingName}
                },
              ]
            };

            final response = await http.post(
              Uri.parse(_dbUrl!),
              headers: _headers,
              body: jsonEncode(body),
            );

            if (response.statusCode == 200) {
              cleanedCount++;
              print('✅ 고아 레코드 정리됨: ${zone.parkingName}');
            } else {
              print('⚠️ 고아 레코드 정리 실패: ${zone.parkingName}');
            }
          }
        }

        if (cleanedCount > 0) {
          print('🗑️  총 ${cleanedCount}개의 고아 DB 레코드가 정리되었습니다.');
        }
      }
    } catch (e) {
      print('⚠️ 고아 DB 레코드 정리 중 오류: $e');
    }
  }

  /// 파일시스템에 있지만 DB에 없는 파일들을 DB에 추가
  Future<void> _addMissingFilesToDb() async {
    try {
      print('📁 누락된 파일 DB 추가 중...');

      // 파일시스템의 모든 파일 조회
      final allFiles = await _fileManager.listFiles();
      final existingZones = await getAllParkingZones();

      // tb_parking_zone에 등록된 파일 경로
      final existingZoneFilePaths = <String>{};
      // tb_files에 등록된 파일 경로 (직접 DB 쿼리)
      final existingFilesPaths = <String>{};

      if (existingZones.success && existingZones.data != null) {
        for (final zone in existingZones.data!) {
          existingZoneFilePaths.add(zone.fileAddress);
        }
      }

      // tb_files에서 기존 파일 경로 조회
      try {
        final filesResponse = await http.post(
          Uri.parse(_dbUrl!),
          headers: _headers,
          body: jsonEncode({"statement": "#S_AllFilePaths"}),
        );

        if (filesResponse.statusCode == 200) {
          final data = jsonDecode(filesResponse.body);
          if (data['resultSet'] != null) {
            for (final row in data['resultSet']) {
              if (row['file_path'] != null) {
                existingFilesPaths.add(row['file_path']);
              }
            }
          }
        }
      } catch (e) {
        print('⚠️ tb_files 조회 중 오류: $e');
      }

      int addedToParkingZone = 0;
      int addedToFiles = 0;

      for (final fileInfo in allFiles) {
        // 1. tb_parking_zone에 없는 파일들 추가
        if (!existingZoneFilePaths.contains(fileInfo.fullPath)) {
          print('📝 주차구역 테이블에 누락된 파일 발견: ${fileInfo.filename}');

          final fileExtension = fileInfo.extension.toLowerCase();
          final fileCategory = _determineFileCategory(fileExtension);
          final mimeType = _determineMimeType(fileExtension);

          final body = {
            "transaction": [
              // 새로운 파일 관리 테이블에 파일 정보 저장
              {
                "statement": "#I_File",
                "values": {
                  "filename": fileInfo.filename,
                  "original_filename": fileInfo.filename,
                  "file_path": fileInfo.fullPath,
                  "file_type": fileExtension,
                  "file_category": fileCategory,
                  "file_size": fileInfo.sizeBytes,
                  "mime_type": mimeType,
                  "description": '동기화로 추가된 파일: ${fileInfo.filename}',
                }
              },
              // 기존 주차구역 테이블에도 저장 (하위 호환성)
              {
                "statement": "#I_TbPakringZone",
                "values": {
                  "parking_name": fileInfo.filename,
                  "file_address": fileInfo.fullPath,
                }
              },
            ]
          };

          final response = await http.post(
            Uri.parse(_dbUrl!),
            headers: _headers,
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            addedToParkingZone++;
            print('✅ 주차구역 테이블에 파일 추가됨: ${fileInfo.filename}');
          } else {
            print(
                '⚠️ 주차구역 테이블 파일 추가 실패: ${fileInfo.filename} - ${response.body}');
          }
        }
        // 2. tb_parking_zone에는 있지만 tb_files에 없는 파일들 추가
        else if (!existingFilesPaths.contains(fileInfo.fullPath)) {
          print('📝 파일 테이블에 누락된 파일 발견: ${fileInfo.filename}');

          final fileExtension = fileInfo.extension.toLowerCase();
          final fileCategory = _determineFileCategory(fileExtension);
          final mimeType = _determineMimeType(fileExtension);

          final body = {
            "transaction": [
              {
                "statement": "#I_File",
                "values": {
                  "filename": fileInfo.filename,
                  "original_filename": fileInfo.filename,
                  "file_path": fileInfo.fullPath,
                  "file_type": fileExtension,
                  "file_category": fileCategory,
                  "file_size": fileInfo.sizeBytes,
                  "mime_type": mimeType,
                  "description": '기존 파일 동기화: ${fileInfo.filename}',
                }
              }
            ]
          };

          final response = await http.post(
            Uri.parse(_dbUrl!),
            headers: _headers,
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            addedToFiles++;
            print('✅ 파일 테이블에 기존 파일 추가됨: ${fileInfo.filename}');
          } else {
            print(
                '⚠️ 파일 테이블 기존 파일 추가 실패: ${fileInfo.filename} - ${response.body}');
          }
        }
      }

      if (addedToParkingZone > 0 || addedToFiles > 0) {
        print('📋 동기화 완료:');
        print('   • 주차구역 테이블에 추가: ${addedToParkingZone}개');
        print('   • 파일 테이블에 추가: ${addedToFiles}개');
      }
    } catch (e) {
      print('⚠️ 누락된 파일 DB 추가 중 오류: $e');
    }
  }

  /// 파일시스템 수동 동기화 (Public API)
  Future<ParkingZoneServiceResponse<Map<String, dynamic>>>
      syncFileSystem() async {
    try {
      final startTime = DateTime.now();
      await _syncFileSystem();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final fileSystemStatus = await _fileManager.getFileSystemReport();
      final allZones = await getAllParkingZones();

      return ParkingZoneServiceResponse.success(
        '파일시스템 동기화가 완료되었습니다.',
        {
          ...fileSystemStatus,
          'syncDurationMs': duration.inMilliseconds,
          'syncedAt': endTime.toIso8601String(),
          'totalParkingZones': allZones.data?.length ?? 0,
          'status': 'completed',
        },
      );
    } catch (e) {
      return ParkingZoneServiceResponse.error(
        '파일시스템 동기화 중 오류가 발생했습니다: $e',
        ParkingZoneConstants.errorFileOperation,
      );
    }
  }

  /// 서비스 상태 확인
  Future<ParkingZoneServiceResponse<Map<String, dynamic>>>
      getServiceHealth() async {
    try {
      final serviceStatus = await getServiceStatus();
      final fileSystemStatus = await _fileManager.getFileSystemReport();

      return ParkingZoneServiceResponse.success(
        '서비스 상태 확인 완료',
        {
          'service': serviceStatus,
          'fileSystem': fileSystemStatus,
          'timestamp': DateTime.now().toIso8601String(),
          'version': '1.0.0',
        },
      );
    } catch (e) {
      return ParkingZoneServiceResponse.error(
        '서비스 상태 확인 중 오류가 발생했습니다: $e',
        ParkingZoneConstants.errorFileOperation,
      );
    }
  }

  /// 서비스 정보
  Future<ParkingZoneServiceResponse<Map<String, dynamic>>>
      getServiceInfo() async {
    try {
      final allZones = await getAllParkingZones();
      final allFiles = await getAllFiles();

      return ParkingZoneServiceResponse.success(
        '서비스 정보 조회 완료',
        {
          'serviceName': 'ParkingZoneService',
          'version': '1.0.0',
          'features': [
            'File Upload/Download',
            'Parking Zone Management',
            'File System Synchronization',
            'Health Monitoring',
          ],
          'supportedFileTypes': ParkingZoneConstants.supportedExtensions,
          'maxFileSize': ParkingZoneConstants.maxFileSizeBytes,
          'statistics': {
            'totalZones': allZones.data?.length ?? 0,
            'totalFiles': allFiles.length,
          },
          'endpoints': [
            'GET /api/v1/settings/parking-zones',
            'POST /api/v1/settings/parking-zones',
            'PUT /api/v1/settings/parking-zones/{name}',
            'DELETE /api/v1/settings/parking-zones/{name}',
            'POST /api/v1/settings/parking-zones/sync',
            'GET /api/v1/settings/parking-zones/health',
            'GET /api/v1/settings/parking-zones/info',
          ],
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return ParkingZoneServiceResponse.error(
        '서비스 정보 조회 중 오류가 발생했습니다: $e',
        ParkingZoneConstants.errorFileOperation,
      );
    }
  }

  /// 리소스 정리
  void dispose() {
    // 필요한 경우 여기서 리소스 정리
  }
}
