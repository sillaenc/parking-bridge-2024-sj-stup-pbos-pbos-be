/// bin/main.dart
/// 스마트 파킹 백엔드 서버의 메인 엔트리 포인트
///
/// 주요 기능:
/// - OpenAPI 3.0 스타일의 RESTful API 제공
/// - ws4sqlite를 통한 데이터베이스 통신
/// - 주기적 엔진 데이터 수집 및 처리
/// - JWT 기반 인증 시스템

import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// 분리된 모듈들 import
import 'config/server_config.dart';
import 'routes/router_config.dart';
import 'middleware/cors_middleware.dart';
import 'services/periodic_task_service.dart';

/// 애플리케이션 메인 함수
/// 서버 초기화, 설정 로드, 라우터 구성 및 서버 시작을 담당
void main() async {
  print('🚀 스마트 파킹 백엔드 서버를 시작합니다...\n');

  try {
    // 1. 서버 설정 초기화
    final serverConfig = ServerConfig();
    await serverConfig.initialize();

    // 2. 라우터 설정
    final routerConfig =
        RouterConfig(manageAddress: serverConfig.manageAddress);
    routerConfig.printApiInfo();

    // 3. 미들웨어 파이프라인 구성
    final handler = _createHandler(routerConfig.router);

    // 4. 주기적 작업 서비스 시작
    final periodicTaskService = PeriodicTaskService(
      manageAddress: serverConfig.manageAddress,
    );
    periodicTaskService.startPeriodicTask();

    // 5. 서버 시작
    final server = await serve(
      handler,
      serverConfig.host,
      serverConfig.port,
    );

    print('✅ 서버가 성공적으로 시작되었습니다!');
    print('   📍 주소: http://${server.address.host}:${server.port}');
    print('   🌐 API 기본 경로: /api/v1');
    print('   🔄 주기적 작업: ${periodicTaskService.isRunning ? '실행 중' : '중지됨'}');
    print('\n서버가 요청을 대기하고 있습니다...\n');

    // 6. 서버 종료 처리 (선택사항)
    _setupGracefulShutdown(server, periodicTaskService);
  } catch (e, stackTrace) {
    print('❌ 서버 시작 중 오류가 발생했습니다:');
    print('   오류: $e');
    print('   스택트레이스: $stackTrace');
    print('\n서버를 종료합니다.');
    return;
  }
}

/// HTTP 요청 처리 파이프라인을 구성하는 함수
/// 로깅, CORS, 라우팅 미들웨어를 순서대로 적용
Handler _createHandler(Router router) {
  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(CorsMiddleware.create())
      .addHandler(router);
}

/// 우아한 서버 종료 처리를 설정하는 함수
/// SIGTERM, SIGINT 시그널 처리 (현재는 주석 처리됨)
void _setupGracefulShutdown(
  HttpServer server,
  PeriodicTaskService periodicTaskService,
) {
  // 향후 필요시 시그널 처리 구현
  // ProcessSignal.sigterm.watch().listen((signal) async {
  //   print('\n🛑 종료 신호를 받았습니다: $signal');
  //   print('서버를 정리하고 종료합니다...');
  //
  //   periodicTaskService.stop();
  //   await server.close();
  //
  //   print('✅ 서버가 정상적으로 종료되었습니다.');
  //   exit(0);
  // });
}
