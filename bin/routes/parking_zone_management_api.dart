import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/parking_zone_models.dart';
import '../services/parking_zone_service.dart';
import '../utils/file_utils.dart';
import '../data/manage_address.dart';

/// RESTful 주차 구역 관리 API
class ParkingZoneManagementApi {
  final ParkingZoneService _parkingZoneService;

  ParkingZoneManagementApi({required ManageAddress manageAddress})
      : _parkingZoneService = ParkingZoneService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // GET /api/v1/files - 모든 주차 구역 조회
    router.get('/', _getAllParkingZones);

    // GET /api/v1/files/{name} - 특정 주차 구역 조회
    router.get('/<name>', _getParkingZoneByName);

    // POST /api/v1/files - 파일 업로드 및 주차 구역 생성
    router.post('/', _uploadFile);

    // PUT /api/v1/files/{name} - 파일 업데이트 및 주차 구역 업데이트
    router.put('/<name>', _updateFile);

    // DELETE /api/v1/files/{name} - 파일 삭제 및 주차 구역 삭제
    router.delete('/<name>', _deleteFile);

    // PATCH /api/v1/files/lots/{tag}/type - 주차 공간 유형 변경
    router.patch('/lots/<tag>/type', _changeLotType);

    // PATCH /api/v1/files/lots/{tag}/status - 주차 상태 변경
    router.patch('/lots/<tag>/status', _changeParkingStatus);

    // GET /api/v1/files/list - 파일 시스템 파일 목록 조회
    router.get('/list', _getAllFiles);

    // POST /api/v1/files/sync - 수동 파일시스템 동기화
    router.post('/sync', _syncFileSystem);

    // GET /api/v1/files/health - 파일시스템 상태 확인
    router.get('/health', _checkFileSystemHealth);

    // GET /api/v1/files/service-health - 서비스 상태 확인
    router.get('/service-health', _getServiceHealth);

