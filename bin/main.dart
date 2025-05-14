/// bin/main.dart
import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'routes/confirm_account_list.dart'; // 계정 확인
import 'routes/create_admin.dart'; // 관리자 계정 생성
import 'routes/first_setting.dart';
import 'routes/login_setting.dart'; // 주차 관련 차량 정보 획득
import 'routes/login_main.dart';
import 'routes/multiple_electric_signs.dart';
import 'routes/receive_enginedata_send_to_dartserver.dart';
import 'routes/settings_db_management.dart';
import 'routes/settings_account.dart';
import 'routes/settings_parking_area.dart';
import 'routes/settings_cam_parking_area.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'routes/statistics_cam_parking_area.dart';
import 'data/manage_address.dart';
import 'routes/get_resource.dart';
import 'routes/graphData.dart';
import 'routes/central.dart';
import 'routes/base_information.dart';
import 'routes/billboard.dart';
import 'routes/display.dart';
import 'routes/settings.dart';
import 'routes/isalive.dart';
import 'routes/pabi.dart';
import 'routes/led_cal.dart';
import 'routes/ping.dart';

String formatDateTime(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String hour = dateTime.hour.toString().padLeft(2, '0');

  return "$year-$month-$day $hour";
}

Future<String?> fetchEngineAddr(http.Client client, String url) async {
  try {
    var header = {'Content-Type': 'application/json'};
    var body = {
      "transaction": [
        {"query": "#S_TbDbSetting"}
      ]
    };
    var response = await client.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var engine = jsonDecode(response.body);
      return engine['results'][0]['resultSet'][0]['engine_db_addr'];
    } else {
      print('Failed to fetch engine address. Status code: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error fetching engine address: $e');
    print('StackTrace: $stackTrace');
  }
  return null;
}

// 표준화된 응답 형식을 위한 미들웨어
Middleware standardResponse() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        final response = await innerHandler(request);
        final body = await response.readAsString();
        Map<String, dynamic> responseBody;
        
        try {
          responseBody = json.decode(body);
        } catch (e) {
          responseBody = {'data': body};
        }

        final standardizedResponse = {
          'status': response.statusCode < 400 ? 'success' : 'error',
          'data': responseBody,
          'message': response.statusCode < 400 ? '성공적으로 처리되었습니다' : '처리 중 오류가 발생했습니다',
          'timestamp': DateTime.now().toIso8601String(),
        };

        return Response(
          response.statusCode,
          body: json.encode(standardizedResponse),
          headers: {
            'content-type': 'application/json',
            ...response.headers,
          },
        );
      } catch (e) {
        final errorResponse = {
          'status': 'error',
          'data': null,
          'message': '서버 내부 오류가 발생했습니다',
          'timestamp': DateTime.now().toIso8601String(),
        };

        return Response(
          500,
          body: json.encode(errorResponse),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

// CORS 미들웨어
Middleware corsHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
        });
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      });
    };
  };
}

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final manageAddress = ManageAddress();
  manageAddress.displayDbAddr = env['displayDbAddr'];
  manageAddress.displayDbLPR = env['displayDbLPR'];
  final confirmAccountList = ConfirmAccountList(manageAddress: manageAddress);
  final createAdmin = CreateAdmin(confirmAccountList: confirmAccountList);
  final loginMain = LoginMain(manageAddress: manageAddress);
  final loginSetting = LoginSetting(confirmAccountList: confirmAccountList);
  final settingsAccount = SettingsAccount(manageAddress: manageAddress);
  final statisticsCamParkingArea = StatisticsCamParkingArea(manageAddress: manageAddress);
  final settingsDbManagement = SettingsDbManagement(manageAddress: manageAddress);
  final settingsParkingArea = SettingsParkingArea(manageAddress: manageAddress);
  final settingsCamParkingArea = SettingsCamParkingArea(manageAddress: manageAddress);
  final multipleElectricSigns = MultipleElectricSigns(manageAddress: manageAddress);
  final getResource = GetResource(manageAddress: manageAddress);
  final graphdata = GraphData(manageAddress: manageAddress);
  final central = Central(manageAddress: manageAddress);
  final baseInformation = BaseInformation(manageAddress: manageAddress);
  final billBoard = BillBoard(manageAddress: manageAddress);
  final display = Display(manageAddress: manageAddress);
  final settings = Settings(manageAddress: manageAddress);
  final isalive = Isalive(manageAddress: manageAddress);
  final pabi = Pabi(manageAddress: manageAddress);
  final ledCal = LedCal(manageAddress: manageAddress);
  final ping = Ping(manageAddress: manageAddress);

  final router = Router();

  // API 버전 1 라우팅
  final api = Router();

  // 계정 관련 API
  api.mount('/accounts', confirmAccountList.router);
  api.mount('/accounts/admin', createAdmin.router);
  api.mount('/accounts/settings', settingsAccount.router);

  // 주차장 관련 API
  api.mount('/parking-areas', settingsParkingArea.router);
  api.mount('/parking-areas/cam', settingsCamParkingArea.router);
  api.mount('/parking-areas/status', loginMain.router);
  api.mount('/parking-areas/settings', loginSetting.router);

  // 통계 관련 API
  api.mount('/statistics/parking-areas', statisticsCamParkingArea.router);
  api.mount('/statistics/graph', graphdata.router);

  // 디스플레이 관련 API
  api.mount('/displays', display.router);
  api.mount('/displays/electric-signs', multipleElectricSigns.router);
  api.mount('/displays/billboard', billBoard.router);
  api.mount('/displays/led-calibration', ledCal.router);

  // 시스템 관련 API
  api.mount('/system/settings', settings.router);
  api.mount('/system/db-management', settingsDbManagement.router);
  api.mount('/system/base-info', baseInformation.router);
  api.mount('/system/central', central.router);
  api.mount('/system/pabi', pabi.router);
  api.mount('/system/resource', getResource.router);

  // 상태 확인 API
  api.mount('/health/isalive', isalive.router);
  api.mount('/health/ping', ping.router);

  // API 버전 1을 메인 라우터에 마운트
  router.mount('/api/v1', api);

  String? url = manageAddress.displayDbAddr;
  DateTime check = DateTime.now();

  firstSetting(url);

  // http.Client를 재사용하기 위한 인스턴스
  final client = http.Client();
  final engineAddr = await fetchEngineAddr(client, url!);
  manageAddress.engineDbAddr = engineAddr;
  bool isProcessing = false; // 타이머 콜백 중복 실행 방지용 플래그
  
  Timer.periodic(Duration(milliseconds: 1000), (timer) async {
    if (isProcessing) {
      // 이전 주기 작업이 아직 끝나지 않았다면 이번 주기 건너뛰기, 확인용!!
      return;
    }
    isProcessing = true;
    try {
      final engineAddr = await fetchEngineAddr(client, url);
      // print(engineAddr);
      if (engineAddr != null && manageAddress.displayDbAddr != null) {
        await receiveEnginedataSendToDartserver(engineAddr, manageAddress.displayDbAddr!,manageAddress.displayDbLPR, check);
        check = DateTime.now();
      }
    } catch (e, stackTrace) {
      print('Error in periodic task: $e');
      print('StackTrace: $stackTrace');
    } finally {
      isProcessing = false;
    }
  });

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addMiddleware(standardResponse())
      .addHandler(router);

  int? port = int.tryParse(env['PORT']!);
  print('Server running on port $port');
  var server = await serve(handler, '0.0.0.0', port!);
  print('Serving at http://${server.address.host}:${server.port}');
}
