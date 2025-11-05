# 🔍 레거시 API 전수 분석 및 마이그레이션 계획

> 날짜: 2025-11-04  
> 기준: `/Users/bjs/Desktop/project/pbos_be_copy` 실제 구 버전 코드  
> 목표: **레거시 API 경로를 수정 없이 똑같이 작동**하도록 호환성 레이어 구현

---

## 📋 전체 요약

### 레거시 서버 구조
- **프레임워크**: Dart + Shelf
- **라우팅 방식**: Router 클래스 기반 마운트
- **총 라우트 파일**: 23개
- **데이터베이스**: ws4sqlite (pb.yaml 쿼리 기반)
- **백그라운드 작업**: 2초 주기 엔진 데이터 동기화

### 현재 리팩토링 서버와의 차이점
| 구분 | 레거시 | 리팩토링 |
|------|--------|----------|
| **API 스타일** | 기능별 경로 (`/login_setting`) | RESTful (`/api/v1/auth/login`) |
| **인증** | JWT 직접 구현 | JWT + 미들웨어 분리 |
| **에러 처리** | 기본 try-catch | 표준화된 에러 응답 |
| **서비스 레이어** | 없음 (라우트에서 직접 DB) | Service 계층 분리 |
| **백그라운드** | Timer.periodic | 별도 서비스 |

---

## 🗂️ 레거시 API 전체 목록 (main.dart 기준)

### 1. 인증 및 로그인
```dart
router.mount('/login_setting', loginSetting.router);
router.mount('/parking_status', loginMain.router);
router.mount('/confirm_account_list', confirmAccountList.router);
router.mount('/create_admin', createAdmin.router);
```

**상세 엔드포인트** (`/login_setting`):
- `POST /login_setting/` - 로그인 (account, passwd)
- `GET /login_setting/base` - 주차장 기본 정보 조회
- `GET /login_setting/display` - 디스플레이 정보
- `GET /login_setting/token` - 토큰 정보
- `GET /login_setting/protected` - 보호된 리소스

**현재 마이그레이션 상태**: ✅ `/api/v1/auth/*`로 구현됨
**레거시 호환성**: ⚠️ 부분적 (auth_api.dart의 legacyRouter)

---

### 2. 사용자 관리
```dart
router.mount('/settings/account', settingsAccount.router);
```

**상세 엔드포인트**:
- `GET /settings/account/` - 전체 사용자 목록 조회
- `POST /settings/account/updateUser` - 사용자 정보 수정
- `POST /settings/account/changePassword` - 비밀번호 변경
- `POST /settings/account/addUser` - 사용자 추가
- `POST /settings/account/deleteUser` - 사용자 삭제

**현재 마이그레이션 상태**: ✅ `/api/v1/users/*`로 구현됨
**레거시 호환성**: ❌ 없음

---

### 3. 주차 구역 관리
```dart
router.mount('/settings/parking_area', settingsParkingArea.router);
```

**상세 엔드포인트**:
- `GET /settings/parking_area/` - 주차 구역 목록 조회
- `POST /settings/parking_area/insertFile` - 파일 업로드
- `POST /settings/parking_area/getLots` - 구역별 로트 정보
- `POST /settings/parking_area/updateZone` - 구역 정보 수정
- `POST /settings/parking_area/deleteZone` - 구역 삭제
- `POST /settings/parking_area/insertZone` - 구역 추가

**현재 마이그레이션 상태**: 🔶 부분적 (`/api/v1/parking-zones/*`)
**레거시 호환성**: ❌ 없음

---

### 4. 카메라 주차 구역 관리
```dart
router.mount('/settings/cam_parking_area', settingsCamParkingArea.router);
```

**상세 엔드포인트**:
- `GET /settings/cam_parking_area/` - 카메라 구역 목록
- `POST /settings/cam_parking_area/updateZone` - 카메라 구역 수정
- `POST /settings/cam_parking_area/deleteZone` - 카메라 구역 삭제
- `POST /settings/cam_parking_area/insertZone` - 카메라 구역 추가

**현재 마이그레이션 상태**: 🔶 부분적 (`/api/v1/camera-parking/*`)
**레거시 호환성**: ❌ 없음

---

### 5. 데이터베이스 관리
```dart
router.mount('/settings/db_management', settingsDbManagement.router);
```

**상세 엔드포인트**:
- `GET /settings/db_management/` - DB 설정 조회
- `POST /settings/db_management/test` - DB 연결 테스트
- `POST /settings/db_management/update` - DB 설정 수정

**현재 마이그레이션 상태**: 🔶 부분적 (`/api/v1/database/*`)
**레거시 호환성**: ❌ 없음

---

