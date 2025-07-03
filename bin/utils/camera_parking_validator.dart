import '../models/camera_parking_models.dart';

/// 카메라 주차 표면 유효성 검사 유틸리티
class CameraParkingSurfaceValidator {
  /// 태그 유효성 검사
  static bool isValidTag(String tag) {
    if (tag.isEmpty) return false;
    if (tag.length > CameraParkingSurfaceConstants.maxTagLength) return false;

    // 태그는 영문, 숫자, 언더스코어, 하이픈만 허용
    final validTagPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validTagPattern.hasMatch(tag)) return false;

    return tag.trim().isNotEmpty;
  }

  /// 엔진 코드 유효성 검사
  static bool isValidEngineCode(String engineCode) {
    if (engineCode.isEmpty) return false;
    if (engineCode.length > CameraParkingSurfaceConstants.maxEngineCodeLength)
      return false;

    // 엔진 코드는 영문, 숫자만 허용
    final validEngineCodePattern = RegExp(r'^[a-zA-Z0-9]+$');
    if (!validEngineCodePattern.hasMatch(engineCode)) return false;

    return engineCode.trim().isNotEmpty;
  }

  /// URI 유효성 검사
  static bool isValidUri(String uri) {
    if (uri.isEmpty) return false;
    if (uri.length > CameraParkingSurfaceConstants.maxUriLength) return false;

    // 기본 URI 형식 검사
    try {
      final parsed = Uri.parse(uri);

      // 스키마가 http 또는 https인지 확인
      if (!['http', 'https'].contains(parsed.scheme)) {
        return false;
      }

      // 호스트가 있는지 확인
      if (parsed.host.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 카메라 주차 표면 생성 요청 종합 유효성 검사
  static CameraValidationResult validateCreateRequest(
      CreateCameraParkingSurfaceRequest request) {
    final errors = <String>[];

    if (!isValidTag(request.tag)) {
      errors.add(
          'Invalid tag format. Use only alphanumeric characters, underscores, and hyphens (max ${CameraParkingSurfaceConstants.maxTagLength} chars)');
    }

    if (!isValidEngineCode(request.engineCode)) {
      errors.add(
          'Invalid engine code format. Use only alphanumeric characters (max ${CameraParkingSurfaceConstants.maxEngineCodeLength} chars)');
    }

    if (!isValidUri(request.uri)) {
      errors.add(
          'Invalid URI format. Must be a valid HTTP/HTTPS URL (max ${CameraParkingSurfaceConstants.maxUriLength} chars)');
    }

    return CameraValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 카메라 주차 표면 업데이트 요청 종합 유효성 검사
  static CameraValidationResult validateUpdateRequest(
      UpdateCameraParkingSurfaceRequest request) {
    final errors = <String>[];

    if (!isValidTag(request.tag)) {
      errors.add(
          'Invalid tag format. Use only alphanumeric characters, underscores, and hyphens (max ${CameraParkingSurfaceConstants.maxTagLength} chars)');
    }

    if (!isValidEngineCode(request.engineCode)) {
      errors.add(
          'Invalid engine code format. Use only alphanumeric characters (max ${CameraParkingSurfaceConstants.maxEngineCodeLength} chars)');
    }

    if (!isValidUri(request.uri)) {
      errors.add(
          'Invalid URI format. Must be a valid HTTP/HTTPS URL (max ${CameraParkingSurfaceConstants.maxUriLength} chars)');
    }

    // beforeTag가 있는 경우 검증
    if (request.beforeTag != null && !isValidTag(request.beforeTag!)) {
      errors.add('Invalid before tag format');
    }

    return CameraValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 카메라 주차 표면 삭제 요청 종합 유효성 검사
  static CameraValidationResult validateDeleteRequest(
      DeleteCameraParkingSurfaceRequest request) {
    final errors = <String>[];

    if (!isValidTag(request.tag)) {
      errors.add('Invalid tag format');
    }

    return CameraValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 태그 중복 검사를 위한 헬퍼 메서드
  static bool isTagConflict(String newTag, String? oldTag) {
    if (oldTag == null) return false;
    return newTag != oldTag;
  }

  /// 태그 목록에서 중복 검사
  static bool isTagDuplicate(
      String tag, List<CameraParkingSurface> existingSurfaces,
      {String? excludeTag}) {
    return existingSurfaces.any((surface) =>
        surface.tag == tag &&
        (excludeTag == null || surface.tag != excludeTag));
  }

  /// URI 형식의 세부 검증 (포트, 경로 등)
  static Map<String, dynamic> analyzeUri(String uri) {
    try {
      final parsed = Uri.parse(uri);

      return {
        'isValid': true,
        'scheme': parsed.scheme,
        'host': parsed.host,
        'port': parsed.port,
        'path': parsed.path,
        'hasQuery': parsed.hasQuery,
        'hasFragment': parsed.hasFragment,
        'isSecure': parsed.scheme == 'https',
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': e.toString(),
      };
    }
  }

  /// 엔진 코드 패턴 추천
  static List<String> suggestEngineCodePatterns() {
    return [
      'CAM001',
      'CAM002',
      'CAM003',
      'ENG01',
      'ENG02',
      'ENG03',
      'ZONE1',
      'ZONE2',
      'ZONE3',
      'A001',
      'B001',
      'C001',
    ];
  }

  /// 태그 패턴 추천
  static List<String> suggestTagPatterns() {
    return [
      'parking-zone-1',
      'parking-zone-2',
      'camera_01',
      'camera_02',
      'surface-a',
      'surface-b',
      'zone_north',
      'zone_south',
      'entrance-cam',
      'exit-cam',
    ];
  }

  /// 일괄 유효성 검사 (여러 표면 동시 검증)
  static Map<String, CameraValidationResult> validateMultipleSurfaces(
      List<CreateCameraParkingSurfaceRequest> requests) {
    final results = <String, CameraValidationResult>{};
    final usedTags = <String>{};

    for (int i = 0; i < requests.length; i++) {
      final request = requests[i];
      final key = 'surface_$i';

      // 개별 유효성 검사
      final individualResult = validateCreateRequest(request);

      // 태그 중복 검사
      final errors = List<String>.from(individualResult.errors);
      if (usedTags.contains(request.tag)) {
        errors.add('Duplicate tag "${request.tag}" found in the same batch');
      } else {
        usedTags.add(request.tag);
      }

      results[key] = CameraValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
      );
    }

    return results;
  }
}
