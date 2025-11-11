import 'dart:async';
import '../data/manage_address.dart';
import 'engine_service.dart';
import 'engine_data_processor.dart';

/// 주기적 작업을 관리하는 서비스 클래스
/// 엔진 데이터 수신 및 처리 작업을 2초마다 실행
class PeriodicTaskService {
  Timer? _timer;
  bool _isProcessing = false;
  final EngineService _engineService;
  final EngineDataProcessor _engineDataProcessor;
  final ManageAddress _manageAddress;
  PeriodicTaskService({
    required ManageAddress manageAddress,
    EngineService? engineService,
    EngineDataProcessor? engineDataProcessor,
  })  : _manageAddress = manageAddress,
        _engineService = engineService ?? EngineService(),
        _engineDataProcessor = engineDataProcessor ?? EngineDataProcessor();

  /// 주기적 작업을 시작
  /// 2초마다 엔진 데이터를 가져와서 처리
  void startPeriodicTask() {
    _timer = Timer.periodic(Duration(milliseconds: 2000), (timer) async {
      await _executePeriodicTask();
    });
    print('주기적 작업이 시작되었습니다.');
  }

  /// 주기적 작업 실행 로직
  /// 중복 실행 방지 및 에러 처리 포함
  Future<void> _executePeriodicTask() async {
    if (_isProcessing) {
      // 이전 주기 작업이 아직 끝나지 않았다면 이번 주기 건너뛰기
      return;
    }

    _isProcessing = true;
    try {
      final displayDbAddr = _manageAddress.displayDbAddr;
      if (displayDbAddr == null) {
        print('Display DB address is not set');
        return;
      }

      final engineAddr = await _engineService.fetchEngineAddr(displayDbAddr);

      if (engineAddr != null && _manageAddress.displayDbAddr != null) {
        await _engineDataProcessor.processEngineData(
          engineDbAddr: engineAddr,
          displayDbAddr: _manageAddress.displayDbAddr!,
          displayDbLPR: _manageAddress.displayDbLPR ?? '',
        );
      }
    } catch (e, stackTrace) {
      print('Error in periodic task: $e');
      print('StackTrace: $stackTrace');
    } finally {
      _isProcessing = false;
    }
  }

  /// 주기적 작업 중지 및 리소스 해제
  void stop() {
    _timer?.cancel();
    _timer = null;
    _engineService.dispose();
    _engineDataProcessor.dispose();
    print('주기적 작업이 중지되었습니다.');
  }

  /// 현재 작업이 진행 중인지 확인
  bool get isProcessing => _isProcessing;

  /// 타이머가 실행 중인지 확인
  bool get isRunning => _timer?.isActive ?? false;
}