### 6. 통계
```dart
router.mount('/statistics/cam_parking_area', statisticsCamParkingArea.router);
```

**상세 엔드포인트**:
- `GET /statistics/cam_parking_area/oneDayAll` - 당일 전체 통계
- `GET /statistics/cam_parking_area/oneDay` - 당일 시간별 통계
- `GET /statistics/cam_parking_area/graphData` - 그래프 데이터
- `GET /statistics/cam_parking_area/oneWeek` - 주간 통계
- `GET /statistics/cam_parking_area/oneMonth` - 월간 통계
- `POST /statistics/cam_parking_area/specific` - 특정 기간 통계

**현재 마이그레이션 상태**: ✅ `/api/v1/statistics/*`로 구현됨
**레거시 호환성**: ❌ 없음

---

### 7. 차량 정보
```dart
router.mount('/pabi', pabi.router);
```

**상세 엔드포인트**:
- `POST /pabi/tag` - 태그로 차량 정보 조회
- `POST /pabi/car` - 번호판으로 차량 위치 조회

**현재 마이그레이션 상태**: ✅ `/api/v1/vehicle/*`로 구현됨
**레거시 호환성**: ⚠️ 부분적 (vehicle_info_api.dart의 POST 메서드)

---

### 8. 디스플레이 & UI
```dart
router.mount('/central', central.router);
router.mount('/base', baseInformation.router);
router.mount('/billboard', billBoard.router);
router.mount('/display', display.router);
router.mount('/settings', settings.router);
```

**상세 엔드포인트**:
- `GET /central/` - 중앙 대시보드 데이터
- `POST /base/` - 기본 정보 등록/수정
- `GET /base/get` - 기본 정보 조회
- `POST /billboard/` - 전광판 층별 데이터
- `POST /billboard/part_system` - 전광판 시스템 제어
- `POST /display/` - 디스플레이 데이터 조회
- `POST /display/dlatl` - 디스플레이 데이터 업데이트
- `GET /settings/` - 설정 정보

**현재 마이그레이션 상태**: 🔶 부분적
**레거시 호환성**: ❌ 없음

---

### 9. 기타 유틸리티
```dart
router.mount('/getResource', getResource.router);
router.mount('/graphData', graphdata.router);
router.mount('/multiple_electric_signs', multipleElectricSigns.router);
router.mount('/led_cal', ledCal.router);
router.mount('/isalive', isalive.router);
router.mount('/ping', ping.router);
```

**상세 엔드포인트**:
- `POST /getResource/get` - 리소스 조회
- `POST /graphData/` - 그래프 데이터 생성
- `GET /graphData/test` - 테스트 데이터
- `POST /multiple_electric_signs/` - 다중 전광판 제어
- `POST /led_cal/` - LED 계산
- `GET /isalive/` - 서비스 상태 확인
- `GET /ping/` - 핑 체크

**현재 마이그레이션 상태**: 🔶 부분적
**레거시 호환성**: ❌ 없음

---

## 🔥 중요 발견사항

### 1. 백그라운드 작업 (Timer.periodic)
레거시 `main.dart` 132-151줄:
```dart
Timer.periodic(Duration(milliseconds: 2000), (timer) async {
  final engineAddr = await fetchEngineAddr(client, url!);
  if (engineAddr != null && manageAddress.displayDbAddr != null) {
    await receiveEnginedataSendToDartserver(
      engineAddr, 
      manageAddress.displayDbAddr!,
      manageAddress.displayDbLPR, 
      check
    );
    check = DateTime.now();
  }
});
```

**설명**: 2초마다 엔진 DB 주소를 조회하고, 엔진 데이터를 Dart 서버 DB로 동기화
**현재 상태**: ❌ 리팩토링 버전에는 없음
**필요성**: 🔴 **매우 중요** - 실시간 주차 데이터 동기화의 핵심 기능

---

### 2. 데이터베이스 쿼리 방식
레거시는 `pb.yaml`의 쿼리 ID를 직접 사용:
```dart
var body = {
  "transaction": [
    {"query": "#S_TbUsers"}
  ]
};
```

리팩토링은 서비스 레이어를 통해 추상화:
```dart
await _userManagementService.getAllUsers();
```

**호환성 문제**: 쿼리 ID가 일치하지 않을 수 있음

---

### 3. 에러 응답 형식
레거시:
```dart
return Response.internalServerError(body: '아이디 혹은 비밀번호가 틀렸습니다.');
```

리팩토링:
```dart
return Response(401, body: jsonEncode({
  'success': false,
  'message': '인증에 실패했습니다.',
  'error': 'INVALID_CREDENTIALS',
  'timestamp': DateTime.now().toIso8601String(),
}));
```

**호환성 문제**: 클라이언트가 JSON 구조를 기대하지 않을 수 있음

