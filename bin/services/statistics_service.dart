/// 통계 조회 비즈니스 로직을 담당하는 서비스 클래스
/// 통계 데이터 조회, 날짜 계산, 쿼리 실행 등의 기능을 제공

import '../models/statistics_models.dart';
import 'database_client.dart';

/// 통계 서비스 예외 클래스
class StatisticsServiceException implements Exception {
  final String message;
  final String? details;

  StatisticsServiceException(this.message, {this.details});

  @override
  String toString() =>
      'StatisticsServiceException: $message${details != null ? ' - $details' : ''}';
}

/// 통계 조회 서비스 클래스
class StatisticsService {
  final DatabaseClient _databaseClient;
  final String _databaseUrl;

  StatisticsService({
    required DatabaseClient databaseClient,
    required String databaseUrl,
  })  : _databaseClient = databaseClient,
        _databaseUrl = databaseUrl;

  /// 일별 전체 통계 조회
  Future<StatisticsResult> getOneDayAllStatistics() async {
    try {
      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneDayAll,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneDayAll,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '일별 전체 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 일별 통계 조회 (전일 대비)
  Future<StatisticsResult> getOneDayStatistics() async {
    try {
      final params = StatisticsDateHelper.getDayRangeParams();

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneDay,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneDay,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '일별 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 주별 통계 조회
  Future<StatisticsResult> getOneWeekStatistics() async {
    try {
      final params = StatisticsDateHelper.getWeekRangeParams();

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneWeek,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneWeek,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '주별 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 월별 전체 통계 조회
  Future<StatisticsResult> getOneMonthAllStatistics() async {
    try {
      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneMonthAll,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneMonthAll,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '월별 전체 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 월별 통계 조회 (전월 대비)
  Future<StatisticsResult> getOneMonthStatistics() async {
    try {
      final params = StatisticsDateHelper.getMonthRangeParams();

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneMonth,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneMonth,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '월별 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 연별 전체 통계 조회
  Future<StatisticsResult> getOneYearAllStatistics() async {
    try {
      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneYearAll,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneYearAll,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '연별 전체 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 연별 통계 조회 (전년 대비)
  Future<StatisticsResult> getOneYearStatistics() async {
    try {
      final params = StatisticsDateHelper.getYearRangeParams();

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneYear,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.oneYear,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '연별 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 다년도 전체 통계 조회
  Future<StatisticsResult> getSeveralYearsAllStatistics() async {
    try {
      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.severalYearsAll,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.severalYearsAll,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '다년도 전체 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 다년도 통계 조회
  Future<StatisticsResult> getSeveralYearsStatistics() async {
    try {
      final params = StatisticsDateHelper.getSeveralYearsRangeParams();

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.severalYears,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.severalYears,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '다년도 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 사용자 정의 기간 통계 조회
  Future<StatisticsResult> getCustomPeriodStatistics(
      String startDay, String endDay) async {
    try {
      // 입력값 유효성 검사
      if (startDay.isEmpty || endDay.isEmpty) {
        throw StatisticsServiceException('시작일과 종료일은 필수입니다.');
      }

      final params = {
        'startDay': startDay,
        'endDay': endDay,
      };

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.search,
        values: params,
      );

      return StatisticsResult(
        data: result,
        query: StatisticsQueries.search,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '사용자 정의 기간 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 그래프용 통계 조회
  Future<StatisticsResult> getGraphStatistics(
      String startDay, String endDay) async {
    try {
      // 입력값 유효성 검사
      if (startDay.isEmpty || endDay.isEmpty) {
        throw StatisticsServiceException('시작일과 종료일은 필수입니다.');
      }

      final params =
          StatisticsDateHelper.getCustomRangeParams(startDay, endDay);

      final result = await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.graph,
        values: params,
      );

      // 결과 컬럼 정규화: car_type → lot_type 변환
      final normalizedResult = (result as List<dynamic>)
          .map<Map<String, dynamic>>((row) {
        final normalizedRow =
            Map<String, dynamic>.from(row as Map<String, dynamic>);
        if (normalizedRow.containsKey('car_type')) {
          final lotTypeValue = normalizedRow['car_type'];
          normalizedRow
            ..remove('car_type')
            ..['lot_type'] = lotTypeValue;
        }
        return normalizedRow;
      }).toList();

      return StatisticsResult(
        data: normalizedResult,
        query: StatisticsQueries.graph,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw StatisticsServiceException(
        '그래프 통계 조회 실패',
        details: e.toString(),
      );
    }
  }

  /// 통계 서비스 상태 확인
  Future<bool> isHealthy() async {
    try {
      await _databaseClient.executeQuery(
        url: _databaseUrl,
        queryId: StatisticsQueries.oneDayAll,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 서비스 종료 시 리소스 정리
  void dispose() {
    _databaseClient.dispose();
  }
}
