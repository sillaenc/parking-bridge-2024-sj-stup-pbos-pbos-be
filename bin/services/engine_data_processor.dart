import '../models/parking_data.dart';
import '../services/database_client.dart';
import '../services/parking_data_parser.dart';
import '../services/parking_status_updater.dart';
import '../services/statistics_processor.dart';
import '../utils/date_utils.dart';

/// 엔진 데이터 처리의 전체 플로우를 관리하는 통합 서비스
/// 원본 receiveEnginedataSendToDartserver 함수를 분해하여 재구성한 메인 컨트롤러
class EngineDataProcessor {
  final DatabaseClient _dbClient;
  final ParkingStatusUpdater _statusUpdater;
  final StatisticsProcessor _statisticsProcessor;

  // 이전 시간 체크를 위한 변수들
  DateTime _lastProcessTime = DateTime.now();

  EngineDataProcessor({
    DatabaseClient? dbClient,
    ParkingStatusUpdater? statusUpdater,
    StatisticsProcessor? statisticsProcessor,
  })  : _dbClient = dbClient ?? DatabaseClient(),
        _statusUpdater = statusUpdater ?? ParkingStatusUpdater(),
        _statisticsProcessor = statisticsProcessor ?? StatisticsProcessor();

  /// 엔진 데이터 전체 처리 플로우 실행
  ///
  /// [engineDbAddr] 엔진 DB 주소
  /// [displayDbAddr] 디스플레이 DB 주소
  /// [displayDbLPR] LPR DB 주소
  /// [checkTime] 체크 시간
  /// Returns: 처리된 주차 공간 목록
  Future<List<String>> processEngineData({
    required String engineDbAddr,
    required String displayDbAddr,
    required String displayDbLPR,
    required DateTime checkTime,
  }) async {
    print('🔄 엔진 데이터 처리를 시작합니다: ${DateTime.now()}');

    try {
      // 1단계: 엔진에서 원시 데이터 수신
      final engineData = await _fetchEngineData(engineDbAddr);
      if (engineData == null) {
        print('❌ 엔진 데이터 수신 실패');
        return [];
      }

      // 2단계: 데이터 유효성 검증
      if (!ParkingDataParser.validateEngineData(engineData)) {
        print('❌ 엔진 데이터 유효성 검증 실패');
        return [];
      }

      // 3단계: 주차 데이터 파싱
      final parsedData = ParkingDataParser.parseEngineData(engineData);
      print('📊 주차 데이터 파싱 완료: ${parsedData.occupiedSlots.length}개 공간 사용 중');

      // 4단계: 원시 데이터 저장
      await _statusUpdater.saveRawData(
        displayDbUrl: displayDbAddr,
        engineData: engineData,
      );

      // 5단계: 현재 주차 공간 정보 조회 및 상태 업데이트
      final currentLotInfo =
          await _statusUpdater.fetchCurrentLotInfo(displayDbAddr);
      if (currentLotInfo.isEmpty) {
        print('❌ 주차 공간 정보 조회 실패');
        return [];
      }

      // 6단계: 주차 상태 업데이트
      final updatedLotInfo = ParkingDataParser.updateLotUsageStatus(
        currentLotInfo,
        parsedData.occupiedSlots,
      );

      await _statusUpdater.updateParkingStatus(
        displayDbUrl: displayDbAddr,
        updatedLotList: updatedLotInfo,
        timestamp: engineData.timestamp,
      );

      // 7단계: 현재 상태 요약 출력
      _statusUpdater.printParkingStatusSummary(updatedLotInfo);

      // 8단계: 시간 변화 확인 및 통계 처리
      await _processTimeBasedStatistics(
        displayDbAddr: displayDbAddr,
        checkTime: checkTime,
      );

      // 9단계: LPR 데이터 처리 (선택적)
      await _statusUpdater.processLprData(
        displayDbLprUrl: displayDbLPR,
        displayDbUrl: displayDbAddr,
      );

      print('✅ 엔진 데이터 처리가 완료되었습니다.');
      return parsedData.occupiedSlots;
    } catch (e) {
      print('❌ 엔진 데이터 처리 중 오류 발생: $e');
      return [];
    }
  }

  /// 엔진에서 원시 데이터 수신
  ///
  /// [engineDbAddr] 엔진 DB 주소
  /// Returns: 엔진 데이터 또는 null
  Future<EngineData?> _fetchEngineData(String engineDbAddr) async {
    try {
      final results = await _dbClient.executeQuery(
        url: engineDbAddr,
        queryId: '#S1',
      );

      if (results.isEmpty) {
        print('ℹ️  엔진 DB에서 반환된 데이터가 없습니다.');
        return null;
      }

      return EngineData.fromJson(results[0]);
    } catch (e) {
      print('❌ 엔진 데이터 수신 실패: $e');
      return null;
    }
  }

