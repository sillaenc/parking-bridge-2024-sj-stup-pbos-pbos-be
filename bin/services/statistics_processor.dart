import '../models/parking_data.dart';
import '../services/database_client.dart';
import '../services/parking_data_parser.dart';
import '../utils/date_utils.dart';

/// 시간/일/월/년별 통계 데이터 처리를 담당하는 서비스
/// 주차 데이터를 기반으로 다양한 기간별 통계를 생성하고 저장
class StatisticsProcessor {
  final DatabaseClient _dbClient;

  StatisticsProcessor({DatabaseClient? dbClient})
      : _dbClient = dbClient ?? DatabaseClient();

  /// 시간별 통계 처리
  /// 현재 시간이 이전 시간과 다를 때 실행
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [currentTime] 현재 시간
  /// Returns: 처리 완료 여부
  Future<bool> processHourlyStatistics({
    required String displayDbUrl,
    required DateTime currentTime,
  }) async {
    try {
      print('📊 시간별 통계 처리를 시작합니다...');

      // 한 시간 전 범위 계산
      final timeRange = DateUtils.calculateTimeRangeObject(currentTime);
      final formattedStartTime =
          DateUtils.formatFullDateTime(timeRange.startTime);
      final formattedEndTime = DateUtils.formatFullDateTime(timeRange.endTime);

      // 해당 시간 범위의 주차 상태 데이터 조회
      final statusData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLotStatus',
        values: {
          'start_time': formattedStartTime,
          'end_time': formattedEndTime,
        },
      );

      // 주차 공간 정보 조회
      final lotData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLots',
      );

      if (lotData.isEmpty) {
        print('⚠️  주차 공간 정보가 없습니다.');
        return false;
      }

      // 데이터 처리
      final lotInfoList =
          lotData.map((data) => LotInfo.fromJson(data)).toList();
      final parkingStatusMap =
          ParkingDataParser.processStatisticsData(statusData);
      final lotTypeMap = ParkingDataParser.extractLotTypeMap(lotInfoList);

      // 이미 처리된 데이터인지 확인
      final oneHourBefore = DateUtils.getOneHourBefore(currentTime);
      final existingCount = await _dbClient.getCount(
        url: displayDbUrl,
        queryId: '#S_CountProcessedDb',
        values: {'time': oneHourBefore},
      );

