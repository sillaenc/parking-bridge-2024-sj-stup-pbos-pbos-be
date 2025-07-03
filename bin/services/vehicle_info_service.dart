/// 차량 정보 조회 비즈니스 로직 서비스
///
/// 주차 구역별 차량 정보 및 번호판 기반 차량 위치 조회를 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_info_models.dart';
import '../data/manage_address.dart';

class VehicleInfoService {
  final ManageAddress manageAddress;

  VehicleInfoService({required this.manageAddress});

  /// 태그(주차 구역)로 차량 정보 조회
  ///
  /// 특정 주차 구역에 주차된 차량의 정보를 조회
  Future<VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>>
      getVehicleInfoByTag(VehicleInfoByTagRequest request) async {
    try {
      // 태그 유효성 검사
      if (request.tag.isEmpty) {
        return VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>(
          success: false,
          message: '주차 구역 태그가 제공되지 않았습니다.',
          error: 'MISSING_TAG',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {
            "query": "#get_plate",
            "values": {"tag": request.tag}
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final decodedResponse = jsonDecode(utf8DecodedBody);

      final resultSet = decodedResponse['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>(
          success: false,
          message: '해당 주차 구역을 찾을 수 없습니다.',
          error: 'TAG_NOT_FOUND',
        );
      }

      final vehicleData = resultSet[0];
      final vehicleInfo = ParkingSpaceVehicleInfo.fromJson(vehicleData);

      return VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>(
        success: true,
        message: '차량 정보 조회 완료',
        data: vehicleInfo,
      );
    } catch (e, stackTrace) {
      print('VehicleInfoService.getVehicleInfoByTag 오류: $e');
      print('스택 트레이스: $stackTrace');

      return VehicleInfoServiceResponse<ParkingSpaceVehicleInfo>(
        success: false,
        message: '차량 정보 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 번호판으로 차량 위치 조회
  ///
  /// 번호판 번호를 통해 차량이 주차된 위치를 조회
  Future<VehicleInfoServiceResponse<List<VehicleLocationInfo>>>
      getVehicleLocationByPlate(VehicleInfoByPlateRequest request) async {
    try {
      // 번호판 유효성 검사
      if (request.plate.isEmpty) {
        return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
          success: false,
          message: '차량 번호판이 제공되지 않았습니다.',
          error: 'MISSING_PLATE',
        );
      }

      // 번호판 형식 검증 (한국 차량 번호판 기본 패턴)
      if (!_isValidPlateNumber(request.plate)) {
        return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
          success: false,
          message: '유효하지 않은 차량 번호판 형식입니다.',
          error: 'INVALID_PLATE_FORMAT',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final searchPlate = '%${request.plate}';

      final body = {
        "transaction": [
          {
            "query": "#get_tag",
            "values": {"plate": searchPlate}
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final decodedResponse = jsonDecode(utf8DecodedBody);

      final resultSet = decodedResponse['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
          success: false,
          message: '해당 번호판의 차량을 찾을 수 없습니다.',
          error: 'VEHICLE_NOT_FOUND',
        );
      }

      final locationInfoList =
          resultSet.map((item) => VehicleLocationInfo.fromJson(item)).toList();

      return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
        success: true,
        message: '차량 위치 조회 완료 (${locationInfoList.length}건)',
        data: locationInfoList,
      );
    } catch (e, stackTrace) {
      print('VehicleInfoService.getVehicleLocationByPlate 오류: $e');
      print('스택 트레이스: $stackTrace');

      return VehicleInfoServiceResponse<List<VehicleLocationInfo>>(
        success: false,
        message: '차량 위치 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 번호판 형식 유효성 검사
  ///
  /// 한국 차량 번호판의 기본적인 형식을 검증
  bool _isValidPlateNumber(String plate) {
    if (plate.isEmpty || plate.length < 4) return false;

    // 특수문자나 공백 제거 후 길이 확인
    final cleanedPlate = plate.replaceAll(RegExp(r'[^가-힣a-zA-Z0-9]'), '');
    if (cleanedPlate.length < 4 || cleanedPlate.length > 8) return false;

    // 한글, 영문, 숫자 조합 확인
    final hasKorean = RegExp(r'[가-힣]').hasMatch(cleanedPlate);
    final hasAlphaNumeric = RegExp(r'[a-zA-Z0-9]').hasMatch(cleanedPlate);

    return hasKorean || hasAlphaNumeric;
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) return false;

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {
            "query": "#get_plate",
            "values": {"tag": "TEST"}
          }
        ]
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('VehicleInfoService 상태 확인 실패: $e');
      return false;
    }
  }
}
