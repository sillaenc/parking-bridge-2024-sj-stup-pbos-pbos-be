/// 레거시 차량 정보 조회 API (/pabi)
///
/// 기존 클라이언트 호환성을 위한 레거시 엔드포인트
/// 레거시 방식 그대로 DB 쿼리를 직접 사용하여 응답 형식 완벽 재현

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import '../../data/manage_address.dart';

/// 레거시 Pabi (Parking Area Vehicle Information) API
///
/// 레거시 경로: /pabi/tag, /pabi/car
class LegacyPabi {
  final ManageAddress _manageAddress;

  LegacyPabi({required ManageAddress manageAddress})
      : _manageAddress = manageAddress;

  Router get router {
    final router = Router();

    // POST /pabi/tag - 태그로 차량 정보 조회 (레거시)
    router.post('/tag', _handleGetVehicleByTag);

    // POST /pabi/car - 번호판으로 차량 위치 조회 (레거시)
    router.post('/car', _handleGetVehicleByPlate);

    return router;
  }

  /// 태그로 차량 정보 조회 (레거시 응답 형식)
  ///
  /// 요청: {"tag": "A101"}
  /// 응답: {"tag": "A101", "plate": "12가3456", "startTime": "...", "point": "..."} 또는 "없어"
  Future<Response> _handleGetVehicleByTag(Request request) async {
    try {
      final url = _manageAddress.displayDbAddr;
      if (url == null) {
        return Response.internalServerError(
            body: 'Error: 데이터베이스 주소가 설정되지 않았습니다.');
      }

      var payload = await request.readAsString();
      var input = jsonDecode(payload);
      print('[LegacyPabi] /tag 요청: $input');

      var key = input['tag'];

      // 레거시 방식: 직접 DB 쿼리 (#get_plate)
      var headers = {'Content-Type': 'application/json'};
      var getBody = {
        "transaction": [
          {
            "query": "#get_plate",
            "values": {"tag": key}
          }
        ]
      };

      var getResponse = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(getBody),
      );

      var utf8decodebody = utf8.decode(getResponse.bodyBytes);
      var decodedGet = jsonDecode(utf8decodebody);
      print('[LegacyPabi] DB 응답: $decodedGet');

      // 레거시 응답 형식
      var currentValue = decodedGet['results'][0]['resultSet'][0];
      if (currentValue != null && currentValue.isNotEmpty) {
        print('[LegacyPabi] /tag 성공: $currentValue');
        return Response.ok(
          jsonEncode(currentValue),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // 레거시 에러 형식: 단순 문자열
        print('[LegacyPabi] /tag 차량 없음');
        return Response.ok('없어');
      }
    } catch (e, stackTrace) {
      print('[LegacyPabi] /tag 오류: $e');
      print('스택 트레이스: $stackTrace');
      // 레거시 에러 형식
      return Response.badRequest(body: 'Error: $e');
    }
  }

  /// 번호판으로 차량 위치 조회 (레거시 응답 형식)
  ///
  /// 요청: {"plate": "1234"}
  /// 응답: [{"tag": "A101", "plate": "12가3456", "startTime": "...", "point": "..."}] 또는 "없어"
  Future<Response> _handleGetVehicleByPlate(Request request) async {
    try {
      final url = _manageAddress.displayDbAddr;
      if (url == null) {
        return Response.internalServerError(
            body: 'Error: 데이터베이스 주소가 설정되지 않았습니다.');
      }

      var payload = await request.readAsString();
      var input = jsonDecode(payload);
      print('[LegacyPabi] /car 요청: $input');

      var key = input['plate'];
      var key2 = '%$key'; // 레거시 방식: LIKE 검색을 위한 와일드카드

      // 레거시 방식: 직접 DB 쿼리 (#get_tag)
      var headers = {'Content-Type': 'application/json'};
      var getBody = {
        "transaction": [
          {
            "query": "#get_tag",
            "values": {"plate": key2}
          }
        ]
      };

      var getResponse = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(getBody),
      );

      var utf8decodebody = utf8.decode(getResponse.bodyBytes);
      var decodedGet = jsonDecode(utf8decodebody);
      print('[LegacyPabi] DB 응답: $decodedGet');

      // 레거시 응답 형식: 배열로 반환
      var resultSet = decodedGet['results'][0]['resultSet'];
      if (resultSet != null && resultSet.isNotEmpty) {
        print('[LegacyPabi] /car 성공: ${resultSet.length}건');
        return Response.ok(
          jsonEncode(resultSet),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        // 레거시 에러 형식: 단순 문자열
        print('[LegacyPabi] /car 차량 없음');
        return Response.ok('없어');
      }
    } catch (e, stackTrace) {
      print('[LegacyPabi] /car 오류: $e');
      print('스택 트레이스: $stackTrace');
      // 레거시 에러 형식
      return Response.badRequest(body: 'Error: $e');
    }
  }
}
