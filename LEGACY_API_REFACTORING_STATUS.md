# 🔄 레거시 API 리팩토링 상태 보고서

> **작성일**: 2025-11-05  
> **기준**: 클라이언트 JSON 설정 파일 분석

---

## 📊 전체 요약

| 카테고리 | 총 API | 구현됨 | 미구현 | 호환율 |
|---------|--------|--------|--------|--------|
| 그래프/통계 | 7 | 7 | 0 | ✅ 100% |
| 로그인/인증 | 5 | 5 | 0 | ✅ 100% |
| 주차 관리 | 4 | 4 | 0 | ✅ 100% |
| 설정 관리 | 9 | 8 | 1 | ⚠️ 89% |
| 디스플레이 | 2 | 2 | 0 | ✅ 100% |
| **전체** | **27** | **26** | **1** | **✅ 96%** |

---

## 🔄 주요 레거시 → RESTful API 매핑

### ⭐ 핵심 변경사항

#### 1. **설정 조회 API** (가장 중요!)
```
레거시: POST /settings/get
        Body: {"key": "display_mode"}

   ↓↓↓

RESTful: GET /api/v1/settings/general/get?key=display_mode
         Query Parameter 사용

✅ 두 방식 모두 지원 (하위 호환)
```

#### 2. **차량 정보 조회**
```
레거시: POST /pabi/tag
        Body: {"tag": "ABC123"}

   ↓↓↓

RESTful: GET /api/v1/vehicle/by-tag?tag=ABC123
         또는
         POST /api/v1/vehicle/by-tag
         Body: {"tag": "ABC123"}
```

#### 3. **사용자 관리**
```
레거시: POST /settings/account/deleteUser
        Body: {"account": "user123"}

   ↓↓↓

RESTful: DELETE /api/v1/users/user123
         Path Parameter 사용
```

#### 4. **통계 API**
```
레거시: GET /statistics/cam_parking_area/oneDay

   ↓↓↓

RESTful: GET /api/v1/statistics/daily
         더 간결한 경로
```

#### 5. **인증 API**
```
레거시: POST /login_setting
        Body: {username, password}

   ↓↓↓

RESTful: POST /api/v1/auth/login
         Body: {username, password}
         Response: JWT 토큰 포함
```

---

## 1️⃣ 그래프/통계 엔드포인트 (graphEndPoint)

### ✅ 완전 호환 (7/7)

| 키 | 레거시 경로 | 현재 상태 | RESTful API 경로 |
|---|------------|----------|------------------|
| `oneDay` | `GET /statistics/cam_parking_area/oneDay` | ✅ 작동 | `GET /api/v1/statistics/daily` |
| `week` | `GET /statistics/cam_parking_area/oneWeek` | ✅ 작동 | `GET /api/v1/statistics/weekly` |
| `month` | `GET /statistics/cam_parking_area/oneMonth` | ✅ 작동 | `GET /api/v1/statistics/monthly` |
| `year` | `GET /statistics/cam_parking_area/oneYear` | ✅ 작동 | `GET /api/v1/statistics/yearly` |
| `search` | `POST /statistics/cam_parking_area/searchDay` | ✅ 작동 | `POST /api/v1/statistics/custom-period` |
| `graphData` | `POST /graphData` | ✅ 작동 | `POST /api/v1/statistics/graph-data` |
| `graphRangeData` | `POST /statistics/cam_parking_area/searchgraph` | ✅ 작동 | `POST /api/v1/statistics/graph` |

**마운트 위치**:
- `/statistics/cam_parking_area` → `StatisticsCamParkingArea` 클래스 (레거시)
- `/graphData` → `graphData` 클래스 (레거시)
- `/api/v1/statistics/*` → `StatisticsApi` 클래스 (RESTful)

**메서드**: GET (일반 조회), POST (커스텀 기간/그래프 데이터)

---

## 2️⃣ 로그인/인증 엔드포인트 (loginEndPoint)

