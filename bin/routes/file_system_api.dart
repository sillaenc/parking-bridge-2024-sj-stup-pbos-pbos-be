import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/parking_zone_models.dart';
import '../services/parking_zone_service.dart';
import '../data/manage_address.dart';

/// 파일 시스템 관리 전용 RESTful API
/// 경로: /api/v1/files/*
class FileSystemApi {
  final ParkingZoneService _parkingZoneService;

  /// FileSystemApi 생성자
  FileSystemApi({required ManageAddress manageAddress})
      : _parkingZoneService = ParkingZoneService(manageAddress: manageAddress);

  /// 파일 시스템 API 라우터 생성
  Router get router {
    final router = Router();

    // GET /api/v1/files - 파일 시스템 파일 목록 조회
    router.get('/', _getAllFiles);

    // POST /api/v1/files/sync - 수동 파일시스템 동기화
    router.post('/sync', _syncFileSystem);

    // GET /api/v1/files/health - 파일시스템 상태 확인
    router.get('/health', _checkFileSystemHealth);

    // GET /api/v1/files/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    return router;
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

  /// 수동 파일시스템 동기화
  Future<Response> _syncFileSystem(Request request) async {
    try {
      final result = await _parkingZoneService.syncFileSystem();

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
      final healthStatus = await _parkingZoneService.checkFileSystemHealth();

      return Response.ok(
        jsonEncode(healthStatus),
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

  /// 서비스 정보 조회
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'File System Management API',
        'version': '1.0.0',
        'description':
            'RESTful API for file system operations and synchronization',
        'endpoints': {
          'GET /': 'Get all files in the file system with metadata',
          'POST /sync': 'Manually synchronize file system with database',
          'GET /health': 'File system health check',
          'GET /info': 'Service information'
        },
        'supportedDirectories': [
          'file/ (general files)',
          'json_folder/ (JSON configuration files)',
          'display/ (display configuration)',
          'error/ (error logs)'
        ],
        'supportedFileTypes': [
          'JSON (.json)',
          'Images (.jpg, .jpeg, .png, .gif, .bmp)',
          'Videos (.mp4, .avi, .mov, .mkv)',
          'Documents (.pdf, .txt, .doc, .docx)',
          'Archives (.zip, .tar.gz, .rar)',
          'Audio (.mp3, .wav, .flac)',
          'Data (.csv, .xml, .yaml)'
        ],
        'maxFileSize': '500MB',
        'features': [
          'Real-time file monitoring',
          'Automatic metadata extraction',
          'File integrity checking',
          'Synchronization with database',
          'Directory structure validation'
        ],
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// ParkingZoneServiceException 처리
  Response _handleParkingZoneServiceException(ParkingZoneServiceException e) {
    int statusCode;
    switch (e.errorCode) {
      case ParkingZoneConstants.errorZoneNotFound:
        statusCode = 404;
        break;
      case ParkingZoneConstants.errorZoneExists:
        statusCode = 409;
        break;
      case ParkingZoneConstants.errorValidationFailed:
        statusCode = 400;
        break;
      default:
        statusCode = 500;
    }

    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
