/// RTSP 캡처 스케줄러 서비스
///
/// 환경변수(RTSP)에서 설정된 주기마다 RTSP 캡처를 실행합니다.
/// Isolate를 사용하지 않고 Timer를 사용하여 메인 스레드에서 실행하되,
/// 비동기 방식으로 다른 작업에 영향을 주지 않습니다.

import 'dart:async';
import 'dart:io';

import '../config/rtsp_config.dart';
import '../services/rtsp_capture_service.dart';

/// RTSP 스케줄러 서비스
class RtspSchedulerService {
  final RtspCaptureService _captureService;
  final String _databaseUrl;

  Timer? _timer;
  bool _isRunning = false;
  bool _isCapturing = false;
  int _intervalSeconds = RtspConfig.DEFAULT_CAPTURE_INTERVAL_SECONDS;

  DateTime? _nextCaptureTime;
  int _executionCount = 0;

  RtspSchedulerService({
    required RtspCaptureService captureService,
    required String databaseUrl,
  })  : _captureService = captureService,
        _databaseUrl = databaseUrl;

  /// 스케줄러 실행 여부
  bool get isRunning => _isRunning;

  /// 캡처 중 여부
  bool get isCapturing => _isCapturing;

  /// 다음 캡처 예정 시간
  DateTime? get nextCaptureTime => _nextCaptureTime;

  /// 실행 횟수
  int get executionCount => _executionCount;

  /// 캡처 주기 (초)
  int get intervalSeconds => _intervalSeconds;

  /// 스케줄러 시작
  ///
  /// 환경변수에서 RTSP 값을 읽어 캡처 주기를 설정하고,
  /// 주기적으로 캡처를 실행합니다.
  Future<bool> start() async {
    if (_isRunning) {
      print('⚠️  RTSP 스케줄러가 이미 실행 중입니다');
      return false;
    }

    try {
      print('🚀 RTSP 스케줄러 시작...');

      // 환경변수에서 캡처 주기 읽기
      final rtspEnv = Platform.environment['RTSP'];
      if (rtspEnv != null && rtspEnv.isNotEmpty) {
        final parsedInterval = int.tryParse(rtspEnv);
        if (parsedInterval != null && parsedInterval > 0) {
          _intervalSeconds = parsedInterval;
          print('✅ 환경변수 RTSP: ${_intervalSeconds}초 주기로 캡처');
        } else {
          print(
              '⚠️  잘못된 RTSP 값: $rtspEnv, 기본값 사용: ${RtspConfig.DEFAULT_CAPTURE_INTERVAL_SECONDS}초');
          _intervalSeconds = RtspConfig.DEFAULT_CAPTURE_INTERVAL_SECONDS;
        }
      } else {
        print(
            'ℹ️  환경변수 RTSP 없음, 기본값 사용: ${RtspConfig.DEFAULT_CAPTURE_INTERVAL_SECONDS}초');
        _intervalSeconds = RtspConfig.DEFAULT_CAPTURE_INTERVAL_SECONDS;
      }

      // 서비스 초기화
      final initialized = await _captureService.initialize();
      if (!initialized) {
        print('❌ RTSP 캡처 서비스 초기화 실패');
        return false;
      }

      _isRunning = true;

      // 첫 캡처 즉시 실행 (서버 시작 직후)
      print('🎬 첫 캡처 즉시 실행...');
      _executeCapture();

      // 주기적 실행 시작
      _scheduleNextCapture();

      print('✅ RTSP 스케줄러 시작 완료 (${_intervalSeconds}초 주기)');
      return true;
    } catch (e, stackTrace) {
      print('❌ RTSP 스케줄러 시작 실패: $e');
      print('   Stack trace: $stackTrace');
      _isRunning = false;
      return false;
    }
  }

  /// 다음 캡처 예약
  void _scheduleNextCapture() {
    if (!_isRunning) return;

    _nextCaptureTime = DateTime.now().add(Duration(seconds: _intervalSeconds));

    _timer = Timer(Duration(seconds: _intervalSeconds), () {
      _executeCapture();
      _scheduleNextCapture(); // 다음 캡처 예약
    });

    print('⏰ 다음 캡처 예정: ${_nextCaptureTime!.toLocal()}');
  }