### ✅ 완전 호환 (5/5)

| 키 | 레거시 경로 | 현재 상태 | RESTful API 경로 |
|---|------------|----------|------------------|
| `login` | `POST /login_setting` | ✅ 작동 | `POST /api/v1/auth/login` |
| `create` | `POST /create_admin` | ✅ 작동 | `POST /api/v1/users` (관리자) |
| `confirm` | `POST /confirm_account_list` | ✅ 작동 | `GET /api/v1/users` |
| `modifypassword` | `POST /settings/account/changePassword` | ✅ 작동 | `PATCH /api/v1/users/{account}/password` |
| `insertUser` | `POST /settings/account/insertUser` | ✅ 작동 | `POST /api/v1/users` |

**마운트 위치**:
- `/login_setting` → `LoginSetting` 클래스 (레거시)
- `/create_admin` → `CreateAdmin` 클래스 (레거시)
- `/confirm_account_list` → `ConfirmAccountList` 클래스 (레거시)
- `/settings/account/*` → `SettingsAccount` 클래스 (레거시)
- `/api/v1/auth/*` → `AuthApi` 클래스 (RESTful)
- `/api/v1/users/*` → `UserManagementApi` 클래스 (RESTful)

**메서드**: POST (생성/수정), GET (조회), PATCH (부분 수정)

**보안**:
- ✅ 이중 SHA-256 해싱
- ✅ JWT 토큰 인증
- ✅ 비밀번호 확인 검증

---

## 3️⃣ 주차 관리 엔드포인트 (parkingEndPoint)

### ✅ 완전 호환 (4/4)

| 키 | 레거시 경로 | 현재 상태 | RESTful API 경로 |
|---|------------|----------|------------------|
| `base` | `GET /login_setting/base` | ✅ 작동 | `GET /api/v1/auth/base-info` |
| `area` | `GET/POST /settings/parking_area` | ✅ 작동 | `GET /api/v1/parking-zones`<br>`POST /api/v1/parking-zones/{zoneId}` |
| `tag` | `POST /pabi/tag` | ✅ 작동 | `GET /api/v1/vehicle/by-tag?tag={tag}`<br>`POST /api/v1/vehicle/by-tag` |
| `car` | `POST /pabi/car` | ✅ 작동 | `GET /api/v1/vehicle/by-plate?plate={plate}`<br>`POST /api/v1/vehicle/by-plate` |

**마운트 위치**:
- `/login_setting/base` → `LoginSetting.router.get('/base')` (레거시)
- `/settings/parking_area` → `SettingsParkingArea` 클래스 (레거시 - 슬래시/언더스코어 모두)
- `/pabi/*` → `LegacyPabi` 클래스 (레거시 호환 레이어)
- `/api/v1/vehicle/*` → `VehicleInfoApi` 클래스 (RESTful)
- `/api/v1/parking-zones/*` → `ParkingZonesApi` 클래스 (RESTful)

**메서드**: 
- 레거시: GET `/login_setting/base`, POST `/pabi/tag`, `/pabi/car`
- RESTful: GET (조회), POST (생성/검색)

**특징**:
- `/pabi` API는 레거시 방식 그대로 DB 쿼리 사용
- 응답 형식 완벽 재현 (레거시 "없어" 메시지 포함)
- RESTful은 GET/POST 메서드로 구분하여 REST 원칙 준수

---

## 4️⃣ 설정 관리 엔드포인트 (settingEndPoint)

### ✅ 거의 완전 호환 (8/9 - 89%)

