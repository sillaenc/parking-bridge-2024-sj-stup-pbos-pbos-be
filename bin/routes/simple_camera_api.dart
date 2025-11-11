import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mime/mime.dart';

import '../models/simple_camera_models.dart';
import '../services/simple_camera_service.dart';
import '../services/database_client.dart';
import '../data/manage_address.dart';

/// 단순한 카메라 관리 RESTful API
///
/// 카메라 기본 CRUD와 이미지 조회 기능만 제공합니다.
class SimpleCameraApi {
  final ManageAddress _manageAddress;
  late final SimpleCameraService _cameraService;

  /// 카메라 API 생성자
  SimpleCameraApi({required ManageAddress manageAddress})
      : _manageAddress = manageAddress {
    final databaseClient = DatabaseClient();
    _cameraService = SimpleCameraService(databaseClient: databaseClient);
  }

  /// 카메라 API 라우터 생성
  Router get router {
    final router = Router();

    // 모든 카메라 조회
    router.get('/', _getAllCameras);

    // 카메라 등록
    router.post('/', _createCamera);

    // 특정 경로들을 먼저 정의 (라우터 충돌 방지)
    // 서비스 헬스 체크
    router.get('/health', _getServiceHealth);

    // 서비스 정보
    router.get('/info', _getServiceInfo);

    // 변수 경로들은 마지막에 정의
    // 특정 카메라 조회
    router.get('/<tag>', _getCameraByTag);

    // 카메라 삭제
    router.delete('/<tag>', _deleteCamera);

    // 카메라 이미지 조회 ⭐ 핵심 기능
    router.get('/<tag>/image', _getCameraImage);

    // 이미지 링크 업데이트 (Shell script용)
    router.patch('/<tag>/image', _updateImageLink);

    return router;
  }

  /// 모든 카메라 조회
  /// GET /api/v1/cameras
  Future<Response> _getAllCameras(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      final result = await _cameraService.getAllCameras(databaseUrl);
      return _createResponse(result);
    } catch (e) {
      return _createErrorResponse('카메라 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 카메라 등록
  /// POST /api/v1/cameras
  Future<Response> _createCamera(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final cameraRequest = CameraRequest.fromJson(data);
      final result =
          await _cameraService.createCamera(databaseUrl, cameraRequest);

      return _createResponse(result, statusCode: result.success ? 201 : 400);
    } catch (e) {
      return _createErrorResponse('카메라 등록 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 카메라 조회
  /// GET /api/v1/cameras/{tag}
  Future<Response> _getCameraByTag(Request request) async {
    try {
      final tag = request.params['tag']!;
      final databaseUrl = _manageAddress.displayDbAddr;

      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      final result = await _cameraService.getCameraByTag(databaseUrl, tag);
      return _createResponse(result, statusCode: result.success ? 200 : 404);
    } catch (e) {
      return _createErrorResponse('카메라 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 카메라 삭제
  /// DELETE /api/v1/cameras/{tag}
  Future<Response> _deleteCamera(Request request) async {
    try {
      final tag = request.params['tag']!;
      final databaseUrl = _manageAddress.displayDbAddr;

      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      final result = await _cameraService.deleteCamera(databaseUrl, tag);
      return _createResponse(result, statusCode: result.success ? 200 : 404);
    } catch (e) {
      return _createErrorResponse('카메라 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 카메라 이미지 조회 ⭐ 핵심 기능
  /// GET /api/v1/cameras/{tag}/image
  Future<Response> _getCameraImage(Request request) async {
    try {
      final tag = request.params['tag']!;
      final databaseUrl = _manageAddress.displayDbAddr;

      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      // 카메라 이미지 경로 조회
      final result = await _cameraService.getCameraImagePath(databaseUrl, tag);

      if (!result.success || result.data == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': result.message,
            'error_code': result.errorCode,
          }),
          headers: _getCorsHeaders(),
        );
      }

      final imagePath = result.data!;
      final file = File(imagePath);

      // 파일 존재 여부 확인
      if (!await file.exists()) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': '이미지 파일을 찾을 수 없습니다.',
            'error_code': 'FILE_NOT_FOUND',
          }),
          headers: _getCorsHeaders(),
        );
      }

      // 이미지 파일 반환
      final mimeType = lookupMimeType(imagePath) ?? 'application/octet-stream';
      final imageBytes = await file.readAsBytes();

      return Response.ok(
        imageBytes,
        headers: {
          'Content-Type': mimeType,
          'Content-Length': imageBytes.length.toString(),
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
          ..._getCorsHeaders(),
        },
      );
    } catch (e) {
      return _createErrorResponse('이미지 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 이미지 링크 업데이트 (Shell script용)
  /// PATCH /api/v1/cameras/{tag}/image
  Future<Response> _updateImageLink(Request request) async {
    try {
      final tag = request.params['tag']!;
      final databaseUrl = _manageAddress.displayDbAddr;

      if (databaseUrl == null) {
        return _createErrorResponse('데이터베이스 URL이 설정되지 않았습니다.');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final imagePath = data['last_image_path'] as String;

      final result = await _cameraService.updateImageLink(
        databaseUrl,
        tag,
        imagePath,
      );

      return _createResponse(result);
    } catch (e) {
      return _createErrorResponse('이미지 링크 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 서비스 헬스 체크
  /// GET /api/v1/cameras/health
  Future<Response> _getServiceHealth(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;

      return Response.ok(
        jsonEncode({
          'status': 'healthy',
          'database_configured': databaseUrl != null,
          'pb_yaml_status': 'camera_table_required',
          'note': 'pb.yaml에 tb_camera 테이블과 관련 쿼리 추가 필요',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'status': 'unhealthy',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: _getCorsHeaders(),
      );
    }
  }

  /// 서비스 정보
  /// GET /api/v1/cameras/info
  Future<Response> _getServiceInfo(Request request) async {
    return Response.ok(
      jsonEncode({
        'service': 'Simple Camera Management API',
        'version': '1.0.0',
        'description': '단순한 카메라 관리 및 이미지 조회 서비스',
        'endpoints': {
          'GET /': '모든 카메라 조회',
          'POST /': '카메라 등록',
          'GET /{tag}': '특정 카메라 조회',
          'DELETE /{tag}': '카메라 삭제',
          'GET /{tag}/image': '카메라 이미지 조회 (핵심)',
          'PATCH /{tag}/image': '이미지 링크 업데이트 (Shell script용)',
          'GET /health': '서비스 헬스 체크',
          'GET /info': '서비스 정보',
        },
        'note': 'pb.yaml에 카메라 테이블과 쿼리 추가 필요',
      }),
      headers: _getCorsHeaders(),
    );
  }

  /// 공통 응답 생성
  Response _createResponse(CameraServiceResponse result, {int? statusCode}) {
    final code = statusCode ?? (result.success ? 200 : 400);

    return Response(
      code,
      body: jsonEncode(result.toJson()),
      headers: _getCorsHeaders(),
    );
  }

  /// 에러 응답 생성
  Response _createErrorResponse(String message, {int statusCode = 500}) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': message,
        'error_code': 'INTERNAL_ERROR',
      }),
      headers: _getCorsHeaders(),
    );
  }

  /// CORS 헤더 생성
  Map<String, String> _getCorsHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };
  }

  /// 리소스 해제
  void dispose() {
    _cameraService.dispose();
  }
}
