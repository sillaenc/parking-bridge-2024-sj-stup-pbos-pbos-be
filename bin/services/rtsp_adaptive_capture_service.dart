/// RTSP 적응형 캡처 서비스
///
/// 기존 RtspCaptureService를 확장하여 다음 기능을 추가:
/// - 동적 배치 크기 조정 (성공률에 따라 5~40개)
/// - 블랙리스트 관리 (연속 실패 주소 제외)
/// - 우선순위 기반 정렬 (응답 시간 빠른 순)
/// - 동적 대기 시간 (성공률에 따라 50~500ms)

import 'dart:math';
import '../config/rtsp_config.dart';
import '../services/database_client.dart';
import '../services/rtsp_capture_service.dart';

/// 적응형 RTSP 캡처 서비스
///
/// 시스템 상황과 성공률에 따라 동적으로 배치 크기를 조정하여
/// 최적의 성능을 유지합니다.
class RtspAdaptiveCaptureService extends RtspCaptureService {
  // === 동적 배치 크기 ===
  int _currentBatchSize = RtspConfig.INITIAL_CONCURRENT_CAPTURES;

  // === 블랙리스트 관리 ===
  /// 주소별 연속 실패 횟수
  final Map<String, int> _failureCount = {};

  /// 블랙리스트 (일시적으로 제외된 주소)
  final Set<String> _blacklist = {};

  /// 마지막 블랙리스트 리셋 시간
  DateTime? _lastBlacklistReset;

  // === 성능 통계 ===
  /// 주소별 평균 응답 시간 (밀리초)
  final Map<String, int> _averageResponseTime = {};

  /// 주소별 최근 캡처 시간
  final Map<String, DateTime> _lastCaptureTime = {};

  // === 통계 정보 ===
  int _batchAdjustmentCount = 0;
  int _blacklistAddCount = 0;
  int _blacklistRemoveCount = 0;

  RtspAdaptiveCaptureService(DatabaseClient databaseClient)
      : super(databaseClient);

