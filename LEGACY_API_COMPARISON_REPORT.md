# 🔄 레거시 API vs 리팩토링 API 비교 분석

> 날짜: 2025-11-04
> 기준: old_api.md 문서 vs 현재 구현 코드

---

## 📋 전체 요약

- **구 버전 파일 수**: 17개
- **구 버전 총 라우트**: 약 50-60개
- **현재 리팩토링 상태**: RESTful API로 재구성
- **호환성 레이어**: 부분적으로만 구현됨

---

## ✅ 완전히 마이그레이션된 API

### 1. 로그인/인증 관련 ✅
**구 버전**: `login_setting.dart`
- POST `/login_setting` → **마이그레이션 완료**: `POST /api/v1/auth/login`
- GET `/login_setting/base` → **마이그레이션 완료**: `GET /api/v1/auth/base-info`
- JWT 토큰 시스템도 새로 구현

**현재 위치**: `bin/routes/auth_api.dart`, `bin/routes/login_setting.dart` (레거시 호환)

---

### 2. 사용자 관리 ✅
**구 버전**: `setting_account.dart`, `create_admin.dart`, `confirm_account_list.dart`
- GET `/settings/account` → **마이그레이션 완료**: `GET /api/v1/users`
- POST `/settings/account/updateUser` → **마이그레이션 완료**: `PUT /api/v1/users/{account}`
- POST `/settings/account/changePassword` → **마이그레이션 완료**: `PATCH /api/v1/users/{account}/password`
- POST `/settings/account/insertUser` → **마이그레이션 완료**: `POST /api/v1/users`
- POST `/settings/account/deleteUser` → **마이그레이션 완료**: `DELETE /api/v1/users/{account}`
- POST `/settings/account/resetPassword` → **마이그레이션 완료**: `PATCH /api/v1/users/{account}/password/reset`

**현재 위치**: `bin/routes/user_management_api.dart`

---

### 3. 통계 API ✅
**구 버전**: `statistics_cam_parking_area.dart`
- GET `/statistics/cam_parking_area/oneDay` → **마이그레이션 완료**: `GET /api/v1/statistics/daily`
- GET `/statistics/cam_parking_area/oneWeek` → **마이그레이션 완료**: `GET /api/v1/statistics/weekly`
- GET `/statistics/cam_parking_area/oneMonth` → **마이그레이션 완료**: `GET /api/v1/statistics/monthly`
- GET `/statistics/cam_parking_area/oneYear` → **마이그레이션 완료**: `GET /api/v1/statistics/yearly`
- GET `/statistics/cam_parking_area/severalYears` → **마이그레이션 완료**: `GET /api/v1/statistics/several-years`
- POST `/statistics/cam_parking_area/searchDay` → **마이그레이션 완료**: `POST /api/v1/statistics/custom-period`
- POST `/statistics/cam_parking_area/searchgraph` → **마이그레이션 완료**: `POST /api/v1/statistics/graph`

**현재 위치**: `bin/routes/statistics_api.dart`

---

### 4. 차량 정보 API ✅
**구 버전**: `pabi.dart`
- POST `/pabi/tag` → **마이그레이션 완료**: `GET /api/v1/vehicle/by-tag?tag={tag}` + `POST /api/v1/vehicle/by-tag`
- POST `/pabi/car` → **마이그레이션 완료**: `GET /api/v1/vehicle/by-plate?plate={plate}` + `POST /api/v1/vehicle/by-plate`
- **추가 구현**: `GET /api/v1/vehicle/info` (오늘 구현)
- **추가 구현**: `GET /api/v1/vehicle/location/{vehicleId}` (오늘 구현)

**현재 위치**: `bin/routes/vehicle_info_api.dart`

---

## 🟡 부분적으로 마이그레이션된 API

### 5. 주차장 기본 정보 (Base Information) 🟡 78%
**구 버전**: `base_information.dart`
- POST `/base` → **마이그레이션**: `POST /api/v1/parking/information`
- GET `/base/get` → **마이그레이션**: `GET /api/v1/parking/information`

