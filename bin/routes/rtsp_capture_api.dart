/// RTSP 캡처 API 엔드포인트
///
/// RTSP 캡처 설정 관리 및 이미지 조회 RESTful API 제공

import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/rtsp_config.dart';
import '../data/manage_address.dart';
import '../models/rtsp_capture_models.dart';
import '../services/rtsp_capture_service.dart';
import '../services/rtsp_adaptive_capture_service.dart'; // 적응형 서비스
import '../services/rtsp_scheduler_service.dart';
import '../utils/rtsp_utils.dart';

/// RTSP 캡처 API
class RtspCaptureApi {
  final ManageAddress _manageAddress;
  final RtspCaptureService _captureService;
  RtspSchedulerService? _schedulerService;

  RtspCaptureApi({
    required ManageAddress manageAddress,
    required RtspCaptureService captureService,
  })  : _manageAddress = manageAddress,
        _captureService = captureService;

  /// 스케줄러 설정
  void setScheduler(RtspSchedulerService scheduler) {
    _schedulerService = scheduler;
  }

  /// RTSP 캡처 API 라우터
  Router get router {
    final router = Router();

    // GET /api/v1/rtsp/image/{tag} - 특정 구역 최신 캡처 이미지 조회
    router.get('/image/<tag>', _handleGetImage);

    // GET /api/v1/rtsp/list - 모든 RTSP 설정 조회
    router.get('/list', _handleGetList);

    // POST /api/v1/rtsp - RTSP 설정 추가
    router.post('/', _handleCreate);

    // PUT /api/v1/rtsp/<tag> - RTSP 설정 수정
    router.put('/<tag>', _handleUpdate);

    // DELETE /api/v1/rtsp/<tag> - RTSP 설정 삭제
    router.delete('/<tag>', _handleDelete);

    // GET /api/v1/rtsp/health - 캡처 서비스 상태
    router.get('/health', _handleHealthCheck);

    // POST /api/v1/rtsp/trigger - 수동 캡처 실행
    router.post('/trigger', _handleTriggerCapture);

    // GET /api/v1/rtsp/info - 서비스 정보
    router.get('/info', _handleServiceInfo);

    // GET /api/v1/rtsp/stats - 통계 정보
    router.get('/stats', _handleStats);

    // GET /api/v1/rtsp/adaptive-stats - 적응형 통계 정보
    router.get('/adaptive-stats', _handleAdaptiveStats);

    // POST /api/v1/rtsp/blacklist/reset - 블랙리스트 초기화
    router.post('/blacklist/reset', _handleBlacklistReset);

    // DELETE /api/v1/rtsp/blacklist/<address> - 블랙리스트에서 제거
    router.delete('/blacklist/<address>', _handleBlacklistRemove);

    // GET /api/v1/rtsp/scheduler - 스케줄러 상태
    router.get('/scheduler', _handleSchedulerStatus);

    return router;
  }

  /// 특정 태그의 최신 캡처 이미지 조회
  Future<Response> _handleGetImage(Request request, String tag) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      // DB에서 캡처 정보 조회
      final capture = await _captureService.getCaptureByTag(databaseUrl, tag);

      if (capture == null) {
        return Response.notFound(
          jsonEncode(RtspImageResponse(
            success: false,
            message: RtspCaptureConstants.msgTagNotFound,
            errorCode: RtspCaptureConstants.errorTagNotFound,
          ).toJson()),
          headers: _getCorsHeaders(),
        );
      }

      // 이미지 파일 존재 확인
      if (capture.lastImagePath == null) {
        return Response(
          404,
          body: jsonEncode(RtspImageResponse(
            success: false,
            message: RtspCaptureConstants.msgImageNotFound,
            errorCode: RtspCaptureConstants.errorImageNotFound,
          ).toJson()),
          headers: _getCorsHeaders(),
        );
      }

      final imageExists = await fileExists(capture.lastImagePath!);
      if (!imageExists) {
        return Response(
          404,
          body: jsonEncode(RtspImageResponse(
            success: false,
            message: RtspCaptureConstants.msgImageNotFound,
            errorCode: RtspCaptureConstants.errorImageNotFound,
          ).toJson()),
          headers: _getCorsHeaders(),
        );
      }

