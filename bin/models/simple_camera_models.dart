/// 단순한 카메라 모델 클래스
/// 
/// 카메라 기본 정보와 이미지 링크 관리를 위한 최소한의 모델

/// 카메라 정보 모델
class Camera {
  final int? uid;
  final String tag;
  final String cameraName;
  final String? imageLink;

  /// 카메라 정보 생성자
  Camera({
    this.uid,
    required this.tag,
    required this.cameraName,
    this.imageLink,
  });

  /// JSON에서 Camera 객체 생성
  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      uid: json['uid'] as int?,
      tag: json['tag'] as String,
      cameraName: json['camera_name'] as String,
      imageLink: json['image_link'] as String?,
    );
  }

  /// Camera 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'tag': tag,
      'camera_name': cameraName,
      'image_link': imageLink,
    };
  }

  @override
  String toString() {
    return 'Camera(uid: $uid, tag: $tag, cameraName: $cameraName, imageLink: $imageLink)';
  }
}

/// 카메라 등록/수정 요청 모델
class CameraRequest {
  final String tag;
  final String cameraName;

  /// 카메라 요청 생성자
  CameraRequest({
    required this.tag,
    required this.cameraName,
  });

  /// JSON에서 CameraRequest 객체 생성
  factory CameraRequest.fromJson(Map<String, dynamic> json) {
    return CameraRequest(
      tag: json['tag'] as String,
      cameraName: json['camera_name'] as String,
    );
  }

  /// CameraRequest 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'camera_name': cameraName,
    };
  }
}

/// 카메라 서비스 응답 모델
class CameraServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  /// 카메라 서비스 응답 생성자
  CameraServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  /// 성공 응답 생성
  factory CameraServiceResponse.success(String message, T data) {
    return CameraServiceResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  /// 실패 응답 생성
  factory CameraServiceResponse.error(String message, String errorCode) {
    return CameraServiceResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  /// 응답을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      if (errorCode != null) 'error_code': errorCode,
    };
  }
}