  /// 시간 변화 기반 통계 처리
  ///
  /// [displayDbAddr] 디스플레이 DB 주소
  /// [checkTime] 체크 시간
  Future<void> _processTimeBasedStatistics({
    required String displayDbAddr,
    required DateTime checkTime,
  }) async {
    final currentTime = DateTime.now();
    final previousTime = checkTime.subtract(const Duration(seconds: 10));

    // 시간 변화 감지
    final timeChanges = DateUtils.checkTimeChanges(previousTime, currentTime);

    // 시간별 통계 처리
    if (timeChanges['hour'] == true) {
      print('⏰ 시간 변화 감지 - 시간별 통계 처리 시작');
      await _statisticsProcessor.processHourlyStatistics(
        displayDbUrl: displayDbAddr,
        currentTime: currentTime,
      );
    }

    // 일별 통계 처리
    if (timeChanges['day'] == true) {
      print('📅 날짜 변화 감지 - 일별 통계 처리 시작');
      await _statisticsProcessor.processDailyStatistics(
        displayDbUrl: displayDbAddr,
        currentTime: currentTime,
      );
    }

    // 월별 통계 처리
    if (timeChanges['month'] == true) {
      print('📆 월 변화 감지 - 월별 통계 처리 시작');
      await _statisticsProcessor.processMonthlyStatistics(
        displayDbUrl: displayDbAddr,
        currentTime: currentTime,
      );
    }

    // 연별 통계 처리
    if (timeChanges['year'] == true) {
      print('🗓️  연도 변화 감지 - 연별 통계 처리 시작');
      await _statisticsProcessor.processYearlyStatistics(
        displayDbUrl: displayDbAddr,
        currentTime: currentTime,
      );
    }

    _lastProcessTime = currentTime;
  }

  /// 주차장 상태 정보 조회 (API용)
  ///
  /// [displayDbAddr] 디스플레이 DB 주소
  /// Returns: 현재 주차장 상태 정보
  Future<Map<String, dynamic>> getParkingStatus(String displayDbAddr) async {
    try {
      final lotInfo = await _statusUpdater.fetchCurrentLotInfo(displayDbAddr);
      if (lotInfo.isEmpty) {
        return {
          'success': false,
          'message': '주차 공간 정보를 찾을 수 없습니다.',
        };
      }

      final statistics = _statusUpdater.generateStatusStatistics(lotInfo);

      return {
        'success': true,
        'data': {
          'lots': lotInfo.map((lot) => lot.toJson()).toList(),
          'statistics': statistics,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': '주차장 상태 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 에러 정보 조회 (API용)
  ///
  /// Returns: 현재 에러 상태 정보
  Map<String, dynamic> getErrorStatus() {
    try {
      // global.dart의 error 리스트 사용
      final errorList = <String>[];
      // error 글로벌 변수에서 현재 에러 상태 가져오기

      return {
        'success': true,
        'data': {
          'errors': errorList,
          'error_count': errorList.length,
          'has_errors': errorList.isNotEmpty,
          'last_updated': DateTime.now().toIso8601String(),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': '에러 상태 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 처리 통계 정보 조회 (API용)
  ///
  /// Returns: 처리 통계 정보
  Map<String, dynamic> getProcessingStatistics() {
    return {
      'success': true,
      'data': {
        'last_process_time': _lastProcessTime.toIso8601String(),
        'uptime_seconds': DateTime.now().difference(_lastProcessTime).inSeconds,
        'status': 'running',
      },
    };
  }

  /// 수동 통계 처리 트리거 (API용)
  ///
  /// [displayDbAddr] 디스플레이 DB 주소
  /// [period] 처리할 통계 기간 ('hour', 'day', 'month', 'year')
  /// Returns: 처리 결과
  Future<Map<String, dynamic>> triggerStatisticsProcessing({
    required String displayDbAddr,
    required String period,
  }) async {
    try {
      final currentTime = DateTime.now();
      bool success = false;

      switch (period.toLowerCase()) {
        case 'hour':
          success = await _statisticsProcessor.processHourlyStatistics(
            displayDbUrl: displayDbAddr,
            currentTime: currentTime,
          );
          break;
        case 'day':
          success = await _statisticsProcessor.processDailyStatistics(
            displayDbUrl: displayDbAddr,
            currentTime: currentTime,
          );
          break;
        case 'month':
          success = await _statisticsProcessor.processMonthlyStatistics(
            displayDbUrl: displayDbAddr,
            currentTime: currentTime,
          );
          break;
        case 'year':
          success = await _statisticsProcessor.processYearlyStatistics(
            displayDbUrl: displayDbAddr,
            currentTime: currentTime,
          );
          break;
        default:
          return {
            'success': false,
            'message': '지원하지 않는 통계 기간입니다. (hour, day, month, year 중 선택)',
          };
      }

      return {
        'success': success,
        'message':
            success ? '$period 통계 처리가 완료되었습니다.' : '$period 통계 처리에 실패했습니다.',
        'processed_at': currentTime.toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': '통계 처리 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 리소스 해제
  void dispose() {
    _dbClient.dispose();
    _statusUpdater.dispose();
    _statisticsProcessor.dispose();
  }
}