---

## 📝 마이그레이션 진행 계획

### Phase 1: 레거시 호환성 레이어 구축 (1-2일)
**목표**: 기존 API 경로를 수정 없이 작동하도록 라우터 추가

#### 1.1 레거시 라우터 구조 생성
```
bin/routes/legacy/
├── legacy_router.dart          # 메인 레거시 라우터
├── legacy_login_setting.dart   # /login_setting 호환
├── legacy_settings_account.dart # /settings/account 호환
├── legacy_pabi.dart            # /pabi 호환
├── legacy_statistics.dart      # /statistics 호환
├── legacy_parking_area.dart    # /settings/parking_area 호환
├── legacy_cam_parking_area.dart # /settings/cam_parking_area 호환
├── legacy_display.dart         # /display, /billboard, /central 호환
└── legacy_utils.dart           # /graphData, /getResource 등
```

#### 1.2 구현 전략
각 레거시 라우터는:
1. **경로는 완전히 동일**하게 유지
2. **요청/응답 형식** 레거시 방식 준수
3. 내부적으로는 **리팩토링된 서비스 호출**
4. **에러 처리** 레거시 스타일 반환

예시 (`legacy_login_setting.dart`):
```dart
class LegacyLoginSetting {
  final AuthService _authService;
  
  Router get router {
    final router = Router();
    
    // POST /login_setting/ - 완전히 동일한 경로
    router.post('/', (Request request) async {
      var requestBody = await request.readAsString();
      var loginData = jsonDecode(requestBody);
      var account = loginData['account'];
      var passwd = loginData['passwd'];
      
      // 내부적으로는 리팩토링된 서비스 사용
      final serviceResponse = await _authService.login(account, passwd);
      
      if (serviceResponse.success) {
        // 레거시 응답 형식으로 변환
        return Response.ok(
          jsonEncode(serviceResponse.data + [{'token': serviceResponse.token}]),
          headers: {'Content-Type': 'application/json'}
        );
      } else {
        // 레거시 에러 형식
        return Response.internalServerError(
          body: '아이디 혹은 비밀번호가 틀렸습니다.'
        );
      }
    });
    
    // GET /login_setting/base
    router.get('/base', (Request request) async {
      // ... 레거시 응답 형식 유지
    });
    
    return router;
  }
}
```

#### 1.3 main.dart 통합
```dart
// 리팩토링 라우터 (새로운 API)
router.mount('/api/v1/auth', authApi.router);
router.mount('/api/v1/users', userManagementApi.router);
// ... 기타 RESTful API

// 레거시 라우터 (기존 API 호환)
final legacyRouter = LegacyRouter(
  authService: authService,
  userManagementService: userManagementService,
  // ... 기타 서비스
);
router.mount('/login_setting', legacyRouter.loginSetting);
router.mount('/settings/account', legacyRouter.settingsAccount);
router.mount('/pabi', legacyRouter.pabi);
// ... 기타 레거시 경로
```

---

### Phase 2: 백그라운드 작업 구현 (1일)
**목표**: 2초 주기 엔진 데이터 동기화 기능 복원

#### 2.1 백그라운드 서비스 생성
```
bin/services/background/
├── engine_sync_service.dart    # 엔진 데이터 동기화
└── background_scheduler.dart   # 스케줄러 관리
```

#### 2.2 구현 내용
```dart
class EngineSyncService {
  final http.Client _client;
  final ManageAddress _manageAddress;
  Timer? _timer;
  bool _isProcessing = false;
  DateTime _lastCheck = DateTime.now();
  
  /// 백그라운드 동기화 시작 (2초 주기)
  void startSync() {
    _timer = Timer.periodic(Duration(milliseconds: 2000), _syncTask);
  }
  
  Future<void> _syncTask(Timer timer) async {
    if (_isProcessing) return; // 중복 실행 방지
    
    _isProcessing = true;
    try {
      final engineAddr = await _fetchEngineAddr();
      if (engineAddr != null) {
        await _syncEngineData(engineAddr);
        _lastCheck = DateTime.now();
      }
    } catch (e, stackTrace) {
      print('EngineSyncService 오류: $e');
      print('스택 트레이스: $stackTrace');
    } finally {
      _isProcessing = false;
    }
  }
  
  void stopSync() {
    _timer?.cancel();
  }
}
```

#### 2.3 main.dart 통합
```dart
void main() async {
  // ... 기존 초기화
  
  // 백그라운드 서비스 시작
  final engineSyncService = EngineSyncService(
    client: http.Client(),
    manageAddress: manageAddress,
  );
  engineSyncService.startSync();
  
  // ... 서버 시작
}
```

---

