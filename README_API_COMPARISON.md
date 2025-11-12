# README.md vs 실제 구현 API 비교 분석

## 📋 개요
README.md에 문서화된 API와 실제 구현된 API를 비교하여 누락되거나 부정확한 부분을 정리합니다.

---

## ✅ README에 명시된 API vs 실제 구현

### 1. README에 명시된 API (14개)

| README 명시 | 실제 경로 | 상태 |
|------------|---------|------|
| `/api/v1/central/*` | `/api/v1/central/*` | ✅ 일치 |
| `/api/v1/vehicle/*` | `/api/v1/vehicle/*` | ✅ 일치 |
| `/api/v1/billboard/*` | `/api/v1/billboard/*` | ✅ 일치 |
| `/api/v1/display/*` | `/api/v1/display/*` | ✅ 일치 |
| `/api/v1/led/*` | `/api/v1/led/*` | ✅ 일치 |
| `/api/v1/system/*` | `/api/v1/system/*` | ✅ 일치 |
| `/api/v1/engine/*` | `/api/v1/engine/data/*` | ⚠️ 경로 차이 |
| `/api/v1/statistics/*` | `/api/v1/statistics/*` | ✅ 일치 |
| `/api/v1/auth/*` | `/api/v1/auth/*` | ✅ 일치 |
| `/api/v1/users/*` | `/api/v1/users/*` | ✅ 일치 |
| `/api/v1/parking/*` | `/api/v1/parking/*` | ✅ 일치 |
| `/api/v1/camera/*` | `/api/v1/cameras/*` | ⚠️ 경로 차이 |
| `/api/v1/base-info/*` | `/api/v1/parking/information/*` | ⚠️ 경로 차이 |
| `/api/v1/electric-signs/*` | `/api/v1/parking/electric-signs/*` | ⚠️ 경로 차이 |

---

## ❌ README에 누락된 실제 구현 API들

### 1. 인증 관련 (Auth) - 3개 추가
- ✅ `/api/v1/auth/accounts/check` - 계정 확인
- ✅ `/api/v1/auth/legacy` - 레거시 인증 API
- ✅ `/api/v1/auth/status` - 인증 상태 확인

### 2. 사용자 관리 (Users) - 2개 추가
- ✅ `/api/v1/users/admin` - 관리자 생성
- ✅ `/api/v1/users/legacy` - 레거시 사용자 API

### 3. 주차 구역 관리 (Parking Zones) - 2개 추가
- ✅ `/api/v1/parking-zones` - 주차 구역 관리 (분리된 API)
- ✅ `/api/v1/parking-lots` - 주차 공간 관리 (분리된 API)

### 4. 파일 관리 (Files) - 1개 추가
- ✅ `/api/v1/files` - 파일 시스템 관리
- ✅ `/api/v1/files/legacy` - 레거시 파일 API

### 5. 설정 관리 (Settings) - 3개 추가
- ✅ `/api/v1/settings/database` - 데이터베이스 설정
- ✅ `/api/v1/settings/camera-parking` - 카메라 주차 설정
- ✅ `/api/v1/settings/general` - 일반 설정
- ✅ `/api/v1/settings/database/legacy` - 레거시 DB 설정

### 6. 통계 (Statistics) - 2개 추가
- ✅ `/api/v1/statistics/parking-areas` - 주차 구역별 통계
- ✅ `/api/v1/statistics/graphs` - 그래프 데이터

### 7. 주차 정보 (Parking) - 4개 추가
- ✅ `/api/v1/parking/central` - 중앙 대시보드
- ✅ `/api/v1/parking/pabi` - 차량 정보 조회 (레거시)
- ✅ `/api/v1/parking/information/legacy` - 레거시 기본 정보
- ✅ `/api/v1/parking/electric-signs/legacy` - 레거시 전광판

### 8. 시스템 (System) - 3개 추가
- ✅ `/api/v1/system/billboard` - 전광판 제어
- ✅ `/api/v1/system/display` - 디스플레이 관리
- ✅ `/api/v1/system/led-calendar` - LED 캘린더

