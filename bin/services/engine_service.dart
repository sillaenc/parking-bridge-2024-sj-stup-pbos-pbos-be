import 'dart:convert';
import 'package:http/http.dart' as http;

/// 엔진 관련 서비스를 처리하는 클래스
/// ws4sqlite를 통한 엔진 데이터베이스 통신을 담당
class EngineService {
  final http.Client _client;

  EngineService({http.Client? client}) : _client = client ?? http.Client();

  /// 엔진 데이터베이스 주소를 가져오는 함수
  ///
  /// [url] 디스플레이 데이터베이스 URL
  /// Returns: 엔진 주소 또는 null (실패시)
  Future<String?> fetchEngineAddr(String url) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var body = {
        "transaction": [
          {"query": "#S_TbDbSetting"}
        ]
      };

      var response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData['results'][0]['resultSet'][0]['engine_db_addr'];
      } else {
        print(
            'Failed to fetch engine address. Status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching engine address: $e');
      print('StackTrace: $stackTrace');
    }
    return null;
  }

  /// HTTP 클라이언트 리소스 해제
  void dispose() {
    _client.close();
  }
}
