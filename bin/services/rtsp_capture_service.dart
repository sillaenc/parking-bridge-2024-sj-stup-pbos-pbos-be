/// RTSP 캡처 핵심 서비스
///
/// DB에서 RTSP 주소를 조회하고, FFmpeg로 이미지를 캡처하며,
/// 결과를 DB에 저장하는 핵심 비즈니스 로직을 제공합니다.

import '../config/rtsp_config.dart';
import '../models/rtsp_capture_models.dart';
import '../services/database_client.dart';
import '../utils/rtsp_utils.dart';

/// RTSP 캡처 서비스
class RtspCaptureService {
  final DatabaseClient _databaseClient;
  RtspCaptureStatus _status = RtspCaptureStatus.notInitialized;
  DateTime? _lastCaptureTime;
  int _totalCaptures = 0;
  int _successfulCaptures = 0;
  int _failedCaptures = 0;

  RtspCaptureService(this._databaseClient);

  /// 현재 서비스 상태
  RtspCaptureStatus get status => _status;

  /// 마지막 캡처 시간
  DateTime? get lastCaptureTime => _lastCaptureTime;

  /// 서비스 초기화
  ///
  /// 캡처 디렉토리 생성 및 FFmpeg 설치 확인
  Future<bool> initialize() async {
    try {
      print('🚀 RTSP 캡처 서비스 초기화 시작...');
      _status = RtspCaptureStatus.initializing;

      // 1. 설정 검증
      if (!RtspConfig.validateConfig()) {
        print('❌ RTSP 설정이 유효하지 않습니다');
        _status = RtspCaptureStatus.error;
        return false;
      }

      // 2. 캡처 디렉토리 생성
      await ensureDirectoryExists(RtspConfig.CAPTURE_OUTPUT_DIR);

      // 3. FFmpeg 설치 확인
      final ffmpegInstalled = await isFFmpegInstalled();
      if (!ffmpegInstalled) {
        print('❌ FFmpeg가 설치되어 있지 않습니다');
        print('   설치 방법:');
        print('   - macOS: brew install ffmpeg');
        print('   - Ubuntu/Debian: sudo apt-get install ffmpeg');
        print('   - Windows: https://ffmpeg.org/download.html');
        _status = RtspCaptureStatus.error;
        return false;
      }

      final ffmpegVersion = await getFFmpegVersion();
      print('✅ FFmpeg 설치 확인: $ffmpegVersion');

      _status = RtspCaptureStatus.running;
      print('✅ RTSP 캡처 서비스 초기화 완료');
      return true;
    } catch (e, stackTrace) {
      print('❌ 초기화 실패: $e');
      print('   Stack trace: $stackTrace');
      _status = RtspCaptureStatus.error;
      return false;
    }
  }

