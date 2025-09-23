/// 데이터베이스 관리 서비스
///
/// 엔진 DB 및 디스플레이 DB 설정 관리를 담당하는 서비스

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/manage_address.dart';

/// 서비스 응답 모델
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

/// 데이터베이스 설정 모델
class DatabaseConfig {
  final String? engineDb;
  final String? displayDb;
  final String? displayDbLPR;

  DatabaseConfig({
    this.engineDb,
    this.displayDb,
    this.displayDbLPR,
  });

  Map<String, dynamic> toJson() {
    return {
      'engineDb': engineDb,
      'displayDb': displayDb,
      'displayDbLPR': displayDbLPR,
    };
  }

  factory DatabaseConfig.fromJson(Map<String, dynamic> json) {
    return DatabaseConfig(
      engineDb: json['engineDb'] as String?,
      displayDb: json['displayDb'] as String?,
      displayDbLPR: json['displayDbLPR'] as String?,
    );
  }
}

class DatabaseManagementService {
  final ManageAddress _manageAddress;

  DatabaseManagementService({required ManageAddress manageAddress})
      : _manageAddress = manageAddress;

  /// 현재 데이터베이스 설정 조회
  Future<ServiceResponse<DatabaseConfig>> getDatabaseConfig() async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#S_TbDbSetting"}
        ]
      };

      final response = await http.post(
        Uri.parse(displayDbAddr),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final resultSet = responseData['results'][0]['resultSet'];

        if (resultSet.isNotEmpty) {
          final dbSettings = resultSet[0];
          final config = DatabaseConfig(
            engineDb: dbSettings['changeEngine'],
            displayDb: dbSettings['changeDisplay'],
            displayDbLPR: _manageAddress.displayDbLPR,
          );

          return ServiceResponse(
            success: true,
            message: '데이터베이스 설정을 성공적으로 조회했습니다.',
            data: config,
          );
        } else {
          return ServiceResponse(
            success: false,
            message: '데이터베이스 설정을 찾을 수 없습니다.',
            error: 'NO_DATABASE_CONFIG_FOUND',
          );
        }
      } else {
        return ServiceResponse(
          success: false,
          message: '데이터베이스 설정 조회에 실패했습니다.',
          error: 'DATABASE_QUERY_FAILED',
        );
      }
    } catch (e) {
      print('DatabaseManagementService.getDatabaseConfig 오류: $e');
      return ServiceResponse(
        success: false,
        message: '데이터베이스 설정 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 엔진 DB 설정 업데이트
  Future<ServiceResponse<String>> updateEngineDatabase(String engineDb) async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      // URL 유효성 검사
      if (!_isValidDatabaseUrl(engineDb)) {
        return ServiceResponse(
          success: false,
          message: '유효하지 않은 데이터베이스 URL입니다.',
          error: 'INVALID_DATABASE_URL',
        );
      }

      final headers = {'Content-Type': 'application/json'};

      // 현재 설정 조회
      final getBody = {
        "transaction": [
          {"query": "#S_TbDbSetting"}
        ]
      };

      final getResponse = await http.post(
        Uri.parse(displayDbAddr),
        headers: headers,
        body: jsonEncode(getBody),
      );

      if (getResponse.statusCode != 200) {
        return ServiceResponse(
          success: false,
          message: '현재 설정 조회에 실패했습니다.',
          error: 'DATABASE_QUERY_FAILED',
        );
      }

      // 설정 업데이트
      final updateBody = {
        "transaction": [
          {
            "statement": "#U_TbDbSetting",
            "values": {"changeEngine": engineDb}
          }
        ]
      };

      final updateResponse = await http.post(
        Uri.parse(displayDbAddr),
        headers: headers,
        body: jsonEncode(updateBody),
      );

      if (updateResponse.statusCode == 200) {
        // ManageAddress 업데이트
        _manageAddress.engineDbAddr = engineDb;

        return ServiceResponse(
          success: true,
          message: '엔진 DB 설정이 성공적으로 업데이트되었습니다.',
          data: engineDb,
        );
      } else {
        return ServiceResponse(
          success: false,
          message: '엔진 DB 설정 업데이트에 실패했습니다.',
          error: 'DATABASE_UPDATE_FAILED',
        );
      }
    } catch (e) {
      print('DatabaseManagementService.updateEngineDatabase 오류: $e');
      return ServiceResponse(
        success: false,
        message: '엔진 DB 설정 업데이트 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 디스플레이 DB 설정 업데이트
  Future<ServiceResponse<String>> updateDisplayDatabase(
      String displayDb) async {
    try {
      final currentDisplayDbAddr = _manageAddress.displayDbAddr;
      if (currentDisplayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '현재 디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      // URL 유효성 검사
      if (!_isValidDatabaseUrl(displayDb)) {
        return ServiceResponse(
          success: false,
          message: '유효하지 않은 데이터베이스 URL입니다.',
          error: 'INVALID_DATABASE_URL',
        );
      }

      final headers = {'Content-Type': 'application/json'};

      // 현재 설정 조회
      final getBody = {
        "transaction": [
          {"query": "#S_TbDbSetting"}
        ]
      };

      final getResponse = await http.post(
        Uri.parse(currentDisplayDbAddr),
        headers: headers,
        body: jsonEncode(getBody),
      );

      if (getResponse.statusCode != 200) {
        return ServiceResponse(
          success: false,
          message: '현재 설정 조회에 실패했습니다.',
          error: 'DATABASE_QUERY_FAILED',
        );
      }

      // 설정 업데이트
      final updateBody = {
        "transaction": [
          {
            "statement": "#U_TbDbSetting",
            "values": {"changeDisplay": displayDb}
          }
        ]
      };

      final updateResponse = await http.post(
        Uri.parse(currentDisplayDbAddr),
        headers: headers,
        body: jsonEncode(updateBody),
      );

      if (updateResponse.statusCode == 200) {
        // ManageAddress 업데이트
        _manageAddress.displayDbAddr = displayDb;

        return ServiceResponse(
          success: true,
          message: '디스플레이 DB 설정이 성공적으로 업데이트되었습니다.',
          data: displayDb,
        );
      } else {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 설정 업데이트에 실패했습니다.',
          error: 'DATABASE_UPDATE_FAILED',
        );
      }
    } catch (e) {
      print('DatabaseManagementService.updateDisplayDatabase 오류: $e');
      return ServiceResponse(
        success: false,
        message: '디스플레이 DB 설정 업데이트 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 전체 데이터베이스 설정 업데이트
  Future<ServiceResponse<DatabaseConfig>> updateDatabaseConfig(
      Map<String, dynamic> configData) async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return ServiceResponse(
          success: false,
          message: '디스플레이 DB 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final engineDb = configData['engineDb'] as String?;
      final displayDb = configData['displayDb'] as String?;

      // URL 유효성 검사
      if (engineDb != null && !_isValidDatabaseUrl(engineDb)) {
        return ServiceResponse(
          success: false,
          message: '유효하지 않은 엔진 DB URL입니다.',
          error: 'INVALID_DATABASE_URL',
        );
      }

      if (displayDb != null && !_isValidDatabaseUrl(displayDb)) {
        return ServiceResponse(
          success: false,
          message: '유효하지 않은 디스플레이 DB URL입니다.',
          error: 'INVALID_DATABASE_URL',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final updateValues = <String, dynamic>{};

      if (engineDb != null) {
        updateValues['changeEngine'] = engineDb;
      }
      if (displayDb != null) {
        updateValues['changeDisplay'] = displayDb;
      }

      if (updateValues.isEmpty) {
        return ServiceResponse(
          success: false,
          message: '업데이트할 설정이 없습니다.',
          error: 'NO_UPDATE_DATA',
        );
      }

      // 설정 업데이트
      final updateBody = {
        "transaction": [
          {"statement": "#U_TbDbSetting", "values": updateValues}
        ]
      };

      final updateResponse = await http.post(
        Uri.parse(displayDbAddr),
        headers: headers,
        body: jsonEncode(updateBody),
      );

      if (updateResponse.statusCode == 200) {
        // ManageAddress 업데이트
        if (engineDb != null) {
          _manageAddress.engineDbAddr = engineDb;
        }
        if (displayDb != null) {
          _manageAddress.displayDbAddr = displayDb;
        }

        final updatedConfig = DatabaseConfig(
          engineDb: engineDb ?? _manageAddress.engineDbAddr,
          displayDb: displayDb ?? _manageAddress.displayDbAddr,
          displayDbLPR: _manageAddress.displayDbLPR,
        );

        return ServiceResponse(
          success: true,
          message: '데이터베이스 설정이 성공적으로 업데이트되었습니다.',
          data: updatedConfig,
        );
      } else {
        return ServiceResponse(
          success: false,
          message: '데이터베이스 설정 업데이트에 실패했습니다.',
          error: 'DATABASE_UPDATE_FAILED',
        );
      }
    } catch (e) {
      print('DatabaseManagementService.updateDatabaseConfig 오류: $e');
      return ServiceResponse(
        success: false,
        message: '데이터베이스 설정 업데이트 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스 연결 테스트
  Future<ServiceResponse<Map<String, dynamic>>> testDatabaseConnection(
      Map<String, dynamic>? testConfig) async {
    try {
      final testResults = <String, dynamic>{};

      // 테스트할 설정 결정
      final engineDbUrl =
          testConfig?['engineDb'] ?? _manageAddress.engineDbAddr;
      final displayDbUrl =
          testConfig?['displayDb'] ?? _manageAddress.displayDbAddr;

      // 엔진 DB 연결 테스트
      if (engineDbUrl != null) {
        testResults['engineDb'] = await _testSingleDatabaseConnection(
          engineDbUrl,
          'Engine DB',
        );
      }

      // 디스플레이 DB 연결 테스트
      if (displayDbUrl != null) {
        testResults['displayDb'] = await _testSingleDatabaseConnection(
          displayDbUrl,
          'Display DB',
        );
      }

      final allHealthy = testResults.values
          .where((result) => result is Map<String, dynamic>)
          .every((result) => result['healthy'] == true);

      return ServiceResponse(
        success: true,
        message: allHealthy
            ? '모든 데이터베이스 연결 테스트가 성공했습니다.'
            : '일부 데이터베이스 연결 테스트가 실패했습니다.',
        data: testResults,
      );
    } catch (e) {
      print('DatabaseManagementService.testDatabaseConnection 오류: $e');
      return ServiceResponse(
        success: false,
        message: '데이터베이스 연결 테스트 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 단일 데이터베이스 연결 테스트
  Future<Map<String, dynamic>> _testSingleDatabaseConnection(
      String dbUrl, String dbName) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "SELECT 1 as test"}
        ]
      };

      final startTime = DateTime.now();
      final response = await http
          .post(
            Uri.parse(dbUrl),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      if (response.statusCode == 200) {
        return {
          'healthy': true,
          'name': dbName,
          'url': dbUrl,
          'response_time_ms': responseTime,
          'status': 'connected',
          'tested_at': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'healthy': false,
          'name': dbName,
          'url': dbUrl,
          'status': 'connection_failed',
          'error': 'HTTP ${response.statusCode}',
          'tested_at': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'healthy': false,
        'name': dbName,
        'url': dbUrl,
        'status': 'connection_error',
        'error': e.toString(),
        'tested_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        return false;
      }

      // 간단한 연결 테스트
      final testResult = await _testSingleDatabaseConnection(
        displayDbAddr,
        'Display DB',
      );

      return testResult['healthy'] == true;
    } catch (e) {
      print('DatabaseManagementService.isServiceHealthy 오류: $e');
      return false;
    }
  }

  /// URL 유효성 검사
  bool _isValidDatabaseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }
}
