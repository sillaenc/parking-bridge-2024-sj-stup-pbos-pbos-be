/// 주차장 기본 정보 등록/수정 요청 모델
class BaseInformationRequest {
  final String name;
  final String address;
  final String latitude;
  final String longitude;
  final String manager;
  final String phoneNumber;

  const BaseInformationRequest({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.manager,
    required this.phoneNumber,
  });

  factory BaseInformationRequest.fromJson(Map<String, dynamic> json) {
    return BaseInformationRequest(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      manager: json['manager'] as String,
      phoneNumber: json['phonenumber'] as String, // API에서는 phonenumber로 전송
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'manager': manager,
      'phoneNumber': phoneNumber,
    };
  }

  /// 데이터베이스 저장용 형식 (기존 API 호환)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'manager': manager,
      'phoneNumber': phoneNumber, // 데이터베이스에는 phoneNumber로 저장
    };
  }

  /// 필수 필드 유효성 검사
  bool isValid() {
    return name.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        latitude.trim().isNotEmpty &&
        longitude.trim().isNotEmpty &&
        manager.trim().isNotEmpty &&
        phoneNumber.trim().isNotEmpty;
  }

  /// 위치 좌표 유효성 검사
  bool hasValidCoordinates() {
    final lat = double.tryParse(latitude);
    final lng = double.tryParse(longitude);

    if (lat == null || lng == null) return false;

    // 대한민국 영역 내 좌표인지 확인 (대략적)
    return lat >= 33.0 && lat <= 38.5 && lng >= 124.0 && lng <= 132.0;
  }

  /// 전화번호 형식 유효성 검사
  bool hasValidPhoneNumber() {
    // 한국 전화번호 패턴 (간단한 검증)
    final phonePattern =
        RegExp(r'^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$|^[0-9]{10,11}$');
    return phonePattern
        .hasMatch(phoneNumber.replaceAll('-', '').replaceAll(' ', ''));
  }
}

/// 주차장 기본 정보 모델
class BaseInformation {
  final int uid;
  final String name;
  final String address;
  final String latitude;
  final String longitude;
  final String manager;
  final String phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseInformation({
    required this.uid,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.manager,
    required this.phoneNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory BaseInformation.fromJson(Map<String, dynamic> json) {
    return BaseInformation(
      uid: json['uid'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      manager: json['manager'] as String,
      phoneNumber: json['phone_number'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'manager': manager,
      'phoneNumber': phoneNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// 위치 좌표를 double로 변환
  double? get latitudeAsDouble => double.tryParse(latitude);
  double? get longitudeAsDouble => double.tryParse(longitude);

  /// 연락처 정보 포맷팅
  String get formattedPhoneNumber {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phoneNumber;
  }
}

/// 주차장 통계 정보 모델
class ParkingLotStatistics {
  final int totalLots;
  final int usedLots;
  final int availableLots;
  final double usageRate;

  const ParkingLotStatistics({
    required this.totalLots,
    required this.usedLots,
  })  : availableLots = totalLots - usedLots,
        usageRate = totalLots > 0 ? (usedLots / totalLots * 100) : 0.0;

  factory ParkingLotStatistics.fromCounts(int total, int used) {
    return ParkingLotStatistics(
      totalLots: total,
      usedLots: used,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLots': totalLots,
      'usedLots': usedLots,
      'availableLots': availableLots,
      'usageRate': double.parse(usageRate.toStringAsFixed(2)),
    };
  }

  /// 레거시 형식 (기존 API 호환)
  Map<String, dynamic> toLegacyJson() {
    return {
      'all': totalLots,
      'use': usedLots,
    };
  }
}

/// 주차장 기본 정보 + 통계 응답 모델
class BaseInformationWithStats {
  final BaseInformation baseInfo;
  final ParkingLotStatistics statistics;

  const BaseInformationWithStats({
    required this.baseInfo,
    required this.statistics,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseInformation': baseInfo.toJson(),
      'statistics': statistics.toJson(),
    };
  }

  /// 레거시 형식 (기존 API 호환)
  Map<String, dynamic> toLegacyJson() {
    return {
      'all': statistics.totalLots,
      'use': statistics.usedLots,
      'db': baseInfo.toJson(),
    };
  }
}

/// 기본 정보 서비스 응답 모델
class BaseInformationServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const BaseInformationServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory BaseInformationServiceResponse.success(String message, [T? data]) {
    return BaseInformationServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory BaseInformationServiceResponse.error(String message,
      [String? errorCode]) {
    return BaseInformationServiceResponse<T>(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'success': success,
      'message': message,
    };

    if (data != null) {
      if (data is BaseInformation) {
        result['data'] = (data as BaseInformation).toJson();
      } else if (data is BaseInformationWithStats) {
        result['data'] = (data as BaseInformationWithStats).toJson();
      } else if (data is ParkingLotStatistics) {
        result['data'] = (data as ParkingLotStatistics).toJson();
      } else {
        result['data'] = data;
      }
    }

    if (errorCode != null) {
      result['errorCode'] = errorCode;
    }

    return result;
  }
}

/// 기본 정보 서비스 예외 클래스
class BaseInformationServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const BaseInformationServiceException(this.message, this.errorCode,
      [this.statusCode]);

  @override
  String toString() =>
      'BaseInformationServiceException: $message (Code: $errorCode)';
}

/// 기본 정보 관련 상수들
class BaseInformationConstants {
  // 에러 코드
  static const String errorValidationFailed = 'VALIDATION_FAILED';
  static const String errorMissingFields = 'MISSING_REQUIRED_FIELDS';
  static const String errorInvalidCoordinates = 'INVALID_COORDINATES';
  static const String errorInvalidPhoneNumber = 'INVALID_PHONE_NUMBER';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_ERROR';
  static const String errorInformationNotFound = 'INFORMATION_NOT_FOUND';
  static const String errorInformationExists = 'INFORMATION_EXISTS';

  // 성공 메시지
  static const String messageInformationCreated =
      'Base information created successfully';
  static const String messageInformationUpdated =
      'Base information updated successfully';
  static const String messageInformationRetrieved =
      'Base information retrieved successfully';
  static const String messageStatisticsRetrieved =
      'Parking statistics retrieved successfully';

  // 에러 메시지
  static const String messageValidationFailed = 'Input validation failed';
  static const String messageMissingFields = 'Required fields are missing';
  static const String messageInvalidCoordinates =
      'Invalid latitude or longitude coordinates';
  static const String messageInvalidPhoneNumber = 'Invalid phone number format';
  static const String messageDatabaseError = 'Database operation failed';
  static const String messageInformationNotFound = 'Base information not found';

  // 필드명
  static const List<String> requiredFields = [
    'name',
    'address',
    'latitude',
    'longitude',
    'manager',
    'phonenumber'
  ];

  // 쿼리 ID들
  static const String queryCheckingExists = '#checking';
  static const String statementInsertBase = '#base';
  static const String statementUpdateBase = '#get_base';
  static const String queryGetInformation = '#get_information';
  static const String queryAllParkingLot = '#allParkingLot';
  static const String queryUsedParkingLot = '#usedParkingLot';
}