| 키 | 레거시 경로 | 현재 상태 | RESTful API 경로 | 비고 |
|---|------------|----------|------------------|------|
| `list` | `GET /settings/account` | ✅ 작동 | `GET /api/v1/users` | 전체 사용자 목록 |
| `delete` | `POST /settings/account/deleteUser` | ✅ 작동 | `DELETE /api/v1/users/{account}` | |
| `update` | `POST /settings/account/updateUser` | ✅ 작동 | `PUT /api/v1/users/{account}` | |
| `reset` | `POST /settings/account/resetPassword` | ✅ 작동 | `PATCH /api/v1/users/{account}/password/reset` | |
| `postparkData` | `POST /base` | ✅ 작동 | `POST /api/v1/parking/information` | 주차장 정보 저장 |
| `getparkData` | `GET /base/get` | ✅ 작동 | `GET /api/v1/parking/information` | 주차장 정보 조회 |
| `postBujeValue` | `/setOverride` | ⚠️ 외부 | 없음 (전광판 장치 직접) | 이 서버 API 아님 |
| `ping` | `GET /ping` | ✅ 작동 | `GET /api/v1/monitoring/ping` | 서버 핑 체크 |
| `isalive` | `GET /isalive/isalive` | ✅ 작동 | `GET /api/v1/monitoring/health` | 헬스 체크 |

**⭐ 중요한 변경사항**:

클라이언트 JSON에는 없지만 연관된 중요 API:
```
POST /settings/get → GET /api/v1/settings/general/get?key={key}
```
- 레거시: `POST /settings/get` (JSON body로 key 전달)
- RESTful: `GET /api/v1/settings/general/get?key={key}` (Query parameter)
- **두 방식 모두 지원됨** (하위 호환성)

**마운트 위치**:
- `/settings/account/*` → `SettingsAccount` 클래스 (레거시)
- `/settings/get` → `Settings` 클래스 (레거시 POST 방식)
- `/base` → `BaseInformation` 클래스 (레거시)
- `/ping` → `Ping` 클래스 (레거시)
- `/isalive` → `Isalive` 클래스 (레거시)
- `/api/v1/users/*` → `UserManagementApi` 클래스 (RESTful)
- `/api/v1/parking/information/*` → `BaseInformationApi` 클래스 (RESTful)
- `/api/v1/monitoring/*` → `MonitoringApi` 클래스 (RESTful)
- `/api/v1/settings/*` → `SettingsApi` 클래스 (RESTful)

**메서드**: GET, POST

**특이사항**:
1. **`/setOverride`**: 
   - ⚠️ 이 서버의 엔드포인트가 아님
   - `/billboard/part_system`에서 외부 전광판 장치로 요청 전송
   - 클라이언트가 직접 전광판 장치에 접근하는 것으로 추정

2. **`/isalive/isalive`**:
   - ✅ 정상 구현됨
   - `router.get('/isalive')` - 서버 상태 확인
   - 응답: `"1"` (살아있음)

---

## 5️⃣ 디스플레이 엔드포인트 (displayEndPoint)

### ✅ 완전 호환 (2/2)

| 키 | 레거시 경로 | 현재 상태 | RESTful API 경로 |
|---|------------|----------|------------------|
| `display` | `POST /display` | ✅ 작동 | `GET /api/v1/display/{displayId}`<br>`POST /api/v1/display/config` |
| `led` | `POST /led_cal` | ✅ 작동 | `GET /api/v1/led/calibration`<br>`POST /api/v1/led/calibration` |

**마운트 위치**:
- `/display` → `Display` 클래스 (레거시)
- `/led_cal` → `LedCal` 클래스 (레거시)
- `/api/v1/display/*` → `DisplayApi` 클래스 (RESTful)
- `/api/v1/led/*` → `LedApi` 클래스 (RESTful)

**메서드**: 
- 레거시: POST (설정 저장/업데이트)
- RESTful: GET (조회), POST (생성/업데이트)

---

## 🔍 상세 분석

### ✅ 완벽하게 작동하는 API (26개)

모든 레거시 경로가 정상 작동하며, RESTful 방식과 병행 운영됩니다.

**특징**:
1. **완전한 하위 호환성** - 레거시 클라이언트 수정 불필요
2. **이중 경로 지원** - 레거시 + RESTful 동시 지원
3. **응답 형식 유지** - 레거시 응답 형식 그대로 재현

