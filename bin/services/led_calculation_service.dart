/// LED 계산 비즈니스 로직 서비스
///
/// LED 표시등 계산 및 카메라별 상태 결정을 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/led_calculation_models.dart';
import '../data/manage_address.dart';

class LedCalculationService {
  final ManageAddress manageAddress;

  LedCalculationService({required this.manageAddress});

  /// LED 계산 수행
  ///
  /// 카메라별 주차 공간 사용률을 계산하여 LED 색상 결정
  Future<LedCalculationServiceResponse> calculateLedStatus() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return LedCalculationServiceResponse(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#cal_get"}
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      final decodedResponse = jsonDecode(response.body);
      final resultSet = decodedResponse['results'][0]['resultSet'] as List;

      if (resultSet.isEmpty) {
        return LedCalculationServiceResponse(
          success: false,
          message: 'LED 계산을 위한 데이터가 없습니다.',
          error: 'NO_CALCULATION_DATA',
        );
      }

      // 카메라별 상태 계산
      final cameraStatuses = <CameraStatusInfo>[];
      int redCount = 0;
      int greenCount = 0;

      for (final entry in resultSet) {
        final camera = entry['camera']?.toString() ?? '';
        final tagCount = entry['tag_count'] ?? 0;
        final isUsedCount = entry['isUsed_count'] ?? 0;

        final cameraStatus =
            CameraStatusInfo.fromCalculation(camera, tagCount, isUsedCount);
        cameraStatuses.add(cameraStatus);

        if (cameraStatus.color == 'red') {
          redCount++;
        } else {
          greenCount++;
        }
      }

      final responseData = LedCalculationResponseData(
        cameraStatuses: cameraStatuses,
        totalCameras: cameraStatuses.length,
        redCount: redCount,
        greenCount: greenCount,
      );

      return LedCalculationServiceResponse(
        success: true,
        message: 'LED 계산 완료 (총 ${cameraStatuses.length}개 카메라)',
        data: responseData,
      );
    } catch (e, stackTrace) {
      print('LedCalculationService.calculateLedStatus 오류: $e');
      print('스택 트레이스: $stackTrace');

      return LedCalculationServiceResponse(
        success: false,
        message: 'LED 계산 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 서비스 상태 확인
  Future<bool> isServiceHealthy() async {
    try {
      final url = manageAddress.displayDbAddr;
      if (url == null) return false;

      final headers = {'Content-Type': 'application/json'};
      final body = {
        "transaction": [
          {"query": "#cal_get"}
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
      print('LedCalculationService 상태 확인 실패: $e');
      return false;
    }
  }
}
