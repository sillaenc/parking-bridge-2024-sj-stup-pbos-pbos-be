import '../models/parking_data.dart';
import '../data/global.dart';

/// 주차 데이터 파싱 및 에러 처리를 담당하는 서비스
/// 엔진에서 받은 원시 데이터를 구조화된 형태로 변환
class ParkingDataParser {
  /// 엔진 데이터를 파싱하여 주차장 데이터로 변환
  ///
  /// [engineData] 엔진에서 받은 원시 데이터
  /// Returns: 파싱된 주차장 데이터
  static ParkingLotData parseEngineData(EngineData engineData) {
    final parkingLot = engineData.parkingLot;

    // 쉼표로 분리하여 주차 공간 목록 생성
    final List<String> parkingLotList = parkingLot.split(',');

    // "start" 제거 및 정렬
    if (parkingLotList.isNotEmpty) {
      parkingLotList.removeAt(0); // "start" 제거
      parkingLotList.sort();
    }

    // 에러 슬롯 추출 및 글로벌 에러 리스트 업데이트
    final errorSlots = _extractErrorSlots(parkingLotList);

    return ParkingLotData(
      occupiedSlots: parkingLotList,
      errorSlots: errorSlots,
      totalSlots: parkingLotList.length,
    );
  }

  /// 에러 슬롯을 추출하고 글로벌 에러 리스트 업데이트
  ///
  /// [parkingLotList] 주차 공간 목록
  /// Returns: 에러가 발생한 슬롯 목록
  static List<String> _extractErrorSlots(List<String> parkingLotList) {
    final List<String> errorSlots = [];

    // 글로벌 에러 리스트 초기화
    error.clear();

    // X000을 포함하는 에러 슬롯 찾기
    for (final element in parkingLotList.where((e) => e.contains('X000'))) {
      final parts = element.split('_');
      if (parts.length >= 4) {
        final value = parts[1];
        if (!error.contains(value)) {
          error.add(value);
          errorSlots.add(element);
        }
      } else {
        // 예상 형식이 아닐 때 로그 출력
        print('⚠️  예상하지 못한 에러 슬롯 형식: $element');
        errorSlots.add(element);
      }
    }

    return errorSlots;
  }

  /// 주차 공간 목록과 현재 점유 상태를 비교하여 LotInfo 업데이트
  ///
  /// [lotInfoList] 현재 주차 공간 정보 목록
  /// [occupiedSlots] 점유된 슬롯 목록
  /// Returns: 업데이트된 LotInfo 목록
  static List<LotInfo> updateLotUsageStatus(
    List<LotInfo> lotInfoList,
    List<String> occupiedSlots,
  ) {
    return lotInfoList.map((lot) {
      final isOccupied = occupiedSlots.contains(lot.tag);
      return lot.copyWith(isUsed: isOccupied);
    }).toList();
  }

  /// 주차 통계 데이터 처리 - 주차 사용 여부를 그룹화
  ///
  /// [statisticsData] 원시 통계 데이터
  /// Returns: lot별 주차 사용 여부 Map
  static Map<int, bool> processStatisticsData(
      List<Map<String, dynamic>> statisticsData) {
    final Map<int, bool> processedResult = {};

    for (final item in statisticsData) {
      final int lot = item['lot'] ?? 0;
      final int value = _extractParkingValue(item);

      // lot별로 주차 여부를 저장 (한 번이라도 1이면 true)
      processedResult[lot] = processedResult[lot] ?? false;
      if (value == 1) {
        processedResult[lot] = true;
      }
    }

    return processedResult;
  }

  /// 다양한 통계 데이터에서 주차 값 추출
  ///
  /// [item] 통계 데이터 항목
  /// Returns: 주차 사용 여부 (0 또는 1)
  static int _extractParkingValue(Map<String, dynamic> item) {
    // 시간별, 일별, 월별, 연별 주차 데이터 중 해당하는 것 반환
    return item['isParked'] ??
        item['hour_parking'] ??
        item['day_parking'] ??
        item['month_parking'] ??
        item['year_parking'] ??
        0;
  }

  /// lot별 타입 정보를 Map으로 변환
  ///
  /// [lotInfoList] 주차 공간 정보 목록
  /// Returns: uid별 lot_type Map
  static Map<int, dynamic> extractLotTypeMap(List<LotInfo> lotInfoList) {
    final Map<int, dynamic> lotTypeMap = {};

    for (final lot in lotInfoList) {
      lotTypeMap[lot.uid] = lot.lotType;
    }

    return lotTypeMap;
  }

  /// 주차 공간 정보에서 uid 맵핑 생성
  ///
  /// [lotInfoList] 주차 공간 정보 목록
  /// Returns: uid별 uid Map (자기 자신 맵핑)
  static Map<int, int> extractUidMapping(List<LotInfo> lotInfoList) {
    final Map<int, int> uidMapping = {};

    for (final lot in lotInfoList) {
      uidMapping[lot.uid] = lot.uid;
    }

    return uidMapping;
  }

  /// 여러 통계 데이터 소스를 결합하여 처리
  ///
  /// [statisticsDataList] 통계 데이터 목록들
  /// [lotInfoList] 주차 공간 정보 목록
  /// Returns: 결합된 처리 결과
  static Map<String, dynamic> combineStatisticsResults(
    List<List<Map<String, dynamic>>> statisticsDataList,
    List<LotInfo> lotInfoList,
  ) {
    final Map<int, bool> combinedParkingStatus = {};

    // 모든 통계 데이터를 결합
    for (final statisticsData in statisticsDataList) {
      final processedData = processStatisticsData(statisticsData);

      for (final entry in processedData.entries) {
        combinedParkingStatus[entry.key] =
            combinedParkingStatus[entry.key] ?? false || entry.value;
      }
    }

    return {
      'parking_status': combinedParkingStatus,
      'lot_types': extractLotTypeMap(lotInfoList),
      'uid_mapping': extractUidMapping(lotInfoList),
    };
  }

  /// 원시 주차 데이터의 유효성 검증
  ///
  /// [engineData] 엔진 데이터
  /// Returns: 데이터가 유효한지 여부
  static bool validateEngineData(EngineData engineData) {
    if (engineData.id.isEmpty) {
      print('⚠️  엔진 데이터의 ID가 비어있습니다.');
      return false;
    }

    if (engineData.timestamp.isEmpty) {
      print('⚠️  엔진 데이터의 타임스탬프가 비어있습니다.');
      return false;
    }

    if (engineData.parkingLot.isEmpty) {
      print('⚠️  엔진 데이터의 주차장 정보가 비어있습니다.');
      return false;
    }

    return true;
  }

  /// 통계 데이터 유효성 검증
  ///
  /// [statisticsData] 통계 데이터 목록
  /// Returns: 데이터가 유효한지 여부
  static bool validateStatisticsData(
      List<Map<String, dynamic>> statisticsData) {
    if (statisticsData.isEmpty) {
      print('ℹ️  통계 데이터가 비어있습니다.');
      return false;
    }

    return true;
  }

  /// 에러 통계 정보 생성
  ///
  /// [errorSlots] 에러 슬롯 목록
  /// [totalSlots] 전체 슬롯 수
  /// Returns: 에러 통계 정보
  static Map<String, dynamic> generateErrorStatistics(
    List<String> errorSlots,
    int totalSlots,
  ) {
    return {
      'total_errors': errorSlots.length,
      'error_rate': totalSlots > 0 ? errorSlots.length / totalSlots : 0.0,
      'error_slots': errorSlots,
      'has_errors': errorSlots.isNotEmpty,
    };
  }
}