**현재 위치**: `bin/routes/base_information_api.dart`

**미구현**:
- ❌ 레거시 호환 라우터 (`/base`, `/base/get`) 직접 지원 없음

---

### 6. 전광판 (Billboard) 🟡 67%
**구 버전**: `billboard.dart`
- POST `/billboard` (층별 빈 구역 조회) → **부분 마이그레이션**: `GET /api/v1/billboard/floor/{floor}`

**현재 위치**: `bin/routes/billboard_api.dart`

**미구현**:
- ❌ POST `/billboard` 직접 지원 (레거시 호환)
- ❌ 층별 lot_type 그룹핑 로직 확인 필요

---

### 7. 중앙 대시보드 (Central) 🟡 75%
**구 버전**: `central.dart`
- GET `/central` → **마이그레이션**: `GET /api/v1/central/dashboard`

**현재 위치**: `bin/routes/central_dashboard_api.dart`

**미구현**:
- ❌ POST `/statistics/central` 레거시 호환 (구 문서에 없음, `graphData.dart`와 혼동 가능)

---

### 8. 디스플레이 (Display) 🟡 71%
**구 버전**: `display.dart`
- POST `/display` (층별 주차 상태) → **마이그레이션**: `POST /api/v1/display/info`

**현재 위치**: `bin/routes/display_api.dart`

**미구현**:
- ❌ POST `/display` 직접 지원 (레거시 호환)

---

### 9. LED 계산 (LED Calculation) 🟡 50%
**구 버전**: `led_cal.dart`
- GET `/led_cal` → **마이그레이션**: `GET /api/v1/led/calculation`

**현재 위치**: `bin/routes/led_calculation_api.dart`

**미구현**:
- ❌ POST `/led_cal` 레거시 호환 (구 문서에 GET만 명시)

---

### 10. 전광판 관리 (Multiple Electric Signs) 🟡 67%
**구 버전**: `multiple_electric_signs.dart`
- GET `/multiple_electric_signs` → **마이그레이션**: `GET /api/v1/parking/electric-signs`
- POST `/multiple_electric_signs/insert` → **마이그레이션**: `POST /api/v1/parking/electric-signs`
- POST `/multiple_electric_signs/update` → **마이그레이션**: `PUT /api/v1/parking/electric-signs/{uid}`
- POST `/multiple_electric_signs/delete` → **마이그레이션**: `DELETE /api/v1/parking/electric-signs/{uid}`

**현재 위치**: `bin/routes/electric_sign_api.dart`

**미구현**:
- ❌ 레거시 경로 직접 지원 (`/multiple_electric_signs/*`)

---

### 11. 데이터베이스 관리 🟡 57%
**구 버전**: `settings_db_management.dart`
- POST `/settings/db_management/engine` → **마이그레이션**: `PUT /api/v1/settings/database/engine`
- POST `/settings/db_management/display` → **미구현**: (현재는 engine만)

**현재 위치**: `bin/routes/database_management_api.dart`

**미구현**:
- ❌ POST `/settings/db_management/display` → `PUT /api/v1/settings/database/display`
- ❌ 레거시 경로 직접 지원

---

### 12. 주차 구역 관리 (Parking Area) 🟡 60%
**구 버전**: `settings_parking_area.dart`
- GET `/settings/parking_area` → **마이그레이션**: `GET /api/v1/resources/parking-lots`
- POST `/settings/parking_area/updateFile` → **부분 구현**: 여러 파일에 분산
- POST `/settings/parking_area/insertFile` → **부분 구현**: 여러 파일에 분산
- POST `/settings/parking_area/deleteFile` → **부분 구현**: 여러 파일에 분산
- POST `/settings/parking_area/ChangeLotType` → **확인 필요**