  /// 적응형 전체 캡처
  ///
  /// 주요 개선사항:
  /// 1. 동적 배치 크기 조정 (5~40개)
  /// 2. 블랙리스트 필터링 (연속 실패 주소 제외)
  /// 3. 우선순위 기반 정렬 (빠른 응답 시간 우선)
  /// 4. 동적 대기 시간 (성공률에 따라 조정)
  @override
  Future<Map<String, dynamic>> captureAll(String databaseUrl) async {
    try {
      print('🎬 적응형 RTSP 캡처 시작 (Adaptive Batch Processing)...');
      final startTime = DateTime.now();

      // 1. 블랙리스트 리셋 확인 (30분마다)
      _checkAndResetBlacklist();

      // 2. 고유 RTSP 주소 목록 조회
      var rtspAddresses = await getDistinctRtspAddresses(databaseUrl);

      if (rtspAddresses.isEmpty) {
        print('ℹ️  캡처할 RTSP 주소가 없습니다');
        return _emptyResult();
      }

      final originalCount = rtspAddresses.length;

      // 3. 블랙리스트 필터링
      rtspAddresses = _filterBlacklist(rtspAddresses);

      if (rtspAddresses.isEmpty) {
        print(
            '⚠️  모든 주소가 블랙리스트에 등록되어 있습니다 ($originalCount개)');
        return _emptyResult();
      }

      final activeCount = rtspAddresses.length;
      final blacklistedCount = originalCount - activeCount;

      // 4. 우선순위 정렬 (응답 시간이 빠른 순)
      rtspAddresses = _sortByPriority(rtspAddresses);

      print('📋 총 주소: $originalCount개');
      print('   활성: $activeCount개');
      if (blacklistedCount > 0) {
        print('   블랙리스트: $blacklistedCount개');
      }
      print('🔧 현재 배치 크기: $_currentBatchSize');

      // 5. 적응형 배치 처리
      int totalSuccessCount = 0;
      int totalFailCount = 0;
      int batchIndex = 0;
      int processedCount = 0;

      while (processedCount < activeCount) {
        batchIndex++;

        // 현재 배치 생성
        final remainingCount = activeCount - processedCount;
        final currentBatchSize = min(_currentBatchSize, remainingCount);
        final batch =
            rtspAddresses.sublist(processedCount, processedCount + currentBatchSize);

        final batchStartTime = DateTime.now();
        print(
            '\n📦 배치 $batchIndex 시작 (크기: $currentBatchSize, ${batchStartTime.toString().substring(11, 19)})');

        // 배치 처리
        final batchResult = await _processBatch(databaseUrl, batch);
        final batchEndTime = DateTime.now();
        final batchDuration = batchEndTime.difference(batchStartTime);

        // 결과 집계
        final batchSuccessCount = batchResult['success_count'] as int;
        final batchFailCount = batchResult['fail_count'] as int;
        totalSuccessCount += batchSuccessCount;
        totalFailCount += batchFailCount;

        // 배치 성공률 계산
        final batchSuccessRate = batchSuccessCount / currentBatchSize;

        print('✅ 배치 $batchIndex 완료 (${batchEndTime.toString().substring(11, 19)})');
        print(
            '   성공: $batchSuccessCount/$currentBatchSize (${(batchSuccessRate * 100).toStringAsFixed(1)}%)');
        print('   소요 시간: ${batchDuration.inSeconds}초');

        // 6. 동적 배치 크기 조정
        _adjustBatchSize(batchSuccessRate, batchDuration);

        // 7. 동적 대기 시간
        if (processedCount + currentBatchSize < activeCount) {
          final waitTime = _calculateWaitTime(batchSuccessRate);
          if (waitTime > 0) {
            print('⏸️  배치 간 대기: ${waitTime}ms');
            await Future.delayed(Duration(milliseconds: waitTime));
          }
        }

        processedCount += currentBatchSize;
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('\n✅ 적응형 RTSP 캡처 완료');
      print('   총 주소: $originalCount개');
      print('   활성: $activeCount개');
      print('   성공: $totalSuccessCount개 '
          '(${activeCount > 0 ? (totalSuccessCount / activeCount * 100).toStringAsFixed(1) : 0}%)');
      print('   실패: $totalFailCount개');
      if (blacklistedCount > 0) {
        print('   블랙리스트: $blacklistedCount개');
      }
      print('   소요 시간: ${duration.inSeconds}초');
      print('   최종 배치 크기: $_currentBatchSize');
      print('   배치 조정 횟수: $_batchAdjustmentCount');

      return {
        'success': true,
        'message': '적응형 캡처 완료',
        'total': originalCount,
        'active': activeCount,
        'successful': totalSuccessCount,
        'failed': totalFailCount,
        'blacklisted': blacklistedCount,
        'duration_seconds': duration.inSeconds,
        'final_batch_size': _currentBatchSize,
        'batch_count': batchIndex,
        'batch_adjustments': _batchAdjustmentCount,
        'timestamp': endTime.toIso8601String(),
      };
    } catch (e, stackTrace) {
      print('❌ 적응형 캡처 실패: $e');
      print('   Stack trace: $stackTrace');
      return {
        'success': false,
        'message': '적응형 캡처 실패: $e',
      };
    }
  }

  /// 단일 배치 처리
  ///
  /// 배치 내 모든 주소를 병렬로 캡처하고 통계를 업데이트합니다.
  Future<Map<String, dynamic>> _processBatch(
    String databaseUrl,
    List<String> batch,
  ) async {
    int successCount = 0;
    int failCount = 0;

    // 배치 내 모든 주소를 병렬로 캡처
    final captureFutures = batch.map((rtspAddress) async {
      final captureStartTime = DateTime.now();
      final success = await captureFromRtsp(databaseUrl, rtspAddress);
      final responseTime =
          DateTime.now().difference(captureStartTime).inMilliseconds;

      // 결과 추적
      _updateStatistics(rtspAddress, success, responseTime);

      return success;
    }).toList();

    final results = await Future.wait(captureFutures);

    for (final success in results) {
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    return {
      'success_count': successCount,
      'fail_count': failCount,
    };
  }

  /// 통계 업데이트
  ///
  /// 주소별 성공/실패를 추적하고 블랙리스트를 관리합니다.
  void _updateStatistics(String rtspAddress, bool success, int responseTime) {
    _lastCaptureTime[rtspAddress] = DateTime.now();

    if (success) {
      // 성공 시 실패 카운트 리셋
      _failureCount[rtspAddress] = 0;

      // 블랙리스트에서 제거
      if (_blacklist.remove(rtspAddress)) {
        _blacklistRemoveCount++;
        print('✅ 블랙리스트 제거: $rtspAddress (복구됨)');
      }

      // 평균 응답 시간 업데이트 (지수 이동 평균 - EMA)
      final currentAvg = _averageResponseTime[rtspAddress] ?? responseTime;
      _averageResponseTime[rtspAddress] =
          ((currentAvg * 0.7) + (responseTime * 0.3)).round();
    } else {
      // 실패 카운트 증가
      _failureCount[rtspAddress] = (_failureCount[rtspAddress] ?? 0) + 1;

      // 연속 실패가 임계값을 넘으면 블랙리스트 추가
      if (_failureCount[rtspAddress]! >= RtspConfig.MAX_CONSECUTIVE_FAILURES) {
        if (_blacklist.add(rtspAddress)) {
          _blacklistAddCount++;
          print(
              '🚫 블랙리스트 추가: $rtspAddress (연속 ${_failureCount[rtspAddress]}회 실패)');
          // TODO: 알림 발송 (향후 구현)
          // _sendAlert('카메라 오프라인', rtspAddress);
        }
      }
    }
  }

  /// 동적 배치 크기 조정
  ///
  /// 성공률과 소요 시간에 따라 배치 크기를 증가/감소시킵니다.
  void _adjustBatchSize(double successRate, Duration batchDuration) {
    final oldSize = _currentBatchSize;

    // 성공률이 높고 빠르게 완료되면 배치 크기 증가
    if (successRate >= RtspConfig.BATCH_SUCCESS_THRESHOLD_HIGH &&
        batchDuration.inSeconds <
            RtspConfig.BATCH_DURATION_THRESHOLD_SECONDS) {
      _currentBatchSize = min(
        _currentBatchSize + RtspConfig.BATCH_SIZE_ADJUSTMENT_STEP,
        RtspConfig.MAX_CONCURRENT_CAPTURES_ADAPTIVE,
      );
    }
    // 성공률이 낮으면 배치 크기 감소
    else if (successRate < RtspConfig.BATCH_SUCCESS_THRESHOLD_LOW) {
      _currentBatchSize = max(
        _currentBatchSize - RtspConfig.BATCH_SIZE_ADJUSTMENT_STEP,
        RtspConfig.MIN_CONCURRENT_CAPTURES,
      );
    }

    if (oldSize != _currentBatchSize) {
      _batchAdjustmentCount++;
      print(
          '🔧 배치 크기 조정: $oldSize → $_currentBatchSize (성공률: ${(successRate * 100).toStringAsFixed(1)}%)');
    }
  }

  /// 동적 대기 시간 계산
  ///
  /// 성공률에 따라 배치 간 대기 시간을 조정합니다.
  int _calculateWaitTime(double successRate) {
    if (successRate >= 0.9) {
      return RtspConfig.BATCH_WAIT_TIME_EXCELLENT; // 50ms
    } else if (successRate >= 0.7) {
      return RtspConfig.BATCH_WAIT_TIME_GOOD; // 100ms
    } else if (successRate >= 0.5) {
      return RtspConfig.BATCH_WAIT_TIME_FAIR; // 200ms
    } else {
      return RtspConfig.BATCH_WAIT_TIME_POOR; // 500ms
    }
  }

  /// 블랙리스트 필터링
  ///
  /// 블랙리스트에 등록된 주소를 제외합니다.
  List<String> _filterBlacklist(List<String> addresses) {
    return addresses.where((addr) => !_blacklist.contains(addr)).toList();
  }

  /// 우선순위 정렬
  ///
  /// 응답 시간이 빠른 주소를 우선적으로 처리합니다.
  List<String> _sortByPriority(List<String> addresses) {
    addresses.sort((a, b) {
      // 1차: 응답 시간 (빠른 순)
      final timeA = _averageResponseTime[a] ?? 5000;
      final timeB = _averageResponseTime[b] ?? 5000;
      return timeA.compareTo(timeB);

      // TODO: 2차 정렬 기준 추가 가능
      // - 우선순위 가중치 (입구/출구 > 일반)
      // - 성공률 (높은 순)
    });

    return addresses;
  }

  /// 블랙리스트 리셋 확인
  ///
  /// 설정된 주기마다 블랙리스트를 초기화합니다.
  void _checkAndResetBlacklist() {
    if (_lastBlacklistReset == null) {
      _lastBlacklistReset = DateTime.now();
      return;
    }

    final elapsed = DateTime.now().difference(_lastBlacklistReset!);
    if (elapsed.inMinutes >= RtspConfig.BLACKLIST_RESET_MINUTES) {
      if (_blacklist.isNotEmpty) {
        print(
            '🔄 블랙리스트 초기화: ${_blacklist.length}개 주소 (${RtspConfig.BLACKLIST_RESET_MINUTES}분 경과)');
        _blacklist.clear();
        _failureCount.clear();
      }
      _lastBlacklistReset = DateTime.now();
    }
  }

  /// 빈 결과 반환
  Map<String, dynamic> _emptyResult() {
    return {
      'success': true,
      'message': '캡처할 RTSP 주소가 없습니다',
      'total': 0,
      'active': 0,
      'successful': 0,
      'failed': 0,
      'blacklisted': 0,
    };
  }

  /// 적응형 통계 정보 조회
  ///
  /// 현재 상태와 성능 통계를 반환합니다.
  Map<String, dynamic> getAdaptiveStats() {
    return {
      'adaptive_mode': true,
      'current_batch_size': _currentBatchSize,
      'batch_size_range': {
        'min': RtspConfig.MIN_CONCURRENT_CAPTURES,
        'max': RtspConfig.MAX_CONCURRENT_CAPTURES_ADAPTIVE,
      },
      'blacklist': {
        'count': _blacklist.length,
        'addresses': _blacklist.toList(),
        'last_reset': _lastBlacklistReset?.toIso8601String(),
      },
      'statistics': {
        'tracked_addresses': _failureCount.length,
        'batch_adjustments': _batchAdjustmentCount,
        'blacklist_additions': _blacklistAddCount,
        'blacklist_removals': _blacklistRemoveCount,
      },
      'performance': {
        'average_response_times': _averageResponseTime,
        'failure_counts': _failureCount,
      },
      'service_info': getServiceInfo(),
    };
  }

  /// 블랙리스트 수동 초기화
  ///
  /// 테스트 또는 강제 리셋이 필요한 경우 사용합니다.
  void resetBlacklist() {
    if (_blacklist.isNotEmpty) {
      print('🔄 블랙리스트 수동 초기화: ${_blacklist.length}개 주소');
      _blacklist.clear();
      _failureCount.clear();
      _lastBlacklistReset = DateTime.now();
    }
  }

  /// 특정 주소를 블랙리스트에서 제거
  ///
  /// 수동으로 복구가 필요한 경우 사용합니다.
  bool removeFromBlacklist(String rtspAddress) {
    final removed = _blacklist.remove(rtspAddress);
    if (removed) {
      _failureCount[rtspAddress] = 0;
      print('✅ 블랙리스트에서 수동 제거: $rtspAddress');
    }
    return removed;
  }

  /// 배치 크기 수동 조정
  ///
  /// 테스트 또는 특수한 경우에 사용합니다.
  void setBatchSize(int newSize) {
    if (newSize < RtspConfig.MIN_CONCURRENT_CAPTURES ||
        newSize > RtspConfig.MAX_CONCURRENT_CAPTURES_ADAPTIVE) {
      print(
          '❌ 잘못된 배치 크기: $newSize (범위: ${RtspConfig.MIN_CONCURRENT_CAPTURES}~${RtspConfig.MAX_CONCURRENT_CAPTURES_ADAPTIVE})');
      return;
    }

    final oldSize = _currentBatchSize;
    _currentBatchSize = newSize;
    print('🔧 배치 크기 수동 조정: $oldSize → $_currentBatchSize');
  }
}