    // GET /api/v1/files/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
  }

  /// 모든 주차 구역 조회
  Future<Response> _getAllParkingZones(Request request) async {
    try {
      final result = await _parkingZoneService.getAllParkingZones();

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 특정 주차 구역 조회
  Future<Response> _getParkingZoneByName(Request request) async {
    try {
      final name = request.params['name']!;
      final zone = await _parkingZoneService.getParkingZoneByName(name);

      if (zone == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': ParkingZoneConstants.messageZoneNotExists,
            'errorCode': ParkingZoneConstants.errorZoneNotFound,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = ParkingZoneServiceResponse.success(
        'Parking zone retrieved successfully',
        zone,
      );

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일 업로드 및 주차 구역 생성
  Future<Response> _uploadFile(Request request) async {
    try {
      // Multipart 요청 파싱
      final uploadRequest = await MultipartParser.parseFileUpload(request);
      if (uploadRequest == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Invalid multipart request format',
            'errorCode': ParkingZoneConstants.errorValidationFailed,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _parkingZoneService.uploadFile(uploadRequest);

      return Response(
        201,
        body: jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일 업데이트 및 주차 구역 업데이트
  Future<Response> _updateFile(Request request) async {
    try {
      final name = request.params['name']!;

      // Multipart 요청 파싱
      final updateRequest = await MultipartParser.parseFileUpdate(request);
      if (updateRequest == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Invalid multipart request format',
            'errorCode': ParkingZoneConstants.errorValidationFailed,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // URL 파라미터와 multipart 데이터의 old filename이 일치하는지 확인
      if (updateRequest.oldFilename != name) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message':
                'URL parameter name does not match old filename in multipart data',
            'errorCode': ParkingZoneConstants.errorValidationFailed,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await _parkingZoneService.updateFile(updateRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일 삭제 및 주차 구역 삭제
  Future<Response> _deleteFile(Request request) async {
    try {
      final name = request.params['name']!;

      final deleteRequest = FileDeleteRequest(filename: name);
      final result = await _parkingZoneService.deleteFile(deleteRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 주차 공간 유형 변경
  Future<Response> _changeLotType(Request request) async {
    try {
      final tag = request.params['tag']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 tag를 requestData에 추가
      requestData['tag'] = tag;

      final lotTypeRequest = LotTypeChangeRequest.fromJson(requestData);
      final result = await _parkingZoneService.changeLotType(lotTypeRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': 'Invalid JSON format',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 주차 상태 변경
  Future<Response> _changeParkingStatus(Request request) async {
    try {
      final tag = request.params['tag']!;
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      // URL 파라미터의 tag를 requestData에 추가
      requestData['tag'] = tag;

      final statusRequest = ParkingStatusChangeRequest.fromJson(requestData);
      final result =
          await _parkingZoneService.changeParkingStatus(statusRequest);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } on FormatException catch (e) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'message': 'Invalid JSON format',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일 시스템 파일 목록 조회
  Future<Response> _getAllFiles(Request request) async {
    try {
      final files = await _parkingZoneService.getAllFiles();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Files retrieved successfully',
          'data': files.map((file) => file.toJson()).toList(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final status = await _parkingZoneService.getServiceStatus();

      return Response.ok(
        jsonEncode(status),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'unhealthy',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 수동 파일시스템 동기화
  Future<Response> _syncFileSystem(Request request) async {
    try {
      final result = await _parkingZoneService.syncFileSystemManually();

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일시스템 상태 확인
  Future<Response> _checkFileSystemHealth(Request request) async {
    try {
      final result = await _parkingZoneService.checkFileSystemHealth();

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on ParkingZoneServiceException catch (e) {
      return _handleParkingZoneServiceException(e);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 정보
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'Parking Zone Management API',
        'version': '2.0.0', // 동기화 기능 추가로 버전 업
        'description':
            'RESTful API for parking zone file management with auto-sync',
        'endpoints': {
          'GET /': 'Get all parking zones',
          'GET /{name}': 'Get parking zone by name',
          'POST /': 'Upload file and create parking zone',
          'PUT /{name}': 'Update file and parking zone',
          'DELETE /{name}': 'Delete file and parking zone',
          'PATCH /lots/{tag}/type': 'Change lot type',
          'PATCH /lots/{tag}/status': 'Change parking status',
          'GET /files': 'List all files in file system',
          'POST /sync': 'Manual filesystem synchronization',
          'GET /filesystem-health': 'Check filesystem health',
          'GET /health': 'Service health check',
          'GET /info': 'Service information',
        },
        'features': [
          'Video file support (mp4, avi, mov, etc.)',
          'Large file support (500MB max)',
          'Automatic filesystem synchronization',
          'Orphaned file cleanup',
          'Health monitoring',
        ],
        'supportedFileTypes': ParkingZoneConstants.supportedExtensions,
        'maxFileSize':
            '${ParkingZoneConstants.maxFileSizeBytes / (1024 * 1024)}MB',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// ParkingZoneServiceException을 적절한 HTTP Response로 변환
  Response _handleParkingZoneServiceException(ParkingZoneServiceException e) {
    final errorResponse = {
      'success': false,
      'message': e.message,
      'errorCode': e.errorCode,
    };

    final statusCode = e.statusCode ?? 500;

    switch (statusCode) {
      case 400:
        return Response.badRequest(
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 401:
        return Response.unauthorized(
          jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 404:
        return Response.notFound(
          jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      case 409:
        return Response(
          409,
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
      default:
        return Response.internalServerError(
          body: jsonEncode(errorResponse),
          headers: {'Content-Type': 'application/json'},
        );
    }
  }
}

/// 레거시 호환성을 위한 기존 API 래퍼
class LegacyParkingZoneApi {
  final ParkingZoneService _parkingZoneService;

  LegacyParkingZoneApi({required ManageAddress manageAddress})
      : _parkingZoneService = ParkingZoneService(manageAddress: manageAddress);

  Router get router {
    final router = Router();

    // 기존 API 엔드포인트들 (하위 호환성 유지)
    router.get('/', _legacyGetAllParkingZones);
    router.post('/insertFile', _legacyInsertFile);
    router.post('/deleteFile', _legacyDeleteFile);
    router.post('/UpdateFile', _legacyUpdateFile);
    router.post('/ChangeLotType', _legacyChangeLotType);
    router.post('/ChangeParked', _legacyChangeParked);

    return router;
  }

  /// 레거시: 모든 주차 구역 조회
  Future<Response> _legacyGetAllParkingZones(Request request) async {
    try {
      final result = await _parkingZoneService.getAllParkingZones();
      // 기존 형식으로 변환 (resultSet 직접 반환)
      final zones = result.data ?? [];
      final resultSet = zones.map((zone) => zone.toJson()).toList();

      return Response.ok(jsonEncode(resultSet));
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 파일 업로드
  Future<Response> _legacyInsertFile(Request request) async {
    try {
      final uploadRequest = await MultipartParser.parseFileUpload(request);
      if (uploadRequest == null) {
        return Response.badRequest(body: 'bad request');
      }

      await _parkingZoneService.uploadFile(uploadRequest);
      return Response.ok('File uploaded and saved to database');
    } catch (e) {
      if (e is ParkingZoneServiceException) {
        if (e.errorCode == ParkingZoneConstants.errorZoneExists) {
          return Response.internalServerError(body: 'File upload failed');
        }
      }
      return Response.internalServerError(body: 'File upload failed');
    }
  }

  /// 레거시: 파일 삭제
  Future<Response> _legacyDeleteFile(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final deleteRequest = FileDeleteRequest.fromJson(requestData);
      await _parkingZoneService.deleteFile(deleteRequest);

      return Response.ok("delete success");
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 파일 업데이트
  Future<Response> _legacyUpdateFile(Request request) async {
    try {
      final updateRequest = await MultipartParser.parseFileUpdate(request);
      if (updateRequest == null) {
        return Response.badRequest(body: 'bad request');
      }

      await _parkingZoneService.updateFile(updateRequest);
      return Response.ok('File uploaded and saved to database');
    } catch (e) {
      return Response.internalServerError(body: 'File upload failed');
    }
  }

  /// 레거시: 주차 공간 유형 변경
  Future<Response> _legacyChangeLotType(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final lotTypeRequest = LotTypeChangeRequest.fromJson(requestData);
      await _parkingZoneService.changeLotType(lotTypeRequest);

      return Response.ok("차종 변경완료");
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  }

  /// 레거시: 주차 상태 변경
  Future<Response> _legacyChangeParked(Request request) async {
    try {
      final requestBody = await request.readAsString();
      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

      final statusRequest = ParkingStatusChangeRequest.fromJson(requestData);
      await _parkingZoneService.changeParkingStatus(statusRequest);

      return Response.ok("사용여부 변경완료");
    } catch (e) {
      print('에러 발생 - /ChangeParked: $e');
      return Response.internalServerError(body: '/ChangeParked 서버 오류로 실패');
    } finally {
      print('/ChangeParked 요청 처리 완료');
    }
  }

  /// 파일시스템 동기화
  Future<Response> _syncFileSystem(Request request) async {
    try {
      final result = await _parkingZoneService.syncFileSystem();

      return Response.ok(
        jsonEncode({
          'success': result.success,
          'message': result.message,
          'data': result.data,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error during sync',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 파일시스템 상태 확인
  Future<Response> _checkFileSystemHealth(Request request) async {
    try {
      final result = await _parkingZoneService.checkFileSystemHealth();

      return Response.ok(
        jsonEncode({
          'success': result.success,
          'message': result.message,
          'data': result.data,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error during health check',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final result = await _parkingZoneService.getServiceHealth();

      return Response.ok(
        jsonEncode({
          'success': result.success,
          'message': result.message,
          'data': result.data,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error during service health check',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// 서비스 정보
  Future<Response> _getServiceInfo(Request request) async {
    try {
      final result = await _parkingZoneService.getServiceInfo();

      return Response.ok(
        jsonEncode({
          'success': result.success,
          'message': result.message,
          'data': result.data,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Internal server error during service info retrieval',
          'error': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