### ✅ 정상 작동 확인 (1개)

#### `/isalive/isalive`

**구현 상태**: ✅ 완벽하게 작동

**현재 구현**:
```dart
// isalive.dart (140-142번 줄)
router.get('/isalive', (Request request) async {
  return Response.ok("1"); // 서버 살아있음
});
```

**전체 경로**:
```
GET /isalive/isalive
→ 응답: "1"
```

**추가 엔드포인트**:
- `POST /isalive/` - isalive URL 목록에 추가
- `GET /isalive/get` - 등록된 서버들 상태 확인

### ❌ 외부 엔드포인트 (1개)

#### `/setOverride`

**설명**: 
- 이 서버의 API가 아님
- 외부 전광판 하드웨어 장치의 엔드포인트
- `/billboard/part_system`을 통해 간접 제어됨

**클라이언트 동작 추정**:
```
클라이언트 → 전광판 장치 (직접)
         POST /setOverride
```

**또는**:
```
클라이언트 → 이 서버 → 전광판 장치
         POST /billboard/part_system
```

---

## 📋 마운트 경로 전체 목록

### 레거시 경로 (26개)

```
✅ 인증/사용자 (6개)
   /login_setting
   /create_admin
   /confirm_account_list
   /settings_account
   /settings/account ✅ (슬래시)

✅ 주차 관리 (6개)
   /base
   /base_information
   /settings_parking_area
   /settings/parking_area ✅ (슬래시)
   /settings_cam_parking_area
   /settings/cam_parking_area ✅ (슬래시)

✅ 차량 정보 (1개)
   /pabi (→ /tag, /car)

✅ 통계/그래프 (2개)
   /statistics/cam_parking_area (→ 7개 서브경로)
   /graphData

✅ 디스플레이 (4개)
   /display
   /led_cal
   /billboard
   /multiple_electric_signs

✅ 중앙/기타 (3개)
   /central
   /settings
   /settings/db_management

✅ 모니터링 (4개)
   /ping
   /isalive
   /getResource
```

### RESTful 경로 (신규)

```
/api/v1/auth/*
/api/v1/users/*
/api/v1/parking-zones/*
/api/v1/parking-lots/*
/api/v1/parking/information/*
/api/v1/parking/central/*
/api/v1/vehicle/*
/api/v1/statistics/*
/api/v1/display/*
/api/v1/billboard/*
/api/v1/led/*
/api/v1/central/*
/api/v1/system/*
/api/v1/monitoring/*
/api/v1/resources/*
/api/v1/settings/*
```

---

## 🎯 권장 사항

### 1. ~~`/isalive/isalive` 확인~~ ✅ 완료

**우선순위**: ~~🔴 높음~~ ✅ 해결됨

```bash
# 작동 확인됨 ✅
curl http://localhost:8080/isalive/isalive
# 응답: "1"
```

### 2. `/setOverride` 클라이언트 처리

**우선순위**: 🟡 중간

**옵션 A**: 클라이언트가 전광판 장치에 직접 요청
```javascript
// 클라이언트 코드
fetch(`${deviceUrl}/setOverride`, {
  method: 'POST',
  body: JSON.stringify({value: floor})
});
```

**옵션 B**: 이 서버를 통해 간접 제어
```javascript
// 클라이언트 코드
fetch('/billboard/part_system', {
  method: 'POST',
  body: JSON.stringify({floor: 'F1'})
});
```

### 3. 클라이언트 설정 업데이트 제안

**현재 설정**:
```json
{
  "settingEndPoint": {
    "postBujeValue": "/setOverride"
  }
}
```

**권장 변경**:
```json
{
  "settingEndPoint": {
    "postBujeValue": "/billboard/part_system",
    "postBujeValueDirect": "${deviceUrl}/setOverride"
  }
}
```

---

## 📊 호환성 매트릭스