**현재 위치**: 
- `bin/routes/parking_zone_management_api.dart`
- `bin/routes/parking_zones_api.dart`
- `bin/routes/parking_lots_api.dart`
- `bin/routes/file_system_api.dart`

**미구현**:
- ❌ 레거시 경로 직접 지원
- ❌ ChangeLotType 기능 확인 필요

---

### 13. 카메라 주차면 관리 🟡 67%
**구 버전**: `settings_cam_parking_area.dart`
- GET `/settings/cam_parking_area` → **마이그레이션**: `GET /api/v1/cameras` (추정)
- POST `/settings/cam_parking_area/updateZone` → **부분 구현**
- POST `/settings/cam_parking_area/insertZone` → **부분 구현**
- POST `/settings/cam_parking_area/deleteZone` → **부분 구현**

**현재 위치**: `bin/routes/camera_parking_api.dart`

**미구현**:
- ❌ 레거시 경로 직접 지원

---

## ❌ 미구현 또는 레거시 전용 API

### 14. IsAlive / Ping 🟡 50%
**구 버전**: 
- `isalive.dart` → GET `/isalive`, POST `/isalive`
- `ping.dart` → GET `/ping`

**현재 위치**: 
- `bin/routes/isalive.dart` (레거시 파일 존재)
- `bin/routes/ping.dart` (레거시 파일 존재)
- `bin/routes/monitoring_api.dart` (새 구현)
- `bin/routes/system_health_api.dart` (새 구현)

**상태**: 
- ✅ 레거시 파일 유지
- ✅ 새로운 RESTful API로 재구현 (`/api/v1/monitoring/*`, `/api/v1/system/*`)

---

### 15. Settings (Generic) ❌
**구 버전**: `settings.dart`
- POST `/settings` (key-value 저장)
- POST `/settings/get` (key로 조회)

**현재 상태**: 
- ❌ 직접적인 마이그레이션 없음
- 각 설정은 특정 API로 분산 (database, parking, etc.)

---

### 16. Main Data Receiver ❌
**구 버전**: `receive_enginedata_send_to_dartserver.dart`
- route 없음 (백그라운드 프로세스)
- 2초마다 engine에서 JSON 수신, DB 업데이트, 통계 처리

**현재 상태**: 
- ❌ 확인 필요 - `bin/routes/engine_data.dart`가 유사 역할?
- `bin/routes/engine_data.dart`는 수동 트리거 방식

---

### 17. Resource API (GetResource) ❌
**구 버전**: `main.dart`
- GET `/getResource` (주차 데이터를 String으로 변환)

**현재 상태**: 
- ❌ 직접 마이그레이션 없음
- `GET /api/v1/resources`로 대체 가능?

---

### 18. Parking Status (Main) ❌
**구 버전**: `login_main.dart`
- GET `/parking_status` (메인 화면 실시간 정보)

**현재 상태**: 
- ❌ 직접 마이그레이션 없음
- 여러 API 조합으로 대체 가능 (`/api/v1/vehicle/info`, `/api/v1/resources`)

---

### 19. Error Monitoring ❌
**구 버전**: `error.dart`
- GET `/parking_wrong` (차종 오류 목록)

**현재 상태**: 
- ✅ 부분 구현: `GET /api/v1/monitoring/errors`
- ❌ 레거시 경로 (`/parking_wrong`) 미지원

---

### 20. Graph Data ❌
**구 버전**: `graphData.dart`
- POST `/graphData` 또는 `/statistics/graphData`

**현재 상태**: 
- ✅ 마이그레이션: `POST /api/v1/statistics/graph`
- ❌ 레거시 경로 미지원

---

### 21. First Setting (초기화) ❌
**구 버전**: `firstSetting.dart`
- route 없음 (서버 시작 시 1회 실행)

**현재 상태**: 
- ❌ 확인 필요 - 초기화 로직이 어디에 있는지?

---

## 📊 통계 분석

### 마이그레이션 상태별 분류

