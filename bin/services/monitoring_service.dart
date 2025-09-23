/// 모니터링 서비스
///
/// 시스템 생존 확인, 서비스 등록, 오류 상태 모니터링을 담당하는 서비스

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/manage_address.dart';
import '../data/global.dart';

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

/// 시스템 상태 모델
class SystemHealth {
  final bool isHealthy;
  final String status;
  final Map<String, dynamic> services;
  final Map<String, dynamic> databases;
  final DateTime checkedAt;

  SystemHealth({
    required this.isHealthy,
    required this.status,
    required this.services,
    required this.databases,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_healthy': isHealthy,
      'status': status,
      'services': services,
      'databases': databases,
      'checked_at': checkedAt.toIso8601String(),
    };
  }
}

/// 등록된 서비스 모델
class RegisteredService {
  final String key;
  final String url;
  final bool isAlive;
  final int? responseTimeMs;
  final DateTime lastChecked;
  final String? error;

  RegisteredService({
    required this.key,
    required this.url,
    required this.isAlive,
    this.responseTimeMs,
    required this.lastChecked,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'url': url,
      'is_alive': isAlive,
      'response_time_ms': responseTimeMs,
      'last_checked': lastChecked.toIso8601String(),
      'error': error,
    };
  }
}

/// 오류 정보 모델
class ErrorInfo {
  final String id;
  final String type;
  final String message;
  final String? details;
  final DateTime occurredAt;
  final bool resolved;

  ErrorInfo({
    required this.id,
    required this.type,
    required this.message,
    this.details,
    required this.occurredAt,
    this.resolved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'details': details,
      'occurred_at': occurredAt.toIso8601String(),
      'resolved': resolved,
    };
  }
}

class MonitoringService {
  final ManageAddress _manageAddress;
  final Map<String, String> _registeredServices = {};
  final List<ErrorInfo> _errors = [];

  MonitoringService({required ManageAddress manageAddress})
      : _manageAddress = manageAddress;