### Phase 3: 테스트 및 검증 (1일)
**목표**: 레거시 클라이언트와의 완벽한 호환성 확인

#### 3.1 테스트 항목
1. **인증 테스트**
   - `POST /login_setting/` - 로그인
   - `GET /login_setting/base` - 기본 정보

2. **사용자 관리 테스트**
   - `GET /settings/account/` - 사용자 목록
   - `POST /settings/account/updateUser` - 수정

3. **차량 정보 테스트**
   - `POST /pabi/tag` - 태그 조회
   - `POST /pabi/car` - 번호판 조회

4. **통계 테스트**
   - `GET /statistics/cam_parking_area/oneDayAll`

5. **백그라운드 테스트**
   - 2초 주기 동기화 확인
   - 로그 출력 확인

#### 3.2 테스트 방법
```python
# test_legacy_compatibility.py
import requests
import json

BASE_URL = "http://localhost:8080"

def test_legacy_login():
    """레거시 로그인 테스트"""
    response = requests.post(
        f"{BASE_URL}/login_setting/",
        json={"account": "admin", "passwd": "password"}
    )
    assert response.status_code == 200
    data = response.json()
    assert 'token' in data[0]
    print("✅ 레거시 로그인 테스트 통과")

def test_legacy_user_list():
    """레거시 사용자 목록 테스트"""
    response = requests.get(f"{BASE_URL}/settings/account/")
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    print("✅ 레거시 사용자 목록 테스트 통과")

# ... 기타 테스트
```

---

### Phase 4: 문서화 및 배포 (0.5일)
**목표**: 호환성 레이어 문서 작성

#### 4.1 문서 내용
1. 레거시 API 목록 및 사용법
2. 새로운 RESTful API와의 매핑
3. 마이그레이션 가이드
4. 주의사항 및 제한사항

---

## 🎯 최종 목표 달성 기준

### ✅ 성공 조건
1. **모든 레거시 경로 작동**: `/login_setting`, `/settings/account`, `/pabi` 등 52개 경로
2. **요청/응답 형식 동일**: 기존 클라이언트 코드 수정 없이 작동
3. **백그라운드 작업 정상**: 2초 주기 엔진 데이터 동기화
4. **에러 없음**: 기존 기능 100% 재현
5. **RESTful API 병행**: 신규 API (`/api/v1/*`)와 레거시 API 동시 제공

### ⚠️ 주의사항
1. **데이터베이스 쿼리 ID 확인**: `pb.yaml`의 쿼리 ID가 레거시와 동일한지 검증
2. **에러 메시지**: 레거시 클라이언트가 기대하는 형식 유지
3. **인코딩**: UTF-8 인코딩 일관성 유지
4. **성능**: 레거시 방식의 직접 DB 호출 vs 서비스 레이어 오버헤드 모니터링

---

## 📊 예상 일정

| Phase | 작업 내용 | 예상 시간 | 상태 |
|-------|----------|-----------|------|
| Phase 1 | 레거시 호환성 레이어 구축 | 1-2일 | ⏳ 대기 중 |
| Phase 2 | 백그라운드 작업 구현 | 1일 | ⏳ 대기 중 |
| Phase 3 | 테스트 및 검증 | 1일 | ⏳ 대기 중 |
| Phase 4 | 문서화 및 배포 | 0.5일 | ⏳ 대기 중 |
| **합계** | **전체 프로젝트** | **3.5-4.5일** | **0% 완료** |

---

## 🚀 즉시 시작 가능 항목

### 1순위 (즉시)
- [x] 레거시 코드 분석 완료
- [ ] `bin/routes/legacy/` 폴더 생성
- [ ] `legacy_login_setting.dart` 구현 (가장 많이 사용)
- [ ] `legacy_pabi.dart` 구현 (차량 정보 - 핵심 기능)

### 2순위 (1일차)
- [ ] `legacy_settings_account.dart` 구현
- [ ] `legacy_statistics.dart` 구현
- [ ] 백그라운드 서비스 기본 구조

### 3순위 (2일차)
- [ ] 나머지 레거시 라우터 구현
- [ ] 백그라운드 동기화 완료
- [ ] 테스트 스크립트 작성

---

## 💡 권장사항

1. **점진적 마이그레이션**: 우선순위가 높은 API부터 레거시 호환성 구현
2. **병렬 운영**: 레거시 API와 새로운 RESTful API를 동시에 제공
3. **클라이언트 업데이트**: 장기적으로는 클라이언트를 RESTful API로 마이그레이션 권장
4. **모니터링**: 레거시 API 사용량 추적하여 단계적 폐기 계획 수립

---

**작성자**: AI Assistant  
**검토 필요**: 데이터베이스 쿼리 ID 매핑, 에러 응답 형식 검증