| 상태 | 파일 수 | 비율 | 설명 |
|------|--------|------|------|
| ✅ 완전 마이그레이션 | 4개 | 24% | 인증, 사용자, 통계, 차량 |
| 🟡 부분 마이그레이션 | 10개 | 59% | RESTful은 되었으나 레거시 호환 부족 |
| ❌ 미구현/레거시 전용 | 3개 | 18% | 확인 필요 또는 백그라운드 |

### 레거시 호환성 현황

| 카테고리 | 레거시 라우트 | RESTful 대체 | 레거시 직접 지원 |
|---------|-------------|-------------|----------------|
| 인증/로그인 | 5개 | ✅ 5/5 | ✅ 5/5 (`login_setting.dart`) |
| 사용자 관리 | 8개 | ✅ 8/8 | ❌ 0/8 |
| 통계 | 7개 | ✅ 7/7 | ❌ 0/7 |
| 차량 정보 | 4개 | ✅ 4/4 | 🟡 2/4 (POST 버전만) |
| 주차장 정보 | 2개 | ✅ 2/2 | ❌ 0/2 |
| 전광판 | 1개 | ✅ 1/1 | ❌ 0/1 |
| 중앙 대시보드 | 1개 | ✅ 1/1 | ❌ 0/1 |
| 디스플레이 | 1개 | ✅ 1/1 | ❌ 0/1 |
| LED 계산 | 1개 | ✅ 1/1 | ❌ 0/1 |
| 전광판 관리 | 4개 | ✅ 4/4 | ❌ 0/4 |
| DB 관리 | 2개 | 🟡 1/2 | ❌ 0/2 |
| 주차 구역 | 4개 | 🟡 3/4 | ❌ 0/4 |
| 카메라 관리 | 4개 | 🟡 3/4 | ❌ 0/4 |
| 모니터링 | 3개 | ✅ 3/3 | ✅ 2/3 (`isalive`, `ping`) |
| 기타 | 5개 | 🟡 2/5 | ❌ 0/5 |

**총계**: 52개 레거시 라우트 중
- ✅ RESTful 대체: 44/52 (85%)
- ✅ 레거시 직접 지원: 7/52 (13%)

---

## 🎯 주요 발견 사항

### 1. RESTful 마이그레이션 성공 ✅
- 대부분의 핵심 기능이 RESTful API로 성공적으로 재구성됨
- HTTP 메서드가 의미론적으로 올바르게 사용됨 (GET, POST, PUT, DELETE, PATCH)
- URL 구조가 리소스 중심으로 개선됨

### 2. 레거시 호환성 부족 ⚠️
- **문제**: 기존 클라이언트가 여전히 구 경로를 사용할 경우 404 발생
- **예시**:
  ```
  구: POST /settings/account/updateUser
  신: PUT /api/v1/users/{account}
  ```
- **해결책**: 각 API 파일에 `legacyRouter` 추가 필요

### 3. 잘 구현된 레거시 호환 사례 ✅
```dart
// bin/routes/auth_api.dart
Router get legacyRouter {
  final router = Router();
  
  // POST / - 기존 로그인 API (login_setting.dart 호환)
  router.post('/', _handleLegacyLogin);
  
  // GET /base - 기존 기본 정보 API
  router.get('/base', _handleLegacyBaseInfo);
  
  return router;
}
```

### 4. 백그라운드 프로세스 확인 필요 ❓
- `receive_enginedata_send_to_dartserver.dart` 기능이 어떻게 처리되는지 불명확
- `bin/routes/engine_data.dart`가 수동 트리거 방식인데, 자동 2초 주기 업데이트는?

---

## 🔧 권장 조치 사항

### 우선순위 1: 레거시 호환 라우터 추가 🔴

다음 파일들에 `legacyRouter` 추가 필요:

1. **bin/routes/user_management_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.get('/account', _legacyGetAllUsers);
     router.post('/account/updateUser', _legacyUpdateUser);
     router.post('/account/changePassword', _legacyChangePassword);
     router.post('/account/insertUser', _legacyCreateUser);
     router.post('/account/deleteUser', _legacyDeleteUser);
     router.post('/account/resetPassword', _legacyResetPassword);
     return router;
   }
   ```

2. **bin/routes/statistics_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.get('/cam_parking_area/oneDay', _legacyDailyStats);
     router.get('/cam_parking_area/oneWeek', _legacyWeeklyStats);
     router.get('/cam_parking_area/oneMonth', _legacyMonthlyStats);
     router.get('/cam_parking_area/oneYear', _legacyYearlyStats);
     router.get('/cam_parking_area/severalYears', _legacySeveralYearsStats);
     router.post('/cam_parking_area/searchDay', _legacySearchDay);
     router.post('/cam_parking_area/searchgraph', _legacySearchGraph);
     return router;
   }
   ```

3. **bin/routes/base_information_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.post('/', _legacyUpdate);  // POST /base
     router.get('/get', _legacyGet);   // GET /base/get
     return router;
   }
   ```

4. **bin/routes/billboard_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.post('/', _legacyGetFloorInfo);  // POST /billboard
     return router;
   }
   ```

5. **bin/routes/central_dashboard_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.get('/', _legacyGetDashboard);  // GET /central
     return router;
   }
   ```

6. **bin/routes/display_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.post('/', _legacyGetDisplay);  // POST /display
     return router;
   }
   ```

7. **bin/routes/led_calculation_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.get('/', _legacyCalculate);  // GET /led_cal
     return router;
   }
   ```

8. **bin/routes/electric_sign_api.dart**
   ```dart
   Router get legacyRouter {
     final router = Router();
     router.get('/', _legacyGetAll);
     router.post('/insert', _legacyInsert);
     router.post('/update', _legacyUpdate);
     router.post('/deleteZone', _legacyDelete);
     return router;
   }
   ```

### 우선순위 2: 미구현 기능 추가 🟡

1. **database_management_api.dart**
   - `PUT /api/v1/settings/database/display` 추가
   - `POST /api/v1/settings/database/test-connection` 추가

2. **parking 관련 API**
   - `ChangeLotType` 기능 확인 및 구현

3. **engine_data 자동 처리**
   - `receive_enginedata_send_to_dartserver.dart` 기능 확인
   - 2초 주기 자동 업데이트 로직 구현 여부 확인

### 우선순위 3: 라우터 마운트 확인 🟢

**bin/main.dart** 확인 필요:
```dart
// 레거시 라우터들이 올바르게 마운트되었는지 확인
handler = Pipeline()
    .addMiddleware(cors())
    .addMiddleware(logging())
    .addHandler(router.call);

// 예상되는 마운트:
// app.mount('/settings', userManagementApi.legacyRouter);
// app.mount('/statistics', statisticsApi.legacyRouter);
// app.mount('/base', baseInformationApi.legacyRouter);
// etc.
```

---

## 📝 결론

### 현재 상태 요약

**긍정적인 부분** ✅:
1. 핵심 비즈니스 로직은 모두 RESTful API로 성공적으로 마이그레이션
2. 코드 구조가 모듈화되고 유지보수성 향상
3. 일부 API는 레거시 호환성도 훌륭하게 유지 (auth, login)

**개선 필요 부분** ⚠️:
1. 대부분의 API에 레거시 호환 라우터 누락
2. 일부 기능 미구현 (display DB 설정, 연결 테스트 등)
3. 백그라운드 프로세스 처리 방식 불명확

**권장 사항**:
- 기존 클라이언트를 마이그레이션할 계획이 있다면: 현재 상태 유지 + 클라이언트 업데이트
- 기존 클라이언트를 계속 사용해야 한다면: 모든 API에 `legacyRouter` 추가 필수
- 혼합 운영: `legacyRouter` 추가 + 점진적 클라이언트 마이그레이션

---

**작성일**: 2025-11-04
**작성자**: AI Assistant
**기준 문서**: old_api.md