      if (existingCount == 0 && lotInfoList.isNotEmpty) {
        // 시간별 통계 데이터 저장
        await _saveHourlyStatistics(
          displayDbUrl: displayDbUrl,
          lotInfoList: lotInfoList,
          parkingStatusMap: parkingStatusMap,
          lotTypeMap: lotTypeMap,
          recordedTime: oneHourBefore,
        );

        print('✅ 시간별 통계 처리가 완료되었습니다.');
        return true;
      } else {
        print('ℹ️  이미 처리된 시간별 데이터입니다.');
        return false;
      }
    } catch (e) {
      print('❌ 시간별 통계 처리 중 오류 발생: $e');
      return false;
    }
  }

  /// 일별 통계 처리
  /// 현재 날짜가 이전 날짜와 다를 때 실행
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [currentTime] 현재 시간
  /// Returns: 처리 완료 여부
  Future<bool> processDailyStatistics({
    required String displayDbUrl,
    required DateTime currentTime,
  }) async {
    try {
      print('📊 일별 통계 처리를 시작합니다...');

      // 전날 정보 계산
      final dateFormats = DateUtils.getOneDayBeforeFormats(currentTime);

      // 전날의 시간별 통계 데이터 조회
      final processedData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_ProcessedDB',
        values: {'checkdate': '${dateFormats['day']}%'},
      );

      // 주차 공간 정보 조회
      final lotData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLots',
      );

      if (lotData.isEmpty) {
        print('⚠️  주차 공간 정보가 없습니다.');
        return false;
      }

      // 데이터 처리
      final lotInfoList =
          lotData.map((data) => LotInfo.fromJson(data)).toList();
      final parkingStatusMap =
          ParkingDataParser.processStatisticsData(processedData);
      final lotTypeMap = ParkingDataParser.extractLotTypeMap(lotInfoList);

      // 이미 처리된 데이터인지 확인
      final existingCount = await _dbClient.getCount(
        url: displayDbUrl,
        queryId: '#S_CountRecordedDay',
        values: {'time': dateFormats['day']},
      );

      if (existingCount == 0 && lotInfoList.isNotEmpty) {
        // 일별 통계 데이터 저장
        await _saveDailyStatistics(
          displayDbUrl: displayDbUrl,
          lotInfoList: lotInfoList,
          parkingStatusMap: parkingStatusMap,
          lotTypeMap: lotTypeMap,
          recordedTime: dateFormats['day']!,
        );

        print('✅ 일별 통계 처리가 완료되었습니다.');
        return true;
      } else {
        print('ℹ️  이미 처리된 일별 데이터입니다.');
        return false;
      }
    } catch (e) {
      print('❌ 일별 통계 처리 중 오류 발생: $e');
      return false;
    }
  }

  /// 월별 통계 처리
  /// 현재 월이 이전 월과 다를 때 실행
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [currentTime] 현재 시간
  /// Returns: 처리 완료 여부
  Future<bool> processMonthlyStatistics({
    required String displayDbUrl,
    required DateTime currentTime,
  }) async {
    try {
      print('📊 월별 통계 처리를 시작합니다...');

      // 이전 월 정보 계산
      final prevMonthFormats = DateUtils.getOneDayBeforeFormats(currentTime);

      // 이전 월의 일별 통계 데이터 조회
      final dailyData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_PerDay',
        values: {'checkdate': '${prevMonthFormats['month']}%'},
      );

      // 주차 공간 정보 조회
      final lotData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLots',
      );

      if (lotData.isEmpty) {
        print('⚠️  주차 공간 정보가 없습니다.');
        return false;
      }

      // 데이터 처리
      final lotInfoList =
          lotData.map((data) => LotInfo.fromJson(data)).toList();
      final parkingStatusMap =
          ParkingDataParser.processStatisticsData(dailyData);
      final lotTypeMap = ParkingDataParser.extractLotTypeMap(lotInfoList);

      // 이전 월 문자열 생성
      final prevMonthString = DateUtils.getPreviousMonthString(currentTime);

      // 이미 처리된 데이터인지 확인
      final existingCount = await _dbClient.getCount(
        url: displayDbUrl,
        queryId: '#S_CountPerMonth',
        values: {'time': prevMonthString},
      );

      if (existingCount == 0 && lotInfoList.isNotEmpty) {
        // 월별 통계 데이터 저장
        await _saveMonthlyStatistics(
          displayDbUrl: displayDbUrl,
          lotInfoList: lotInfoList,
          parkingStatusMap: parkingStatusMap,
          lotTypeMap: lotTypeMap,
          recordedTime: prevMonthString,
        );

        print('✅ 월별 통계 처리가 완료되었습니다.');
        return true;
      } else {
        print('ℹ️  이미 처리된 월별 데이터입니다.');
        return false;
      }
    } catch (e) {
      print('❌ 월별 통계 처리 중 오류 발생: $e');
      return false;
    }
  }

  /// 연별 통계 처리
  /// 현재 년도가 이전 년도와 다를 때 실행
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [currentTime] 현재 시간
  /// Returns: 처리 완료 여부
  Future<bool> processYearlyStatistics({
    required String displayDbUrl,
    required DateTime currentTime,
  }) async {
    try {
      print('📊 연별 통계 처리를 시작합니다...');

      // 이전 년도 정보 계산
      final prevYearFormats = DateUtils.getOneDayBeforeFormats(currentTime);

      // 이전 년도의 월별 통계 데이터 조회
      final monthlyData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_PerMonth',
        values: {'checkdate': '${prevYearFormats['year']}%'},
      );

      // 주차 공간 정보 조회
      final lotData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLots',
      );

      if (lotData.isEmpty) {
        print('⚠️  주차 공간 정보가 없습니다.');
        return false;
      }

      // 데이터 처리
      final lotInfoList =
          lotData.map((data) => LotInfo.fromJson(data)).toList();
      final parkingStatusMap =
          ParkingDataParser.processStatisticsData(monthlyData);
      final lotTypeMap = ParkingDataParser.extractLotTypeMap(lotInfoList);

      // 이전 년도 문자열 생성
      final prevYearString = DateUtils.getPreviousYearString(currentTime);

      // 이미 처리된 데이터인지 확인
      final existingCount = await _dbClient.getCount(
        url: displayDbUrl,
        queryId: '#S_CountPerYear',
        values: {'time': prevYearString},
      );

      if (existingCount == 0 && lotInfoList.isNotEmpty) {
        // 연별 통계 데이터 저장
        await _saveYearlyStatistics(
          displayDbUrl: displayDbUrl,
          lotInfoList: lotInfoList,
          parkingStatusMap: parkingStatusMap,
          lotTypeMap: lotTypeMap,
          recordedTime: prevYearString,
        );

        print('✅ 연별 통계 처리가 완료되었습니다.');
        return true;
      } else {
        print('ℹ️  이미 처리된 연별 데이터입니다.');
        return false;
      }
    } catch (e) {
      print('❌ 연별 통계 처리 중 오류 발생: $e');
      return false;
    }
  }

  /// 시간별 통계 데이터 저장
  Future<void> _saveHourlyStatistics({
    required String displayDbUrl,
    required List<LotInfo> lotInfoList,
    required Map<int, bool> parkingStatusMap,
    required Map<int, dynamic> lotTypeMap,
    required String recordedTime,
  }) async {
    final transactions = <Map<String, dynamic>>[];

    for (final lot in lotInfoList) {
      final uid = lot.uid;
      final hasParking = parkingStatusMap[uid] ?? false;
      final carType = lotTypeMap[uid];

      transactions.add({
        "statement": "#I_processedDB",
        "values": {
          "lot": uid,
          "car_type": carType,
          "hour_parking": hasParking ? 1 : 0,
          "recorded_hour": recordedTime,
        },
      });
    }

    if (transactions.isNotEmpty) {
      await _dbClient.executeBatch(
        url: displayDbUrl,
        transactions: transactions,
      );
    }
  }

  /// 일별 통계 데이터 저장
  Future<void> _saveDailyStatistics({
    required String displayDbUrl,
    required List<LotInfo> lotInfoList,
    required Map<int, bool> parkingStatusMap,
    required Map<int, dynamic> lotTypeMap,
    required String recordedTime,
  }) async {
    final transactions = <Map<String, dynamic>>[];

    for (final lot in lotInfoList) {
      final uid = lot.uid;
      final hasParking = parkingStatusMap[uid] ?? false;
      final carType = lotTypeMap[uid];

      transactions.add({
        "statement": "#I_PerDay",
        "values": {
          "lot": uid,
          "car_type": carType,
          "day_parking": hasParking ? 1 : 0,
          "fromattedTime": recordedTime,
        },
      });
    }

    if (transactions.isNotEmpty) {
      await _dbClient.executeBatch(
        url: displayDbUrl,
        transactions: transactions,
      );
    }
  }

  /// 월별 통계 데이터 저장
  Future<void> _saveMonthlyStatistics({
    required String displayDbUrl,
    required List<LotInfo> lotInfoList,
    required Map<int, bool> parkingStatusMap,
    required Map<int, dynamic> lotTypeMap,
    required String recordedTime,
  }) async {
    final transactions = <Map<String, dynamic>>[];

    for (final lot in lotInfoList) {
      final uid = lot.uid;
      final hasParking = parkingStatusMap[uid] ?? false;
      final carType = lotTypeMap[uid];

      transactions.add({
        "statement": "#I_PerMonth",
        "values": {
          "lot": uid,
          "car_type": carType,
          "month_parking": hasParking ? 1 : 0,
          "fromattedTime": recordedTime,
        },
      });
    }

    if (transactions.isNotEmpty) {
      await _dbClient.executeBatch(
        url: displayDbUrl,
        transactions: transactions,
      );
    }
  }

  /// 연별 통계 데이터 저장
  Future<void> _saveYearlyStatistics({
    required String displayDbUrl,
    required List<LotInfo> lotInfoList,
    required Map<int, bool> parkingStatusMap,
    required Map<int, dynamic> lotTypeMap,
    required String recordedTime,
  }) async {
    final transactions = <Map<String, dynamic>>[];

    for (final lot in lotInfoList) {
      final uid = lot.uid;
      final hasParking = parkingStatusMap[uid] ?? false;
      final carType = lotTypeMap[uid];

      transactions.add({
        "statement": "#I_PerYear",
        "values": {
          "lot": uid,
          "car_type": carType,
          "year_parking": hasParking ? 1 : 0,
          "fromattedTime": recordedTime,
        },
      });
    }

    if (transactions.isNotEmpty) {
      await _dbClient.executeBatch(
        url: displayDbUrl,
        transactions: transactions,
      );
    }
  }

  /// 리소스 해제
  void dispose() {
    _dbClient.dispose();
  }
}
