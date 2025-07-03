/// 중앙 대시보드 관련 데이터 모델
///
/// 주차장 전체 현황 및 통계 정보를 위한 데이터 구조들을 정의

/// 주차장 통계 기본 정보
class ParkingStatistics {
  final int totalSpaces;
  final int usedSpaces;

  ParkingStatistics({
    required this.totalSpaces,
    required this.usedSpaces,
  });

  Map<String, dynamic> toJson() => {
        'total_spaces': totalSpaces,
        'used_spaces': usedSpaces,
        'available_spaces': totalSpaces - usedSpaces,
        'occupancy_rate': totalSpaces > 0
            ? (usedSpaces / totalSpaces * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// 층별/타입별 주차 현황
class ParkingOccupancy {
  final int lotType;
  final String floor;
  final int count;

  ParkingOccupancy({
    required this.lotType,
    required this.floor,
    required this.count,
  });

  factory ParkingOccupancy.fromJson(Map<String, dynamic> json) =>
      ParkingOccupancy(
        lotType: json['lot_type'] ?? 0,
        floor: json['floor'] ?? '',
        count: json['count'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'lot_type': lotType,
        'floor': floor,
        'count': count,
      };
}

/// 중앙 대시보드 전체 응답
class CentralDashboardResponse {
  final ParkingStatistics statistics;
  final List<String> floors;
  final List<int> lotTypes;
  final List<ParkingOccupancy> occupancyData;

  CentralDashboardResponse({
    required this.statistics,
    required this.floors,
    required this.lotTypes,
    required this.occupancyData,
  });

  Map<String, dynamic> toJson() => {
        'statistics': statistics.toJson(),
        'floors': floors,
        'lot_types': lotTypes,
        'occupancy_data': occupancyData.map((e) => e.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 서비스 응답 래퍼
class CentralDashboardServiceResponse {
  final bool success;
  final String message;
  final CentralDashboardResponse? data;
  final String? error;

  CentralDashboardServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        if (data != null) 'data': data!.toJson(),
        if (error != null) 'error': error,
        'timestamp': DateTime.now().toIso8601String(),
      };
}