      // 성공 응답
      return Response.ok(
        jsonEncode(RtspImageResponse(
          success: true,
          message: RtspCaptureConstants.msgImageRetrieved,
          tag: capture.tag,
          imagePath: capture.lastImagePath,
          imageUrl: '/${capture.lastImagePath}',
          rtspAddress: capture.rtspAddress,
        ).toJson()),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in get image: $e');
      return _createErrorResponse(
        'Failed to retrieve image',
        statusCode: 500,
      );
    }
  }

  /// 모든 RTSP 설정 조회
  Future<Response> _handleGetList(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final captures = await _captureService.getAllCaptures(databaseUrl);
      final stats = await _captureService.getStats(databaseUrl);

      return Response.ok(
        jsonEncode(RtspCaptureListResponse(
          success: true,
          message: RtspCaptureConstants.msgListRetrieved,
          data: captures,
          metadata: {
            'total': captures.length,
            'stats': stats.toJson(),
          },
        ).toJson()),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in get list: $e');
      return _createErrorResponse(
        'Failed to retrieve list',
        statusCode: 500,
      );
    }
  }

  /// RTSP 설정 추가
  Future<Response> _handleCreate(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final captureRequest = RtspCaptureRequest.fromJson(requestData);

      final result = await _captureService.createCapture(
        databaseUrl,
        captureRequest,
      );

      if (result.success) {
        return Response.ok(
          jsonEncode(result.toJson()),
          headers: _getCorsHeaders(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return Response(
          statusCode,
          body: jsonEncode(result.toJson()),
          headers: _getCorsHeaders(),
        );
      }
    } catch (e) {
      print('Error in create: $e');
      return _createErrorResponse(
        'Invalid request format',
        statusCode: 400,
      );
    }
  }

  /// RTSP 설정 수정
  Future<Response> _handleUpdate(Request request, String tag) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final requestBody = await request.readAsString();
      if (requestBody.isEmpty) {
        return _createErrorResponse(
          'Request body is required',
          statusCode: 400,
        );
      }

      final requestData = jsonDecode(requestBody) as Map<String, dynamic>;
      final captureRequest = RtspCaptureRequest.fromJson(requestData);

      final result = await _captureService.updateCapture(
        databaseUrl,
        tag,
        captureRequest,
      );

      if (result.success) {
        return Response.ok(
          jsonEncode(result.toJson()),
          headers: _getCorsHeaders(),
        );
      } else {
        final statusCode = _getStatusCodeFromError(result.errorCode);
        return Response(
          statusCode,
          body: jsonEncode(result.toJson()),
          headers: _getCorsHeaders(),
        );
      }
    } catch (e) {
      print('Error in update: $e');
      return _createErrorResponse(
        'Invalid request format',
        statusCode: 400,
      );
    }
  }

  /// RTSP 설정 삭제
  Future<Response> _handleDelete(Request request, String tag) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final success = await _captureService.deleteCapture(databaseUrl, tag);

      if (success) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': RtspCaptureConstants.msgCaptureDeleted,
          }),
          headers: _getCorsHeaders(),
        );
      } else {
        return Response(
          404,
          body: jsonEncode({
            'success': false,
            'message': RtspCaptureConstants.msgTagNotFound,
            'errorCode': RtspCaptureConstants.errorTagNotFound,
          }),
          headers: _getCorsHeaders(),
        );
      }
    } catch (e) {
      print('Error in delete: $e');
      return _createErrorResponse(
        'Failed to delete capture',
        statusCode: 500,
      );
    }
  }

  /// 서비스 상태 확인
  Future<Response> _handleHealthCheck(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;

      final ffmpegInstalled = await isFFmpegInstalled();
      final dirExists = await Directory(RtspConfig.CAPTURE_OUTPUT_DIR).exists();

      final healthInfo = {
        'status': _captureService.status.displayName,
        'healthy': _captureService.status.isHealthy,
        'ffmpeg_installed': ffmpegInstalled,
        'capture_directory_exists': dirExists,
        'database_configured': databaseUrl != null,
        'service': 'rtsp_capture',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final isHealthy = _captureService.status.isHealthy &&
          ffmpegInstalled &&
          dirExists &&
          databaseUrl != null;

      return Response(
        isHealthy ? 200 : 503,
        body: jsonEncode(healthInfo),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in health check: $e');
      return _createErrorResponse(
        'Health check failed',
        statusCode: 500,
      );
    }
  }

  /// 수동 캡처 트리거
  Future<Response> _handleTriggerCapture(Request request) async {
    try {
      if (_schedulerService == null) {
        return Response(
          503,
          body: jsonEncode({
            'success': false,
            'message': '스케줄러가 초기화되지 않았습니다',
          }),
          headers: _getCorsHeaders(),
        );
      }

      final result = await _schedulerService!.triggerCapture();

      return Response.ok(
        jsonEncode(result),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in trigger capture: $e');
      return _createErrorResponse(
        'Failed to trigger capture',
        statusCode: 500,
      );
    }
  }

  /// 서비스 정보 조회
  Future<Response> _handleServiceInfo(Request request) async {
    try {
      final serviceInfo = _captureService.getServiceInfo();

      return Response.ok(
        jsonEncode(serviceInfo),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in service info: $e');
      return _createErrorResponse(
        'Failed to retrieve service info',
        statusCode: 500,
      );
    }
  }

  /// 통계 정보 조회
  Future<Response> _handleStats(Request request) async {
    try {
      final databaseUrl = _manageAddress.displayDbAddr;
      if (databaseUrl == null) {
        return _createErrorResponse(
          'Database configuration not available',
          statusCode: 503,
        );
      }

      final stats = await _captureService.getStats(databaseUrl);
      final dirStats = await getCaptureDirectoryStats();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            ...stats.toJson(),
            'directory_stats': dirStats,
          },
        }),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in stats: $e');
      return _createErrorResponse(
        'Failed to retrieve stats',
        statusCode: 500,
      );
    }
  }

  /// 적응형 통계 정보 조회
  ///
  /// RtspAdaptiveCaptureService의 상세 통계를 반환합니다.
  /// - 현재 배치 크기
  /// - 블랙리스트 정보
  /// - 주소별 응답 시간
  /// - 실패 횟수
  Future<Response> _handleAdaptiveStats(Request request) async {
    try {
      // 적응형 서비스 타입 확인
      final service = _captureService;
      if (service is! RtspAdaptiveCaptureService) {
        return Response.ok(
          jsonEncode({
            'success': false,
            'message': '적응형 모드가 활성화되지 않았습니다',
            'data': {
              'adaptive_mode': false,
              'service_type': 'basic',
            },
          }),
          headers: _getCorsHeaders(),
        );
      }

      final adaptiveStats = service.getAdaptiveStats();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': '적응형 통계 조회 성공',
          'data': adaptiveStats,
        }),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in adaptive stats: $e');
      return _createErrorResponse(
        'Failed to retrieve adaptive stats',
        statusCode: 500,
      );
    }
  }

  /// 블랙리스트 초기화
  ///
  /// 모든 블랙리스트와 실패 카운트를 초기화합니다.
  Future<Response> _handleBlacklistReset(Request request) async {
    try {
      final service = _captureService;
      if (service is! RtspAdaptiveCaptureService) {
        return _createErrorResponse(
          '적응형 모드가 활성화되지 않았습니다',
          statusCode: 400,
        );
      }

      service.resetBlacklist();

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': '블랙리스트가 초기화되었습니다',
        }),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in blacklist reset: $e');
      return _createErrorResponse(
        'Failed to reset blacklist',
        statusCode: 500,
      );
    }
  }

  /// 블랙리스트에서 특정 주소 제거
  ///
  /// 지정된 RTSP 주소를 블랙리스트에서 제거합니다.
  Future<Response> _handleBlacklistRemove(
      Request request, String address) async {
    try {
      final service = _captureService;
      if (service is! RtspAdaptiveCaptureService) {
        return _createErrorResponse(
          '적응형 모드가 활성화되지 않았습니다',
          statusCode: 400,
        );
      }

      // URL 디코딩 (경로 파라미터로 전달된 경우)
      final decodedAddress = Uri.decodeComponent(address);

      final removed = service.removeFromBlacklist(decodedAddress);

      if (removed) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': '블랙리스트에서 제거되었습니다',
            'data': {'address': decodedAddress},
          }),
          headers: _getCorsHeaders(),
        );
      } else {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'message': '블랙리스트에 해당 주소가 없습니다',
            'data': {'address': decodedAddress},
          }),
          headers: _getCorsHeaders(),
        );
      }
    } catch (e) {
      print('Error in blacklist remove: $e');
      return _createErrorResponse(
        'Failed to remove from blacklist',
        statusCode: 500,
      );
    }
  }

  /// 스케줄러 상태 조회
  Future<Response> _handleSchedulerStatus(Request request) async {
    try {
      if (_schedulerService == null) {
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': '스케줄러가 초기화되지 않았습니다',
            'data': {'status': 'not_initialized'},
          }),
          headers: _getCorsHeaders(),
        );
      }

      final status = _schedulerService!.getStatus();

      return Response.ok(
        jsonEncode({
          'success': true,
          'data': status,
        }),
        headers: _getCorsHeaders(),
      );
    } catch (e) {
      print('Error in scheduler status: $e');
      return _createErrorResponse(
        'Failed to retrieve scheduler status',
        statusCode: 500,
      );
    }
  }

  // === 유틸리티 메서드들 ===

  /// 에러 응답 생성
  Response _createErrorResponse(
    String message, {
    String? errorCode,
    int statusCode = 500,
  }) {
    final responseBody = <String, dynamic>{
      'success': false,
      'message': message,
    };

    if (errorCode != null) {
      responseBody['errorCode'] = errorCode;
    }

    return Response(
      statusCode,
      body: jsonEncode(responseBody),
      headers: _getCorsHeaders(),
    );
  }

  /// 에러 코드에 따른 HTTP 상태 코드 결정
  int _getStatusCodeFromError(String? errorCode) {
    switch (errorCode) {
      case RtspCaptureConstants.errorInvalidTag:
      case RtspCaptureConstants.errorInvalidRtsp:
        return 400;
      case RtspCaptureConstants.errorTagNotFound:
      case RtspCaptureConstants.errorImageNotFound:
      case RtspCaptureConstants.errorCaptureNotFound:
        return 404;
      case RtspCaptureConstants.errorTagExists:
        return 409;
      case RtspCaptureConstants.errorFFmpegNotFound:
        return 503;
      case RtspCaptureConstants.errorDatabaseOperation:
      case RtspCaptureConstants.errorCaptureFailed:
      case RtspCaptureConstants.errorFileOperation:
      default:
        return 500;
    }
  }

  /// CORS 헤더 생성
  Map<String, String> _getCorsHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    };
  }
}
