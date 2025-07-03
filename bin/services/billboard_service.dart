/// 전광판 비즈니스 로직 서비스
///
/// 전광판 표시 정보 조회 및 부분 시스템 제어를 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/billboard_models.dart';
import '../data/manage_address.dart';

class BillboardService {
  final ManageAddress manageAddress;

  BillboardService({required this.manageAddress});

  /// 층별 주차 정보 조회
  ///
  /// 특정 층의 주차 타입별 가용 공간 정보를 조회
  Future<BillboardServiceResponse<BillboardDisplayData>> getFloorParkingInfo(
      FloorParkingInfoRequest request) async {
    try {
      // 층 정보 유효성 검사
      if (request.floor.isEmpty) {
        return BillboardServiceResponse<BillboardDisplayData>(
          success: false,
          message: '층 정보가 제공되지 않았습니다.',
          error: 'MISSING_FLOOR',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return BillboardServiceResponse<BillboardDisplayData>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {
            "query": "#floor",
            "values": {"floor": request.floor}
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final decodedResponse = jsonDecode(response.body);
      final resultSet = decodedResponse['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return BillboardServiceResponse<BillboardDisplayData>(
          success: false,
          message: '해당 층의 주차 정보를 찾을 수 없습니다.',
          error: 'FLOOR_NOT_FOUND',
        );
      }

      // 주차 타입별 정보 변환
      final parkingInfo =
          resultSet.map((item) => FloorParkingTypeInfo.fromJson(item)).toList();

      // 전체 가용 공간 계산
      final totalAvailable = parkingInfo
          .map((info) => info.count)
          .fold(0, (prev, count) => prev + count);

      final displayData = BillboardDisplayData(
        floor: request.floor,
        parkingInfo: parkingInfo,
        totalAvailable: totalAvailable,
      );

      return BillboardServiceResponse<BillboardDisplayData>(
        success: true,
        message: '층별 주차 정보 조회 완료',
        data: displayData,
      );
    } catch (e, stackTrace) {
      print('BillboardService.getFloorParkingInfo 오류: $e');
      print('스택 트레이스: $stackTrace');

      return BillboardServiceResponse<BillboardDisplayData>(
        success: false,
        message: '층별 주차 정보 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 부분 시스템 제어
  ///
  /// 설정된 엔드포인트들에 대해 setOverride 값 전송
  Future<BillboardServiceResponse<PartSystemControlResult>> controlPartSystem(
      PartSystemControlRequest request) async {
    try {
      // 값 유효성 검사
      if (request.value.isEmpty) {
        return BillboardServiceResponse<PartSystemControlResult>(
          success: false,
          message: '제어 값이 제공되지 않았습니다.',
          error: 'MISSING_VALUE',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return BillboardServiceResponse<PartSystemControlResult>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};

      // 활성 엔드포인트 조회
      final endpoints = await _getActiveEndpoints(url, headers);
      if (endpoints.isEmpty) {
        return BillboardServiceResponse<PartSystemControlResult>(
          success: false,
          message: '활성화된 엔드포인트가 없습니다.',
          error: 'NO_ACTIVE_ENDPOINTS',
        );
      }

      // 각 엔드포인트에 제어 명령 전송
      int successCount = 0;
      final controlResults = <Future<bool>>[];

      for (final endpoint in endpoints) {
        controlResults
            .add(_sendControlCommand(endpoint, request.value, headers));
      }

      // 병렬 처리로 모든 제어 명령 실행
      final results = await Future.wait(controlResults);
      successCount = results.where((success) => success).length;

      final controlResult = PartSystemControlResult(
        endpoints: endpoints,
        value: request.value,
        successCount: successCount,
        totalCount: endpoints.length,
      );

      final isFullSuccess = successCount == endpoints.length;

      return BillboardServiceResponse<PartSystemControlResult>(
        success: isFullSuccess,
        message: isFullSuccess
            ? '모든 부분 시스템 제어 완료'
            : '일부 부분 시스템 제어 실패 ($successCount/${endpoints.length})',
        data: controlResult,
      );
    } catch (e, stackTrace) {
      print('BillboardService.controlPartSystem 오류: $e');
      print('스택 트레이스: $stackTrace');

      return BillboardServiceResponse<PartSystemControlResult>(
        success: false,
        message: '부분 시스템 제어 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 활성 엔드포인트 목록 조회
  Future<List<String>> _getActiveEndpoints(
      String url, Map<String, String> headers) async {
    final body = {
      "transaction": [
        {"query": "#get_alive"}
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final decodedResponse = jsonDecode(response.body);
    final resultSet = decodedResponse['results'][0]['resultSet'][0]['value'];

    List<String> endpoints = [];
    if (resultSet is String) {
      // 중괄호 제거 및 파싱
      final trimmed = resultSet.substring(1, resultSet.length - 1);
      endpoints = trimmed
          .split(',')
          .map((e) => e.trim().replaceAll("'", ""))
          .where((endpoint) => endpoint.isNotEmpty)
          .toList();
    } else if (resultSet is Iterable) {
      endpoints = resultSet.map((e) => e.toString()).toList();
    }

    return endpoints;
  }

  /// 개별 엔드포인트에 제어 명령 전송
  Future<bool> _sendControlCommand(
      String endpoint, String value, Map<String, String> headers) async {
    try {
      final overrideUrl = "$endpoint/setOverride";
      final overrideBody = jsonEncode({"value": value});

      final response = await http
          .post(
            Uri.parse(overrideUrl),
            headers: headers,
            body: overrideBody,
          )
          .timeout(Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('엔드포인트 $endpoint 제어 실패: $e');
      return false;
    }
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) return false;

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#get_alive"}
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
      print('BillboardService 상태 확인 실패: $e');
      return false;
    }
  }
}
