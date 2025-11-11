import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import '../services/engine_data_processor.dart';

/// 엔진 데이터 처리 관련 API 엔드포인트를 제공하는 라우터
/// 기존 receive_enginedata_send_to_dartserver 기능을 RESTful API로 구현
class EngineDataRoutes {
  final ManageAddress _manageAddress;
  final EngineDataProcessor _processor;
  late final Router _router;

  EngineDataRoutes({required ManageAddress manageAddress})
      : _manageAddress = manageAddress,
        _processor = EngineDataProcessor() {
    _setupRoutes();
  }

  Router get router => _router;

  /// API 라우트 설정
  void _setupRoutes() {
    _router = Router()

      // GET /api/v1/engine/data/process
      // 엔진 데이터 수동 처리 트리거
      ..get('/process', _processEngineData)

      // GET /api/v1/engine/data/status
      // 현재 주차장 상태 조회
      ..get('/status', _getParkingStatus)

      // GET /api/v1/engine/data/errors
      // 현재 에러 상태 조회
      ..get('/errors', _getErrorStatus)

      // GET /api/v1/engine/data/statistics
      // 처리 통계 정보 조회
      ..get('/statistics', _getProcessingStatistics)

      // POST /api/v1/engine/data/statistics/trigger
      // 수동 통계 처리 트리거
      ..post('/statistics/trigger', _triggerStatisticsProcessing)

      // GET /api/v1/engine/data/health
      // 엔진 데이터 처리 서비스 헬스 체크
      ..get('/health', _healthCheck);
  }

