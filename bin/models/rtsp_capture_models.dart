/// RTSP 캡처 관련 데이터 모델
///
/// 주차 구역(tag)과 RTSP 카메라 주소를 매핑하고,
/// 캡처된 이미지 경로를 관리합니다.

/// RTSP 캡처 설정 모델
class RtspCaptureModel {
  final int uid;
  final String tag;
  final String rtspAddress;
  final String? lastImagePath;

  RtspCaptureModel({
    required this.uid,
    required this.tag,
    required this.rtspAddress,
    this.lastImagePath,
  });

  /// JSON에서 모델 생성
  factory RtspCaptureModel.fromJson(Map<String, dynamic> json) {
    return RtspCaptureModel(
      uid: json['uid'] as int,
      tag: json['tag'] as String,
      rtspAddress: json['rtsp_address'] as String,
      lastImagePath: json['last_image_path'] as String?,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'tag': tag,
      'rtsp_address': rtspAddress,
      'last_image_path': lastImagePath,
    };
  }

  /// API 응답용 JSON (snake_case 유지)
  Map<String, dynamic> toApiJson() {
    return {
      'uid': uid,
      'tag': tag,
      'rtsp_address': rtspAddress,
      'last_image_path': lastImagePath,
    };
  }

  /// 복사본 생성 (일부 필드 변경)
  RtspCaptureModel copyWith({
    int? uid,
    String? tag,
    String? rtspAddress,
    String? lastImagePath,
  }) {
    return RtspCaptureModel(
      uid: uid ?? this.uid,
      tag: tag ?? this.tag,
      rtspAddress: rtspAddress ?? this.rtspAddress,
      lastImagePath: lastImagePath ?? this.lastImagePath,
    );
  }

  @override
  String toString() {
    return 'RtspCaptureModel(uid: $uid, tag: $tag, rtspAddress: $rtspAddress, lastImagePath: $lastImagePath)';
  }
}

/// RTSP 캡처 생성/업데이트 요청 모델
class RtspCaptureRequest {
  final String tag;
  final String rtspAddress;
  final String? lastImagePath;

  RtspCaptureRequest({
    required this.tag,
    required this.rtspAddress,
    this.lastImagePath,
  });

  /// JSON에서 요청 모델 생성
  factory RtspCaptureRequest.fromJson(Map<String, dynamic> json) {
    return RtspCaptureRequest(
      tag: json['tag'] as String,
      rtspAddress: json['rtsp_address'] as String,
      lastImagePath: json['last_image_path'] as String?,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'rtsp_address': rtspAddress,
      'last_image_path': lastImagePath,
    };
  }

  /// 유효성 검증
  bool isValid() {
    return tag.isNotEmpty && rtspAddress.isNotEmpty;
  }

  /// RTSP 주소 형식 검증
  bool isValidRtspAddress() {
    try {
      final uri = Uri.parse(rtspAddress);
      return uri.scheme == 'rtsp' && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// RTSP 캡처 응답 모델 (API 응답용)
class RtspCaptureResponse {
  final bool success;
  final String message;
  final RtspCaptureModel? data;
  final String? errorCode;

  RtspCaptureResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'success': success,
      'message': message,
    };

    if (data != null) {
      json['data'] = data!.toApiJson();
    }

    if (errorCode != null) {
      json['errorCode'] = errorCode;
    }

    return json;
  }
}

/// RTSP 캡처 목록 응답 모델
class RtspCaptureListResponse {
  final bool success;
  final String message;
  final List<RtspCaptureModel>? data;
  final Map<String, dynamic>? metadata;

  RtspCaptureListResponse({
    required this.success,
    required this.message,
    this.data,
    this.metadata,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'success': success,
      'message': message,
    };

    if (data != null) {
      json['data'] = data!.map((item) => item.toApiJson()).toList();
    }

    if (metadata != null) {
      json['metadata'] = metadata;
    }

    return json;
  }
}

/// RTSP 캡처 이미지 응답 모델
class RtspImageResponse {
  final bool success;
  final String message;
  final String? tag;
  final String? imagePath;
  final String? imageUrl;
  final String? rtspAddress;
  final String? errorCode;