| 클라이언트 버전 | 레거시 API | RESTful API | 권장 방식 |
|----------------|-----------|-------------|----------|
| 구버전 (1.x) | ✅ 100% | ❌ 미지원 | 레거시 사용 |
| 중간 버전 (2.x) | ✅ 100% | ✅ 부분 지원 | 혼용 가능 |
| 신규 버전 (3.x) | ✅ 100% | ✅ 100% | RESTful 권장 |

---

## ✅ 최종 결론

### 호환성 달성률: **96% (26/27)**

**완벽하게 작동** ✅:
- 그래프/통계: 7/7 (100%)
- 로그인/인증: 5/5 (100%)
- 주차 관리: 4/4 (100%)
- 디스플레이: 2/2 (100%)

**확인 완료** ✅:
- `/isalive/isalive` - 정상 작동 확인됨

**외부 엔드포인트** 🔗:
- `/setOverride` (전광판 장치)

### 레거시 클라이언트 호환성

✅ **기존 클라이언트는 코드 수정 없이 바로 사용 가능합니다!**

**단, 주의사항**:
1. ✅ `/isalive/isalive` - 정상 작동 확인됨
2. ⚠️ `/setOverride` - 전광판 장치 직접 호출 필요 (이 서버 엔드포인트 아님)

---

## 📋 전체 레거시 → RESTful 매핑 테이블

### 클라이언트 JSON의 27개 API 전체 매핑

| # | 레거시 API | RESTful API | 메서드 변경 | 비고 |
|---|-----------|-------------|------------|------|
| **그래프/통계** |
| 1 | `GET /statistics/cam_parking_area/oneDay` | `GET /api/v1/statistics/daily` | 동일 | 경로 간소화 |
| 2 | `GET /statistics/cam_parking_area/oneWeek` | `GET /api/v1/statistics/weekly` | 동일 | 경로 간소화 |
| 3 | `GET /statistics/cam_parking_area/oneMonth` | `GET /api/v1/statistics/monthly` | 동일 | 경로 간소화 |
| 4 | `GET /statistics/cam_parking_area/oneYear` | `GET /api/v1/statistics/yearly` | 동일 | 경로 간소화 |
| 5 | `POST /statistics/cam_parking_area/searchDay` | `POST /api/v1/statistics/custom-period` | 동일 | 경로 간소화 |
| 6 | `POST /graphData` | `POST /api/v1/statistics/graph-data` | 동일 | 경로 구조화 |
| 7 | `POST /statistics/cam_parking_area/searchgraph` | `POST /api/v1/statistics/graph` | 동일 | 경로 간소화 |
| **로그인/인증** |
| 8 | `POST /login_setting` | `POST /api/v1/auth/login` | 동일 | 경로 구조화 + JWT |
| 9 | `POST /create_admin` | `POST /api/v1/users` | 동일 | role=admin |
| 10 | `POST /confirm_account_list` | `GET /api/v1/users` | **POST→GET** | REST 원칙 |
| 11 | `POST /settings/account/changePassword` | `PATCH /api/v1/users/{account}/password` | **POST→PATCH** | REST 원칙 |
| 12 | `POST /settings/account/insertUser` | `POST /api/v1/users` | 동일 | 경로 간소화 |
| **주차 관리** |
| 13 | `GET /login_setting/base` | `GET /api/v1/auth/base-info` | 동일 | 경로 구조화 |
| 14 | `GET /settings/parking_area` | `GET /api/v1/parking-zones` | 동일 | 경로 간소화 |
| 15 | `POST /pabi/tag` | `GET /api/v1/vehicle/by-tag?tag=` | **POST→GET** | Query param<br>(POST도 지원) |
| 16 | `POST /pabi/car` | `GET /api/v1/vehicle/by-plate?plate=` | **POST→GET** | Query param<br>(POST도 지원) |
| **설정 관리** |
| 17 | `GET /settings/account` | `GET /api/v1/users` | 동일 | 경로 간소화 |
| 18 | `POST /settings/account/deleteUser` | `DELETE /api/v1/users/{account}` | **POST→DELETE** | REST 원칙 |
| 19 | `POST /settings/account/updateUser` | `PUT /api/v1/users/{account}` | **POST→PUT** | REST 원칙 |
| 20 | `POST /settings/account/resetPassword` | `PATCH /api/v1/users/{account}/password/reset` | **POST→PATCH** | REST 원칙 |
| 21 | `POST /base` | `POST /api/v1/parking/information` | 동일 | 경로 구조화 |
| 22 | `GET /base/get` | `GET /api/v1/parking/information` | 동일 | 경로 간소화 |
| 23 | `/setOverride` | 없음 | N/A | ⚠️ 외부 장치 API |
| 24 | `GET /ping` | `GET /api/v1/monitoring/ping` | 동일 | 경로 구조화 |
| 25 | `GET /isalive/isalive` | `GET /api/v1/monitoring/health` | 동일 | 경로 간소화 |
| **디스플레이** |
| 26 | `POST /display` | `POST /api/v1/display/config` | 동일 | 경로 구조화 |
| 27 | `POST /led_cal` | `POST /api/v1/led/calibration` | 동일 | 경로 구조화 |

