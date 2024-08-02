// bin/main.dart
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

String formatDateTime(DateTime dateTime) {
  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String hour = dateTime.hour.toString().padLeft(2, '0');

  return "$year-$month-$day $hour";
}
void main() async {
  // 라우터 생성
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // 인스턴스는 메모리 누수의 주범. dart 같이 garbage collector가 제대로 돌아가지 않는 언어인 경우, 함부로 인스턴스 선언을 통해 메모리 누수를 유발하지 말것!! 
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
  final router = Router();

  manageAddress.displayDbAddr = env['displayDbAddr'];
  String? url = env['displayDbAddr'];
  var displayaddr = manageAddress.displayDbAddr;
  DateTime check = DateTime.now();
  // List enginedData;
  router.mount('/confirm_account_list', confirmAccountList.router);
  router.mount('/create_admin', createAdmin.router);
  router.mount('/login_main', loginMain.router);
  router.mount('/login_setting', loginSetting.router);
  router.mount('/settings/db_management', settingsDbManagement.router);
  router.mount('/settings/account', settingsAccount.router);
  router.mount('/settings/parking_area', settingsParkingArea.router);
  router.mount('/settings/cam_parking_area', settingsCamParkingArea.router);
  router.mount('/statistics/cam_parking_area', statisticsCamParkingArea.router);
  router.mount('/multiple_electric_signs', multipleElectricSigns.router);
  router.mount('/getResource', getResource.router);

  firstSetting(url);
  //0.5 Seconds Per delay - 반복 동작.
  Timer.periodic(Duration(milliseconds: 1000), (timer) async {
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
      //print('engine : $engine');
      engineaddr = engine['results'][0]['resultSet'][0]['engine_db_addr'];
      manageAddress.engineDbAddr = engineaddr;
      
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }

    await receiveEnginedataSendToDartserver(engineaddr, displayaddr, check);
    // String strRawData;
    // List enginedData = await receiveEnginedataSendToDartserver(engineaddr, displayaddr, check);
    // router.get('/getResource', (Request request) async {
    //   strRawData = 'start,${enginedData.join(',')}';
    //   return Response.ok(strRawData);
    // });
    // strRawData='';
    // enginedData.clear();

    DateTime now = DateTime.now();
    check = now;
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
  var server = await serve(handler, '0.0.0.0', 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
