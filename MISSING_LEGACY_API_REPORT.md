# 🔍 누락된 레거시 API 분석 보고서

> 날짜: 2025-11-04  
> 기준: pbos_be_copy/bin/main.dart vs 현재 프로젝트

---

## 📊 전체 요약

### 레거시 프로젝트 (pbos_be_copy)
**총 마운트된 경로**: 23개

### 현재 리팩토링 프로젝트
**레거시 호환 경로**: 12개 (52%)

### 누락된 경로
**총 11개** (48%)

---

## ✅ 이미 구현된 레거시 경로 (12개)

| 순번 | 레거시 경로 | 현재 위치 | 상태 |
|------|-------------|-----------|------|
| 1 | `/confirm_account_list` | _configureLegacyRoutes() | ✅ |
| 2 | `/create_admin` | _configureLegacyRoutes() | ✅ |
| 3 | `/parking_status` | _configureLegacyRoutes() | ✅ |
| 4 | `/login_setting` | _configureLegacyRoutes() | ✅ |
| 5 | `/settings/account` | `/settings_account` | ✅ |
| 6 | `/settings/parking_area` | _configureLegacyRoutes() | ✅ |
| 7 | `/settings/cam_parking_area` | _configureLegacyRoutes() | ✅ |
| 8 | `/multiple_electric_signs` | _configureLegacyRoutes() | ✅ |
| 9 | `/base_information` | _configureLegacyRoutes() | ✅ |
| 10 | `/pabi/tag`, `/pabi/car` | `legacy/legacy_pabi.dart` | ✅ (신규 추가) |

---

## ❌ 누락된 레거시 경로 (11개)

### 🔴 우선순위 1: 필수 기능 (5개)

#### 1. `/settings/db_management` - 데이터베이스 관리
**파일**: `bin/routes/settings_db_management.dart`

**엔드포인트**:
- `GET /settings/db_management/` - DB 설정 조회
- `POST /settings/db_management/test` - DB 연결 테스트
- `POST /settings/db_management/update` - DB 설정 수정

**현재 상태**: 
- 파일은 존재하지만 레거시 경로로 마운트되지 않음
- RESTful API로만 제공됨 (`/api/v1/settings/database/*`)

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 2. `/statistics/cam_parking_area` - 카메라 주차 통계
**파일**: `bin/routes/statistics_cam_parking_area.dart`

**엔드포인트**:
- `GET /statistics/cam_parking_area/oneDayAll` - 당일 전체 통계
- `GET /statistics/cam_parking_area/oneDay` - 당일 시간별 통계
- `GET /statistics/cam_parking_area/graphData` - 그래프 데이터
- `GET /statistics/cam_parking_area/oneWeek` - 주간 통계
- `GET /statistics/cam_parking_area/oneMonth` - 월간 통계
- `POST /statistics/cam_parking_area/specific` - 특정 기간 통계

**현재 상태**: 
- 파일은 존재하지만 레거시 경로로 마운트되지 않음
- RESTful API로만 제공됨 (`/api/v1/statistics/parking-areas/*`)

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 3. `/central` - 중앙 대시보드
**파일**: `bin/routes/central.dart`

**엔드포인트**:
- `GET /central/` - 중앙 대시보드 데이터 (전체 주차장 현황)

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/parking/central`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 4. `/base` - 주차장 기본 정보
**파일**: `bin/routes/base_information.dart`

**엔드포인트**:
- `POST /base/` - 기본 정보 등록/수정
- `GET /base/get` - 기본 정보 조회

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/parking/information/*`로 제공
- 현재는 `/base_information`으로만 마운트되어 있음

**필요 작업**: `/base`로 추가 마운트

---

#### 5. `/settings` - 일반 설정
**파일**: `bin/routes/settings.dart`

