import 'package:dotenv/dotenv.dart';
import '../data/manage_address.dart';

/// 서버 설정을 관리하는 클래스
/// 환경 변수 로드 및 서버 초기화 설정 담당
class ServerConfig {
  static const String DEFAULT_HOST = '0.0.0.0';
  static const int DEFAULT_PORT = 8080;

  final DotEnv _env;
  final ManageAddress _manageAddress;

  ServerConfig()
      : _env = DotEnv(includePlatformEnvironment: true),
        _manageAddress = ManageAddress();

  /// 환경 변수를 로드하고 설정을 초기화
  Future<void> initialize() async {
    try {
      _env.load();
      await _configureDatabase();
      print('서버 설정이 완료되었습니다.');
    } catch (e) {
      print('서버 설정 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 데이터베이스 관련 설정
  Future<void> _configureDatabase() async {
    _manageAddress.displayDbAddr = _env['displayDbAddr'];
    _manageAddress.displayDbLPR = _env['displayDbLPR'];

    if (_manageAddress.displayDbAddr == null) {
      throw Exception('displayDbAddr 환경 변수가 설정되지 않았습니다.');
    }

    print('Database configuration completed:');
    print('- Display DB: ${_manageAddress.displayDbAddr}');
    print('- Display LPR: ${_manageAddress.displayDbLPR}');
  }

  /// 서버 포트 가져오기
  int get port {
    final portStr = _env['PORT'];
    if (portStr == null) {
      print('PORT 환경 변수가 설정되지 않아 기본값 $DEFAULT_PORT을 사용합니다.');
      return DEFAULT_PORT;
    }

    final port = int.tryParse(portStr);
    if (port == null) {
      print('PORT 환경 변수가 잘못된 형식입니다. 기본값 $DEFAULT_PORT을 사용합니다.');
      return DEFAULT_PORT;
    }

    return port;
  }

  /// 서버 호스트 가져오기
  String get host => DEFAULT_HOST;

  /// ManageAddress 인스턴스 가져오기
  ManageAddress get manageAddress => _manageAddress;

  /// 환경 변수 값 가져오기
  String? getEnv(String key) => _env[key];

  /// 필수 환경 변수 검증
  void validateRequiredEnvVars() {
    final requiredVars = ['displayDbAddr'];
    final missingVars = <String>[];

    for (final varName in requiredVars) {
      if (_env[varName] == null || _env[varName]!.isEmpty) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw Exception('필수 환경 변수가 누락되었습니다: ${missingVars.join(', ')}');
    }
  }
}
