/// 시스템 상태 확인 비즈니스 로직 서비스
///
/// 시스템 생존 확인 및 네트워크 상태 모니터링을 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/system_health_models.dart';
import '../data/manage_address.dart';

class SystemHealthService {
  final ManageAddress manageAddress;

  SystemHealthService({required this.manageAddress});

  /// 시스템 상태 확인
  ///
  /// 등록된 모든 시스템의 생존 상태를 확인
  Future<SystemHealthServiceResponse> checkSystemHealth() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return SystemHealthServiceResponse(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#check_alive"}
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final decodedResponse = jsonDecode(utf8DecodedBody);

      final resultSet = decodedResponse['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return SystemHealthServiceResponse(
          success: false,
          message: '등록된 시스템이 없습니다.',
          error: 'NO_SYSTEMS_REGISTERED',
        );
      }

      // 시스템 정보 파싱
      final systems =
          resultSet.map((item) => SystemAliveInfo.fromJson(item)).toList();

      final onlineSystems = systems.where((system) => system.isAlright).length;
      final offlineSystems = systems.length - onlineSystems;

      final responseData = SystemHealthResponseData(
        systems: systems,
        totalSystems: systems.length,
        onlineSystems: onlineSystems,
        offlineSystems: offlineSystems,
      );

      return SystemHealthServiceResponse(
        success: true,
        message: '시스템 상태 확인 완료 (온라인: $onlineSystems, 오프라인: $offlineSystems)',
        data: responseData,
      );
    } catch (e, stackTrace) {
      print('SystemHealthService.checkSystemHealth 오류: $e');
      print('스택 트레이스: $stackTrace');

      return SystemHealthServiceResponse(
        success: false,
        message: '시스템 상태 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 특정 시스템 상태 확인
  ///
  /// 시스템 이름으로 특정 시스템의 상태만 확인
  Future<SystemHealthServiceResponse> checkSpecificSystemHealth(
      String systemName) async {
    try {
      final fullHealthResponse = await checkSystemHealth();

      if (!fullHealthResponse.success || fullHealthResponse.data == null) {
        return fullHealthResponse;
      }

      final targetSystem = fullHealthResponse.data!.systems
          .where((system) =>
              system.name.toLowerCase().contains(systemName.toLowerCase()))
          .toList();

      if (targetSystem.isEmpty) {
        return SystemHealthServiceResponse(
          success: false,
          message: '지정된 시스템을 찾을 수 없습니다: $systemName',
          error: 'SYSTEM_NOT_FOUND',
        );
      }

      final onlineSystems =
          targetSystem.where((system) => system.isAlright).length;
      final offlineSystems = targetSystem.length - onlineSystems;

      final responseData = SystemHealthResponseData(
        systems: targetSystem,
        totalSystems: targetSystem.length,
        onlineSystems: onlineSystems,
        offlineSystems: offlineSystems,
      );

      return SystemHealthServiceResponse(
        success: true,
        message: '시스템 "$systemName" 상태 확인 완료',
        data: responseData,
      );
    } catch (e, stackTrace) {
      print('SystemHealthService.checkSpecificSystemHealth 오류: $e');
      print('스택 트레이스: $stackTrace');

      return SystemHealthServiceResponse(
        success: false,
        message: '특정 시스템 상태 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
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
          {"query": "#check_alive"}
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
      print('SystemHealthService 상태 확인 실패: $e');
      return false;
    }
  }
}
