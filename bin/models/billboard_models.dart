/// 전광판 관련 데이터 모델
///
/// 전광판 표시 정보 및 부분 시스템 제어를 위한 데이터 구조들을 정의

/// 층별 주차 정보 요청
class FloorParkingInfoRequest {
  final String floor;

  FloorParkingInfoRequest({required this.floor});

  factory FloorParkingInfoRequest.fromJson(Map<String, dynamic> json) =>
      FloorParkingInfoRequest(
        floor: json['floor']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'floor': floor,
      };
}

/// 부분 시스템 제어 요청
class PartSystemControlRequest {
  final String value;

  PartSystemControlRequest({required this.value});

  factory PartSystemControlRequest.fromJson(Map<String, dynamic> json) =>
      PartSystemControlRequest(
        value: json['value']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'value': value,
      };
}

/// 층별 주차 타입별 정보
class FloorParkingTypeInfo {
  final int lotType;
  final int count;

  FloorParkingTypeInfo({
    required this.lotType,
    required this.count,
  });

  factory FloorParkingTypeInfo.fromJson(Map<String, dynamic> json) =>
      FloorParkingTypeInfo(
        lotType: json['lot_type'] ?? 0,
        count: json['count'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'lot_type': lotType,
        'count': count,
      };
}

/// 전광판 표시 데이터
class BillboardDisplayData {
  final String floor;
  final List<FloorParkingTypeInfo> parkingInfo;
  final int totalAvailable;

  BillboardDisplayData({
    required this.floor,
    required this.parkingInfo,
    required this.totalAvailable,
  });

  Map<String, dynamic> toJson() => {
        'floor': floor,
        'parking_info': parkingInfo.map((e) => e.toJson()).toList(),
        'total_available': totalAvailable,
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 부분 시스템 제어 결과
class PartSystemControlResult {
  final List<String> endpoints;
  final String value;
  final int successCount;
  final int totalCount;

  PartSystemControlResult({
    required this.endpoints,
    required this.value,
    required this.successCount,
    required this.totalCount,
  });

  Map<String, dynamic> toJson() => {
        'endpoints': endpoints,
        'value': value,
        'success_count': successCount,
        'total_count': totalCount,
        'success_rate': totalCount > 0
            ? (successCount / totalCount * 100).toStringAsFixed(1)
            : '0.0',
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 전광판 서비스 응답
class BillboardServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  BillboardServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'success': success,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (data != null) {
      if (data is BillboardDisplayData) {
        result['data'] = (data as BillboardDisplayData).toJson();
      } else if (data is PartSystemControlResult) {
        result['data'] = (data as PartSystemControlResult).toJson();
      } else {
        result['data'] = data;
      }
    }

    if (error != null) {
      result['error'] = error;
    }

    return result;
  }
}
