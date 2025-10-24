/// RTSP 캡처 관련 설정 상수
///
/// 모든 설정값은 코드에 하드코딩되어 있으며,
/// 환경변수에서는 RTSP (캡처 주기) 값만 읽어옵니다.

class RtspConfig {
  /// 캡처 이미지 저장 경로 (고정)
  /// 프로젝트 루트 기준 상대 경로
  static const String CAPTURE_OUTPUT_DIR = 'camera/captures';

  /// 이미지 포맷 (고정)
  static const String IMAGE_FORMAT = 'jpg';

  /// FFmpeg 타임아웃 (초)
  /// RTSP 연결 및 캡처 작업의 최대 대기 시간
  /// 병렬 실행을 고려하여 짧게 설정
  static const int CAPTURE_TIMEOUT_SECONDS = 5;

  /// 이미지 품질 (1-31, 낮을수록 고품질)
  /// q:v 파라미터에 사용 (2 = 매우 높은 품질)
  static const int IMAGE_QUALITY = 2;

  /// RTSP 전송 프로토콜
  /// tcp: 안정적이지만 느림, udp: 빠르지만 패킷 손실 가능
  static const String RTSP_TRANSPORT = 'tcp';

  /// 파일명 날짜 포맷 (사용 안 함, 파일명은 RTSP 주소 기반)
  static const String FILENAME_DATE_FORMAT = 'yyyyMMdd_HHmmss';

  /// 기본 캡처 주기 (초)
  /// 환경변수에서 읽지 못할 경우 사용
  static const int DEFAULT_CAPTURE_INTERVAL_SECONDS = 60;

  /// FFmpeg 실행 파일 경로 (시스템 PATH에서 찾음)
  static const String FFMPEG_EXECUTABLE = 'ffmpeg';

  /// 임시 파일 접두사
  /// 원자적 쓰기를 위해 임시 파일을 먼저 생성
  static const String TEMP_FILE_PREFIX = '.tmp_';

  /// 최대 파일명 길이
  /// 파일시스템 호환성을 위해 제한
  static const int MAX_FILENAME_LENGTH = 60;

  /// 해시 길이 (긴 파일명 단축 시 사용)
  static const int HASH_LENGTH = 12;

  /// FFmpeg 로그 레벨
  /// panic, fatal, error, warning, info, verbose, debug, trace
  static const String FFMPEG_LOG_LEVEL = 'error';

  /// 캡처 실패 시 재시도 횟수
  static const int MAX_RETRY_COUNT = 3;

  /// 재시도 간격 (초)
  /// 병렬 실행으로 빠른 재시도 가능
  static const int RETRY_DELAY_SECONDS = 2;

  /// 서비스 상태 확인 주기 (초)
  static const int HEALTH_CHECK_INTERVAL_SECONDS = 30;

  /// 동시 캡처 최대 개수
  /// 시스템 부하를 고려하여 한 번에 처리할 최대 RTSP 주소 수를 제한
  /// 80개 주소가 있어도 20개씩 4배치로 나눠서 처리
  static const int MAX_CONCURRENT_CAPTURES = 20;

  /// 이미지 파일 확장자
  static String get imageExtension => '.$IMAGE_FORMAT';

  /// 전체 캡처 출력 경로 (확장자 포함)
  static String getFullOutputPath(String filename) {
    return '$CAPTURE_OUTPUT_DIR/$filename.$IMAGE_FORMAT';
  }

  /// 임시 파일 경로 생성
  static String getTempFilePath(String filename) {
    return '$CAPTURE_OUTPUT_DIR/$TEMP_FILE_PREFIX$filename.$IMAGE_FORMAT';
  }

  /// FFmpeg 타임아웃 값 (마이크로초)
  /// FFmpeg는 타임아웃을 마이크로초 단위로 받음
  static int get ffmpegTimeoutMicroseconds => CAPTURE_TIMEOUT_SECONDS * 1000000;

  /// 설정 정보 출력 (디버깅용)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'capture_output_dir': CAPTURE_OUTPUT_DIR,
      'image_format': IMAGE_FORMAT,
      'capture_timeout_seconds': CAPTURE_TIMEOUT_SECONDS,
      'image_quality': IMAGE_QUALITY,
      'rtsp_transport': RTSP_TRANSPORT,
      'default_interval_seconds': DEFAULT_CAPTURE_INTERVAL_SECONDS,
      'ffmpeg_executable': FFMPEG_EXECUTABLE,
      'max_filename_length': MAX_FILENAME_LENGTH,
      'ffmpeg_log_level': FFMPEG_LOG_LEVEL,
      'max_retry_count': MAX_RETRY_COUNT,
      'retry_delay_seconds': RETRY_DELAY_SECONDS,
    };
  }

  /// 설정 검증
  static bool validateConfig() {
    // 기본적인 설정 검증
    if (CAPTURE_TIMEOUT_SECONDS <= 0) return false;
    if (IMAGE_QUALITY < 1 || IMAGE_QUALITY > 31) return false;
    if (CAPTURE_OUTPUT_DIR.isEmpty) return false;
    if (IMAGE_FORMAT.isEmpty) return false;

    return true;
  }
}

/// RTSP 캡처 서비스 상태
enum RtspCaptureStatus {
  /// 초기화 전
  notInitialized,

  /// 초기화 중
  initializing,

  /// 실행 중
  running,

  /// 일시 정지
  paused,

  /// 정지됨
  stopped,

  /// 오류 발생
  error,
}

/// RTSP 캡처 서비스 상태 확장
extension RtspCaptureStatusExtension on RtspCaptureStatus {
  String get displayName {
    switch (this) {
      case RtspCaptureStatus.notInitialized:
        return 'Not Initialized';
      case RtspCaptureStatus.initializing:
        return 'Initializing';
      case RtspCaptureStatus.running:
        return 'Running';
      case RtspCaptureStatus.paused:
        return 'Paused';
      case RtspCaptureStatus.stopped:
        return 'Stopped';
      case RtspCaptureStatus.error:
        return 'Error';
    }
  }

  bool get isHealthy {
    return this == RtspCaptureStatus.running ||
        this == RtspCaptureStatus.initializing;
  }
}
