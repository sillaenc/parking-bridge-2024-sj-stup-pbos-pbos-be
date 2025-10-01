import 'package:shelf/shelf.dart';

/// CORS(Cross-Origin Resource Sharing) 미들웨어
/// 클라이언트-서버 간 CORS 정책을 관리
class CorsMiddleware {
  /// CORS 헤더들을 정의
  static const Map<String, String> _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, X-Auth-Token, Authorization',
  };

  /// CORS 미들웨어를 생성
  ///
  /// OPTIONS 요청에 대한 프리플라이트 처리 및
  /// 모든 응답에 CORS 헤더 추가
  static Middleware create() {
    return (Handler innerHandler) {
      return (Request request) async {
        // OPTIONS 요청 (프리플라이트) 처리
        if (request.method == 'OPTIONS') {
          return Response.ok(null, headers: _corsHeaders);
        }

        // 일반 요청 처리 후 응답에 CORS 헤더 추가
        try {
          Response response = await innerHandler(request);
          return response.change(headers: _corsHeaders);
        } catch (e) {
          // 에러 발생시에도 CORS 헤더 포함
          return Response.internalServerError(
            body: 'Internal Server Error',
            headers: _corsHeaders,
          );
        }
      };
    };
  }

  /// 특정 오리진만 허용하는 CORS 미들웨어 생성
  ///
  /// [allowedOrigins] 허용할 오리진 목록
  static Middleware createRestrictive(List<String> allowedOrigins) {
    return (Handler innerHandler) {
      return (Request request) async {
        final origin = request.headers['origin'];
        final isAllowed = origin != null && allowedOrigins.contains(origin);

        final headers = {
          'Access-Control-Allow-Origin': isAllowed ? origin : 'null',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, X-Auth-Token, Authorization',
        };

        if (request.method == 'OPTIONS') {
          return Response.ok(null, headers: headers);
        }

        if (!isAllowed && origin != null) {
          return Response.forbidden('CORS policy violation', headers: headers);
        }

        Response response = await innerHandler(request);
        return response.change(headers: headers);
      };
    };
  }
}