  /// 엔진 데이터 수동 처리 트리거
  ///
  /// GET /api/v1/engine/data/process
  /// Query Parameters:
  ///   - force: true/false (강제 처리 여부)
  Future<Response> _processEngineData(Request request) async {
    try {
      // 주소 정보 검증
      final addresses = _validateAddresses();
      if (addresses['error'] != null) {
        return _errorResponse(400, addresses['error']!);
      }

      final force = request.url.queryParameters['force'] == 'true';
      print('🔄 엔진 데이터 수동 처리 요청 (강제: $force)');

      // 엔진 데이터 처리 실행
      final result = await _processor.processEngineData(
        engineDbAddr: addresses['engine']!,
        displayDbAddr: addresses['display']!,
        displayDbLPR: addresses['lpr']!,
      );

      return _successResponse({
        'message': '엔진 데이터 처리가 완료되었습니다.',
        'processed_slots': result.length,
        'occupied_slots': result,
        'processed_at': DateTime.now().toIso8601String(),
        'forced': force,
      });
    } catch (e) {
      print('❌ 엔진 데이터 처리 API 오류: $e');
      return _errorResponse(500, '엔진 데이터 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 주차장 상태 조회
  ///
  /// GET /api/v1/engine/data/status
  /// Query Parameters:
  ///   - include_details: true/false (상세 정보 포함 여부)
  Future<Response> _getParkingStatus(Request request) async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return _errorResponse(503, '디스플레이 DB 주소가 설정되지 않았습니다.');
      }

      final includeDetails =
          request.url.queryParameters['include_details'] == 'true';

      final result = await _processor.getParkingStatus(displayDbAddr);

      // 상세 정보 제외 옵션
      if (!includeDetails && result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final stats = data['statistics'] as Map<String, dynamic>;

        result['data'] = {
          'summary': {
            'total_spaces': stats['total_spaces'],
            'occupied_spaces': stats['occupied_spaces'],
            'available_spaces': stats['available_spaces'],
            'occupancy_rate': stats['occupancy_rate'],
          },
          'timestamp': stats['timestamp'],
        };
      }

      return _jsonResponse(result);
    } catch (e) {
      print('❌ 주차장 상태 조회 API 오류: $e');
      return _errorResponse(500, '주차장 상태 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 에러 상태 조회
  ///
  /// GET /api/v1/engine/data/errors
  Future<Response> _getErrorStatus(Request request) async {
    try {
      final result = _processor.getErrorStatus();
      return _jsonResponse(result);
    } catch (e) {
      print('❌ 에러 상태 조회 API 오류: $e');
      return _errorResponse(500, '에러 상태 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 처리 통계 정보 조회
  ///
  /// GET /api/v1/engine/data/statistics
  Future<Response> _getProcessingStatistics(Request request) async {
    try {
      final result = _processor.getProcessingStatistics();
      return _jsonResponse(result);
    } catch (e) {
      print('❌ 처리 통계 조회 API 오류: $e');
      return _errorResponse(500, '처리 통계 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 수동 통계 처리 트리거
  ///
  /// POST /api/v1/engine/data/statistics/trigger
  /// Body: {"period": "hour|day|month|year"}
  Future<Response> _triggerStatisticsProcessing(Request request) async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return _errorResponse(503, '디스플레이 DB 주소가 설정되지 않았습니다.');
      }

      // 요청 본문 파싱
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final period = data['period']?.toString();

      if (period == null) {
        return _errorResponse(
            400, 'period 파라미터가 필요합니다. (hour, day, month, year 중 선택)');
      }

      final result = await _processor.triggerStatisticsProcessing(
        displayDbAddr: displayDbAddr,
        period: period,
      );

      return _jsonResponse(result);
    } catch (e) {
      print('❌ 수동 통계 처리 API 오류: $e');
      return _errorResponse(500, '수동 통계 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 헬스 체크
  ///
  /// GET /api/v1/engine/data/health
  Future<Response> _healthCheck(Request request) async {
    try {
      final addresses = _validateAddresses();
      final hasErrors = addresses['error'] != null;

      return _jsonResponse({
        'success': !hasErrors,
        'service': 'engine-data-processor',
        'status': hasErrors ? 'unhealthy' : 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'addresses': {
          'engine_db':
              _manageAddress.engineDbAddr != null ? 'configured' : 'missing',
          'display_db':
              _manageAddress.displayDbAddr != null ? 'configured' : 'missing',
          'lpr_db':
              _manageAddress.displayDbLPR != null ? 'configured' : 'missing',
        },
        'error': addresses['error'],
      });
    } catch (e) {
      return _errorResponse(500, '헬스 체크 중 오류가 발생했습니다: $e');
    }
  }

  /// 주소 정보 유효성 검증
  ///
  /// Returns: 검증된 주소 정보 또는 오류 메시지
  Map<String, String?> _validateAddresses() {
    final engineAddr = _manageAddress.engineDbAddr;
    final displayAddr = _manageAddress.displayDbAddr;
    final lprAddr = _manageAddress.displayDbLPR;

    if (engineAddr == null) {
      return {'error': '엔진 DB 주소가 설정되지 않았습니다.'};
    }
    if (displayAddr == null) {
      return {'error': '디스플레이 DB 주소가 설정되지 않았습니다.'};
    }
    if (lprAddr == null) {
      return {'error': 'LPR DB 주소가 설정되지 않았습니다.'};
    }

    return {
      'engine': engineAddr,
      'display': displayAddr,
      'lpr': lprAddr,
    };
  }

  /// 성공 응답 생성
  ///
  /// [data] 응답 데이터
  /// Returns: JSON 응답
  Response _successResponse(Map<String, dynamic> data) {
    return _jsonResponse({
      'success': true,
      'data': data,
    });
  }

  /// 오류 응답 생성
  ///
  /// [statusCode] HTTP 상태 코드
  /// [message] 오류 메시지
  /// Returns: JSON 오류 응답
  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'error': {
          'message': message,
          'code': statusCode,
          'timestamp': DateTime.now().toIso8601String(),
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// JSON 응답 생성
  ///
  /// [data] 응답 데이터
  /// Returns: JSON 응답
  Response _jsonResponse(Map<String, dynamic> data) {
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 리소스 해제
  void dispose() {
    _processor.dispose();
  }
}
