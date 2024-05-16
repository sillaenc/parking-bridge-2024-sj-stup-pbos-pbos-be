// bin/main.dart
import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'routes/confirm_account_list.dart'; // 계정 확인
import 'routes/create_admin.dart'; // 관리자 계정 생성
import 'routes/firstSetting.dart';
import 'routes/login_setting.dart'; // 주차 관련 차량 정보 획득
import 'routes/login_main.dart';

import 'routes/receive_enginedata_send_to_dartserver.dart';
import 'routes/settings_db_management.dart';
import 'routes/settings_account.dart';
import 'routes/settings_parking_area.dart';
import 'routes/settings_cam_parking_area.dart';
import 'package:http/http.dart' as http;

import 'package:dotenv/dotenv.dart';

import 'routes/statistics_cam_parking_area.dart';
import 'data/manage_address.dart';

String formatDateTime(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String hour = dateTime.hour.toString().padLeft(2, '0');

  return "$year-$month-$day $hour";
}

void main() async {
  // 라우터 생성
  // 2초마다 작업 실행
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // ManageAddress 인스턴스 생성
  ManageAddress manageAddress = ManageAddress();
  // ConfirmAccountList와 CreateAdmin의 생성자를 호출하여 ManageAddress 인스턴스를 전달합니다.
  ConfirmAccountList confirmAccountList = ConfirmAccountList(manageAddress);
  CreateAdmin createAdmin = CreateAdmin(confirmAccountList);
  LoginMain loginMain = LoginMain(manageAddress);
  LoginSetting loginSetting = LoginSetting(confirmAccountList);
  SettingsAccount settingsAccount = SettingsAccount(manageAddress);
  StatisticsCamParkingArea statisticsCamParkingArea = StatisticsCamParkingArea(manageAddress);
  SettingsDbManagement settingsDbManagement = SettingsDbManagement(manageAddress);
  SettingsParkingArea settingsParkingArea = SettingsParkingArea(manageAddress);
  SettingsCamParkingArea settingsCamParkingArea = SettingsCamParkingArea(manageAddress);

  final router = Router();

  manageAddress.displayDbAddr = env['displayDbAddr'];
  String? url = env['displayDbAddr'];
  var displayaddr = manageAddress.displayDbAddr;
  DateTime check = DateTime.now();

  firstSetting(url);

  //2Seconds Per delay - 반복 동작.
  Timer.periodic(Duration(seconds: 2), (timer) async {
    var engineaddr;
    try {
      var header = {'Content-Type': 'application/json'};
      var body = {
        "transaction": [
          {"query": "SELECT * from tb_db_setting"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: header,
        body: jsonEncode(body),
      );
      var engine = jsonDecode(response.body);
      engineaddr = engine['results'][0]['resultSet'][0]['engine_db_addr'];
      manageAddress.engineDbAddr = engineaddr;
      
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }
    var enginedData = await receiveEnginedataSendToDartserver(engineaddr, displayaddr, check);
    print(enginedData);
    var jsonDB = jsonEncode(enginedData);
    router.get('/getResource', (Request request) {
      return Response.ok(jsonDB);
    });
    DateTime now = DateTime.now();
    check = now;
  });

  // 이미 생성된 인스턴스의 메서드 전달
  router.mount('/confirm_account_list', confirmAccountList.router);
  router.mount('/create_admin', createAdmin.router);
  router.mount('/login_main', loginMain.router);
  router.mount('/login_setting', loginSetting.router);

  // 아래는 인스턴스를 생성해 그 인스턴스의 메서드를 직접 호출
  router.mount('/settings/db_management', settingsDbManagement.router);
  router.mount('/settings/account', settingsAccount.router);
  router.mount('/settings/parking_area', settingsParkingArea.router);
  router.mount('/settings/cam_parking_area', settingsCamParkingArea.router);
  router.mount('/statistics/cam_parking_area', statisticsCamParkingArea.router);

  var handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((Handler innerHandler) {
    return (Request request) async {
      var headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      };
      // Handle preflight requests
      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: headers);
      }
      // Handle other requests
      Response response = await innerHandler(request);
      return response.change(headers: headers);
    };
  }).addHandler(router);

  // 서버 시작
  var server = await serve(handler, 'localhost', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
