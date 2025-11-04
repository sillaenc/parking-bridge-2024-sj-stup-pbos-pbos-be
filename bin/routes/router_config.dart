import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import '../routes/first_setting.dart';

// 모든 라우트 클래스들 import
import 'engine_data.dart';
import 'confirm_account_list.dart';
import 'create_admin.dart';
import 'login_main.dart';
import 'login_setting.dart'; // TODO: 레거시 호환성용, 향후 제거 예정
import 'auth_api.dart'; // 새로운 인증 API
import 'settings_account.dart';
import 'user_management_api.dart';
import 'statistics_cam_parking_area.dart';
import 'statistics_api.dart';
import 'settings_db_management.dart';
import 'settings_parking_area.dart';
import 'parking_zone_management_api.dart';
import 'parking_zones_api.dart';
import 'parking_lots_api.dart';
import 'file_system_api.dart';
import 'simple_camera_api.dart';
import 'settings_cam_parking_area.dart';
import 'camera_parking_api.dart';
import 'get_resource.dart';
import 'graphData.dart';
import 'central.dart';
import 'base_information.dart'; // TODO: 레거시 호환성용, 향후 제거 예정
import 'base_information_api.dart'; // 새로운 주차장 기본 정보 API
import 'multiple_electric_signs.dart'; // TODO: 레거시 호환성용, 향후 제거 예정
import 'electric_sign_api.dart'; // 새로운 전광판 API
import 'billboard.dart';
import 'display.dart';
import 'settings.dart';
import 'isalive.dart';
import 'pabi.dart';
import 'led_cal.dart';
import 'ping.dart';
import 'error.dart';

// 레거시 호환성 레이어 import
import 'legacy/legacy_pabi.dart'; // 레거시 /pabi 경로 호환

// 새로 리팩토링된 API들 import
import 'central_dashboard_api.dart';
import 'vehicle_info_api.dart';
import 'billboard_api.dart';
import 'display_api.dart';
import 'led_calculation_api.dart';
import 'system_health_api.dart';
import 'database_management_api.dart';
import 'resource_management_api.dart';
import 'monitoring_api.dart';
import 'rtsp_capture_api.dart';

/// OpenAPI 3.0 스타일의 라우터 설정을 관리하는 클래스
/// 모든 API 엔드포인트를 /api/v1/ 형태로 체계적으로 구성
class RouterConfig {
  static const String API_PREFIX = '/api/v1';

  final ManageAddress _manageAddress;
  late final Router _router;
  late final Future<void> _initializationComplete;

  RouterConfig({required ManageAddress manageAddress})
      : _manageAddress = manageAddress {
    _router = Router();
    _configureRoutes();
    // 초기 설정을 Future로 저장 (비동기 완료 대기 가능)
    _initializationComplete = _initializeSettings();
  }

  /// 초기 설정이 완료될 때까지 대기하는 메서드
  /// RTSP 서비스 등 DB 의존적인 서비스는 이 메서드 완료 후 시작해야 함
  Future<void> waitForInitialization() async {
    await _initializationComplete;
  }

  /// 모든 라우트를 설정하는 메인 함수
  void _configureRoutes() {
    _configureAuthRoutes();
    _configureUserRoutes();
    _configureSettingsRoutes();
    _configureStatisticsRoutes();
    _configureParkingRoutes();
    _configureSystemRoutes();
    _configureMonitoringRoutes();
    _configureResourceRoutes();
    _configureRtspRoutes(); // RTSP 캡처 API
    _configureRefactoredApiRoutes(); // 새로 리팩토링된 API들
    _configureSwaggerRoutes(); // Swagger 문서 서빙
    _configureLegacyRoutes(); // 기존 경로 호환성을 위해 임시 유지
  }

  /// 인증 관련 라우트 설정
  void _configureAuthRoutes() {
    final confirmAccountList =
        ConfirmAccountList(manageAddress: _manageAddress);
    final loginMain = LoginMain(manageAddress: _manageAddress);

    // 새로운 RESTful 인증 API (리팩토링됨)
    final authApi = AuthApi(manageAddress: _manageAddress);

    // 레거시 호환성용 (기존 클라이언트 지원)
    final loginSetting = LoginSetting(confirmAccountList: confirmAccountList);

    // 새로운 RESTful API 라우트
    _router.mount('$API_PREFIX/auth', authApi.router);

    // 기존 API 라우트 (호환성 유지)
    _router.mount('$API_PREFIX/auth/accounts/check', confirmAccountList.router);
    _router.mount('$API_PREFIX/auth/legacy', authApi.legacyRouter);
    _router.mount('$API_PREFIX/auth/status', loginMain.router);
  }

