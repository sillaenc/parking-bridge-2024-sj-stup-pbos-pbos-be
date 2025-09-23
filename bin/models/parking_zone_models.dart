import 'dart:typed_data';

/// 주차 구역 정보 모델
class ParkingZone {
  final String parkingName;
  final String fileAddress;
  final String? filename; // DB에서 때로는 filename으로 반환되기도 함
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ParkingZone({
    required this.parkingName,
    required this.fileAddress,
    this.filename,
    this.createdAt,
    this.updatedAt,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    return ParkingZone(
      parkingName:
          json['parking_name'] as String? ?? json['filename'] as String,
      fileAddress: json['file_address'] as String,
      filename: json['filename'] as String?,
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
      'parking_name': parkingName,
      'file_address': fileAddress,
    };

    if (filename != null) {
      data['filename'] = filename;
    }

    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }

    if (updatedAt != null) {
      data['updated_at'] = updatedAt!.toIso8601String();
    }

    return data;
  }

  ParkingZone copyWith({
    String? parkingName,
    String? fileAddress,
    String? filename,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingZone(
      parkingName: parkingName ?? this.parkingName,
      fileAddress: fileAddress ?? this.fileAddress,
      filename: filename ?? this.filename,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 파일 업로드 요청 모델
class FileUploadRequest {
  final String filename;
  final Uint8List content;
  final String extension;

  const FileUploadRequest({
    required this.filename,
    required this.content,
    required this.extension,
  });

  String get fullFilename => '$filename.$extension';
}

/// 파일 업데이트 요청 모델
class FileUpdateRequest {
  final String newFilename;
  final String oldFilename;
  final Uint8List content;
  final String extension;

  const FileUpdateRequest({
    required this.newFilename,
    required this.oldFilename,
    required this.content,
    required this.extension,
  });

  String get newFullFilename => '$newFilename.$extension';
  String get oldFullFilename => '$oldFilename.$extension';
}

/// 주차 공간 유형 변경 요청 모델
class LotTypeChangeRequest {
  final int lotType;
  final String changedTag;
  final String tag;

  const LotTypeChangeRequest({
    required this.lotType,
    required this.changedTag,
    required this.tag,
  });

  factory LotTypeChangeRequest.fromJson(Map<String, dynamic> json) {
    return LotTypeChangeRequest(
      lotType: json['lot_type'] as int,
      changedTag: json['changed_tag'] as String,
      tag: json['tag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lot_type': lotType,
      'changed_tag': changedTag,
      'tag': tag,
    };
  }
}

/// 주차 상태 변경 요청 모델
class ParkingStatusChangeRequest {
  final bool parked;
  final String tag;

  const ParkingStatusChangeRequest({
    required this.parked,
    required this.tag,
  });

  factory ParkingStatusChangeRequest.fromJson(Map<String, dynamic> json) {
    return ParkingStatusChangeRequest(
      parked: json['parked'] as bool,
      tag: json['tag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parked': parked,
      'tag': tag,
    };
  }
}

/// 파일 삭제 요청 모델
class FileDeleteRequest {
  final String filename;

  const FileDeleteRequest({
    required this.filename,
  });

  factory FileDeleteRequest.fromJson(Map<String, dynamic> json) {
    return FileDeleteRequest(
      filename: json['filename'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
    };
  }
}

/// 주차 구역 서비스 응답 모델
class ParkingZoneServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const ParkingZoneServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ParkingZoneServiceResponse.success(String message, [T? data]) {
    return ParkingZoneServiceResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ParkingZoneServiceResponse.error(String message,
      [String? errorCode]) {
    return ParkingZoneServiceResponse<T>(
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
          if (item is ParkingZone) return item.toJson();
          return item;
        }).toList();
      } else if (data is ParkingZone) {
        result['data'] = (data as ParkingZone).toJson();
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

/// 주차 구역 서비스 예외 클래스
class ParkingZoneServiceException implements Exception {
  final String message;
  final String errorCode;
  final int? statusCode;

  const ParkingZoneServiceException(this.message, this.errorCode,
      [this.statusCode]);

  @override
  String toString() =>
      'ParkingZoneServiceException: $message (Code: $errorCode)';
}

/// 주차 구역 관리 상수들
class ParkingZoneConstants {
  static const String defaultFileDirectory = 'file';
  static const int maxFilenameLength = 100;
  static const int maxFileSizeBytes = 500 * 1024 * 1024; // 500MB (대용량 영상 지원)

  // 지원되는 파일 확장자
  static const List<String> supportedExtensions = [
    // 이미지 파일
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'tiff',
    'ico',
    // 영상 파일
    'mp4',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'mkv',
    'mpg',
    'mpeg',
    'm4v',
    '3gp',
    // 문서 파일
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    // 데이터 파일
    'json',
    'xml',
    'txt',
    'csv',
    'yaml',
    'yml',
    // 압축 파일
    'zip',
    'rar',
    '7z',
    'tar',
    'gz'
  ];

  // 주차 공간 유형
  static const int lotTypeNormal = 1;
  static const int lotTypeElectric = 2;
  static const int lotTypeDisabled = 3;
  static const int lotTypeCompact = 4;

  // 에러 코드
  static const String errorFileNotFound = 'FILE_NOT_FOUND';
  static const String errorFileExists = 'FILE_EXISTS';
  static const String errorInvalidFileType = 'INVALID_FILE_TYPE';
  static const String errorFileTooLarge = 'FILE_TOO_LARGE';
  static const String errorInvalidFilename = 'INVALID_FILENAME';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_ERROR';
  static const String errorFileOperation = 'FILE_OPERATION_ERROR';
  static const String errorValidationFailed = 'VALIDATION_FAILED';
  static const String errorUnauthorized = 'UNAUTHORIZED';
  static const String errorZoneNotFound = 'ZONE_NOT_FOUND';
  static const String errorZoneExists = 'ZONE_EXISTS';

  // 성공 메시지
  static const String messageFileUploaded = 'File uploaded successfully';
  static const String messageFileDeleted = 'File deleted successfully';
  static const String messageFileUpdated = 'File updated successfully';
  static const String messageLotTypeChanged = 'Lot type changed successfully';
  static const String messageParkingStatusChanged =
      'Parking status changed successfully';
  static const String messageZoneCreated = 'Parking zone created successfully';
  static const String messageZoneDeleted = 'Parking zone deleted successfully';
  static const String messageZoneUpdated = 'Parking zone updated successfully';

  // 에러 메시지
  static const String messageFileNotExists = 'File does not exist';
  static const String messageFileAlreadyExists = 'File already exists';
  static const String messageInvalidFileType = 'Unsupported file type';
  static const String messageFileTooLarge = 'File size exceeds maximum limit';
  static const String messageInvalidFilename = 'Invalid filename format';
  static const String messageDatabaseError = 'Database operation failed';
  static const String messageFileOperationError = 'File operation failed';
  static const String messageValidationFailed = 'Input validation failed';
  static const String messageZoneNotExists = 'Parking zone does not exist';
  static const String messageZoneAlreadyExists = 'Parking zone already exists';
}

/// 파일 정보 모델
class FileInfo {
  final String filename;
  final String fullPath;
  final String extension;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const FileInfo({
    required this.filename,
    required this.fullPath,
    required this.extension,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'fullPath': fullPath,
      'extension': extension,
      'sizeBytes': sizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }
}
