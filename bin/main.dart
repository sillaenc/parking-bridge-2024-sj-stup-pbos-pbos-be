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

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  final manageAddress = ManageAddress();
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
  final graphdata = graphData(manageAddress: manageAddress);
  final central = Central(manageAddress: manageAddress);
  final baseInformation = BaseInformation(manageAddress: manageAddress);
  final billBoard = BillBoard(manageAddress: manageAddress);
  final display = Display(manageAddress: manageAddress);
  final settings = Settings(manageAddress: manageAddress);
  final isalive = Isalive(manageAddress: manageAddress);
  final pabi = Pabi(manageAddress: manageAddress);
  // final pabi = Pabi();
  final router = Router();

  manageAddress.displayDbAddr = env['displayDbAddr'];
  manageAddress.displayDbLPR = env['displayDbLPR'];

  String? url = manageAddress.displayDbAddr;
  DateTime check = DateTime.now();

  router.mount('/confirm_account_list', confirmAccountList.router);
  router.mount('/create_admin', createAdmin.router);
  router.mount('/parking_status', loginMain.router);
  router.mount('/login_setting', loginSetting.router);
  router.mount('/settings/db_management', settingsDbManagement.router);
  router.mount('/settings/account', settingsAccount.router);
  router.mount('/settings/parking_area', settingsParkingArea.router);
  router.mount('/settings/cam_parking_area', settingsCamParkingArea.router);
  router.mount('/statistics/cam_parking_area', statisticsCamParkingArea.router);
  router.mount('/multiple_electric_signs', multipleElectricSigns.router);
  router.mount('/getResource', getResource.router);
  router.mount('/graphData', graphdata.router);
  router.mount('/central', central.router);
  router.mount('/base', baseInformation.router);
  router.mount('/billboard',billBoard.router);
  router.mount('/display',display.router);
  router.mount('/settings', settings.router);
  router.mount('/isalive', isalive.router);
  router.mount('/pabi', pabi.router);
  
  firstSetting(url);

  // http.Client를 재사용하기 위한 인스턴스
  final client = http.Client();

  bool isProcessing = false; // 타이머 콜백 중복 실행 방지용 플래그
  
  Timer.periodic(Duration(milliseconds: 4000), (timer) async {
    if (isProcessing) {
      // 이전 주기 작업이 아직 끝나지 않았다면 이번 주기 건너뛰기, 확인용!!
      return;
    }
    isProcessing = true;
    try {
      final engineAddr = await fetchEngineAddr(client, url!);
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
      .addMiddleware((Handler innerHandler) {
    return (Request request) async {
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      };
      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: headers);
      }
      Response response = await innerHandler(request);
      return response.change(headers: headers);
    };
  }).addHandler(router);

  int? port = int.tryParse(env['PORT']!);
  print('port is $port');
  var server = await serve(handler, '0.0.0.0', port!);
  print('Serving at http://${server.address.host}:${server.port}');

  // 서버 종료 시점에 client 자원 해제
  // 이 예제에서는 서버가 무기한 동작하므로 SIGTERM 등 잡아서 종료 시 client.close() 처리 가능
  // ProcessSignal.sigterm.watch().listen((signal) async {
  //   print('Received $signal, closing http.Client()');
  //   client.close();
  //   await server.close();
  //   exit(0);
  // });
}
