import 'dart:convert';
import 'package:http/http.dart' as http;

/// ws4sqlite 데이터베이스와의 HTTP 통신을 담당하는 클라이언트
/// stored statement를 통한 데이터베이스 작업을 추상화하여 제공
class DatabaseClient {
  final http.Client _httpClient;
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  DatabaseClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// stored statement 쿼리 실행
  ///
  /// [url] 데이터베이스 서버 URL
  /// [queryId] stored statement ID (예: #S_TbLots)
  /// [values] 쿼리 파라미터 (선택사항)
  /// Returns: 쿼리 결과 데이터
  Future<List<Map<String, dynamic>>> executeQuery({
    required String url,
    required String queryId,
    Map<String, dynamic>? values,
  }) async {
    try {
      final body = {
        "transaction": [
          {
            "query": queryId,
            if (values != null) "values": values,
          }
        ]
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final results = responseData['results'];

        if (results != null && results.isNotEmpty) {
          return List<Map<String, dynamic>>.from(results[0]['resultSet'] ?? []);
        }
      } else {
        throw DatabaseException(
          'Query failed with status code: ${response.statusCode}',
          queryId: queryId,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Query execution failed: $e',
        queryId: queryId,
        originalError: e,
      );
    }

    return [];
  }

  /// stored statement를 통한 데이터 삽입/업데이트/삭제
  ///
  /// [url] 데이터베이스 서버 URL
  /// [statementId] stored statement ID (예: #I_TbLots)
  /// [values] statement 파라미터
  /// Returns: 실행 성공 여부
  Future<bool> executeStatement({
    required String url,
    required String statementId,
    required Map<String, dynamic> values,
  }) async {
    try {
      final body = {
        "transaction": [
          {
            "statement": statementId,
            "values": values,
          }
        ]
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw DatabaseException(
          'Statement failed with status code: ${response.statusCode}',
          queryId: statementId,
          statusCode: response.statusCode,
        );
      }

      return true;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Statement execution failed: $e',
        queryId: statementId,
        originalError: e,
      );
    }
  }

  /// 배치 트랜잭션 실행 (다중 statement 한번에 실행)
  ///
  /// [url] 데이터베이스 서버 URL
  /// [transactions] 실행할 트랜잭션들의 목록
  /// Returns: 실행 성공 여부
  Future<bool> executeBatch({
    required String url,
    required List<Map<String, dynamic>> transactions,
  }) async {
    try {
      final body = {
        "transaction": transactions,
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw DatabaseException(
          'Batch execution failed with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      return true;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'Batch execution failed: $e',
        originalError: e,
      );
    }
  }

  /// 단일 레코드 개수 조회
  ///
  /// [url] 데이터베이스 서버 URL
  /// [queryId] count 쿼리 ID
  /// [values] 쿼리 파라미터
  /// Returns: 레코드 개수
  Future<int> getCount({
    required String url,
    required String queryId,
    Map<String, dynamic>? values,
  }) async {
    final results = await executeQuery(
      url: url,
      queryId: queryId,
      values: values,
    );

    if (results.isNotEmpty) {
      return results[0]['count'] ?? 0;
    }
    return 0;
  }

  /// UTF-8 디코딩이 필요한 응답 처리
  ///
  /// [url] 데이터베이스 서버 URL
  /// [queryId] 쿼리 ID
  /// [values] 쿼리 파라미터
  /// Returns: UTF-8 디코딩된 결과
  Future<List<Map<String, dynamic>>> executeQueryWithUtf8({
    required String url,
    required String queryId,
    Map<String, dynamic>? values,
  }) async {
    try {
      final body = {
        "transaction": [
          {
            "query": queryId,
            if (values != null) "values": values,
          }
        ]
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(utf8Body);
        final results = responseData['results'];

        if (results != null && results.isNotEmpty) {
          return List<Map<String, dynamic>>.from(results[0]['resultSet'] ?? []);
        }
      } else {
        throw DatabaseException(
          'UTF-8 query failed with status code: ${response.statusCode}',
          queryId: queryId,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException(
        'UTF-8 query execution failed: $e',
        queryId: queryId,
        originalError: e,
      );
    }

    return [];
  }

  /// 범용 쿼리 실행 메서드 (RTSP 등 신규 서비스용)
  ///
  /// ws4sqlite의 응답 형식을 그대로 반환하여 서비스에서 처리
  /// [url] 데이터베이스 서버 URL
  /// [queryId] stored statement ID (# 접두사 포함)
  /// [values] 쿼리 파라미터 (선택사항)
  /// Returns: ws4sqlite 응답 전체
  Future<Map<String, dynamic>> query(
    String url,
    String queryId,
    Map<String, dynamic>? values,
  ) async {
    try {
      // queryId에 # 접두사 추가 (없는 경우)
      final formattedQueryId = queryId.startsWith('#') ? queryId : '#$queryId';

      final body = {
        "transaction": [
          {
            "query": formattedQueryId,
            if (values != null && values.isNotEmpty) "values": values,
          }
        ]
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _defaultHeaders,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ws4sqlite 응답 형식 반환
        return {
          'success': true,
          'results': responseData['results']?[0]?['resultSet'] ?? [],
          'rowsAffected': responseData['results']?[0]?['rowsUpdated'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Query failed with status code: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Query execution failed: $e',
      };
    }
  }

  /// 클라이언트 리소스 해제
  void dispose() {
    _httpClient.close();
  }
}

/// 데이터베이스 관련 예외 클래스
class DatabaseException implements Exception {
  final String message;
  final String? queryId;
  final int? statusCode;
  final dynamic originalError;

  DatabaseException(
    this.message, {
    this.queryId,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('DatabaseException: $message');
    if (queryId != null) buffer.write(' (Query: $queryId)');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (originalError != null) buffer.write(' (Original: $originalError)');
    return buffer.toString();
  }
}
