import 'dart:convert';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class Database {
  static Database? _instance;
  late Connection _conn;
  late Map<String, String> _queries; // 쿼리 저장용

  Database._();

  /// 싱글톤 인스턴스 반환
  static Future<Database> getInstance() async {
    if (_instance == null) {
      _instance = Database._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 비동기 초기화: DB 연결 및 쿼리 로드
  Future<void> _init() async {
    var env = DotEnv()..load();
    _conn = await Connection.open(
      Endpoint(
        host: env['HOST']!,
        database: env['DATABASE']!,
        username: env['USERNAME']!,
        password: env['PASSWORD']!,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    await _loadQueries(); // ✅ 쿼리 파일 로드
  }

  /// queries.json 파일 로드
  Future<void> _loadQueries() async {
    final file = File('queries.json');
    if (!await file.exists()) {
      throw Exception('queries.json 파일을 찾을 수 없습니다.');
    }

    final content = await file.readAsString();
    _queries = jsonDecode(content).cast<String, String>();
  }

  /// 저장된 쿼리 실행
  Future<List<Map<String, dynamic>>> query(String queryName, [Map<String, dynamic>? params]) async {
    if (!_queries.containsKey(queryName)) {
      throw Exception('쿼리 "$queryName"을 찾을 수 없습니다.');
    }

    final sql = _queries[queryName]!;
    //밑에 2줄은 query가 정상 작동하는지 디버깅용
    // print("Original SQL: $sql");
    // print("Parameters: ${params ?? {}}");
    // 🔥 Named Query 적용
    final namedQuery = Sql.named(sql);
    //print("변환된 쿼리: $namedQuery");
    var result = await _conn.execute(
      namedQuery,
      parameters: params ?? {}, // ✅ Map 형태 그대로 전달
    );
    
    return result.map((row) => row.toColumnMap()).toList();
  }

  /// 연결 닫기
  Future<void> close() async {
    await _conn.close();
  }
}
