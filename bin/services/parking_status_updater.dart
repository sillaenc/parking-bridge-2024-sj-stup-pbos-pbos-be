import '../models/parking_data.dart';
import '../services/database_client.dart';

/// 주차 상태 실시간 업데이트를 담당하는 서비스
/// 엔진 데이터를 받아서 주차장 상태를 즉시 업데이트
class ParkingStatusUpdater {
  final DatabaseClient _dbClient;

  ParkingStatusUpdater({DatabaseClient? dbClient})
      : _dbClient = dbClient ?? DatabaseClient();

  /// 원시 데이터를 데이터베이스에 저장
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [engineData] 엔진에서 받은 원시 데이터
  /// Returns: 저장 성공 여부
  Future<bool> saveRawData({
    required String displayDbUrl,
    required EngineData engineData,
  }) async {
    try {
      await _dbClient.executeStatement(
        url: displayDbUrl,
        statementId: '#I_Rawdata',
        values: {
          'id': engineData.id,
          'timestamp': engineData.timestamp,
          'parking_lot': engineData.parkingLot,
        },
      );

      print('✅ 원시 데이터가 저장되었습니다. (ID: ${engineData.id})');
      return true;
    } catch (e) {
      print('❌ 원시 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 현재 주차 공간 정보 조회
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// Returns: 주차 공간 정보 목록
  Future<List<LotInfo>> fetchCurrentLotInfo(String displayDbUrl) async {
    try {
      final lotData = await _dbClient.executeQuery(
        url: displayDbUrl,
        queryId: '#S_TbLots',
      );

      if (lotData.isEmpty) {
        print('⚠️  주차 공간 정보가 없습니다.');
        return [];
      }

      return lotData.map((data) => LotInfo.fromJson(data)).toList();
    } catch (e) {
      print('❌ 주차 공간 정보 조회 실패: $e');
      return [];
    }
  }

  /// 주차 상태 업데이트 및 상태 로그 기록
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [updatedLotList] 업데이트된 주차 공간 목록
  /// [timestamp] 타임스탬프
  /// Returns: 업데이트 성공 여부
  Future<bool> updateParkingStatus({
    required String displayDbUrl,
    required List<LotInfo> updatedLotList,
    required String timestamp,
  }) async {
    try {
      final transactions = <Map<String, dynamic>>[];

      // 각 주차 공간에 대해 상태 업데이트 및 로그 기록
      for (final lot in updatedLotList) {
        // TbLots 테이블 업데이트
        transactions.add({
          "statement": "#U_TbLots",
          "values": {
            "isUsed": lot.isUsed ? 1 : 0,
            "tag": lot.tag,
          },
        });

        // TbLotStatus 테이블에 상태 변화 기록
        transactions.add({
          "statement": "#I_TbLotStatus",
          "values": {
            "lot": lot.uid,
            "isParked": lot.isUsed ? 1 : 0,
            "added": timestamp,
          },
        });
      }

      // 배치 실행
      if (transactions.isNotEmpty) {
        await _dbClient.executeBatch(
          url: displayDbUrl,
          transactions: transactions,
        );

        print('✅ ${updatedLotList.length}개 주차 공간 상태가 업데이트되었습니다.');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ 주차 상태 업데이트 실패: $e');
      return false;
    }
  }

  /// 주차 공간 상태 통계 정보 생성
  ///
  /// [lotInfoList] 주차 공간 정보 목록
  /// Returns: 상태 통계 정보
  Map<String, dynamic> generateStatusStatistics(List<LotInfo> lotInfoList) {
    final totalSpaces = lotInfoList.length;
    final occupiedSpaces = lotInfoList.where((lot) => lot.isOccupied).length;
    final availableSpaces = totalSpaces - occupiedSpaces;

    // 차량 타입별 통계
    final Map<int, int> typeOccupied = {};
    final Map<int, int> typeTotal = {};

    for (final lot in lotInfoList) {
      typeTotal[lot.lotType] = (typeTotal[lot.lotType] ?? 0) + 1;
      if (lot.isOccupied) {
        typeOccupied[lot.lotType] = (typeOccupied[lot.lotType] ?? 0) + 1;
      }
    }

    return {
      'total_spaces': totalSpaces,
      'occupied_spaces': occupiedSpaces,
      'available_spaces': availableSpaces,
      'occupancy_rate': totalSpaces > 0 ? (occupiedSpaces / totalSpaces) : 0.0,
      'availability_rate':
          totalSpaces > 0 ? (availableSpaces / totalSpaces) : 1.0,
      'type_statistics': {
        'occupied_by_type': typeOccupied,
        'total_by_type': typeTotal,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 주차 상태 변화 감지
  ///
  /// [previousLotList] 이전 주차 공간 상태
  /// [currentLotList] 현재 주차 공간 상태
  /// Returns: 변화된 주차 공간 목록
  List<LotInfo> detectStatusChanges({
    required List<LotInfo> previousLotList,
    required List<LotInfo> currentLotList,
  }) {
    final List<LotInfo> changedLots = [];

    // 이전 상태를 Map으로 변환하여 빠른 조회
    final Map<int, bool> previousStatusMap = {};
    for (final lot in previousLotList) {
      previousStatusMap[lot.uid] = lot.isUsed;
    }

    // 현재 상태와 비교하여 변화 감지
    for (final currentLot in currentLotList) {
      final previousStatus = previousStatusMap[currentLot.uid];
      if (previousStatus != null && previousStatus != currentLot.isUsed) {
        changedLots.add(currentLot);
      }
    }

    return changedLots;
  }

  /// 상태 변화 로그 출력
  ///
  /// [changedLots] 변화된 주차 공간 목록
  void logStatusChanges(List<LotInfo> changedLots) {
    if (changedLots.isEmpty) {
      print('ℹ️  주차 상태 변화가 없습니다.');
      return;
    }

    print('🚗 주차 상태 변화 감지:');
    for (final lot in changedLots) {
      final status = lot.isUsed ? '주차됨' : '비어있음';
      final icon = lot.isUsed ? '🚗' : '🅿️';
      print('   $icon ${lot.tag} (UID: ${lot.uid}) -> $status');
    }
  }

  /// 전체 주차장 상태 요약 출력
  ///
  /// [lotInfoList] 주차 공간 정보 목록
  void printParkingStatusSummary(List<LotInfo> lotInfoList) {
    final stats = generateStatusStatistics(lotInfoList);

    print('📊 주차장 현황 요약:');
    print('   전체 공간: ${stats['total_spaces']}개');
    print('   사용 중: ${stats['occupied_spaces']}개');
    print('   이용 가능: ${stats['available_spaces']}개');
    print('   사용률: ${(stats['occupancy_rate'] * 100).toStringAsFixed(1)}%');
  }

  /// LPR(License Plate Recognition) 데이터 처리
  /// 주차장 번호판 인식 시스템 연동 (주석 처리된 기능 구현)
  ///
  /// [displayDbLprUrl] LPR 데이터베이스 URL
  /// [displayDbUrl] 디스플레이 데이터베이스 URL
  /// Returns: 처리 성공 여부
  Future<bool> processLprData({
    required String displayDbLprUrl,
    required String displayDbUrl,
  }) async {
    try {
      // LPR 데이터 조회 (현재는 주석 처리됨)
      final lprData = await _dbClient.executeQueryWithUtf8(
        url: displayDbLprUrl,
        queryId:
            "SELECT slot_name, plate_number, entry_time FROM parking_records;",
      );

      // LPR 데이터를 통한 번호판 정보 업데이트
      for (final record in lprData) {
        await _dbClient.executeStatement(
          url: displayDbUrl,
          statementId: '#update_plate',
          values: {
            'plate': record['plate_number'],
            'startTime': record['entry_time'],
            'slot_name': record['slot_name'],
          },
        );
      }

      // print('ℹ️  LPR 데이터 처리는 현재 비활성화되어 있습니다.');
      return true;
    } catch (e) {
      print('❌ LPR 데이터 처리 실패: $e');
      return false;
    }
  }

  /// 오래된 상태 데이터 정리 (선택적)
  ///
  /// [displayDbUrl] 디스플레이 DB URL
  /// [retentionDays] 보존 기간 (일)
  /// Returns: 정리 성공 여부
  Future<bool> cleanupOldStatusData({
    required String displayDbUrl,
    int retentionDays = 30,
  }) async {
    try {
      // 현재는 구현되지 않음 (필요시 구현)
      // final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
      // await _dbClient.executeStatement(
      //   url: displayDbUrl,
      //   statementId: '#cleanup_old_status',
      //   values: {'cutoff_date': cutoffDate.toIso8601String()},
      // );

      print('ℹ️  오래된 데이터 정리는 현재 구현되지 않았습니다.');
      return true;
    } catch (e) {
      print('❌ 오래된 데이터 정리 실패: $e');
      return false;
    }
  }

  /// 리소스 해제
  void dispose() {
    _dbClient.dispose();
  }
}
