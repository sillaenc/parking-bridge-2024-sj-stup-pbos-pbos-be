/// 카메라 주차 표면 정보 모델
class CameraParkingSurface {
  final int? uid;
  final String tag;
  final String engineCode;
  final String uri;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CameraParkingSurface({
    this.uid,
    required this.tag,
    required this.engineCode,
    required this.uri,
    this.createdAt,
    this.updatedAt,
  });

  factory CameraParkingSurface.fromJson(Map<String, dynamic> json) {
    return CameraParkingSurface(
      uid: json['uid'] as int?,
      tag: json['tag'] as String,
      engineCode:
          json['engine_code'] as String? ?? json['surface_code'] as String,
      uri: json['uri'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'tag': tag,
      'engine_code': engineCode,
      'uri': uri,
    };

    if (uid != null) {
      data['uid'] = uid;
    }

    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }

    if (updatedAt != null) {
      data['updated_at'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  CameraParkingSurface copyWith({
    int? uid,
    String? tag,
    String? engineCode,
    String? uri,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CameraParkingSurface(
      uid: uid ?? this.uid,
      tag: tag ?? this.tag,
      engineCode: engineCode ?? this.engineCode,
      uri: uri ?? this.uri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 카메라 주차 표면 생성 요청 모델
class CreateCameraParkingSurfaceRequest {
  final String tag;
  final String engineCode;
  final String uri;

  const CreateCameraParkingSurfaceRequest({
    required this.tag,
    required this.engineCode,
    required this.uri,
  });

  factory CreateCameraParkingSurfaceRequest.fromJson(
      Map<String, dynamic> json) {
    return CreateCameraParkingSurfaceRequest(
      tag: json['tag'] as String,
      engineCode: json['engine_code'] as String,
      uri: json['uri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'engine_code': engineCode,
      'uri': uri,
    };
  }
}

/// 카메라 주차 표면 업데이트 요청 모델
class UpdateCameraParkingSurfaceRequest {
  final String? beforeTag; // 기존 태그 (URL에서 가져올 수도 있음)
  final String tag;
  final String engineCode;
  final String uri;

  const UpdateCameraParkingSurfaceRequest({
    this.beforeTag,
    required this.tag,
    required this.engineCode,
    required this.uri,
  });

  factory UpdateCameraParkingSurfaceRequest.fromJson(
      Map<String, dynamic> json) {
    return UpdateCameraParkingSurfaceRequest(
      beforeTag: json['beforetag'] as String?,
      tag: json['tag'] as String,
      engineCode: json['engine_code'] as String,
      uri: json['uri'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'tag': tag,
      'engine_code': engineCode,
      'uri': uri,
    };

    if (beforeTag != null) {
      data['beforetag'] = beforeTag;
    }

    return data;
  }
}

/// 카메라 주차 표면 삭제 요청 모델
class DeleteCameraParkingSurfaceRequest {
  final String tag;

  const DeleteCameraParkingSurfaceRequest({
    required this.tag,
  });

  factory DeleteCameraParkingSurfaceRequest.fromJson(
      Map<String, dynamic> json) {
    return DeleteCameraParkingSurfaceRequest(
      tag: json['tag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
    };
  }
}

/// 카메라 주차 표면 서비스 응답 모델
class CameraParkingSurfaceServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const CameraParkingSurfaceServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory CameraParkingSurfaceServiceResponse.success(String message,
      [T? data]) {
    return CameraParkingSurfaceServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory CameraParkingSurfaceServiceResponse.error(String message,
      [String? errorCode]) {
    return CameraParkingSurfaceServiceResponse<T>(
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
      if (data is List) {
        result['data'] = (data as List).map((item) {
          if (item is CameraParkingSurface) return item.toJson();
          return item;
        }).toList();
      } else if (data is CameraParkingSurface) {
        result['data'] = (data as CameraParkingSurface).toJson();
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

/// 카메라 주차 표면 서비스 예외 클래스
class CameraParkingSurfaceServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const CameraParkingSurfaceServiceException(this.message, this.errorCode,
      [this.statusCode]);

  @override
  String toString() =>
      'CameraParkingSurfaceServiceException: $message (Code: $errorCode)';
}

/// 카메라 주차 표면 관리 상수들
class CameraParkingSurfaceConstants {
  // 최대 길이 제한
  static const int maxTagLength = 50;
  static const int maxEngineCodeLength = 10;
  static const int maxUriLength = 500;

  // URI 형식 패턴
  static const String uriPattern = r'^https?://[^\s/$.?#].[^\s]*$';

  // 에러 코드
  static const String errorSurfaceNotFound = 'SURFACE_NOT_FOUND';
  static const String errorSurfaceExists = 'SURFACE_EXISTS';
  static const String errorInvalidTag = 'INVALID_TAG';
  static const String errorInvalidEngineCode = 'INVALID_ENGINE_CODE';
  static const String errorInvalidUri = 'INVALID_URI';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_ERROR';
  static const String errorValidationFailed = 'VALIDATION_FAILED';
  static const String errorUnauthorized = 'UNAUTHORIZED';

  // 성공 메시지
  static const String messageSurfaceCreated =
      'Camera parking surface created successfully';
  static const String messageSurfaceUpdated =
      'Camera parking surface updated successfully';
  static const String messageSurfaceDeleted =
      'Camera parking surface deleted successfully';
  static const String messageSurfaceRetrieved =
      'Camera parking surface retrieved successfully';
  static const String messageSurfacesRetrieved =
      'Camera parking surfaces retrieved successfully';

  // 에러 메시지
  static const String messageSurfaceNotExists =
      'Camera parking surface does not exist';
  static const String messageSurfaceAlreadyExists =
      'Camera parking surface already exists';
  static const String messageInvalidTag = 'Invalid tag format';
  static const String messageInvalidEngineCode = 'Invalid engine code format';
  static const String messageInvalidUri = 'Invalid URI format';
  static const String messageDatabaseError = 'Database operation failed';
  static const String messageValidationFailed = 'Input validation failed';
}

/// 유효성 검사 결과 클래스
class CameraValidationResult {
  final bool isValid;
  final List<String> errors;

  const CameraValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// 첫 번째 에러 메시지를 반환합니다
  String get firstError => errors.isNotEmpty ? errors.first : '';

  /// 모든 에러 메시지를 하나의 문자열로 합칩니다
  String get allErrors => errors.join(', ');
}
