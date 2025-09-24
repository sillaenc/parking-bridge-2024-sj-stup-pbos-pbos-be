import '../models/simple_camera_models.dart';
import '../services/database_client.dart';

/// 단순한 카메라 관리 서비스
///
/// 카메라 정보 조회와 이미지 경로 반환만 담당하는 서비스
class SimpleCameraService {
  final DatabaseClient _databaseClient;

  /// 카메라 서비스 생성자
  SimpleCameraService({required DatabaseClient databaseClient})
      : _databaseClient = databaseClient;

  /// 모든 카메라 조회
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// Returns: 카메라 목록과 응답 정보
  Future<CameraServiceResponse<List<Camera>>> getAllCameras(
    String databaseUrl,
  ) async {
    try {
      final resultSet = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_Camera_All",
      );

      final cameras =
          resultSet.map<Camera>((data) => Camera.fromJson(data)).toList();

      return CameraServiceResponse.success(
        '카메라 목록이 성공적으로 조회되었습니다.',
        cameras,
      );
    } catch (e) {
      print('Error getting all cameras: $e');

      // pb.yaml에 카메라 테이블이 없는 경우
      if (e.toString().contains('Query failed with status code: 400')) {
        return CameraServiceResponse.error(
          'pb.yaml에 tb_camera 테이블과 #S_Camera_All 쿼리를 추가해주세요.',
          'CAMERA_TABLE_NOT_FOUND',
        );
      }

      return CameraServiceResponse.error(
        '카메라 목록 조회 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 태그로 카메라 조회
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// [tag] 카메라 태그
  /// Returns: 카메라 정보와 응답 정보
  Future<CameraServiceResponse<Camera?>> getCameraByTag(
    String databaseUrl,
    String tag,
  ) async {
    try {
      final resultSet = await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#S_Camera_ByTag",
        values: {'tag': tag},
      );

      if (resultSet.isEmpty) {
        return CameraServiceResponse.error(
          '해당 태그의 카메라를 찾을 수 없습니다.',
          'CAMERA_NOT_FOUND',
        );
      }

      final camera = Camera.fromJson(resultSet.first);
      return CameraServiceResponse.success(
        '카메라 정보를 찾았습니다.',
        camera,
      );
    } catch (e) {
      print('Error getting camera by tag: $e');

      // pb.yaml에 카메라 테이블이 없는 경우
      if (e.toString().contains('Query failed with status code: 400')) {
        return CameraServiceResponse.error(
          'pb.yaml에 tb_camera 테이블과 #S_Camera_ByTag 쿼리를 추가해주세요.',
          'CAMERA_TABLE_NOT_FOUND',
        );
      }

      return CameraServiceResponse.error(
        '카메라 조회 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 카메라 등록
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// [request] 카메라 등록 요청
  /// Returns: 등록 결과
  Future<CameraServiceResponse<bool>> createCamera(
    String databaseUrl,
    CameraRequest request,
  ) async {
    try {
      // 중복 태그 확인
      final existingCamera = await getCameraByTag(databaseUrl, request.tag);
      if (existingCamera.success) {
        return CameraServiceResponse.error(
          '이미 존재하는 태그입니다.',
          'TAG_ALREADY_EXISTS',
        );
      }

      // 카메라 등록
      await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#I_Camera",
        values: {
          'tag': request.tag,
          'camera_name': request.cameraName,
        },
      );

      return CameraServiceResponse.success(
        '카메라가 성공적으로 등록되었습니다.',
        true,
      );
    } catch (e) {
      print('Error creating camera: $e');
      return CameraServiceResponse.error(
        '카메라 등록 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 이미지 링크 업데이트 (Shell script에서 사용)
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// [tag] 카메라 태그
  /// [imagePath] 새 이미지 경로
  /// Returns: 업데이트 결과
  Future<CameraServiceResponse<bool>> updateImageLink(
    String databaseUrl,
    String tag,
    String imagePath,
  ) async {
    try {
      await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#U_Camera_ImageLink",
        values: {
          'tag': tag,
          'image_link': imagePath,
        },
      );

      return CameraServiceResponse.success(
        '이미지 링크가 업데이트되었습니다.',
        true,
      );
    } catch (e) {
      print('Error updating image link: $e');
      return CameraServiceResponse.error(
        '이미지 링크 업데이트 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 카메라 삭제
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// [tag] 삭제할 카메라 태그
  /// Returns: 삭제 결과
  Future<CameraServiceResponse<bool>> deleteCamera(
    String databaseUrl,
    String tag,
  ) async {
    try {
      // 카메라 존재 여부 확인
      final existingCamera = await getCameraByTag(databaseUrl, tag);
      if (!existingCamera.success) {
        return CameraServiceResponse.error(
          '해당 태그의 카메라를 찾을 수 없습니다.',
          'CAMERA_NOT_FOUND',
        );
      }

      // 카메라 삭제
      await _databaseClient.executeQuery(
        url: databaseUrl,
        queryId: "#D_Camera",
        values: {'tag': tag},
      );

      return CameraServiceResponse.success(
        '카메라가 성공적으로 삭제되었습니다.',
        true,
      );
    } catch (e) {
      print('Error deleting camera: $e');
      return CameraServiceResponse.error(
        '카메라 삭제 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 태그별 이미지 파일 경로 조회
  ///
  /// [databaseUrl] 데이터베이스 URL
  /// [tag] 카메라 태그
  /// Returns: 이미지 파일 경로
  Future<CameraServiceResponse<String?>> getCameraImagePath(
    String databaseUrl,
    String tag,
  ) async {
    try {
      final cameraResponse = await getCameraByTag(databaseUrl, tag);

      if (!cameraResponse.success || cameraResponse.data == null) {
        return CameraServiceResponse.error(
          '해당 태그의 카메라를 찾을 수 없습니다.',
          'CAMERA_NOT_FOUND',
        );
      }

      final imageLink = cameraResponse.data!.imageLink;

      if (imageLink == null || imageLink.isEmpty) {
        return CameraServiceResponse.error(
          '해당 카메라의 이미지가 없습니다.',
          'IMAGE_NOT_FOUND',
        );
      }

      return CameraServiceResponse.success(
        '이미지 경로를 조회했습니다.',
        imageLink,
      );
    } catch (e) {
      print('Error getting camera image path: $e');
      return CameraServiceResponse.error(
        '이미지 경로 조회 중 오류가 발생했습니다.',
        'DATABASE_ERROR',
      );
    }
  }

  /// 서비스 리소스 해제
  void dispose() {
    _databaseClient.dispose();
  }
}