  /// 모든 RTSP 캡처 설정 조회
  Future<List<RtspCaptureModel>> getAllCaptures(String databaseUrl) async {
    try {
      final response = await _databaseClient.query(
        databaseUrl,
        'S_RtspCapture_All',
        {},
      );

      if (response['success'] == true) {
        final results = response['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map((item) =>
                RtspCaptureModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ RTSP 캡처 목록 조회 실패: $e');
      return [];
    }
  }

  /// 태그로 캡처 설정 조회
  Future<RtspCaptureModel?> getCaptureByTag(
    String databaseUrl,
    String tag,
  ) async {
    try {
      final response = await _databaseClient.query(
        databaseUrl,
        'S_RtspCapture_ByTag',
        {'tag': tag},
      );

      if (response['success'] == true) {
        final results = response['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return RtspCaptureModel.fromJson(
              results.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      print('❌ RTSP 캡처 조회 실패 (tag: $tag): $e');
      return null;
    }
  }

  /// 고유 RTSP 주소 목록 조회
  Future<List<String>> getDistinctRtspAddresses(String databaseUrl) async {
    try {
      final response = await _databaseClient.query(
        databaseUrl,
        'S_RtspCapture_Distinct',
        {},
      );

      if (response['success'] == true) {
        final results = response['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map((item) => item['rtsp_address'] as String)
            .where((addr) => addr.isNotEmpty)
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ 고유 RTSP 주소 조회 실패: $e');
      return [];
    }
  }

  /// 단일 RTSP 주소에서 캡처
  ///
  /// 해당 RTSP 주소를 사용하는 모든 태그의 last_image_path를 업데이트
  Future<bool> captureFromRtsp(String databaseUrl, String rtspAddress) async {
    try {
      // 1. 출력 파일 경로 생성
      final outputPath = rtspToFullPath(rtspAddress);

      // 2. 원자적 캡처 (임시 파일 → 실제 파일)
      final success = await atomicCapture(rtspAddress, outputPath);

      if (!success) {
        _failedCaptures++;
        print('   ❌ 실패: $rtspAddress');
        return false;
      }

      // 3. DB 업데이트 - 해당 RTSP 주소를 가진 모든 태그
      await _databaseClient.query(
        databaseUrl,
        'U_RtspCapture_ByRtsp',
        {
          'rtsp_address': rtspAddress,
          'last_image_path': outputPath,
        },
      );

      _successfulCaptures++;
      print('   ✅ 성공: $rtspAddress');
      return true;
    } catch (e) {
      print('   ❌ 실패: $rtspAddress (에러: $e)');
      _failedCaptures++;
      return false;
    }
  }

  /// 모든 RTSP 주소에서 배치 방식으로 병렬 캡처
  ///
  /// 시스템 부하를 고려하여 MAX_CONCURRENT_CAPTURES 개씩 배치로 나눠서 처리
  /// 예: 80개 주소 → 20개씩 4배치로 처리
  Future<Map<String, dynamic>> captureAll(String databaseUrl) async {
    try {
      print('🎬 전체 RTSP 캡처 시작 (배치 병렬 실행)...');
      final startTime = DateTime.now();

      // 1. 고유 RTSP 주소 목록 조회
      final rtspAddresses = await getDistinctRtspAddresses(databaseUrl);

      if (rtspAddresses.isEmpty) {
        print('ℹ️  캡처할 RTSP 주소가 없습니다');
        return {
          'success': true,
          'message': '캡처할 RTSP 주소가 없습니다',
          'total': 0,
          'successful': 0,
          'failed': 0,
        };
      }

      final totalAddresses = rtspAddresses.length;
      final batchSize = RtspConfig.MAX_CONCURRENT_CAPTURES;
      final batchCount = (totalAddresses / batchSize).ceil();

      print('📋 총 $totalAddresses개의 고유 RTSP 주소 발견');
      print('⚡ 배치 병렬 캡처 시작 (배치 크기: $batchSize, 배치 수: $batchCount)...');

      // 2. 배치별로 처리
      int totalSuccessCount = 0;
      int totalFailCount = 0;

      for (int batchIndex = 0; batchIndex < batchCount; batchIndex++) {
        final startIdx = batchIndex * batchSize;
        final endIdx = (startIdx + batchSize > totalAddresses)
            ? totalAddresses
            : startIdx + batchSize;
        final batch = rtspAddresses.sublist(startIdx, endIdx);

        final batchStartTime = DateTime.now();
        print(
            '\n📦 배치 ${batchIndex + 1}/$batchCount 시작 (${batch.length}개 주소, ${batchStartTime.toString().substring(11, 19)})');

        // 배치 내 모든 주소 목록 출력
        for (int i = 0; i < batch.length; i++) {
          print('   ${startIdx + i + 1}/$totalAddresses: ${batch[i]}');
        }

        print('⚡ ${batch.length}개 주소를 동시에 캡처 시작...\n');

        // 현재 배치의 모든 주소를 병렬로 캡처 (Future 생성)
        final captureFutures = batch
            .map((rtspAddress) => captureFromRtsp(databaseUrl, rtspAddress))
            .toList();

        // 현재 배치의 모든 작업이 완료될 때까지 대기
        final batchResults = await Future.wait(captureFutures);

        final batchEndTime = DateTime.now();
        final batchDuration = batchEndTime.difference(batchStartTime);

        // 배치 결과 집계
        final batchSuccessCount =
            batchResults.where((success) => success).length;
        final batchFailCount = batchResults.where((success) => !success).length;

        totalSuccessCount += batchSuccessCount;
        totalFailCount += batchFailCount;

        print(
            '\n✅ 배치 ${batchIndex + 1}/$batchCount 완료 (${batchEndTime.toString().substring(11, 19)})');
        print('   성공: $batchSuccessCount, 실패: $batchFailCount');
        print('   소요 시간: ${batchDuration.inSeconds}초');

        // 마지막 배치가 아니면 짧은 대기 (시스템 안정화)
        if (batchIndex < batchCount - 1) {
          print('⏸️  배치 간 대기 100ms...\n');
          await Future.delayed(Duration(milliseconds: 100));
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _lastCaptureTime = endTime;
      _totalCaptures++;

      print('\n✅ 전체 RTSP 캡처 완료 (배치 병렬 실행)');
      print('   총 주소: $totalAddresses');
      print('   성공: $totalSuccessCount');
      print('   실패: $totalFailCount');
      print('   소요 시간: ${duration.inSeconds}초');
      print('   배치 처리: $batchCount개 배치 × 최대 $batchSize개');

      return {
        'success': true,
        'message': '전체 캡처 완료 (배치 병렬)',
        'total': totalAddresses,
        'successful': totalSuccessCount,
        'failed': totalFailCount,
        'duration_seconds': duration.inSeconds,
        'batch_count': batchCount,
        'batch_size': batchSize,
        'timestamp': endTime.toIso8601String(),
      };
    } catch (e, stackTrace) {
      print('❌ 전체 캡처 실패: $e');
      print('   Stack trace: $stackTrace');
      return {
        'success': false,
        'message': '전체 캡처 실패: $e',
      };
    }
  }

  /// RTSP 캡처 설정 생성
  Future<RtspCaptureResponse> createCapture(
    String databaseUrl,
    RtspCaptureRequest request,
  ) async {
    try {
      // 유효성 검증
      if (!request.isValid()) {
        return RtspCaptureResponse(
          success: false,
          message: RtspCaptureConstants.msgInvalidTag,
          errorCode: RtspCaptureConstants.errorInvalidTag,
        );
      }

      if (!request.isValidRtspAddress()) {
        return RtspCaptureResponse(
          success: false,
          message: RtspCaptureConstants.msgInvalidRtsp,
          errorCode: RtspCaptureConstants.errorInvalidRtsp,
        );
      }

      // 중복 확인
      final existing = await getCaptureByTag(databaseUrl, request.tag);
      if (existing != null) {
        return RtspCaptureResponse(
          success: false,
          message: RtspCaptureConstants.msgTagExists,
          errorCode: RtspCaptureConstants.errorTagExists,
        );
      }

      // 파일 경로 생성
      final imagePath = rtspToFullPath(request.rtspAddress);

      // DB에 삽입
      final response = await _databaseClient.query(
        databaseUrl,
        'I_RtspCapture',
        {
          'tag': request.tag,
          'rtsp_address': request.rtspAddress,
          'last_image_path': imagePath,
        },
      );

      if (response['success'] == true) {
        final created = RtspCaptureModel(
          uid: 0, // DB에서 자동 생성
          tag: request.tag,
          rtspAddress: request.rtspAddress,
          lastImagePath: imagePath,
        );

        return RtspCaptureResponse(
          success: true,
          message: RtspCaptureConstants.msgCaptureCreated,
          data: created,
        );
      }

      return RtspCaptureResponse(
        success: false,
        message: RtspCaptureConstants.msgDatabaseError,
        errorCode: RtspCaptureConstants.errorDatabaseOperation,
      );
    } catch (e) {
      print('❌ RTSP 캡처 생성 실패: $e');
      return RtspCaptureResponse(
        success: false,
        message: RtspCaptureConstants.msgDatabaseError,
        errorCode: RtspCaptureConstants.errorDatabaseOperation,
      );
    }
  }

  /// RTSP 캡처 설정 업데이트
  Future<RtspCaptureResponse> updateCapture(
    String databaseUrl,
    String tag,
    RtspCaptureRequest request,
  ) async {
    try {
      // 존재 확인
      final existing = await getCaptureByTag(databaseUrl, tag);
      if (existing == null) {
        return RtspCaptureResponse(
          success: false,
          message: RtspCaptureConstants.msgTagNotFound,
          errorCode: RtspCaptureConstants.errorTagNotFound,
        );
      }

      // RTSP 주소 유효성 검증
      if (!isValidRtspAddress(request.rtspAddress)) {
        return RtspCaptureResponse(
          success: false,
          message: RtspCaptureConstants.msgInvalidRtsp,
          errorCode: RtspCaptureConstants.errorInvalidRtsp,
        );
      }

      // 파일 경로 생성
      final imagePath = rtspToFullPath(request.rtspAddress);

      // DB 업데이트
      await _databaseClient.query(
        databaseUrl,
        'U_RtspCapture_Single',
        {
          'tag': tag,
          'rtsp_address': request.rtspAddress,
          'last_image_path': imagePath,
        },
      );

      final updated = RtspCaptureModel(
        uid: existing.uid,
        tag: tag,
        rtspAddress: request.rtspAddress,
        lastImagePath: imagePath,
      );

      return RtspCaptureResponse(
        success: true,
        message: RtspCaptureConstants.msgCaptureUpdated,
        data: updated,
      );
    } catch (e) {
      print('❌ RTSP 캡처 업데이트 실패: $e');
      return RtspCaptureResponse(
        success: false,
        message: RtspCaptureConstants.msgDatabaseError,
        errorCode: RtspCaptureConstants.errorDatabaseOperation,
      );
    }
  }

  /// RTSP 캡처 설정 삭제
  Future<bool> deleteCapture(String databaseUrl, String tag) async {
    try {
      final response = await _databaseClient.query(
        databaseUrl,
        'D_RtspCapture',
        {'tag': tag},
      );

      return response['success'] == true;
    } catch (e) {
      print('❌ RTSP 캡처 삭제 실패: $e');
      return false;
    }
  }

  /// RTSP 캡처 통계 조회
  Future<RtspCaptureStats> getStats(String databaseUrl) async {
    try {
      final response = await _databaseClient.query(
        databaseUrl,
        'S_RtspCapture_Stats',
        {},
      );

      if (response['success'] == true) {
        final results = response['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final data = results.first as Map<String, dynamic>;

          // 실제 캡처된 이미지 개수 계산
          final files = await listCapturedImages();

          return RtspCaptureStats(
            uniqueCameras: data['unique_cameras'] as int? ?? 0,
            totalTags: data['total_tags'] as int? ?? 0,
            capturedImages: files.length,
          );
        }
      }

      return RtspCaptureStats(
        uniqueCameras: 0,
        totalTags: 0,
        capturedImages: 0,
      );
    } catch (e) {
      print('❌ 통계 조회 실패: $e');
      return RtspCaptureStats(
        uniqueCameras: 0,
        totalTags: 0,
        capturedImages: 0,
      );
    }
  }

  /// 서비스 상태 정보 조회
  Map<String, dynamic> getServiceInfo() {
    return {
      'service': 'RTSP Capture Service',
      'version': '1.0.0',
      'status': _status.displayName,
      'is_healthy': _status.isHealthy,
      'last_capture_time': _lastCaptureTime?.toIso8601String(),
      'total_captures': _totalCaptures,
      'successful_captures': _successfulCaptures,
      'failed_captures': _failedCaptures,
      'success_rate': _totalCaptures > 0
          ? '${((_successfulCaptures / _totalCaptures) * 100).toStringAsFixed(1)}%'
          : 'N/A',
      'config': RtspConfig.getConfigInfo(),
    };
  }
}