### 📊 메서드 변경 통계

| 변경 패턴 | 개수 | 비율 |
|----------|------|------|
| 메서드 동일 (경로만 변경) | 19개 | 70% |
| POST → GET | 3개 | 11% |
| POST → DELETE | 1개 | 4% |
| POST → PUT | 1개 | 4% |
| POST → PATCH | 2개 | 7% |
| 외부 API (매핑 없음) | 1개 | 4% |

### 🎯 RESTful 변경 핵심 원칙

1. **POST → GET**: 데이터 조회 작업
   - `/confirm_account_list`: 사용자 목록 조회
   - `/pabi/tag`, `/pabi/car`: 차량 정보 조회

2. **POST → DELETE**: 삭제 작업
   - `/settings/account/deleteUser`: 사용자 삭제

3. **POST → PUT**: 전체 업데이트
   - `/settings/account/updateUser`: 사용자 정보 전체 수정

4. **POST → PATCH**: 부분 업데이트
   - `/settings/account/changePassword`: 비밀번호만 변경
   - `/settings/account/resetPassword`: 비밀번호 리셋만

5. **경로 구조화**:
   - `/api/v1/{resource}/{action}` 형식
   - Kebab-case 사용 (dash-separated)
   - 명확한 리소스 계층 구조

---

## 💡 클라이언트 마이그레이션 가이드

### ✅ 단계별 마이그레이션

#### 1단계: 레거시 API 계속 사용 (현재)
```javascript
// 변경 없음 - 그대로 사용
fetch('/settings/get', {
  method: 'POST',
  body: JSON.stringify({key: 'display_mode'})
});
```

#### 2단계: RESTful API로 점진적 마이그레이션
```javascript
// 새로운 방식
fetch('/api/v1/settings/general/get?key=display_mode', {
  method: 'GET'
});
```

#### 3단계: 혼용 사용 (권장)
```javascript
// 중요 API는 RESTful로, 기타는 레거시로
const APIS = {
  // RESTful 사용
  login: '/api/v1/auth/login',
  getUsers: '/api/v1/users',
  
  // 레거시 유지 (호환성)
  pabiTag: '/pabi/tag',
  display: '/display'
};
```

### 🔄 하위 호환성 보장

**모든 레거시 API는 계속 작동합니다!**

| API 버전 | 상태 | 권장 사용처 |
|---------|------|------------|
| 레거시 (26개) | ✅ 완벽 작동 | 기존 클라이언트, 빠른 개발 |
| RESTful (신규) | ✅ 병행 운영 | 새 프로젝트, 표준 준수 |

---

**보고서 작성**: AI Assistant  
**분석 기준**: 클라이언트 JSON 설정 파일  
**최종 업데이트**: 2025-11-05  
**추가된 정보**: 레거시 → RESTful API 전체 매핑

