/// 중앙 대시보드 비즈니스 로직 서비스
///
/// 주차장 전체 현황 및 통계 데이터 처리를 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/central_dashboard_models.dart';
import '../data/manage_address.dart';

class CentralDashboardService {
  final ManageAddress manageAddress;

  CentralDashboardService({required this.manageAddress});

  /// 중앙 대시보드 데이터 조회
  ///
  /// 주차장 전체 통계, 층별 정보, 타입별 정보, 점유율 데이터를 병렬로 조회
  Future<CentralDashboardServiceResponse> getDashboardData() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return CentralDashboardServiceResponse(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};

      // 병렬로 기본 데이터 조회
      final futures = await Future.wait([
        _getUsedLotTypes(url, headers),
        _getParkingStatistics(url, headers),
        _getActiveFloors(url, headers),
      ]);

      final usedLotTypes = futures[0] as List<int>;
      final statistics = futures[1] as ParkingStatistics;
      final floors = futures[2] as List<String>;

      // 층별/타입별 점유율 데이터 조회
      final occupancyData =
          await _getOccupancyData(url, headers, floors, usedLotTypes);

      final dashboardData = CentralDashboardResponse(
        statistics: statistics,
        floors: floors,
        lotTypes: usedLotTypes,
        occupancyData: occupancyData,
      );

      return CentralDashboardServiceResponse(
        success: true,
        message: '중앙 대시보드 데이터 조회 완료',
        data: dashboardData,
      );
    } catch (e, stackTrace) {
      print('CentralDashboardService.getDashboardData 오류: $e');
      print('스택 트레이스: $stackTrace');

      return CentralDashboardServiceResponse(
        success: false,
        message: '중앙 대시보드 데이터 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 사용 중인 주차 타입 조회
  Future<List<int>> _getUsedLotTypes(
      String url, Map<String, String> headers) async {
    final body = {
      "transaction": [
        {"query": "#central_usedLot"}
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    final resultSet = data['results'][0]['resultSet'] as List;

    return resultSet
        .where((item) => item['uid'] != null)
        .map<int>((item) => item['uid'] as int)
        .toList();
  }

  /// 주차장 전체 통계 조회
  Future<ParkingStatistics> _getParkingStatistics(
      String url, Map<String, String> headers) async {
    final futures = await Future.wait([
      _getTotalParkingLots(url, headers),
      _getUsedParkingLots(url, headers),
    ]);

    return ParkingStatistics(
      totalSpaces: futures[0] as int,
      usedSpaces: futures[1] as int,
    );
  }

  /// 전체 주차 공간 수 조회
  Future<int> _getTotalParkingLots(
      String url, Map<String, String> headers) async {
    final body = {
      "transaction": [
        {"query": "#allParkingLot"}
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    return data['results'][0]['resultSet'][0]['count'] as int;
  }

  /// 사용 중인 주차 공간 수 조회
  Future<int> _getUsedParkingLots(
      String url, Map<String, String> headers) async {
    final body = {
      "transaction": [
        {"query": "#usedParkingLot"}
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    return data['results'][0]['resultSet'][0]['count'] as int;
  }

  /// 활성 층 정보 조회
  Future<List<String>> _getActiveFloors(
      String url, Map<String, String> headers) async {
    final body = {
      "transaction": [
        {"query": "#central_usedfloor"}
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    final resultSet = data['results'][0]['resultSet'] as List;

    return resultSet.map<String>((item) => item['floor'] as String).toList();
  }

  /// 층별/타입별 점유율 데이터 조회
  Future<List<ParkingOccupancy>> _getOccupancyData(
      String url,
      Map<String, String> headers,
      List<String> floors,
      List<int> lotTypes) async {
    final List<ParkingOccupancy> occupancyData = [];

    // 배치 처리를 위한 futures 리스트
    final List<Future<ParkingOccupancy>> futures = [];

    for (final floor in floors) {
      for (final lotType in lotTypes) {
        futures.add(_getFloorLotTypeCount(url, headers, floor, lotType));
      }
    }

    // 병렬 처리로 모든 데이터 조회
    final results = await Future.wait(futures);
    occupancyData.addAll(results);

    return occupancyData;
  }

  /// 특정 층/타입의 주차 공간 수 조회
  Future<ParkingOccupancy> _getFloorLotTypeCount(String url,
      Map<String, String> headers, String floor, int lotType) async {
    final body = {
      "transaction": [
        {
          "query": "#count",
          "values": {'lot_type': lotType, 'floor': floor}
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    final resultSet = data['results'][0]['resultSet'];
    final count = resultSet.isNotEmpty ? resultSet[0]['count'] ?? 0 : 0;

    return ParkingOccupancy(
      lotType: lotType,
      floor: floor,
      count: count,
    );
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) return false;

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#central_usedLot"}
        ]
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('CentralDashboardService 상태 확인 실패: $e');
      return false;
    }
  }
}