**엔드포인트**:
- `POST /settings/` - 설정 저장 (key-value)
- `POST /settings/get` - 설정 조회

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/settings/general/*`로 제공
- 레거시 경로로 마운트되지 않음

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

### 🟡 우선순위 2: UI 관련 (3개)

#### 6. `/billboard` - 전광판
**파일**: `bin/routes/billboard.dart`

**엔드포인트**:
- `POST /billboard/` - 전광판 층별 데이터
- `POST /billboard/part_system` - 전광판 시스템 제어

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/billboard/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 7. `/display` - 디스플레이
**파일**: `bin/routes/display.dart`

**엔드포인트**:
- `POST /display/` - 디스플레이 데이터 조회
- `POST /display/dlatl` - 디스플레이 데이터 업데이트

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/display/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 8. `/led_cal` - LED 계산
**파일**: `bin/routes/led_cal.dart`

**엔드포인트**:
- `POST /led_cal/` - LED 계산

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/led/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

### 🟢 우선순위 3: 유틸리티 (3개)

#### 9. `/graphData` - 그래프 데이터
**파일**: `bin/routes/graphData.dart`

**엔드포인트**:
- `POST /graphData/` - 그래프 데이터 생성
- `GET /graphData/test` - 테스트 데이터

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/statistics/graphs/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 10. `/getResource` - 리소스 조회
**파일**: `bin/routes/get_resource.dart`

**엔드포인트**:
- `POST /getResource/get` - 리소스 조회

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/resources/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 11. `/isalive` - 서비스 상태 확인
**파일**: `bin/routes/isalive.dart`

**엔드포인트**:
- `GET /isalive/` - 서비스 상태 확인

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/monitoring/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

#### 12. `/ping` - 데이터베이스 Ping
**파일**: `bin/routes/ping.dart`

**엔드포인트**:
- `GET /ping/` - DB 연결 확인

**현재 상태**: 
- 파일 존재
- RESTful API는 `/api/v1/monitoring/*`로 제공

**필요 작업**: `_configureLegacyRoutes()`에 마운트만 추가

---

## 🚀 구현 계획

### Phase 1: 간단한 마운트만 추가 (즉시 가능 - 10개)

대부분의 파일이 이미 존재하므로, `router_config.dart`의 `_configureLegacyRoutes()`에 마운트만 추가하면 됩니다.

```dart
void _configureLegacyRoutes() {
  // 기존 라우트들...
  
  // 🔴 우선순위 1: 필수 기능
  _router.mount('/settings/db_management', settingsDbManagement.router);
  _router.mount('/statistics/cam_parking_area', statisticsCamParkingArea.router);
  _router.mount('/central', central.router);
  _router.mount('/base', baseInformation.router); // /base_information 외에 추가
  _router.mount('/settings', settings.router);
  
  // 🟡 우선순위 2: UI 관련
  _router.mount('/billboard', billBoard.router);
  _router.mount('/display', display.router);
  _router.mount('/led_cal', ledCal.router);
  
  // 🟢 우선순위 3: 유틸리티
  _router.mount('/graphData', graphdata.router);
  _router.mount('/getResource', getResource.router);
  _router.mount('/isalive', isalive.router);
  _router.mount('/ping', ping.router);
}
```

**예상 작업 시간**: 5-10분

---

### Phase 2: 테스트 및 검증

1. 서버 재시작
2. 각 레거시 경로 접근 테스트
3. 응답 확인

**예상 작업 시간**: 15-20분

---

## 📋 우선순위별 작업 순서

### 즉시 작업 (1단계)
1. ✅ `/pabi` - **완료**
2. 🔴 `/settings/db_management`
3. 🔴 `/statistics/cam_parking_area`
4. 🔴 `/central`
5. 🔴 `/base`
6. 🔴 `/settings`

### 다음 작업 (2단계)
7. 🟡 `/billboard`
8. 🟡 `/display`
9. 🟡 `/led_cal`

### 마지막 작업 (3단계)
10. 🟢 `/graphData`
11. 🟢 `/getResource`
12. 🟢 `/isalive`
13. 🟢 `/ping`

---

## ✨ 최종 목표

**모든 레거시 경로 (23개) 100% 호환**
- ✅ 이미 구현: 12개 (52%)
- 🔴 즉시 추가 필요: 6개
- 🟡 다음 추가: 3개
- 🟢 마지막 추가: 2개

---

## 📝 참고사항

1. **기존 파일 활용**: 모든 레거시 기능 파일이 이미 존재하므로 새로 작성할 필요 없음
2. **마운트만 추가**: `_configureLegacyRoutes()`에 경로만 추가하면 됨
3. **중복 없음**: RESTful API와 레거시 API가 병행 운영됨
4. **하위 호환성**: 기존 클라이언트가 수정 없이 작동함

---

**작성자**: AI Assistant  
**다음 단계**: `_configureLegacyRoutes()` 수정 및 마운트 추가

