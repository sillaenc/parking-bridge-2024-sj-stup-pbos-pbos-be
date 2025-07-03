/// LED 계산 관련 데이터 모델
///
/// LED 표시등 계산 및 카메라별 상태 정보를 위한 데이터 구조들을 정의

/// 카메라 상태 정보
class CameraStatusInfo {
  final String camera;
  final String color;

  CameraStatusInfo({
    required this.camera,
    required this.color,
  });

  factory CameraStatusInfo.fromCalculation(
      String camera, int tagCount, int isUsedCount) {
    final color = tagCount == isUsedCount ? "red" : "green";
    final shortCamera =
        camera.length >= 3 ? camera.substring(camera.length - 3) : camera;

    return CameraStatusInfo(
      camera: shortCamera,
      color: color,
    );
  }

  Map<String, dynamic> toJson() => {
        'camera': camera,
        'color': color,
      };
}

/// LED 계산 응답 데이터
class LedCalculationResponseData {
  final List<CameraStatusInfo> cameraStatuses;
  final int totalCameras;
  final int redCount;
  final int greenCount;

  LedCalculationResponseData({
    required this.cameraStatuses,
    required this.totalCameras,
    required this.redCount,
    required this.greenCount,
  });

  Map<String, dynamic> toJson() => {
        'camera_statuses': cameraStatuses.map((e) => e.toJson()).toList(),
        'total_cameras': totalCameras,
        'red_count': redCount,
        'green_count': greenCount,
        'red_percentage': totalCameras > 0
            ? (redCount / totalCameras * 100).toStringAsFixed(1)
            : '0.0',
        'green_percentage': totalCameras > 0
            ? (greenCount / totalCameras * 100).toStringAsFixed(1)
            : '0.0',
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// LED 계산 서비스 응답
class LedCalculationServiceResponse {
  final bool success;
  final String message;
  final LedCalculationResponseData? data;
  final String? error;

  LedCalculationServiceResponse({
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
      result['data'] = data!.toJson();
    }

    if (error != null) {
      result['error'] = error;
    }

    return result;
  }
}
