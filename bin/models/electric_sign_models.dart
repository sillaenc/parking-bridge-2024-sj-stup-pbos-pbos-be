/// 전광판 정보 모델
class ElectricSign {
  final int uid;
  final String parkingLot;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ElectricSign({
    required this.uid,
    required this.parkingLot,
    this.createdAt,
    this.updatedAt,
  });

  factory ElectricSign.fromJson(Map<String, dynamic> json) {
    return ElectricSign(
      uid: json['uid'] as int,
      parkingLot: json['parking_lot'] as String,
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
      'parkingLot': parkingLot,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// DB 저장용 형식 (기존 필드명 유지)
  Map<String, dynamic> toDatabaseJson() {
    return {
      'uid': uid,
      'parking_lot': parkingLot,
    };
  }

  /// 전광판 정보가 유효한지 확인
  bool isValid() {
    return uid > 0 && parkingLot.trim().isNotEmpty;
  }

  /// 복사 생성자 (일부 필드만 변경)
  ElectricSign copyWith({
    int? uid,
    String? parkingLot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ElectricSign(
      uid: uid ?? this.uid,
      parkingLot: parkingLot ?? this.parkingLot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 전광판 생성 요청 모델
class CreateElectricSignRequest {
  final int uid;
  final String parkingLot;

  const CreateElectricSignRequest({
    required this.uid,
    required this.parkingLot,
  });

  factory CreateElectricSignRequest.fromJson(Map<String, dynamic> json) {
    return CreateElectricSignRequest(
      uid: json['uid'] as int,
      parkingLot: json['parking_lot'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'parkingLot': parkingLot,
    };
  }

  /// DB 저장용 형식
  Map<String, dynamic> toDatabaseJson() {
    return {
      'uid': uid,
      'parking_lot': parkingLot,
    };
  }

  /// 유효성 검사
  bool isValid() {
    return uid > 0 && parkingLot.trim().isNotEmpty;
  }

  /// ElectricSign 객체로 변환
  ElectricSign toElectricSign() {
    return ElectricSign(
      uid: uid,
      parkingLot: parkingLot,
    );
  }
}

/// 전광판 업데이트 요청 모델
class UpdateElectricSignRequest {
  final String parkingLot;

  const UpdateElectricSignRequest({
    required this.parkingLot,
  });

  factory UpdateElectricSignRequest.fromJson(Map<String, dynamic> json) {
    return UpdateElectricSignRequest(
      parkingLot: json['parking_lot'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parkingLot': parkingLot,
    };
  }

  /// DB 업데이트용 형식
  Map<String, dynamic> toDatabaseJson(int uid) {
    return {
      'uid': uid,
      'parking_lot': parkingLot,
    };
  }

  /// 유효성 검사
  bool isValid() {
    return parkingLot.trim().isNotEmpty;
  }
}

/// 전광판 삭제 요청 모델
class DeleteElectricSignRequest {
  final int uid;

  const DeleteElectricSignRequest({
    required this.uid,
  });

  factory DeleteElectricSignRequest.fromJson(Map<String, dynamic> json) {
    return DeleteElectricSignRequest(
      uid: json['uid'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
    };
  }

  /// DB 삭제용 형식
  Map<String, dynamic> toDatabaseJson() {
    return {
      'uid': uid,
    };
  }

  /// 유효성 검사
  bool isValid() {
    return uid > 0;
  }
}

/// 전광판 서비스 응답 모델
class ElectricSignServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const ElectricSignServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ElectricSignServiceResponse.success(String message, [T? data]) {
    return ElectricSignServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ElectricSignServiceResponse.error(String message,
      [String? errorCode]) {
    return ElectricSignServiceResponse<T>(
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
      if (data is ElectricSign) {
        result['data'] = (data as ElectricSign).toJson();
      } else if (data is List<ElectricSign>) {
        result['data'] =
            (data as List<ElectricSign>).map((sign) => sign.toJson()).toList();
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

/// 전광판 서비스 예외 클래스
class ElectricSignServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const ElectricSignServiceException(this.message, this.errorCode,
      [this.statusCode]);

  @override
  String toString() =>
      'ElectricSignServiceException: $message (Code: $errorCode)';
}

/// 전광판 관련 상수들
class ElectricSignConstants {
  // 에러 코드
  static const String errorValidationFailed = 'VALIDATION_FAILED';
  static const String errorInvalidUid = 'INVALID_UID';
  static const String errorEmptyParkingLot = 'EMPTY_PARKING_LOT';
  static const String errorSignNotFound = 'SIGN_NOT_FOUND';
  static const String errorSignExists = 'SIGN_EXISTS';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_ERROR';

  // 성공 메시지
  static const String messageSignCreated = 'Electric sign created successfully';
  static const String messageSignUpdated = 'Electric sign updated successfully';
  static const String messageSignDeleted = 'Electric sign deleted successfully';
  static const String messageSignsRetrieved =
      'Electric signs retrieved successfully';
  static const String messageSignRetrieved =
      'Electric sign retrieved successfully';

  // 에러 메시지
  static const String messageValidationFailed = 'Input validation failed';
  static const String messageInvalidUid =
      'Invalid UID: must be positive integer';
  static const String messageEmptyParkingLot =
      'Parking lot information cannot be empty';
  static const String messageSignNotFound = 'Electric sign not found';
  static const String messageSignExists =
      'Electric sign with this UID already exists';
  static const String messageDatabaseError = 'Database operation failed';

  // 쿼리/스테이트먼트 ID들
  static const String querySelectAll = '#S_Multi';
  static const String statementInsert = '#I_Multi';
  static const String statementUpdate = '#U_Multi';
  static const String statementDelete = '#D_Multi';

  // 유효성 검사 규칙
  static const int minUid = 1;
  static const int maxUid = 999999;
  static const int maxParkingLotLength = 255;

  /// UID 유효성 검사
  static bool isValidUid(int uid) {
    return uid >= minUid && uid <= maxUid;
  }

  /// 주차장 정보 유효성 검사
  static bool isValidParkingLot(String parkingLot) {
    final trimmed = parkingLot.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxParkingLotLength;
  }

  /// UID 범위 에러 메시지
  static String getUidRangeErrorMessage() {
    return 'UID must be between $minUid and $maxUid';
  }

  /// 주차장 정보 길이 에러 메시지
  static String getParkingLotLengthErrorMessage() {
    return 'Parking lot information must not exceed $maxParkingLotLength characters';
  }
}

/// 전광판 유효성 검사 결과 모델
class ElectricSignValidationResult {
  final bool isValid;
  final List<String> errors;

  const ElectricSignValidationResult({
    required this.isValid,
    required this.errors,
  });

  factory ElectricSignValidationResult.valid() {
    return const ElectricSignValidationResult(
      isValid: true,
      errors: [],
    );
  }

  factory ElectricSignValidationResult.invalid(List<String> errors) {
    return ElectricSignValidationResult(
      isValid: false,
      errors: errors,
    );
  }

  /// 첫 번째 에러 메시지 반환
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// 모든 에러 메시지를 하나의 문자열로 결합
  String get allErrors => errors.join(', ');
}

/// 전광판 통계 정보 모델
class ElectricSignStatistics {
  final int totalSigns;
  final DateTime lastUpdated;
  final Map<String, int> signsByParkingLot;

  const ElectricSignStatistics({
    required this.totalSigns,
    required this.lastUpdated,
    required this.signsByParkingLot,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSigns': totalSigns,
      'lastUpdated': lastUpdated.toIso8601String(),
      'signsByParkingLot': signsByParkingLot,
    };
  }

  /// 통계 요약 정보
  Map<String, dynamic> getSummary() {
    return {
      'totalSigns': totalSigns,
      'uniqueParkingLots': signsByParkingLot.length,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