  RtspImageResponse({
    required this.success,
    required this.message,
    this.tag,
    this.imagePath,
    this.imageUrl,
    this.rtspAddress,
    this.errorCode,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'success': success,
      'message': message,
    };

    if (tag != null || imagePath != null || rtspAddress != null) {
      json['data'] = <String, dynamic>{
        if (tag != null) 'tag': tag,
        if (imagePath != null) 'image_path': imagePath,
        if (imageUrl != null) 'image_url': imageUrl,
        if (rtspAddress != null) 'rtsp_address': rtspAddress,
      };
    }

    if (errorCode != null) {
      json['errorCode'] = errorCode;
    }

    return json;
  }
}

/// RTSP 캡처 통계 모델
class RtspCaptureStats {
  final int uniqueCameras;
  final int totalTags;
  final int capturedImages;

  RtspCaptureStats({
    required this.uniqueCameras,
    required this.totalTags,
    required this.capturedImages,
  });

  /// JSON에서 생성
  factory RtspCaptureStats.fromJson(Map<String, dynamic> json) {
    return RtspCaptureStats(
      uniqueCameras: json['unique_cameras'] as int? ?? 0,
      totalTags: json['total_tags'] as int? ?? 0,
      capturedImages: json['captured_images'] as int? ?? 0,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'unique_cameras': uniqueCameras,
      'total_tags': totalTags,
      'captured_images': capturedImages,
      'efficiency_ratio': uniqueCameras > 0
          ? (totalTags / uniqueCameras).toStringAsFixed(2)
          : '0.00',
    };
  }
}

/// RTSP 캡처 상수
class RtspCaptureConstants {
  // 에러 코드
  static const String errorInvalidTag = 'INVALID_TAG';
  static const String errorInvalidRtsp = 'INVALID_RTSP_ADDRESS';
  static const String errorTagNotFound = 'TAG_NOT_FOUND';
  static const String errorImageNotFound = 'IMAGE_NOT_FOUND';
  static const String errorCaptureNotFound = 'CAPTURE_NOT_FOUND';
  static const String errorTagExists = 'TAG_ALREADY_EXISTS';
  static const String errorDatabaseOperation = 'DATABASE_OPERATION_FAILED';
  static const String errorCaptureFailed = 'CAPTURE_FAILED';
  static const String errorFFmpegNotFound = 'FFMPEG_NOT_FOUND';
  static const String errorFileOperation = 'FILE_OPERATION_FAILED';

  // 성공 메시지
  static const String msgCaptureCreated = 'RTSP 캡처 설정이 생성되었습니다.';
  static const String msgCaptureUpdated = 'RTSP 캡처 설정이 업데이트되었습니다.';
  static const String msgCaptureDeleted = 'RTSP 캡처 설정이 삭제되었습니다.';
  static const String msgImageRetrieved = '캡처 이미지 조회 완료';
  static const String msgListRetrieved = 'RTSP 캡처 목록 조회 완료';
  static const String msgCaptureTriggered = '수동 캡처가 시작되었습니다.';

  // 에러 메시지
  static const String msgInvalidTag = '유효하지 않은 태그입니다.';
  static const String msgInvalidRtsp = '유효하지 않은 RTSP 주소 형식입니다.';
  static const String msgTagNotFound = '해당 태그를 찾을 수 없습니다.';
  static const String msgImageNotFound = '캡처된 이미지가 없습니다.';
  static const String msgTagExists = '이미 존재하는 태그입니다.';
  static const String msgDatabaseError = '데이터베이스 작업 중 오류가 발생했습니다.';
  static const String msgCaptureFailed = '이미지 캡처에 실패했습니다.';
  static const String msgFFmpegNotFound = 'FFmpeg가 설치되어 있지 않습니다.';
}
