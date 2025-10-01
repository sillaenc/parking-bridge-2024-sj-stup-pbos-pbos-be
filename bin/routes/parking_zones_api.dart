import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/parking_zone_models.dart';
import '../services/parking_zone_service.dart';
import '../utils/file_utils.dart';
import '../data/manage_address.dart';

/// 주차 구역 관리 전용 RESTful API
/// 경로: /api/v1/parking-zones/*
class ParkingZonesApi {
  final ParkingZoneService _parkingZoneService;

  /// ParkingZonesApi 생성자
  ParkingZonesApi({required ManageAddress manageAddress})
      : _parkingZoneService = ParkingZoneService(manageAddress: manageAddress);

  /// 주차 구역 API 라우터 생성
  Router get router {
    final router = Router();

    // GET /api/v1/parking-zones - 모든 주차 구역 조회
    router.get('/', _getAllParkingZones);

    // GET /api/v1/parking-zones/health - 서비스 상태 확인
    router.get('/health', _getServiceHealth);

    // GET /api/v1/parking-zones/info - 서비스 정보
    router.get('/info', _getServiceInfo);

    // POST /api/v1/parking-zones - 파일 업로드 및 주차 구역 생성
    router.post('/', _uploadFile);

    // GET /api/v1/parking-zones/{name} - 특정 주차 구역 조회
    router.get('/<name>', _getParkingZoneByName);

    // PUT /api/v1/parking-zones/{name} - 파일 업데이트 및 주차 구역 업데이트
    router.put('/<name>', _updateFile);

    // DELETE /api/v1/parking-zones/{name} - 파일 삭제 및 주차 구역 삭제
    router.delete('/<name>', _deleteFile);

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

  /// 서비스 정보 조회
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'Parking Zones Management API',
        'version': '1.0.0',
        'description': 'RESTful API for parking zone management',
        'endpoints': {
          'GET /': 'Get all parking zones',
          'GET /{name}': 'Get parking zone by name',
          'POST /': 'Upload file and create parking zone',
          'PUT /{name}': 'Update file and parking zone',
          'DELETE /{name}': 'Delete file and parking zone',
          'GET /health': 'Service health check',
          'GET /info': 'Service information'
        },
        'supportedFileTypes': [
          'JSON (.json)',
          'Images (.jpg, .jpeg, .png)',
          'Videos (.mp4, .avi)',
          'Documents (.pdf, .txt)',
          'Archives (.zip, .tar.gz)'
        ],
        'maxFileSize': '500MB',
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