  /// 전체 시스템 생존 상태 확인
  Future<ServiceResponse<SystemHealth>> getSystemHealth(
      bool includeDetails) async {
    try {
      final databaseStatus = await _checkDatabasesHealth();
      final servicesStatus = await _checkServicesHealth();

      final isHealthy = databaseStatus['healthy'] == true &&
          servicesStatus['healthy'] == true &&
          _errors.where((e) => !e.resolved).isEmpty;

      String status;
      if (isHealthy) {
        status = 'healthy';
      } else if (databaseStatus['healthy'] == true ||
          servicesStatus['healthy'] == true) {
        status = 'degraded';
      } else {
        status = 'unhealthy';
      }

      final systemHealth = SystemHealth(
        isHealthy: isHealthy,
        status: status,
        services: includeDetails
            ? servicesStatus
            : {'count': servicesStatus['count']},
        databases: includeDetails
            ? databaseStatus
            : {'healthy': databaseStatus['healthy']},
        checkedAt: DateTime.now(),
      );

      return ServiceResponse(
        success: true,
        message: '시스템 상태를 성공적으로 확인했습니다.',
        data: systemHealth,
      );
    } catch (e) {
      print('MonitoringService.getSystemHealth 오류: $e');
      return ServiceResponse(
        success: false,
        message: '시스템 상태 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 새로운 서비스 URL 등록
  Future<ServiceResponse<Map<String, dynamic>>> registerService(
      String key, String value) async {
    try {
      // URL 유효성 검사
      if (!_isValidUrl(value)) {
        return ServiceResponse(
          success: false,
          message: '유효하지 않은 URL입니다.',
          error: 'INVALID_URL',
        );
      }

      _registeredServices[key] = value;

      // 등록 후 즉시 생존 확인
      final serviceStatus = await _checkSingleService(key, value, 5);

      return ServiceResponse(
        success: true,
        message: '서비스가 성공적으로 등록되었습니다.',
        data: {
          'key': key,
          'url': value,
          'registered_at': DateTime.now().toIso8601String(),
          'initial_check': serviceStatus,
          'total_registered_services': _registeredServices.length,
        },
      );
    } catch (e) {
      print('MonitoringService.registerService 오류: $e');
      return ServiceResponse(
        success: false,
        message: '서비스 등록 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 등록된 서비스들의 생존 상태 확인
  Future<ServiceResponse<List<RegisteredService>>> checkRegisteredServices(
      int timeoutSeconds) async {
    try {
      if (_registeredServices.isEmpty) {
        return ServiceResponse(
          success: false,
          message: '등록된 서비스가 없습니다.',
          error: 'NO_SERVICES_REGISTERED',
        );
      }

      final serviceChecks = <RegisteredService>[];

      for (final entry in _registeredServices.entries) {
        final serviceStatus =
            await _checkSingleService(entry.key, entry.value, timeoutSeconds);
        serviceChecks.add(serviceStatus);
      }

      final aliveCount = serviceChecks.where((s) => s.isAlive).length;
      final totalCount = serviceChecks.length;

      return ServiceResponse(
        success: true,
        message: '$aliveCount/$totalCount 서비스가 정상 상태입니다.',
        data: serviceChecks,
      );
    } catch (e) {
      print('MonitoringService.checkRegisteredServices 오류: $e');
      return ServiceResponse(
        success: false,
        message: '등록된 서비스 상태 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스 생존 확인
  Future<ServiceResponse<Map<String, dynamic>>> pingDatabase() async {
    try {
      final databaseStatus = await _checkDatabasesHealth();

      if (databaseStatus['healthy'] == true) {
        return ServiceResponse(
          success: true,
          message: '데이터베이스가 정상 상태입니다.',
          data: databaseStatus,
        );
      } else {
        return ServiceResponse(
          success: false,
          message: '데이터베이스 연결에 문제가 있습니다.',
          error: 'DATABASE_PING_FAILED',
          data: databaseStatus,
        );
      }
    } catch (e) {
      print('MonitoringService.pingDatabase 오류: $e');
      return ServiceResponse(
        success: false,
        message: '데이터베이스 생존 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스 상세 상태 확인
  Future<ServiceResponse<Map<String, dynamic>>> pingDatabaseDetailed() async {
    try {
      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;
      final displayDbLPR = _manageAddress.displayDbLPR;

      final detailedStatus = <String, dynamic>{
        'engine_db': await _pingSingleDatabase(engineDbAddr, 'Engine DB'),
        'display_db': await _pingSingleDatabase(displayDbAddr, 'Display DB'),
        'display_db_lpr':
            await _pingSingleDatabase(displayDbLPR, 'Display DB LPR'),
      };

      final allHealthy = detailedStatus.values
          .where((db) => db is Map<String, dynamic>)
          .every((db) => db['healthy'] == true);

      detailedStatus['overall_healthy'] = allHealthy;
      detailedStatus['checked_at'] = DateTime.now().toIso8601String();

      return ServiceResponse(
        success: allHealthy,
        message: allHealthy ? '모든 데이터베이스가 정상 상태입니다.' : '일부 데이터베이스에 문제가 있습니다.',
        data: detailedStatus,
      );
    } catch (e) {
      print('MonitoringService.pingDatabaseDetailed 오류: $e');
      return ServiceResponse(
        success: false,
        message: '데이터베이스 상세 상태 확인 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 현재 오류 상태 조회
  Future<ServiceResponse<List<ErrorInfo>>> getErrors(
      bool includeResolved) async {
    try {
      final filteredErrors = includeResolved
          ? _errors
          : _errors.where((e) => !e.resolved).toList();

      return ServiceResponse(
        success: true,
        message: '오류 목록을 성공적으로 조회했습니다.',
        data: filteredErrors,
      );
    } catch (e) {
      print('MonitoringService.getErrors 오류: $e');
      return ServiceResponse(
        success: false,
        message: '오류 목록 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 오류 보고
  Future<ServiceResponse<ErrorInfo>> reportError(
      Map<String, dynamic> errorData) async {
    try {
      final type = errorData['type'] as String?;
      final message = errorData['message'] as String?;

      if (type == null || message == null) {
        return ServiceResponse(
          success: false,
          message: 'type과 message 필드가 필요합니다.',
          error: 'INVALID_ERROR_DATA',
        );
      }

      final errorInfo = ErrorInfo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        message: message,
        details: errorData['details'] as String?,
        occurredAt: DateTime.now(),
        resolved: false,
      );

      _errors.add(errorInfo);

      // 글로벌 에러 리스트에도 추가 (레거시 호환)
      error.add(message);

      return ServiceResponse(
        success: true,
        message: '오류가 성공적으로 보고되었습니다.',
        data: errorInfo,
      );
    } catch (e) {
      print('MonitoringService.reportError 오류: $e');
      return ServiceResponse(
        success: false,
        message: '오류 보고 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 오류 목록 초기화
  Future<ServiceResponse<Map<String, dynamic>>> clearErrors() async {
    try {
      final clearedCount = _errors.length;
      _errors.clear();

      // 글로벌 에러 리스트도 초기화 (레거시 호환)
      error.clear();

      return ServiceResponse(
        success: true,
        message: '오류 목록이 성공적으로 초기화되었습니다.',
        data: {
          'cleared_count': clearedCount,
          'cleared_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('MonitoringService.clearErrors 오류: $e');
      return ServiceResponse(
        success: false,
        message: '오류 목록 초기화 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 전체 모니터링 상태 요약
  Future<ServiceResponse<Map<String, dynamic>>> getMonitoringStatus() async {
    try {
      final databaseStatus = await _checkDatabasesHealth();
      final servicesStatus = await _checkServicesHealth();
      final activeErrors = _errors.where((e) => !e.resolved).length;

      final monitoringStatus = {
        'overall_healthy': databaseStatus['healthy'] == true &&
            servicesStatus['healthy'] == true &&
            activeErrors == 0,
        'databases': {
          'healthy': databaseStatus['healthy'],
          'count': databaseStatus['count'],
        },
        'services': {
          'healthy': servicesStatus['healthy'],
          'alive_count': servicesStatus['alive_count'],
          'total_count': servicesStatus['count'],
        },
        'errors': {
          'active_count': activeErrors,
          'total_count': _errors.length,
        },
        'last_checked': DateTime.now().toIso8601String(),
      };

      return ServiceResponse(
        success: true,
        message: '모니터링 상태 요약을 성공적으로 조회했습니다.',
        data: monitoringStatus,
      );
    } catch (e) {
      print('MonitoringService.getMonitoringStatus 오류: $e');
      return ServiceResponse(
        success: false,
        message: '모니터링 상태 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스들의 상태 확인
  Future<Map<String, dynamic>> _checkDatabasesHealth() async {
    try {
      final engineDbAddr = _manageAddress.engineDbAddr;
      final displayDbAddr = _manageAddress.displayDbAddr;
      final displayDbLPR = _manageAddress.displayDbLPR;

      final databases = [
        if (engineDbAddr != null)
          await _pingSingleDatabase(engineDbAddr, 'Engine DB'),
        if (displayDbAddr != null)
          await _pingSingleDatabase(displayDbAddr, 'Display DB'),
        if (displayDbLPR != null)
          await _pingSingleDatabase(displayDbLPR, 'Display DB LPR'),
      ];

      final healthyCount =
          databases.where((db) => db['healthy'] == true).length;
      final totalCount = databases.length;

      return {
        'healthy': healthyCount == totalCount && totalCount > 0,
        'count': totalCount,
        'healthy_count': healthyCount,
        'databases': databases,
      };
    } catch (e) {
      return {
        'healthy': false,
        'count': 0,
        'healthy_count': 0,
        'error': e.toString(),
      };
    }
  }

  /// 서비스들의 상태 확인
  Future<Map<String, dynamic>> _checkServicesHealth() async {
    try {
      if (_registeredServices.isEmpty) {
        return {
          'healthy': true, // 등록된 서비스가 없으면 정상으로 간주
          'count': 0,
          'alive_count': 0,
          'services': <RegisteredService>[],
        };
      }

      final services = <RegisteredService>[];
      for (final entry in _registeredServices.entries) {
        final serviceStatus =
            await _checkSingleService(entry.key, entry.value, 5);
        services.add(serviceStatus);
      }

      final aliveCount = services.where((s) => s.isAlive).length;
      final totalCount = services.length;

      return {
        'healthy': aliveCount == totalCount,
        'count': totalCount,
        'alive_count': aliveCount,
        'services': services,
      };
    } catch (e) {
      return {
        'healthy': false,
        'count': 0,
        'alive_count': 0,
        'error': e.toString(),
      };
    }
  }

  /// 단일 데이터베이스 핑 확인
  Future<Map<String, dynamic>> _pingSingleDatabase(
      String? dbUrl, String dbName) async {
    if (dbUrl == null || dbUrl.isEmpty) {
      return {
        'name': dbName,
        'healthy': false,
        'error': 'Database URL not configured',
        'checked_at': DateTime.now().toIso8601String(),
      };
    }

    try {
      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "SELECT 1 as ping"}
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

      return {
        'name': dbName,
        'url': dbUrl,
        'healthy': response.statusCode == 200,
        'response_time_ms': responseTime,
        'status_code': response.statusCode,
        'checked_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'name': dbName,
        'url': dbUrl,
        'healthy': false,
        'error': e.toString(),
        'checked_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 단일 서비스 상태 확인
  Future<RegisteredService> _checkSingleService(
      String key, String url, int timeoutSeconds) async {
    try {
      final startTime = DateTime.now();
      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;

      return RegisteredService(
        key: key,
        url: url,
        isAlive: response.statusCode >= 200 && response.statusCode < 300,
        responseTimeMs: responseTime,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      return RegisteredService(
        key: key,
        url: url,
        isAlive: false,
        lastChecked: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// URL 유효성 검사
  bool _isValidUrl(String url) {
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
