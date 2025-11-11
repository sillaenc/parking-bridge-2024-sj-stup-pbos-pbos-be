/// 통계 관련 모델들을 정의하는 파일
/// 통계 조회에 사용되는 데이터 모델들과 상수들을 포함

import 'package:intl/intl.dart';

/// 통계 기간 타입을 나타내는 열거형
enum StatisticsPeriodType { day, week, month, year, severalYears, custom }

/// 통계 조회 요청 파라미터를 나타내는 클래스
class StatisticsQueryParams {
  final String? startDay;
  final String? endDay;
  final StatisticsPeriodType periodType;

  StatisticsQueryParams({
    this.startDay,
    this.endDay,
    required this.periodType,
  });

  /// JSON으로부터 객체 생성
  factory StatisticsQueryParams.fromJson(Map<String, dynamic> json) {
    return StatisticsQueryParams(
      startDay: json['startDay'],
      endDay: json['endDay'],
      periodType: StatisticsPeriodType.custom,
    );
  }

  /// 검증 - 시작일과 종료일이 올바른지 확인
  bool isValid() {
    if (periodType == StatisticsPeriodType.custom) {
      return startDay != null && endDay != null;
    }
    return true;
  }
}

/// 통계 조회 결과를 나타내는 클래스
class StatisticsResult {
  final List<Map<String, dynamic>> data;
  final String query;
  final DateTime timestamp;

  StatisticsResult({
    required this.data,
    required this.query,
    required this.timestamp,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 날짜 관련 유틸리티 클래스
class StatisticsDateHelper {
  /// 하루 전 날짜 계산 (일별 통계용)
  static Map<String, String> getDayRangeParams() {
    final now = DateTime.now();
    final hourago = '${DateFormat('yyyy-MM-dd').format(now)} 9';
    final today = '${DateFormat('yyyy-MM-dd').format(now)} 0';
    final onedayBefore = now.subtract(const Duration(days: 1));
    final yesterday = '${DateFormat('yyyy-MM-dd').format(onedayBefore)}%';

    return {
      'hourago': hourago,
      'today': today,
      'yesterday': yesterday,
    };
  }

  /// 주간 범위 계산 (주별 통계용)
  static Map<String, String> getWeekRangeParams() {
    final now = DateTime.now();
    final thisWeek = DateFormat('yyyy-MM-dd').format(now);
    final lastWeekStart = now.subtract(Duration(days: now.weekday + 7));
    final lastWeek = DateFormat('yyyy-MM-dd').format(lastWeekStart);

    return {
      'today': thisWeek,
      'last_month': lastWeek,
    };
  }

  /// 월간 범위 계산 (월별 통계용)
  static Map<String, String> getMonthRangeParams() {
    final now = DateTime.now();
    final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthStart = DateFormat('yyyy-MM-dd').format(firstDayOfLastMonth);
    final todayFormat = DateFormat('yyyy-MM-dd').format(now);

    return {
      'today': todayFormat,
      'last_month': lastMonthStart,
    };
  }

  /// 연간 범위 계산 (연별 통계용)
  static Map<String, String> getYearRangeParams() {
    final now = DateTime.now();
    final thisYear = DateFormat('yyyy-MM').format(now);
    final onemonthBefore = now.subtract(const Duration(days: 365));
    final lastYear = DateFormat('yyyy-MM').format(onemonthBefore);

    return {
      'today': thisYear,
      'lastYear': lastYear,
    };
  }

  /// 여러 년도 범위 계산 (다년도 통계용)
  static Map<String, String> getSeveralYearsRangeParams() {
    final now = DateTime.now();
    final thisMonth = DateFormat('yyyy-M-d').format(now);
    final onemonthBefore = now.subtract(const Duration(days: 30));
    final lastMonth = DateFormat('yyyy-M-d').format(onemonthBefore);

    return {
      'today': thisMonth,
      'last_month': lastMonth,
    };
  }

  /// 사용자 정의 범위 파라미터 생성 (그래프용)
  static Map<String, String> getCustomRangeParams(
      String startDay, String endDay) {
    final formattedStartDay =
        startDay.contains(' ') ? startDay : '$startDay 00';
    final formattedEndDay =
        endDay.contains(' ') ? endDay : '$endDay 23';

    return {
      'startDay': formattedStartDay,
      'endDay': formattedEndDay,
    };
  }
}

/// 통계 쿼리 상수들
class StatisticsQueries {
  static const String oneDayAll = "#S_OneDayAll";
  static const String oneDay = "#S_OneDay";
  static const String oneWeek = "#S_OneWeek";
  static const String oneMonth = "#S_OneMonth";
  static const String oneMonthAll = "#S_OneMonthAll";
  static const String oneYear = "#S_OneYear";
  static const String oneYearAll = "#S_OneYearAll";
  static const String severalYears = "#SeveralYears";
  static const String severalYearsAll = "#SeveralYearsAll";
  static const String search = "#S_Search";
  static const String graph = "#S_graph";
}
