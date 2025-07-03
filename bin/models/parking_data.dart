/// 주차 관련 데이터 모델들을 정의하는 파일
/// 엔진 데이터 수신 및 처리에 사용되는 핵심 데이터 구조들

/// 엔진에서 받아온 원시 주차 데이터
class EngineData {
  final String id;
  final String timestamp;
  final String parkingLot;

  EngineData({
    required this.id,
    required this.timestamp,
    required this.parkingLot,
  });

  factory EngineData.fromJson(Map<String, dynamic> json) {
    return EngineData(
      id: json['id']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      parkingLot: json['parking_lot']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'parking_lot': parkingLot,
    };
  }
}

/// 파싱된 주차장 데이터
class ParkingLotData {
  final List<String> occupiedSlots;
  final List<String> errorSlots;
  final int totalSlots;

  ParkingLotData({
    required this.occupiedSlots,
    required this.errorSlots,
    required this.totalSlots,
  });

  /// 주차 사용률 계산
  double get occupancyRate {
    if (totalSlots == 0) return 0.0;
    return occupiedSlots.length / totalSlots;
  }

  /// 에러율 계산
  double get errorRate {
    if (totalSlots == 0) return 0.0;
    return errorSlots.length / totalSlots;
  }
}

/// 개별 주차 공간 정보
class LotInfo {
  final int uid;
  final String tag;
  final int lotType;
  final bool isUsed;

  LotInfo({
    required this.uid,
    required this.tag,
    required this.lotType,
    required this.isUsed,
  });

  factory LotInfo.fromJson(Map<String, dynamic> json) {
    return LotInfo(
      uid: json['uid'] ?? 0,
      tag: json['tag']?.toString() ?? '',
      lotType: json['lot_type'] ?? 0,
      isUsed: json['isUsed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'tag': tag,
      'lot_type': lotType,
      'isUsed': isUsed ? 1 : 0,
    };
  }

  /// 사용 중인 주차 공간인지 확인
  bool get isOccupied => isUsed;

  /// 복사본 생성 (상태 변경용)
  LotInfo copyWith({
    int? uid,
    String? tag,
    int? lotType,
    bool? isUsed,
  }) {
    return LotInfo(
      uid: uid ?? this.uid,
      tag: tag ?? this.tag,
      lotType: lotType ?? this.lotType,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

/// 통계 데이터 모델
class ParkingStatistics {
  final int lot;
  final int carType;
  final bool hasParking;
  final String recordedTime;
  final StatisticsPeriod period;

  ParkingStatistics({
    required this.lot,
    required this.carType,
    required this.hasParking,
    required this.recordedTime,
    required this.period,
  });

  factory ParkingStatistics.fromJson(
      Map<String, dynamic> json, StatisticsPeriod period) {
    return ParkingStatistics(
      lot: json['lot'] ?? 0,
      carType: json['car_type'] ?? 0,
      hasParking: (json['hour_parking'] ??
              json['day_parking'] ??
              json['month_parking'] ??
              json['year_parking']) ==
          1,
      recordedTime: json['recorded_hour'] ?? json['fromattedTime'] ?? '',
      period: period,
    );
  }

  Map<String, dynamic> toJson() {
    final parkingKey = switch (period) {
      StatisticsPeriod.hourly => 'hour_parking',
      StatisticsPeriod.daily => 'day_parking',
      StatisticsPeriod.monthly => 'month_parking',
      StatisticsPeriod.yearly => 'year_parking',
    };

    final timeKey = switch (period) {
      StatisticsPeriod.hourly => 'recorded_hour',
      StatisticsPeriod.daily => 'fromattedTime',
      StatisticsPeriod.monthly => 'fromattedTime',
      StatisticsPeriod.yearly => 'fromattedTime',
    };

    return {
      'lot': lot,
      'car_type': carType,
      parkingKey: hasParking ? 1 : 0,
      timeKey: recordedTime,
    };
  }
}

/// 통계 기간 enum
enum StatisticsPeriod {
  hourly('hour'),
  daily('day'),
  monthly('month'),
  yearly('year');

  const StatisticsPeriod(this.value);
  final String value;
}

/// 시간 범위 정보
class TimeRange {
  final DateTime startTime;
  final DateTime endTime;

  TimeRange({
    required this.startTime,
    required this.endTime,
  });

  /// 범위 내 시간인지 확인
  bool contains(DateTime dateTime) {
    return dateTime.isAfter(startTime) && dateTime.isBefore(endTime);
  }

  /// 기간 계산 (분 단위)
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }
}
