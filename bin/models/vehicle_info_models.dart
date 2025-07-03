/// 차량 정보 조회 관련 데이터 모델
///
/// 주차 구역별 차량 정보 및 번호판 기반 검색을 위한 데이터 구조들을 정의

/// 태그 기반 차량 정보 요청
class VehicleInfoByTagRequest {
  final String tag;

  VehicleInfoByTagRequest({required this.tag});

  factory VehicleInfoByTagRequest.fromJson(Map<String, dynamic> json) =>
      VehicleInfoByTagRequest(
        tag: json['tag']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'tag': tag,
      };
}

/// 번호판 기반 차량 정보 요청
class VehicleInfoByPlateRequest {
  final String plate;

  VehicleInfoByPlateRequest({required this.plate});

  factory VehicleInfoByPlateRequest.fromJson(Map<String, dynamic> json) =>
      VehicleInfoByPlateRequest(
        plate: json['plate']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'plate': plate,
      };
}

/// 주차 구역 차량 정보
class ParkingSpaceVehicleInfo {
  final String tag;
  final String? plate;
  final String? startTime;
  final String? point;

  ParkingSpaceVehicleInfo({
    required this.tag,
    this.plate,
    this.startTime,
    this.point,
  });

  factory ParkingSpaceVehicleInfo.fromJson(Map<String, dynamic> json) =>
      ParkingSpaceVehicleInfo(
        tag: json['tag']?.toString() ?? '',
        plate: json['plate']?.toString(),
        startTime: json['startTime']?.toString(),
        point: json['point']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'tag': tag,
        if (plate != null) 'plate': plate,
        if (startTime != null) 'start_time': startTime,
        if (point != null) 'point': point,
        'has_vehicle': plate != null && plate!.isNotEmpty,
      };
}

/// 번호판 기반 차량 위치 정보
class VehicleLocationInfo {
  final String tag;
  final String plate;
  final String? point;

  VehicleLocationInfo({
    required this.tag,
    required this.plate,
    this.point,
  });

  factory VehicleLocationInfo.fromJson(Map<String, dynamic> json) =>
      VehicleLocationInfo(
        tag: json['tag']?.toString() ?? '',
        plate: json['plate']?.toString() ?? '',
        point: json['point']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'plate': plate,
        if (point != null) 'point': point,
      };
}

/// 차량 정보 조회 서비스 응답
class VehicleInfoServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  VehicleInfoServiceResponse({
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
      if (data is List) {
        result['data'] = (data as List).map((item) {
          if (item is VehicleLocationInfo) return item.toJson();
          if (item is ParkingSpaceVehicleInfo) return item.toJson();
          return item;
        }).toList();
      } else if (data is VehicleLocationInfo) {
        result['data'] = (data as VehicleLocationInfo).toJson();
      } else if (data is ParkingSpaceVehicleInfo) {
        result['data'] = (data as ParkingSpaceVehicleInfo).toJson();
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
