/// 디스플레이 비즈니스 로직 서비스
///
/// 디스플레이 정보 조회 및 대량 업데이트를 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/display_models.dart';
import '../data/manage_address.dart';

class DisplayService {
  final ManageAddress manageAddress;

  DisplayService({required this.manageAddress});

  /// 층별 디스플레이 정보 조회
  ///
  /// 쉼표로 구분된 여러 층의 디스플레이 정보를 조회
  Future<DisplayServiceResponse<DisplayResponseData>> getDisplayInfo(
      DisplayInfoRequest request) async {
    try {
      // 층 정보 유효성 검사
      if (request.floors.isEmpty) {
        return DisplayServiceResponse<DisplayResponseData>(
          success: false,
          message: '층 정보가 제공되지 않았습니다.',
          error: 'MISSING_FLOORS',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return DisplayServiceResponse<DisplayResponseData>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      // 층 정보 파싱
      List<String> floors = request.floors.contains(',')
          ? request.floors.split(',').map((f) => f.trim()).toList()
          : [request.floors.trim()];

      final headers = {'Content-Type': 'application/json'};
      List<DisplayInfo> combinedResults = [];

      // 각 층마다 병렬로 쿼리 실행
      final futures = floors
          .map((floor) => _getFloorDisplayInfo(url, headers, floor))
          .toList();
      final results = await Future.wait(futures);

      // 결과 합치기
      for (final result in results) {
        combinedResults.addAll(result);
      }

      final responseData = DisplayResponseData(
        floors: floors,
        displayInfoList: combinedResults,
        totalCount: combinedResults.length,
      );

      return DisplayServiceResponse<DisplayResponseData>(
        success: true,
        message:
            '디스플레이 정보 조회 완료 (${floors.length}개 층, ${combinedResults.length}개 항목)',
        data: responseData,
      );
    } catch (e, stackTrace) {
      print('DisplayService.getDisplayInfo 오류: $e');
      print('스택 트레이스: $stackTrace');

      return DisplayServiceResponse<DisplayResponseData>(
        success: false,
        message: '디스플레이 정보 조회 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 개별 층의 디스플레이 정보 조회
  Future<List<DisplayInfo>> _getFloorDisplayInfo(
      String url, Map<String, String> headers, String floor) async {
    final body = {
      "transaction": [
        {
          "query": "#display",
          "values": {"floor": floor}
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final decodedResponse = jsonDecode(response.body);
    final resultSet = decodedResponse['results'][0]['resultSet'];

    if (resultSet is List) {
      return resultSet.map((item) => DisplayInfo.fromJson(item)).toList();
    } else if (resultSet != null) {
      return [DisplayInfo.fromJson(resultSet)];
    } else {
      return [];
    }
  }

  /// 대량 디스플레이 업데이트
  ///
  /// tb_lots 데이터를 기반으로 display 테이블을 대량 업데이트
  Future<DisplayServiceResponse<BulkUpdateResult>> bulkUpdateDisplay(
      BulkDisplayUpdateRequest request) async {
    try {
      // 데이터 유효성 검사
      if (request.tbLots.isEmpty) {
        return DisplayServiceResponse<BulkUpdateResult>(
          success: false,
          message: 'tb_lots 데이터가 제공되지 않았습니다.',
          error: 'MISSING_TB_LOTS_DATA',
        );
      }

      final url = manageAddress.displayDbAddr;
      if (url == null) {
        return DisplayServiceResponse<BulkUpdateResult>(
          success: false,
          message: '데이터베이스 주소가 설정되지 않았습니다.',
          error: 'DATABASE_ADDRESS_NOT_SET',
        );
      }

      final headers = {'Content-Type': 'application/json'};
      List<Map<String, dynamic>> transactions = [];
      List<String> errors = [];
      int totalItems = request.tbLots.length;

      // 각 tb_lots 항목에 대해 upsert 트랜잭션 생성
      request.tbLots.forEach((key, value) {
        try {
          // 필수 필드 검증
          if (!_validateDisplayItem(value)) {
            errors.add('$key: 필수 필드 누락 (tag, lot_type, point, asset, floor)');
            return;
          }

          transactions.add({
            "statement": "#display_dlatl",
            "values": {
              "tag": value['tag']?.toString() ?? '',
              "lot_type": value['lot_type']?.toString() ?? '',
              "point": value['point']?.toString() ?? '',
              "asset": value['asset']?.toString() ?? '',
              "floor": value['floor']?.toString() ?? '',
            }
          });
        } catch (e) {
          errors.add('$key: 데이터 처리 오류 - $e');
        }
      });

      // 트랜잭션 실행
      if (transactions.isNotEmpty) {
        final body = {"transaction": transactions};

        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode != 200) {
          errors.add('HTTP 요청 실패: ${response.statusCode}');
        }
      }

      final successCount = totalItems - errors.length;
      final updateResult = BulkUpdateResult(
        totalItems: totalItems,
        successCount: successCount,
        errors: errors,
      );

      final isFullSuccess = errors.isEmpty;

      return DisplayServiceResponse<BulkUpdateResult>(
        success: isFullSuccess,
        message: isFullSuccess
            ? '모든 디스플레이 업데이트 완료'
            : '일부 디스플레이 업데이트 실패 ($successCount/$totalItems)',
        data: updateResult,
      );
    } catch (e, stackTrace) {
      print('DisplayService.bulkUpdateDisplay 오류: $e');
      print('스택 트레이스: $stackTrace');

      return DisplayServiceResponse<BulkUpdateResult>(
        success: false,
        message: '대량 디스플레이 업데이트 중 오류가 발생했습니다.',
        error: e.toString(),
      );
    }
  }

  /// 디스플레이 항목 유효성 검사
  bool _validateDisplayItem(dynamic item) {
    if (item is! Map<String, dynamic>) return false;

    final requiredFields = ['tag', 'lot_type', 'point', 'asset', 'floor'];
    for (final field in requiredFields) {
      if (item[field] == null || item[field].toString().isEmpty) {
        return false;
      }
    }

    return true;
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
            "query": "#display",
            "values": {"floor": "TEST"}
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
      print('DisplayService 상태 확인 실패: $e');
      return false;
    }
  }
}