  /// 사용자 관리 라우트 설정
  void _configureUserRoutes() {
    final createAdmin = CreateAdmin(
        confirmAccountList: ConfirmAccountList(manageAddress: _manageAddress));

    // 새로운 RESTful 사용자 관리 API (리팩토링됨)
    final userManagementApi = UserManagementApi(manageAddress: _manageAddress);
    final legacyUserApi = LegacyUserApi(manageAddress: _manageAddress);

    // RESTful API 라우트
    _router.mount('$API_PREFIX/users', userManagementApi.router);
    _router.mount('$API_PREFIX/users/admin', createAdmin.router);

    // 레거시 호환성 라우트 (기존 클라이언트 지원용)
    _router.mount('$API_PREFIX/users/legacy', legacyUserApi.router);
  }

  /// 설정 관리 라우트 설정
  void _configureSettingsRoutes() {
    final settingsDbManagement =
        SettingsDbManagement(manageAddress: _manageAddress);
    final settings = Settings(manageAddress: _manageAddress);

    // 새로운 RESTful 데이터베이스 관리 API (리팩토링됨)
    final databaseManagementApi =
        DatabaseManagementApi(manageAddress: _manageAddress);

    // 새로운 분리된 API들 (리팩토링됨)
    final parkingZonesApi = ParkingZonesApi(manageAddress: _manageAddress);
    final parkingLotsApi = ParkingLotsApi(manageAddress: _manageAddress);
    final fileSystemApi = FileSystemApi(manageAddress: _manageAddress);
    final simpleCameraApi = SimpleCameraApi(manageAddress: _manageAddress);

    // 기존 통합 API (레거시 호환성용)
    final parkingZoneManagementApi =
        ParkingZoneManagementApi(manageAddress: _manageAddress);
    final legacyParkingZoneApi =
        LegacyParkingZoneApi(manageAddress: _manageAddress);

    // 새로운 RESTful 카메라 주차 표면 관리 API (리팩토링됨)
    final cameraParkingApi = CameraParkingAPI(manageAddress: _manageAddress);

    // 새로운 분리된 API 라우트
    _router.mount('$API_PREFIX/parking-zones', parkingZonesApi.router);
    _router.mount('$API_PREFIX/parking-lots', parkingLotsApi.router);
    _router.mount(
        '$API_PREFIX/files', parkingZoneManagementApi.router); // 메인 파일 API
    _router.mount('$API_PREFIX/cameras', simpleCameraApi.router);

    // 기존 설정 관련 API 라우트
    _router.mount(
        '$API_PREFIX/settings/database', databaseManagementApi.router);
    _router.mount(
        '$API_PREFIX/settings/camera-parking', cameraParkingApi.router);
    _router.mount('$API_PREFIX/settings/general', settings.router);

    // 레거시 호환성 라우트 (기존 클라이언트 지원용)
    _router.mount(
        '$API_PREFIX/settings/database/legacy', settingsDbManagement.router);
    _router.mount('$API_PREFIX/files/legacy',
        parkingZoneManagementApi.router); // 레거시 호환성을 위해 동일한 API 제공
  }

  /// 통계 관련 라우트 설정
  void _configureStatisticsRoutes() {
    // 새로운 RESTful 통계 API (리팩토링됨)
    final statisticsApi = StatisticsApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/statistics', statisticsApi.router);

    // 기존 통계 라우트 (레거시 - 호환성 유지)
    final statisticsCamParkingArea =
        StatisticsCamParkingArea(manageAddress: _manageAddress);
    final graphDataInstance = graphData(manageAddress: _manageAddress);

    _router.mount('$API_PREFIX/statistics/parking-areas',
        statisticsCamParkingArea.router);
    _router.mount('$API_PREFIX/statistics/graphs', graphDataInstance.router);
  }