### 9. 모니터링 (Monitoring) - 3개 추가
- ✅ `/api/v1/monitoring/legacy/health` - 서비스 상태 (레거시)
- ✅ `/api/v1/monitoring/legacy/ping` - DB Ping (레거시)
- ✅ `/api/v1/monitoring/legacy/errors` - 에러 조회 (레거시)

### 10. 리소스 관리 (Resources) - 1개 추가
- ✅ `/api/v1/resources` - 리소스 관리
- ✅ `/api/v1/resources/legacy` - 레거시 리소스 API

### 11. RTSP 캡처 (RTSP) - 1개 추가
- ✅ `/api/v1/rtsp` - RTSP 캡처 관리 (동적 등록)

---

## 🔍 주요 차이점 요약

### 1. 경로 불일치

| README | 실제 구현 | 비고 |
|--------|----------|------|
| `/api/v1/engine/*` | `/api/v1/engine/data/*` | `data` 경로가 실제로는 포함됨 |
| `/api/v1/camera/*` | `/api/v1/cameras/*` | 복수형 `cameras` 사용 |
| `/api/v1/base-info/*` | `/api/v1/parking/information/*` | `parking` 하위로 이동 |
| `/api/v1/electric-signs/*` | `/api/v1/parking/electric-signs/*` | `parking` 하위로 이동 |

### 2. README에 누락된 주요 API 카테고리

1. **파일 관리 API** (`/api/v1/files/*`)
   - 주차 구역 파일 업로드/다운로드
   - 이미지 관리

2. **리소스 관리 API** (`/api/v1/resources/*`)
   - 시스템 리소스 조회
   - 리소스 상태 모니터링

3. **RTSP 캡처 API** (`/api/v1/rtsp/*`)
   - RTSP 스트림 캡처
   - 카메라 이미지 저장

4. **설정 관리 API** (`/api/v1/settings/*`)
   - 데이터베이스 설정
   - 카메라 주차 설정
   - 일반 설정

5. **분리된 주차 관리 API**
   - `/api/v1/parking-zones/*` - 주차 구역 전용
   - `/api/v1/parking-lots/*` - 주차 공간 전용

### 3. 레거시 API 경로

README에는 레거시 호환성에 대한 언급만 있고, 실제 레거시 경로 목록이 없습니다.

**실제 레거시 경로 (26개):**
- `/confirm_account_list`
- `/create_admin`
- `/parking_status`
- `/login_setting`
- `/settings_account`
- `/settings/account`
- `/settings_parking_area`
- `/settings/parking_area`
- `/settings_cam_parking_area`
- `/settings/cam_parking_area`
- `/base_information`
- `/base`
- `/pabi`
- `/multiple_electric_signs`
- `/billboard`
- `/display`
- `/led_cal`
- `/statistics/cam_parking_area`
- `/graphData`
- `/central`
- `/settings/db_management`
- `/settings`
- `/isalive`
- `/ping`
- `/getResource`

---

## 📝 README에 추가되어야 할 내용

### 1. 실제 API 경로 정정

