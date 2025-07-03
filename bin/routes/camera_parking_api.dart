import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/camera_parking_models.dart';
import '../services/camera_parking_service.dart';
import '../services/database_client.dart';
import '../data/manage_address.dart';

/// 카메라 주차 표면 관리 RESTful API
class CameraParkingAPI {
  final ManageAddress manageAddress;
  late final CameraParkingSurfaceService _service;

  CameraParkingAPI({required this.manageAddress}) {
    final databaseClient = DatabaseClient();
    _service = CameraParkingSurfaceService(databaseClient);
  }

  Router get router {
    final router = Router();
    final String? databaseUrl = manageAddress.displayDbAddr;

    if (databaseUrl == null) {
      // 데이터베이스 URL이 없는 경우의 기본 라우터
      router.all('/<ignored|.*>', (Request request) {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Database URL not configured',
            'errorCode': 'DATABASE_CONFIG_ERROR',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });
      return router;
    }

    // RESTful API 엔드포인트들

    /// 모든 카메라 주차 표면 조회
    /// GET /api/v1/camera-parking/surfaces
    router.get('/surfaces', (Request request) async {
      try {
        final result = await _service.getAllSurfaces(databaseUrl);

        return Response.ok(
          jsonEncode(result.toJson()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('Error in GET /surfaces: $e');
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Internal server error',
            'errorCode': 'INTERNAL_ERROR',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 특정 태그의 카메라 주차 표면 조회
    /// GET /api/v1/camera-parking/surfaces/{tag}
    router.get('/surfaces/<tag>', (Request request, String tag) async {
      try {
        final result = await _service.getSurfaceByTag(databaseUrl, tag);

        if (result.success) {
          return Response.ok(
            jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          final statusCode = result.errorCode ==
                  CameraParkingSurfaceConstants.errorSurfaceNotFound
              ? 404
              : 400;
          return Response(
            statusCode,
            body: jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        print('Error in GET /surfaces/$tag: $e');
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Internal server error',
            'errorCode': 'INTERNAL_ERROR',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 새 카메라 주차 표면 생성
    /// POST /api/v1/camera-parking/surfaces
    router.post('/surfaces', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        final createRequest =
            CreateCameraParkingSurfaceRequest.fromJson(requestData);
        final result = await _service.createSurface(databaseUrl, createRequest);

        if (result.success) {
          return Response(
            201,
            body: jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          final statusCode = result.errorCode ==
                  CameraParkingSurfaceConstants.errorSurfaceExists
              ? 409
              : 400;
          return Response(
            statusCode,
            body: jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        print('Error in POST /surfaces: $e');
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Invalid request format',
            'errorCode': 'INVALID_REQUEST',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 카메라 주차 표면 정보 업데이트
    /// PUT /api/v1/camera-parking/surfaces/{tag}
    router.put('/surfaces/<tag>', (Request request, String tag) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        final updateRequest =
            UpdateCameraParkingSurfaceRequest.fromJson(requestData);
        final result =
            await _service.updateSurface(databaseUrl, tag, updateRequest);

        if (result.success) {
          return Response.ok(
            jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          final statusCode = result.errorCode ==
                  CameraParkingSurfaceConstants.errorSurfaceNotFound
              ? 404
              : 400;
          return Response(
            statusCode,
            body: jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        print('Error in PUT /surfaces/$tag: $e');
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Invalid request format',
            'errorCode': 'INVALID_REQUEST',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 카메라 주차 표면 삭제
    /// DELETE /api/v1/camera-parking/surfaces/{tag}
    router.delete('/surfaces/<tag>', (Request request, String tag) async {
      try {
        final result = await _service.deleteSurface(databaseUrl, tag);

        if (result.success) {
          return Response.ok(
            jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          final statusCode = result.errorCode ==
                  CameraParkingSurfaceConstants.errorSurfaceNotFound
              ? 404
              : 400;
          return Response(
            statusCode,
            body: jsonEncode(result.toJson()),
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        print('Error in DELETE /surfaces/$tag: $e');
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Internal server error',
            'errorCode': 'INTERNAL_ERROR',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 서비스 상태 확인
    /// GET /api/v1/camera-parking/health
    router.get('/health', (Request request) async {
      try {
        final health = await _service.getServiceHealth(databaseUrl);
        final statusCode = health['status'] == 'healthy' ? 200 : 503;

        return Response(
          statusCode,
          body: jsonEncode(health),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('Error in GET /health: $e');
        return Response(
          503,
          body: jsonEncode({
            'status': 'unhealthy',
            'error': e.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    /// 서비스 정보 조회
    /// GET /api/v1/camera-parking/info
    router.get('/info', (Request request) async {
      try {
        final info = _service.getServiceInfo();

        return Response.ok(
          jsonEncode(info),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('Error in GET /info: $e');
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Internal server error',
            'errorCode': 'INTERNAL_ERROR',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 레거시 호환성 엔드포인트들

    /// 레거시: 모든 표면 조회 (기존 GET /)
    /// GET /api/v1/camera-parking/legacy/
    router.get('/legacy/', (Request request) async {
      try {
        final result = await _service.getAllSurfaces(databaseUrl);

        if (result.success && result.data != null) {
          // 기존 형식에 맞춰 resultSet 형태로 반환
          final legacyResponse =
              result.data!.map((surface) => surface.toJson()).toList();
          return Response.ok(
            jsonEncode(legacyResponse),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.ok('정보 없음');
        }
      } catch (e) {
        print('Error in legacy endpoint: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    /// 레거시: 표면 업데이트 (기존 POST /updateZone)
    /// POST /api/v1/camera-parking/legacy/updateZone
    router.post('/legacy/updateZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        final updateRequest =
            UpdateCameraParkingSurfaceRequest.fromJson(requestData);
        final beforeTag = updateRequest.beforeTag ?? requestData['beforetag'];

        if (beforeTag == null) {
          return Response.badRequest(body: 'beforetag is required');
        }

        final result =
            await _service.updateSurface(databaseUrl, beforeTag, updateRequest);

        if (result.success) {
          return Response.ok("update success");
        } else {
          return Response.internalServerError(body: 'Error: ${result.message}');
        }
      } catch (e) {
        print('Error in legacy updateZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    /// 레거시: 표면 생성 (기존 POST /insertZone)
    /// POST /api/v1/camera-parking/legacy/insertZone
    router.post('/legacy/insertZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        final createRequest =
            CreateCameraParkingSurfaceRequest.fromJson(requestData);
        final result = await _service.createSurface(databaseUrl, createRequest);

        if (result.success) {
          return Response.ok("create success");
        } else {
          return Response.internalServerError(body: 'Error: ${result.message}');
        }
      } catch (e) {
        print('Error in legacy insertZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    /// 레거시: 표면 삭제 (기존 POST /deleteZone)
    /// POST /api/v1/camera-parking/legacy/deleteZone
    router.post('/legacy/deleteZone', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        final tag = requestData['tag'] as String;
        final result = await _service.deleteSurface(databaseUrl, tag);

        if (result.success) {
          return Response.ok("delete success");
        } else {
          return Response.internalServerError(body: 'Error: ${result.message}');
        }
      } catch (e) {
        print('Error in legacy deleteZone: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    return router;
  }
}