  /// 주차 관련 라우트 설정
  void _configureParkingRoutes() {
    // 엔진 데이터 처리 (리팩토링된 새 버전)
    final engineDataRoutes = EngineDataRoutes(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/engine/data', engineDataRoutes.router);

    // 새로운 RESTful 주차장 기본 정보 API (리팩토링됨)
    final baseInformationApi =
        BaseInformationApi(manageAddress: _manageAddress);

    // 새로운 RESTful 전광판 API (리팩토링됨)
    final electricSignApi = ElectricSignApi(manageAddress: _manageAddress);

    final central = Central(manageAddress: _manageAddress);
    final pabi = Pabi(manageAddress: _manageAddress);

    // 새로운 RESTful API 라우트
    _router.mount('$API_PREFIX/parking/information', baseInformationApi.router);
    _router.mount('$API_PREFIX/parking/electric-signs', electricSignApi.router);

    // 레거시 호환성 라우트 (기존 클라이언트 지원용)
    _router.mount('$API_PREFIX/parking/information/legacy',
        baseInformationApi.legacyRouter);
    _router.mount('$API_PREFIX/parking/electric-signs/legacy',
        electricSignApi.legacyRouter);

    _router.mount('$API_PREFIX/parking/central', central.router);
    _router.mount('$API_PREFIX/parking/pabi', pabi.router);
  }

  /// 시스템 관련 라우트 설정
  void _configureSystemRoutes() {
    final billBoard = BillBoard(manageAddress: _manageAddress);
    final display = Display(manageAddress: _manageAddress);
    final ledCal = LedCal(manageAddress: _manageAddress);

    _router.mount('$API_PREFIX/system/billboard', billBoard.router);
    _router.mount('$API_PREFIX/system/display', display.router);
    _router.mount('$API_PREFIX/system/led-calendar', ledCal.router);
  }

  /// 모니터링 관련 라우트 설정
  void _configureMonitoringRoutes() {
    final isalive = Isalive(manageAddress: _manageAddress);
    final ping = Ping(manageAddress: _manageAddress);
    final error = Error(manageAddress: _manageAddress);

    // 새로운 RESTful 모니터링 API (리팩토링됨)
    final monitoringApi = MonitoringApi(manageAddress: _manageAddress);

    // 새로운 RESTful API 라우트
    _router.mount('$API_PREFIX/monitoring', monitoringApi.router);

    // 레거시 호환성 라우트 (기존 클라이언트 지원용)
    _router.mount('$API_PREFIX/monitoring/legacy/health', isalive.router);
    _router.mount('$API_PREFIX/monitoring/legacy/ping', ping.router);
    _router.mount('$API_PREFIX/monitoring/legacy/errors', error.router);
  }

  /// 리소스 관리 라우트 설정
  void _configureResourceRoutes() {
    final getResource = GetResource(manageAddress: _manageAddress);

    // 새로운 RESTful 리소스 관리 API (리팩토링됨)
    final resourceManagementApi =
        ResourceManagementApi(manageAddress: _manageAddress);

    // 새로운 RESTful API 라우트
    _router.mount('$API_PREFIX/resources', resourceManagementApi.router);

    // 레거시 호환성 라우트 (기존 클라이언트 지원용)
    _router.mount('$API_PREFIX/resources/legacy', getResource.router);
  }

  /// RTSP 캡처 관련 라우트 설정
  void _configureRtspRoutes() {
    // 주의: RTSP 캡처 서비스와 스케줄러는 main.dart에서 초기화되어 주입됨
    // 여기서는 임시로 null 체크를 통해 초기화
    print('⚠️  RTSP API 라우트 등록 준비 중...');
    print('   실제 서비스는 main.dart에서 초기화 후 연결됩니다.');
  }

  /// 새로 리팩토링된 API 라우트 설정 (OpenAPI 3.0 표준)
  void _configureRefactoredApiRoutes() {
    // 15단계 리팩토링으로 새로 생성된 RESTful API들

    // 10단계: central_dashboard_api.dart (중앙 대시보드)
    final centralDashboardApi =
        CentralDashboardApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/central', centralDashboardApi.router);

    // 11단계: vehicle_info_api.dart (차량 정보)
    final vehicleInfoApi = VehicleInfoApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/vehicle', vehicleInfoApi.router);

    // 12단계: billboard_api.dart (전광판)
    final billboardApi = BillboardApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/billboard', billboardApi.router);

    // 13단계: display_api.dart (디스플레이)
    final displayApi = DisplayApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/display', displayApi.router);

    // 14단계: led_calculation_api.dart (LED 계산)
    final ledCalculationApi = LedCalculationApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/led', ledCalculationApi.router);

    // 15단계: system_health_api.dart (시스템 상태)
    final systemHealthApi = SystemHealthApi(manageAddress: _manageAddress);
    _router.mount('$API_PREFIX/system', systemHealthApi.router);

    print('✅ 새로 리팩토링된 RESTful API들이 추가되었습니다:');
    print('   ├── $API_PREFIX/central/* (중앙 대시보드)');
    print('   ├── $API_PREFIX/vehicle/* (차량 정보)');
    print('   ├── $API_PREFIX/billboard/* (전광판)');
    print('   ├── $API_PREFIX/display/* (디스플레이)');
    print('   ├── $API_PREFIX/led/* (LED 계산)');
    print('   └── $API_PREFIX/system/* (시스템 상태)');
  }

  /// Swagger UI 및 API 문서 라우트 설정
  void _configureSwaggerRoutes() {
    // 기본 Swagger UI - 완전한 145개 API 문서 UI로 변경
    _router.get('/docs', (Request request) {
      return _serveStaticFile('swagger-ui-complete.html', 'text/html');
    });

    // 표준 Swagger UI 경로 (기본 API 문서)
    _router.get('/swagger-ui.html', (Request request) {
      return _serveStaticFile('swagger-ui.html', 'text/html');
    });

    // API 문서 접근을 위한 별칭
    _router.get('/api-docs', (Request request) {
      return _serveStaticFile('swagger-ui-complete.html', 'text/html');
    });

    // 완전한 145개 API 문서 UI (별칭 유지)
    _router.get('/docs-complete', (Request request) {
      return _serveStaticFile('swagger-ui-complete.html', 'text/html');
    });

    // OpenAPI 스펙 YAML 파일 서빙 (기본 - 주요 API)
    _router.get('/swagger.yaml', (Request request) {
      return _serveStaticFile('swagger.yaml', 'application/x-yaml');
    });

    // 완전한 145개 API 문서 서빙
    _router.get('/swagger-complete.yaml', (Request request) {
      return _serveStaticFile('swagger_complete.yaml', 'application/x-yaml');
    });

    // OpenAPI 스펙 JSON 형태로도 제공 (향후 추가 가능)
    _router.get('/openapi.json', (Request request) {
      return Response.ok(
        '{"message": "JSON 형식은 추후 제공 예정입니다. /swagger.yaml을 사용해주세요."}',
        headers: {'Content-Type': 'application/json'},
      );
    });

    print('📚 Swagger 문서가 다음 경로에서 제공됩니다:');
    print('   • 기본 Swagger UI: http://localhost:8080/swagger-ui.html');
    print('   • 완전한 API UI (145개): http://localhost:8080/docs');
    print('   • API 문서 별칭: http://localhost:8080/api-docs');
    print('   • 기본 OpenAPI 스펙: http://localhost:8080/swagger.yaml');
    print('   • 완전한 145개 API 스펙: http://localhost:8080/swagger-complete.yaml');
  }

  /// 정적 파일 서빙 헬퍼 메서드
  Response _serveStaticFile(String fileName, String contentType) {
    try {
      // 프로젝트 루트에서 파일 읽기
      final file = File(fileName);
      if (!file.existsSync()) {
        return Response.notFound('파일을 찾을 수 없습니다: $fileName');
      }

      final content = file.readAsStringSync();
      return Response.ok(
        content,
        headers: {
          'Content-Type': contentType,
          'Cache-Control': 'no-cache, no-store, must-revalidate', // 캐시 무효화
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
    } catch (e) {
      print('❌ 정적 파일 서빙 오류: $e');
      return Response.internalServerError(
        body: '파일을 읽는 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 기존 경로 호환성을 위한 임시 라우트 (단계적 마이그레이션용)
  void _configureLegacyRoutes() {
    // TODO: 클라이언트 마이그레이션 완료 후 제거 예정
    final confirmAccountList =
        ConfirmAccountList(manageAddress: _manageAddress);
    final createAdmin = CreateAdmin(confirmAccountList: confirmAccountList);
    final loginMain = LoginMain(manageAddress: _manageAddress);
    final loginSetting = LoginSetting(confirmAccountList: confirmAccountList);
    final settingsAccount = SettingsAccount(manageAddress: _manageAddress);
    final settingsParkingArea =
        SettingsParkingArea(manageAddress: _manageAddress);
    final settingsCamParkingArea =
        SettingsCamParkingArea(manageAddress: _manageAddress);
    final baseInformation = BaseInformation(manageAddress: _manageAddress);
    final multipleElectricSigns =
        MultipleElectricSigns(manageAddress: _manageAddress);

    // 레거시 호환성 레이어 (리팩토링된 서비스 사용)
    final legacyPabi = LegacyPabi(manageAddress: _manageAddress);

    // 기존 경로들을 임시로 유지 (Deprecated)
    _router.mount('/confirm_account_list', confirmAccountList.router);
    _router.mount('/create_admin', createAdmin.router);
    _router.mount('/parking_status', loginMain.router);
    _router.mount('/login_setting', loginSetting.router);
    _router.mount('/settings_account', settingsAccount.router);
    _router.mount('/settings_parking_area', settingsParkingArea.router);
    _router.mount('/settings_cam_parking_area', settingsCamParkingArea.router);
    _router.mount('/base_information', baseInformation.router);
    _router.mount('/multiple_electric_signs', multipleElectricSigns.router);
    
    // 레거시 차량 정보 API (/pabi/tag, /pabi/car)
    _router.mount('/pabi', legacyPabi.router);

    print('⚠️  레거시 라우트가 활성화되었습니다. 향후 버전에서 제거될 예정입니다.');
    print('   • /login_setting - 로그인 및 인증');
    print('   • /pabi - 차량 정보 조회 (tag/car)');
    print('   • /settings_account - 사용자 관리');
    print('   • /settings_parking_area - 주차 구역 관리');
    print('   • ... 기타 레거시 경로');
  }

  /// 초기 설정 실행
  Future<void> _initializeSettings() async {
    final displayDbAddr = _manageAddress.displayDbAddr;
    if (displayDbAddr != null) {
      await firstSetting(displayDbAddr);
      print('✅ 초기 설정이 완료되었습니다.');
    } else {
      print('⚠️  Display DB 주소가 설정되지 않아 초기 설정을 건너뛰었습니다.');
    }
  }

  /// 설정된 라우터 반환
  Router get router => _router;

  /// RTSP 캡처 API를 동적으로 등록 (main.dart에서 서비스 초기화 후 호출)
  void mountRtspApi(RtspCaptureApi rtspApi) {
    try {
      _router.mount('$API_PREFIX/rtsp', rtspApi.router);
      print('✅ RTSP 캡처 API 등록 완료: $API_PREFIX/rtsp');
    } catch (e) {
      print('❌ RTSP 캡처 API 등록 실패: $e');
    }
  }

  /// API 정보 출력 (개발용)
  void printApiInfo() {
    print('\n🚀 API Server Information:');
    print('   API Version: v1');
    print('   Base Path: $API_PREFIX');
    print('   Available Endpoints:');
    print('   ├── Auth: $API_PREFIX/auth/* (완전 리팩토링됨 ✅)');
    print('   ├── Users: $API_PREFIX/users/* (완전 리팩토링됨 ✅)');
    print('   ├── Engine: $API_PREFIX/engine/* (완전 리팩토링됨 ✅)');
    print('   ├── Settings: $API_PREFIX/settings/* (완전 리팩토링됨 ✅)');
    print('   ├── Statistics: $API_PREFIX/statistics/* (완전 리팩토링됨 ✅)');
    print('   ├── Parking: $API_PREFIX/parking/* (완전 리팩토링됨 ✅)');
    print('   ├── System: $API_PREFIX/system/* (레거시 + 신규 혼재 ⚠️)');
    print('   ├── Monitoring: $API_PREFIX/monitoring/* (완전 리팩토링됨 ✅)');
    print('   ├── Resources: $API_PREFIX/resources/* (완전 리팩토링됨 ✅)');
    print(
        '   └── 신규 RESTful APIs: central, vehicle, billboard, display, led (완전 리팩토링됨 ✅)');
    print('');
    print('📝 리팩토링 상태 요약:');
    print(
        '   • 완전 리팩토링: Auth, Users, Engine, Settings, Statistics, Parking, Monitoring, Resources, 신규 6개 API');
    print('   • 일부 리팩토링: System (레거시 + 신규 혼재)');
    print('   • 모든 주요 API 리팩토링 완료! 🎉');
    print('');
  }
}
