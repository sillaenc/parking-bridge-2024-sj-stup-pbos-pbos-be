# PBOS Backend - 스마트 파킹 시스템

## 프로젝트 개요
Dart로 작성된 백엔드 프로젝트로, ws4sqlite를 통한 HTTP 통신으로 데이터베이스와 연결하는 스마트 파킹 시스템입니다.

## 기술 스택
- **언어**: Dart
- **프레임워크**: Dart HTTP Server
- **데이터베이스**: SQLite (ws4sqlite를 통한 HTTP 통신)
- **아키텍처**: 3계층 구조 (Model-Service-API)

## 리팩토링 완료 현황 (15/15)

### 주요 리팩토링 목표
1. 한 파일 내 다수 함수/클래스 분리
2. RESTful API로 변경 (목적성 유지하며)
3. stored statement (#xxx) 쿼리 유지

### 완료된 리팩토링 단계들

#### 1-9단계 (이전 완료)
1. **main.dart** (390줄) → 서버 설정, CORS, 엔진 서비스, 주기적 작업, 날짜 유틸리티, 라우터 통합으로 분리
2. **receive_enginedata_send_to_dartserver.dart** (624줄) → 엔진 데이터 수신 모델, 서비스, API로 분리
3. **statistics_cam_parking_area.dart** (397줄) → 통계 모델, 서비스, RESTful API로 분리
4. **settings_account.dart** (336줄) → 사용자 관리 모델, 서비스, API로 분리
5. **settings_parking_area.dart** (293줄) → 주차 구역 관리 모델, 서비스, API로 분리
6. **settings_cam_parking_area.dart** (162줄) → 카메라 주차 표면 관리 모델, 서비스, API로 분리
7. **login_setting.dart** (273줄) → 인증 모델, JWT 서비스, 인증 서비스, API로 분리
8. **base_information.dart** (166줄) → 주차장 기본 정보 모델, 서비스, API로 분리
9. **multiple_electric_signs.dart** (128줄) → 전광판 모델, 서비스, RESTful API로 분리

#### 10-15단계 (현재 세션 완료)
10. **central.dart** (111줄) → 중앙 대시보드 모델, 서비스, API로 분리
11. **pabi.dart** (101줄) → 차량 정보 조회 모델, 서비스, API로 분리
12. **billboard.dart** (98줄) → 전광판 디스플레이 모델, 서비스, API로 분리
13. **display.dart** (87줄) → 디스플레이 정보 모델, 서비스, API로 분리
14. **led_cal.dart** (68줄) → LED 계산 모델, 서비스, API로 분리
15. **ping.dart** (52줄) → 시스템 상태 확인 모델, 서비스, API로 분리

## 새로운 API 구조

### RESTful API 엔드포인트

#### 핵심 API (15개 리팩토링 완료)
- `/api/v1/central/*` - 중앙 대시보드 관리
- `/api/v1/vehicle/*` - 차량 정보 조회
  - `GET /api/v1/vehicle/info` - 전체 차량 정보 목록
  - `GET /api/v1/vehicle/by-tag?tag={tag}` - 태그로 차량 정보 조회
  - `GET /api/v1/vehicle/by-plate?plate={plate}` - 번호판으로 차량 위치 조회
  - `GET /api/v1/vehicle/health` - 서비스 상태 확인
- `/api/v1/billboard/*` - 전광판 제어
- `/api/v1/display/*` - 디스플레이 관리
- `/api/v1/led/*` - LED 계산
- `/api/v1/system/*` - 시스템 상태 모니터링
- `/api/v1/engine/data/*` - 엔진 데이터 처리
- `/api/v1/statistics/*` - 통계 데이터
  - `GET /api/v1/statistics/graph?startDay={start}&endDay={end}` - 그래프 통계 조회
  - `GET /api/v1/statistics/parking-areas/*` - 주차 구역별 통계
  - `GET /api/v1/statistics/graphs/*` - 그래프 데이터
- `/api/v1/auth/*` - 인증 관리
  - `POST /api/v1/auth/login` - 사용자 로그인
  - `GET /api/v1/auth/base-info` - 주차장 기본 정보 조회
  - `GET /api/v1/auth/token` - 현재 토큰 정보 조회
  - `GET /api/v1/auth/accounts/check` - 계정 확인
  - `GET /api/v1/auth/status` - 인증 상태 확인
- `/api/v1/users/*` - 사용자 관리
  - `POST /api/v1/users/admin` - 관리자 생성
  - `GET /api/v1/users/legacy/*` - 레거시 사용자 API
- `/api/v1/parking-zones/*` - 주차 구역 관리 (분리된 API)
- `/api/v1/parking-lots/*` - 주차 공간 관리 (분리된 API)
- `/api/v1/parking/*` - 주차 관련 통합 API
  - `/api/v1/parking/information/*` - 주차장 기본 정보
  - `/api/v1/parking/electric-signs/*` - 전광판 관리
  - `/api/v1/parking/central/*` - 중앙 대시보드
  - `/api/v1/parking/pabi/*` - 차량 정보 조회 (레거시)
- `/api/v1/cameras/*` - 카메라 관리
  - `GET /api/v1/cameras` - 전체 카메라 목록
  - `GET /api/v1/cameras/{tag}` - 특정 카메라 정보
  - `GET /api/v1/cameras/{tag}/image` - 카메라 이미지 조회
  - `POST /api/v1/cameras` - 카메라 등록
  - `PATCH /api/v1/cameras/{tag}/image` - 카메라 이미지 경로 업데이트
  - `DELETE /api/v1/cameras/{tag}` - 카메라 삭제

#### 추가 관리 API
- `/api/v1/files/*` - 파일 시스템 관리
  - 주차 구역 파일 업로드/다운로드
  - 이미지 관리
- `/api/v1/settings/*` - 설정 관리
  - `/api/v1/settings/database` - 데이터베이스 설정
  - `/api/v1/settings/camera-parking` - 카메라 주차 설정
  - `/api/v1/settings/general` - 일반 설정
- `/api/v1/monitoring/*` - 모니터링
  - `/api/v1/monitoring/legacy/health` - 서비스 상태 (레거시)
  - `/api/v1/monitoring/legacy/ping` - DB Ping (레거시)
  - `/api/v1/monitoring/legacy/errors` - 에러 조회 (레거시)
- `/api/v1/resources/*` - 리소스 관리
  - 시스템 리소스 조회
  - 리소스 상태 모니터링
- `/api/v1/rtsp/*` - RTSP 캡처 관리
  - RTSP 스트림 캡처
  - 카메라 이미지 저장

### 레거시 호환성

모든 리팩토링된 API는 기존 클라이언트 지원을 위해 레거시 라우터를 제공하며, 기존 경로도 임시로 유지하고 있습니다.

#### 레거시 API 경로 (26개)

**인증 및 사용자 (6개)**
- `/login_setting` - 로그인 및 인증
- `/parking_status` - 로그인 메인
- `/confirm_account_list` - 계정 확인
- `/create_admin` - 관리자 생성
- `/settings_account` - 사용자 관리 (언더스코어 버전)
- `/settings/account` - 사용자 관리 (슬래시 버전)

**주차 관리 (6개)**
- `/base` - 주차장 기본 정보
- `/base_information` - 주차장 기본 정보 (별칭)
- `/settings_parking_area` - 주차 구역 (언더스코어 버전)
- `/settings/parking_area` - 주차 구역 (슬래시 버전)
- `/settings_cam_parking_area` - 카메라 주차 (언더스코어 버전)
- `/settings/cam_parking_area` - 카메라 주차 (슬래시 버전)

**차량 정보 (1개)**
- `/pabi` - 차량 정보 조회 (tag/car)

**전광판 및 디스플레이 (4개)**
- `/billboard` - 전광판
- `/display` - 디스플레이
- `/led_cal` - LED 계산
- `/multiple_electric_signs` - 다중 전광판

**통계 및 데이터 (3개)**
- `/central` - 중앙 대시보드
- `/statistics/cam_parking_area` - 카메라 주차 통계
- `/graphData` - 그래프 데이터

**시스템 및 설정 (6개)**
- `/settings` - 일반 설정
- `/settings/db_management` - DB 관리
- `/isalive` - 서비스 상태
- `/ping` - DB Ping
- `/getResource` - 리소스 조회

> **⚠️ 참고**: 레거시 경로는 향후 버전에서 제거될 예정입니다. 가능한 한 새로운 RESTful API 경로를 사용해주세요.

## 프로젝트 구조

```
bin/
├── models/              # 데이터 모델
├── services/            # 비즈니스 로직
├── routes/              # API 라우터
├── core/                # 핵심 기능
├── middleware/          # 미들웨어
└── main.dart           # 애플리케이션 진입점
```

## 주요 기능

### 핵심 기능
- **실시간 주차 공간 모니터링**: 엔진 데이터를 통한 실시간 주차 상태 추적
- **차량 번호판 인식 및 추적**: LPR 데이터 기반 차량 위치 조회
- **통계 데이터 생성 및 분석**: 시간별/일별/월별/연별 통계 자동 집계
- **전광판 및 LED 디스플레이 제어**: 전광판 메시지 및 LED 색상 제어
- **시스템 상태 모니터링**: 실시간 시스템 및 데이터베이스 상태 확인
- **사용자 권한 관리**: JWT 기반 인증 및 권한 관리
- **RTSP 스트림 캡처**: 카메라 RTSP 스트림 캡처 및 이미지 저장
- **파일 시스템 관리**: 주차 구역 파일 및 이미지 업로드/다운로드

### 기술적 특징
- **병렬 처리**: 성능 최적화를 위한 비동기 병렬 처리
- **유효성 검사**: 강화된 입력 데이터 검증
- **에러 처리**: 체계적인 예외 처리 및 상세 에러 로깅
- **서비스 상태 모니터링**: 실시간 시스템 상태 확인
- **3계층 구조**: 모델-서비스-API 분리를 통한 유지보수성 향상
- **배치 처리 최적화**: 대량 데이터 처리를 위한 분할 전송 (40개씩)
- **레거시 호환성**: 기존 클라이언트 지원을 위한 레거시 경로 유지
- **RESTful API**: 표준 HTTP 메서드 및 상태 코드 사용

## 실행 방법

### 1. 개발 환경 설정
```bash
# Dart SDK 설치 필요 (권장 버전: 3.0+)
# VSCode에서 Dart 확장 설치 권장
```

### 2. 의존성 설치
```bash
dart pub get
```

### 3. 환경 변수 설정
```bash
# .env 파일 생성 (.env-example 참고)
cp .env-example .env
# 필요한 환경 변수 설정
```

### 4. 실행
```bash
# VSCode에서 실행 (권장)
# 1. VSCode에서 폴더 기준으로 Open
# 2. 우측 상단 실행 버튼 클릭

# 또는 명령어로 실행
dart run bin/main.dart
```

### 5. 서버 확인
- 서버 시작: http://0.0.0.0:8080
- API 문서: 각 라우터 파일 참고
- 상태 확인: `/api/v1/system/health`

## 데이터베이스

### ws4sqlite 연동
- HTTP 통신을 통한 SQLite 데이터베이스 접근
- Stored Statement 활용
- 쿼리 정의: `pb.yaml` 파일 참고

### 주요 테이블
- `tb_users`: 사용자 관리
- `tb_lots`: 주차 공간 정보 (tag, lot_type, point, isUsed, floor, plate, startTime 포함)
- `tb_lot_type`: 주차 공간 타입 정보 (일반, 장애인, 전기차 등)
- `tb_parking_zone`: 주차 구역 설정
- `tb_lot_status`: 주차 상태 이력 (lot, isParked, added)
- `rawdata`: 원시 주차 데이터 (id, timestamp, parking_lot)
- `processed_db`: 시간별 통계 데이터 (lot, car_type, hour_parking, recorded_hour)
- `perday`: 일별 통계 데이터 (lot, car_type, day_parking, recorded_day)
- `permonth`: 월별 통계 데이터 (lot, car_type, month_parking, recorded_month)
- `peryear`: 연별 통계 데이터 (lot, car_type, year_parking, recorded_year)
- `rtsp_capture`: RTSP 캡처 정보 (tag, rtsp_address, last_image_path)

## 개발 가이드

### 새로운 API 추가 시
1. `models/` 폴더에 데이터 모델 정의
2. `services/` 폴더에 비즈니스 로직 구현
3. `routes/` 폴더에 API 라우터 생성
4. `main.dart`에 라우터 등록
5. `pb.yaml`에 필요한 쿼리 추가

### 코딩 컨벤션
- 3계층 구조 준수 (Model-Service-API)
- RESTful API 설계 원칙 적용
- 유효성 검사 및 에러 처리 포함
- 비동기 처리 활용
- 코드 문서화

## 배포

### 프로덕션 빌드
```bash
dart compile exe bin/main.dart
```

### Docker (옵션)
```dockerfile
# Dockerfile 예시
FROM dart:stable AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/main.dart -o pbos_backend

FROM alpine:latest
RUN apk add --no-cache glibc
COPY --from=build /app/pbos_backend /app/pbos_backend
EXPOSE 8080
CMD ["/app/pbos_backend"]
```

## 문제 해결

### 일반적인 문제
- **포트 충돌**: 기본 포트 8080이 사용 중인 경우 환경 변수로 변경
- **데이터베이스 연결**: ws4sqlite 서버 상태 확인
- **권한 문제**: 사용자 계정 및 권한 설정 확인

### 로그 확인
- 서버 시작 시 콘솔 출력 확인
- 에러 로그는 `error/` 폴더 확인

## 기여 가이드

### 개발 워크플로우
1. 이슈 생성 또는 할당
2. 기능별 브랜치 생성
3. 코드 작성 및 테스트
4. Pull Request 생성
5. 코드 리뷰 및 머지

## 라이선스
[라이선스 정보 추가 필요]

## 📚 API 문서 및 테스트

### Swagger UI 접근
서버 실행 후 다음 URL에서 인터랙티브 API 문서를 확인할 수 있습니다:

- **🌐 Swagger UI (177개 API)**: http://localhost:8080/docs-complete
- **📋 API 문서 (별칭)**: http://localhost:8080/docs-complete  
- **📄 기본 OpenAPI 스펙**: http://localhost:8080/swagger.yaml
- **🎯 완전한 177개 API 스펙**: http://localhost:8080/swagger-complete.yaml

> **💡 완전한 API 문서**: `swagger-complete.yaml`에는 모든 177개 API 엔드포인트가 포함되어 있습니다!

### Swagger UI 사용법
1. 브라우저에서 http://localhost:8080/docs-complete  접속 (177개 전체 API 문서)
2. 우측 상단 **Authorize** 버튼 클릭
3. JWT 토큰 입력 (`Bearer <your-token>` 형식)
4. 각 API의 **Try it out** 버튼으로 실제 테스트

### 📋 API 카테고리 (20개 이상)

#### 핵심 기능 API (15개 리팩토링 완료)
- **🔐 인증 (Authentication)** - 사용자 로그인 및 권한 관리
- **📊 중앙 대시보드 (Central Dashboard)** - 주차장 전체 현황
- **🚗 차량 정보 (Vehicle Info)** - 차량 및 주차 공간 조회
- **📺 전광판 (Billboard)** - 전광판 디스플레이 관리
- **🖥️ 디스플레이 (Display)** - 디스플레이 정보 관리
- **💡 LED 계산 (LED Calculation)** - LED 표시등 색상 계산
- **⚡ 시스템 상태 (System Health)** - 시스템 모니터링
- **⚙️ 엔진 데이터 (Engine Data)** - 엔진 데이터 처리
- **📈 통계 (Statistics)** - 통계 데이터 분석
- **👥 사용자 관리 (User Management)** - 사용자 계정 관리
- **🅿️ 주차 구역 (Parking Zones)** - 주차 구역 전용 API
- **🅿️ 주차 공간 (Parking Lots)** - 주차 공간 전용 API
- **📷 카메라 (Cameras)** - 카메라 관리 (rtsp_capture 테이블 기반)
- **ℹ️ 기본 정보 (Base Information)** - 주차장 기본 정보
- **🔌 전광판 (Electric Signs)** - 전광판 제어

#### 추가 관리 API (5개 이상)
- **📁 파일 관리 (File Management)** - 파일 업로드/다운로드 및 이미지 관리
- **⚙️ 설정 관리 (Settings)** - 데이터베이스, 카메라 주차, 일반 설정
- **🔄 리소스 관리 (Resource Management)** - 시스템 리소스 조회 및 관리
- **📹 RTSP 캡처 (RTSP Capture)** - RTSP 스트림 캡처 및 카메라 이미지 저장
- **🔄 모니터링 (Monitoring)** - 실시간 모니터링 및 시스템 상태 확인

### 추가 문서
- **📖 상세 API 문서**: `OPENAPI_SPEC.md`
- **🧪 실전 테스트 가이드**: `API_TEST_EXAMPLES.md`
- **⚙️ OpenAPI 3.0 스펙**: `swagger.yaml`

## 문제 해결

### Swagger 문서 관련
- **Swagger UI 로딩 실패**: 인터넷 연결 확인 (CDN 리소스 필요)
- **YAML 파일 오류**: swagger.yaml 문법 확인
- **CORS 오류**: 브라우저 개발자 도구에서 확인

### API 테스트 관련
- **404 Not Found**: 엔드포인트 경로 확인
- **401 Unauthorized**: JWT 토큰 확인 또는 인증 필요
- **500 Internal Server Error**: 서버 로그 확인

## 업데이트 이력
- **v2.2.0** (최신): 
  - 통계 API 응답 필드 변경 (car_type → lot_type)
  - 통계 시간 경계 감지 로직 수정
  - 카메라 API를 rtsp_capture 테이블로 전환
  - 차량 정보 API에 /info 엔드포인트 추가
  - base-info API에 lotDetails의 tag 필드 추가
  - 주차 상태 업데이트 배치 처리 최적화 (40개씩 분할)
  - 데이터베이스 클라이언트 에러 로깅 강화
- **v2.1.0**: Swagger UI 및 OpenAPI 3.0 문서 추가
- **v2.0.0**: 대규모 리팩토링 완료 (3계층 구조, RESTful API)
- **v1.x.x**: 초기 버전