import 'package:intl/intl.dart';
import '../models/parking_data.dart';

/// 날짜 관련 유틸리티 함수들을 제공하는 모듈
/// 프로젝트 전반에서 사용되는 날짜 포맷팅 기능을 통합 관리
class DateUtils {
  /// DateTime을 'yyyy-MM-dd HH' 형식으로 포맷팅
  ///
  /// [dateTime] 포맷팅할 DateTime 객체
  /// Returns: 'yyyy-MM-dd HH' 형식의 문자열
  static String formatDateTime(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');

    return "$year-$month-$day $hour";
  }

  /// DateTime을 'yyyy-MM-dd HH:mm:ss' 형식으로 포맷팅
  ///
  /// [dateTime] 포맷팅할 DateTime 객체
  /// Returns: 'yyyy-MM-dd HH:mm:ss' 형식의 문자열
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// DateTime을 'yyyy-MM-dd' 형식으로 포맷팅
  ///
  /// [dateTime] 포맷팅할 DateTime 객체
  /// Returns: 'yyyy-MM-dd' 형식의 문자열
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// DateTime을 'yyyy-MM' 형식으로 포맷팅
  ///
  /// [dateTime] 포맷팅할 DateTime 객체
  /// Returns: 'yyyy-MM' 형식의 문자열
  static String formatMonth(DateTime dateTime) {
    return DateFormat('yyyy-MM').format(dateTime);
  }

  /// DateTime을 'yyyy' 형식으로 포맷팅
  ///
  /// [dateTime] 포맷팅할 DateTime 객체
  /// Returns: 'yyyy' 형식의 문자열
  static String formatYear(DateTime dateTime) {
    return DateFormat('yyyy').format(dateTime);
  }

  /// 현재 시간을 기준으로 한 시간 전 범위를 계산
  ///
  /// [now] 기준 시간
  /// Returns: start_time과 end_time을 포함하는 Map
  static Map<String, DateTime> calculateTimeRange(DateTime now) {
    DateTime endTime = DateTime(now.year, now.month, now.day, now.hour);
    DateTime startTime = endTime.subtract(const Duration(hours: 1));
    return {"start_time": startTime, "end_time": endTime};
  }

  /// TimeRange 객체로 시간 범위 계산
  ///
  /// [now] 기준 시간
  /// Returns: TimeRange 객체
  static TimeRange calculateTimeRangeObject(DateTime now) {
    DateTime endTime = DateTime(now.year, now.month, now.day, now.hour);
    DateTime startTime = endTime.subtract(const Duration(hours: 1));
    return TimeRange(startTime: startTime, endTime: endTime);
  }

  /// 한 시간 전 시각을 'yyyy-MM-dd HH' 형식으로 반환
  ///
  /// [now] 기준 시간
  /// Returns: 한 시간 전 시각 문자열
  static String getOneHourBefore(DateTime now) {
    final oneHourBefore = now.subtract(const Duration(hours: 1));
    return formatDateTime(oneHourBefore);
  }

  /// 하루 전 날짜들을 다양한 형식으로 반환
  ///
  /// [now] 기준 시간
  /// Returns: 각종 전날 날짜 문자열들
  static Map<String, String> getOneDayBeforeFormats(DateTime now) {
    final oneDayBefore = DateTime(now.year, now.month, now.day - 1);
    return {
      'day': formatDate(oneDayBefore),
      'month': formatMonth(oneDayBefore),
      'year': formatYear(oneDayBefore),
    };
  }

  /// 이전 월의 년도와 월을 계산
  ///
  /// [now] 기준 시간
  /// Returns: 이전 월 정보 Map
  static Map<String, int> getPreviousMonth(DateTime now) {
    int prevMonth = now.month - 1;
    int prevYear = now.year;
    if (prevMonth < 1) {
      prevMonth = 12;
      prevYear -= 1;
    }
    return {
      'month': prevMonth,
      'year': prevYear,
    };
  }

  /// 이전 월을 'yyyy-MM' 형식으로 반환
  ///
  /// [now] 기준 시간
  /// Returns: 이전 월 문자열
  static String getPreviousMonthString(DateTime now) {
    final prevMonthInfo = getPreviousMonth(now);
    return "${prevMonthInfo['year']}-${prevMonthInfo['month'].toString().padLeft(2, '0')}";
  }

  /// 이전 년도를 문자열로 반환
  ///
  /// [now] 기준 시간
  /// Returns: 이전 년도 문자열
  static String getPreviousYearString(DateTime now) {
    return (now.year - 1).toString();
  }

  /// 주어진 DateTime에서 seconds만큼 빼고 시간 정보 추출
  ///
  /// [dateTime] 기준 시간
  /// [seconds] 뺄 초 수
  /// Returns: 시간 정보 Map
  static Map<String, int> getTimeInfoWithOffset(
      DateTime dateTime, int seconds) {
    final offsetTime = dateTime.subtract(Duration(seconds: seconds));
    return {
      'hour': offsetTime.hour,
      'day': offsetTime.day,
      'month': offsetTime.month,
      'year': offsetTime.year,
    };
  }

  /// 현재 시각과 비교하여 시간/일/월/년이 변경되었는지 확인
  ///
  /// [previousTime] 이전 시간
  /// [currentTime] 현재 시간
  /// Returns: 변경된 단위들의 Map
  static Map<String, bool> checkTimeChanges(
      DateTime previousTime, DateTime currentTime) {
    return {
      'hour': previousTime.hour != currentTime.hour,
      'day': previousTime.day != currentTime.day,
      'month': previousTime.month != currentTime.month,
      'year': previousTime.year != currentTime.year,
    };
  }
}