  /// 캡처 실행
  void _executeCapture() async {
    if (_isCapturing) {
      print('⚠️  이전 캡처가 아직 진행 중입니다. 건너뜁니다.');
      return;
    }

    try {
      _isCapturing = true;
      _executionCount++;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📸 RTSP 캡처 실행 #$_executionCount');
      print('   시작 시간: ${DateTime.now().toLocal()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final result = await _captureService.captureAll(_databaseUrl);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ RTSP 캡처 완료 #$_executionCount');
      print('   종료 시간: ${DateTime.now().toLocal()}');
      print('   결과: ${result['successful']}/${result['total']} 성공');
      if (result['failed'] > 0) {
        print('   실패: ${result['failed']}개');
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stackTrace) {
      print('❌ 캡처 실행 중 예외 발생: $e');
      print('   Stack trace: $stackTrace');
    } finally {
      _isCapturing = false;
    }
  }

  /// 스케줄러 중지
  Future<void> stop() async {
    if (!_isRunning) {
      print('⚠️  RTSP 스케줄러가 실행 중이 아닙니다');
      return;
    }

    print('🛑 RTSP 스케줄러 중지 중...');

    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _nextCaptureTime = null;

    // 진행 중인 캡처가 완료될 때까지 대기
    int waitCount = 0;
    while (_isCapturing && waitCount < 30) {
      print('⏳ 진행 중인 캡처 완료 대기... (${waitCount + 1}/30)');
      await Future.delayed(Duration(seconds: 1));
      waitCount++;
    }

    if (_isCapturing) {
      print('⚠️  진행 중인 캡처가 30초 내에 완료되지 않았습니다');
    }

    print('✅ RTSP 스케줄러 중지 완료');
  }

  /// 수동으로 즉시 캡처 실행 (테스트용)
  Future<Map<String, dynamic>> triggerCapture() async {
    if (_isCapturing) {
      return {
        'success': false,
        'message': '이전 캡처가 아직 진행 중입니다',
      };
    }

    print('🎯 수동 캡처 트리거');
    _executeCapture();

    return {
      'success': true,
      'message': '수동 캡처가 시작되었습니다',
    };
  }

  /// 캡처 주기 변경 (런타임 중)
  void updateInterval(int newIntervalSeconds) {
    if (newIntervalSeconds <= 0) {
      print('❌ 잘못된 주기 값: $newIntervalSeconds');
      return;
    }

    print('🔄 캡처 주기 변경: ${_intervalSeconds}초 → ${newIntervalSeconds}초');
    _intervalSeconds = newIntervalSeconds;

    // 실행 중이면 타이머 재시작
    if (_isRunning) {
      _timer?.cancel();
      _scheduleNextCapture();
    }
  }

  /// 스케줄러 상태 정보
  Map<String, dynamic> getStatus() {
    return {
      'is_running': _isRunning,
      'is_capturing': _isCapturing,
      'interval_seconds': _intervalSeconds,
      'execution_count': _executionCount,
      'next_capture_time': _nextCaptureTime?.toIso8601String(),
      'last_capture_time': _captureService.lastCaptureTime?.toIso8601String(),
      'capture_service_status': _captureService.status.displayName,
      'service_info': _captureService.getServiceInfo(),
    };
  }

  /// 스케줄러 일시 정지
  void pause() {
    if (!_isRunning) {
      print('⚠️  스케줄러가 실행 중이 아닙니다');
      return;
    }

    print('⏸️  RTSP 스케줄러 일시 정지');
    _timer?.cancel();
    _timer = null;
    _nextCaptureTime = null;
  }

  /// 스케줄러 재개
  void resume() {
    if (!_isRunning) {
      print('⚠️  스케줄러가 실행 중이 아닙니다');
      return;
    }

    if (_timer != null) {
      print('⚠️  스케줄러가 이미 실행 중입니다');
      return;
    }

    print('▶️  RTSP 스케줄러 재개');
    _scheduleNextCapture();
  }

  /// 스케줄러 재시작
  Future<bool> restart() async {
    print('🔄 RTSP 스케줄러 재시작...');
    await stop();
    await Future.delayed(Duration(seconds: 2));
    return await start();
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 RTSP 스케줄러 디버그 정보');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('상태: ${_isRunning ? "실행 중" : "중지됨"}');
    print('캡처 중: ${_isCapturing ? "예" : "아니오"}');
    print('캡처 주기: ${_intervalSeconds}초');
    print('실행 횟수: $_executionCount');
    print('다음 캡처: ${_nextCaptureTime?.toLocal() ?? "없음"}');
    print('마지막 캡처: ${_captureService.lastCaptureTime?.toLocal() ?? "없음"}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
