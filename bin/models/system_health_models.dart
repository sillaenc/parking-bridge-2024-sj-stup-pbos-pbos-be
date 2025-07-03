/// 시스템 상태 확인 관련 데이터 모델
///
/// 시스템 생존 확인 및 네트워크 상태 정보를 위한 데이터 구조들을 정의

/// 시스템 생존 정보
class SystemAliveInfo {
  final String name;
  final bool isAlright;

  SystemAliveInfo({
    required this.name,
    required this.isAlright,
  });

  factory SystemAliveInfo.fromJson(Map<String, dynamic> json) =>
      SystemAliveInfo(
        name: json['name']?.toString() ?? '',
        isAlright: json['isalright'] == 1 || json['isalright'] == true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'is_alright': isAlright,
        'status': isAlright ? 'online' : 'offline',
      };
}

/// 시스템 상태 확인 응답 데이터
class SystemHealthResponseData {
  final List<SystemAliveInfo> systems;
  final int totalSystems;
  final int onlineSystems;
  final int offlineSystems;

  SystemHealthResponseData({
    required this.systems,
    required this.totalSystems,
    required this.onlineSystems,
    required this.offlineSystems,
  });

  Map<String, dynamic> toJson() => {
        'systems': systems.map((e) => e.toJson()).toList(),
        'total_systems': totalSystems,
        'online_systems': onlineSystems,
        'offline_systems': offlineSystems,
        'online_percentage': totalSystems > 0
            ? (onlineSystems / totalSystems * 100).toStringAsFixed(1)
            : '0.0',
        'overall_status': offlineSystems == 0 ? 'healthy' : 'warning',
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 시스템 상태 서비스 응답
class SystemHealthServiceResponse {
  final bool success;
  final String message;
  final SystemHealthResponseData? data;
  final String? error;

  SystemHealthServiceResponse({
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
