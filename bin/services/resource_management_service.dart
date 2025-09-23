/// 리소스 관리 서비스
///
/// 주차장 리소스 정보 조회 및 관리를 담당하는 서비스

import 'dart:convert';
import '../data/manage_address.dart';
import '../routes/receive_enginedata_send_to_dartserver.dart';

/// 서비스 응답 모델 (database_management_service.dart와 동일한 구조)
class ServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// 주차장 리소스 정보 모델
class ParkingResourceInfo {
  final int totalSpaces;
  final int occupiedSpaces;
  final int availableSpaces;
  final double occupancyRate;
  final List<dynamic> parkingLotData;
  final DateTime lastUpdated;

  ParkingResourceInfo({
    required this.totalSpaces,
    required this.occupiedSpaces,
    required this.availableSpaces,
    required this.occupancyRate,
    required this.parkingLotData,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_spaces': totalSpaces,
      'occupied_spaces': occupiedSpaces,
      'available_spaces': availableSpaces,
      'occupancy_rate': occupancyRate,
      'parking_lot_data': parkingLotData,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// 리소스 상태 모델
class ResourceStatus {
  final bool engineDbConnected;
  final bool displayDbConnected;
  final DateTime lastDataUpdate;
  final int dataProcessingErrors;
  final String status;

  ResourceStatus({
    required this.engineDbConnected,
    required this.displayDbConnected,
    required this.lastDataUpdate,
    required this.dataProcessingErrors,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'engine_db_connected': engineDbConnected,
      'display_db_connected': displayDbConnected,
      'last_data_update': lastDataUpdate.toIso8601String(),
      'data_processing_errors': dataProcessingErrors,
      'status': status,
    };
  }
}

class ResourceManagementService {
  final ManageAddress _manageAddress;
  List<dynamic>? _cachedParkingLotData;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ResourceManagementService({required ManageAddress manageAddress})
      : _manageAddress = manageAddress;

  /// 주차장 리소스 정보 조회
  Future<ServiceResponse<ParkingResourceInfo>> getParkingResources(
      bool includeDetails) async {
    try {
      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;
      final displayDbLPR = _manageAddress.displayDbLPR;

      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DISPLAY_DB_ADDRESS_NOT_SET',
        );
      }

      // 엔진 데이터 처리를 통해 주차장 데이터 가져오기
      final parkingLotData = await receiveEnginedataSendToDartserver(
        engineDbAddr,
        displayDbAddr,
        displayDbLPR,
        DateTime.now(),
      );

      // 통계 계산
      final totalSpaces = parkingLotData.length;
      final occupiedSpaces = parkingLotData
          .where((data) => data.toString().contains('occupied'))
          .length;
      final availableSpaces = totalSpaces - occupiedSpaces;
      final occupancyRate =
          totalSpaces > 0 ? (occupiedSpaces / totalSpaces) * 100 : 0.0;

      final resourceInfo = ParkingResourceInfo(
        totalSpaces: totalSpaces,
        occupiedSpaces: occupiedSpaces,
        availableSpaces: availableSpaces,
        occupancyRate: double.parse(occupancyRate.toStringAsFixed(2)),
        parkingLotData: includeDetails ? parkingLotData : [],
        lastUpdated: DateTime.now(),
      );

      return ServiceResponse(
        success: true,
        message: '주차장 리소스 정보를 성공적으로 조회했습니다.',
        data: resourceInfo,
      );
    } catch (e) {
      print('ResourceManagementService.getParkingResources 오류: $e');
      return ServiceResponse(
        success: false,
        message: '주차장 리소스 정보 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 주차장 목록 조회
  Future<ServiceResponse<List<dynamic>>> getParkingLotList(
      bool forceRefresh) async {
    try {
      // 캐시 확인
      if (!forceRefresh && _isCacheValid()) {
        return ServiceResponse(
          success: true,
          message: '캐시된 주차장 목록을 반환합니다.',
          data: _cachedParkingLotData!,
        );
      }

      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;
      final displayDbLPR = _manageAddress.displayDbLPR;

      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DISPLAY_DB_ADDRESS_NOT_SET',
        );
      }

      // 엔진 데이터 처리를 통해 주차장 데이터 가져오기
      final parkingLotData = await receiveEnginedataSendToDartserver(
        engineDbAddr,
        displayDbAddr,
        displayDbLPR,
        DateTime.now(),
      );

      // 캐시 업데이트
      _cachedParkingLotData = parkingLotData;
      _lastCacheUpdate = DateTime.now();

      return ServiceResponse(
        success: true,
        message: '주차장 목록을 성공적으로 조회했습니다.',
        data: parkingLotData,
      );
    } catch (e) {
      print('ResourceManagementService.getParkingLotList 오류: $e');
      return ServiceResponse(
        success: false,
        message: '주차장 목록 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 원시 데이터 형태로 주차장 목록 조회 (레거시 호환)
  Future<ServiceResponse<String>> getParkingLotListRaw() async {
    try {
      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;
      final displayDbLPR = _manageAddress.displayDbLPR;

      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DISPLAY_DB_ADDRESS_NOT_SET',
        );
      }

      // 엔진 데이터 처리를 통해 주차장 데이터 가져오기
      final parkingLotData = await receiveEnginedataSendToDartserver(
        engineDbAddr,
        displayDbAddr,
        displayDbLPR,
        DateTime.now(),
      );

      // 레거시 형식으로 변환: "start,data1,data2,data3..."
      final rawData = 'start,${parkingLotData.join(',')}';

      return ServiceResponse(
        success: true,
        message: '원시 형태의 주차장 목록을 성공적으로 조회했습니다.',
        data: rawData,
      );
    } catch (e) {
      print('ResourceManagementService.getParkingLotListRaw 오류: $e');
      return ServiceResponse(
        success: false,
        message: '원시 형태의 주차장 목록 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 리소스 정보 새로고침
  Future<ServiceResponse<Map<String, dynamic>>> refreshResources(
      Map<String, dynamic>? refreshConfig) async {
    try {
      final forceRefresh = refreshConfig?['force_refresh'] == true;
      final clearCache = refreshConfig?['clear_cache'] == true;

      if (clearCache) {
        _cachedParkingLotData = null;
        _lastCacheUpdate = null;
      }

      // 새로운 데이터 가져오기
      final parkingLotResponse = await getParkingLotList(forceRefresh);
      final resourceResponse = await getParkingResources(false);

      final refreshResult = {
        'parking_lot_refresh': {
          'success': parkingLotResponse.success,
          'message': parkingLotResponse.message,
          'data_count': parkingLotResponse.data?.length ?? 0,
        },
        'resource_refresh': {
          'success': resourceResponse.success,
          'message': resourceResponse.message,
          'total_spaces': resourceResponse.data?.totalSpaces ?? 0,
        },
        'cache_cleared': clearCache,
        'refreshed_at': DateTime.now().toIso8601String(),
      };

      final allSuccess = parkingLotResponse.success && resourceResponse.success;

      return ServiceResponse(
        success: allSuccess,
        message: allSuccess
            ? '리소스 정보가 성공적으로 새로고침되었습니다.'
            : '리소스 정보 새로고침 중 일부 오류가 발생했습니다.',
        data: refreshResult,
      );
    } catch (e) {
      print('ResourceManagementService.refreshResources 오류: $e');
      return ServiceResponse(
        success: false,
        message: '리소스 정보 새로고침 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 리소스 상태 조회
  Future<ServiceResponse<ResourceStatus>> getResourceStatus() async {
    try {
      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;

      // 데이터베이스 연결 상태 확인
      final engineDbConnected = engineDbAddr != null && engineDbAddr.isNotEmpty;
      final displayDbConnected =
          displayDbAddr != null && displayDbAddr.isNotEmpty;

      // 마지막 데이터 업데이트 시간
      final lastDataUpdate =
          _lastCacheUpdate ?? DateTime.now().subtract(const Duration(hours: 1));

      // 상태 결정
      String status;
      if (engineDbConnected && displayDbConnected) {
        status = 'healthy';
      } else if (displayDbConnected) {
        status = 'partial';
      } else {
        status = 'unhealthy';
      }

      final resourceStatus = ResourceStatus(
        engineDbConnected: engineDbConnected,
        displayDbConnected: displayDbConnected,
        lastDataUpdate: lastDataUpdate,
        dataProcessingErrors: 0, // TODO: 실제 에러 카운트 구현
        status: status,
      );

      return ServiceResponse(
        success: true,
        message: '리소스 상태를 성공적으로 조회했습니다.',
        data: resourceStatus,
      );
    } catch (e) {
      print('ResourceManagementService.getResourceStatus 오류: $e');
      return ServiceResponse(
        success: false,
        message: '리소스 상태 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return false;
      }

      // 간단한 데이터 가져오기 테스트
      final testResponse = await getParkingLotList(false);
      return testResponse.success;
    } catch (e) {
      print('ResourceManagementService.isServiceHealthy 오류: $e');
      return false;
    }
  }

  /// 캐시 유효성 확인
  bool _isCacheValid() {
    if (_cachedParkingLotData == null || _lastCacheUpdate == null) {
      return false;
    }

    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheUpdate!);
    return cacheAge < _cacheValidDuration;
  }
}