```markdown
### RESTful API 엔드포인트
- `/api/v1/central/*` - 중앙 대시보드 관리
- `/api/v1/vehicle/*` - 차량 정보 조회
- `/api/v1/billboard/*` - 전광판 제어
- `/api/v1/display/*` - 디스플레이 관리
- `/api/v1/led/*` - LED 계산
- `/api/v1/system/*` - 시스템 상태 모니터링
- `/api/v1/engine/data/*` - 엔진 데이터 처리 ⚠️ 수정 필요
- `/api/v1/statistics/*` - 통계 데이터
- `/api/v1/auth/*` - 인증 관리
- `/api/v1/users/*` - 사용자 관리
- `/api/v1/parking-zones/*` - 주차 구역 관리 ⚠️ 추가 필요
- `/api/v1/parking-lots/*` - 주차 공간 관리 ⚠️ 추가 필요
- `/api/v1/parking/*` - 주차 관련 통합 API
- `/api/v1/cameras/*` - 카메라 관리 ⚠️ 수정 필요 (복수형)
- `/api/v1/parking/information/*` - 주차장 기본 정보 ⚠️ 수정 필요
- `/api/v1/parking/electric-signs/*` - 전광판 관리 ⚠️ 수정 필요
- `/api/v1/files/*` - 파일 시스템 관리 ⚠️ 추가 필요
- `/api/v1/settings/*` - 설정 관리 ⚠️ 추가 필요
- `/api/v1/monitoring/*` - 모니터링 ⚠️ 추가 필요
- `/api/v1/resources/*` - 리소스 관리 ⚠️ 추가 필요
- `/api/v1/rtsp/*` - RTSP 캡처 관리 ⚠️ 추가 필요
```

### 2. 레거시 API 섹션 추가

```markdown
## 레거시 API 경로

기존 클라이언트 호환성을 위해 다음 레거시 경로가 유지됩니다:

### 인증 및 사용자 (6개)
- `/login_setting` - 로그인 및 인증
- `/parking_status` - 로그인 메인
- `/confirm_account_list` - 계정 확인
- `/create_admin` - 관리자 생성
- `/settings_account` - 사용자 관리 (언더스코어)
- `/settings/account` - 사용자 관리 (슬래시)

### 주차 관리 (6개)
- `/base` - 주차장 기본 정보
- `/base_information` - 주차장 기본 정보 (별칭)
- `/settings_parking_area` - 주차 구역 (언더스코어)
- `/settings/parking_area` - 주차 구역 (슬래시)
- `/settings_cam_parking_area` - 카메라 주차 (언더스코어)
- `/settings/cam_parking_area` - 카메라 주차 (슬래시)

### 차량 정보 (1개)
- `/pabi` - 차량 정보 조회

### 전광판 및 디스플레이 (4개)
- `/billboard` - 전광판
- `/display` - 디스플레이
- `/led_cal` - LED 계산
- `/multiple_electric_signs` - 다중 전광판

### 통계 및 데이터 (3개)
- `/central` - 중앙 대시보드
- `/statistics/cam_parking_area` - 카메라 주차 통계
- `/graphData` - 그래프 데이터

### 시스템 및 설정 (6개)
- `/settings` - 일반 설정
- `/settings/db_management` - DB 관리
- `/isalive` - 서비스 상태
- `/ping` - DB Ping
- `/getResource` - 리소스 조회
```

### 3. API 카테고리 확장

README의 "API 카테고리 (15개 리팩토링 완료)" 섹션에 다음을 추가해야 합니다:

- **📁 파일 관리 (File Management)** - 파일 업로드/다운로드
- **⚙️ 설정 관리 (Settings)** - 시스템 설정 관리
- **🔄 리소스 관리 (Resource Management)** - 리소스 조회 및 관리
- **📹 RTSP 캡처 (RTSP Capture)** - RTSP 스트림 캡처
- **🅿️ 주차 구역 (Parking Zones)** - 주차 구역 전용 API
- **🅿️ 주차 공간 (Parking Lots)** - 주차 공간 전용 API

---

## 📊 통계

### README에 명시된 API
- **총 14개** 카테고리

### 실제 구현된 API
- **총 20개 이상** 카테고리
- **레거시 경로 26개** 추가

### 누락 비율
- **약 43%** (6개 카테고리 누락)
- **레거시 경로 100%** 누락

---

## ✅ 권장 사항

1. **README 업데이트 필요**
   - 실제 API 경로로 수정
   - 누락된 API 카테고리 추가
   - 레거시 API 섹션 추가

2. **API 문서화 개선**
   - 각 API의 세부 엔드포인트 목록
   - HTTP 메서드 (GET, POST, PUT, DELETE 등)
   - 요청/응답 예시

3. **Swagger 문서와 동기화**
   - README와 Swagger 문서 일치성 확보
   - 177개 API 전체 목록 반영

