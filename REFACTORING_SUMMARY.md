# PBOS Backend 리팩토링 요약

## 📋 개요
구버전의 단일 파일 기반 절차형 코드를 모듈화된 클래스 기반 아키텍처로 전면 리팩토링했습니다.

---

## 🔄 주요 리팩토링 사항

### 1. 통계 API 개선

#### 1.1 응답 필드 변경
- **변경 전**: `car_type` 필드 사용
- **변경 후**: `lot_type` 필드로 통일
- **파일**: `bin/services/statistics_service.dart`, `bin/models/statistics_models.dart`
- **영향**: `/api/v1/statistics/graph` API 응답 형식 변경

#### 1.2 통계 시간 경계 감지 로직 수정
- **문제**: `previousTime`에서 불필요하게 10초를 빼는 로직으로 인해 시간 변화 감지 실패
- **해결**: `previousTime`과 `currentTime`을 직접 비교하도록 수정
- **파일**: `bin/services/engine_data_processor.dart`
- **효과**: 정시마다 시간별 통계가 정상적으로 집계됨

#### 1.3 기간별 필터링 정상화
- **문제**: 그래프 통계 요청 시 기간 문자열에 이중 시간 접미어가 붙는 문제
- **해결**: 기간 문자열을 그대로 서비스로 전달하도록 수정
- **파일**: `bin/routes/statistics_api.dart`, `bin/models/statistics_models.dart`

---

### 2. 엔진 데이터 처리 아키텍처 개선

#### 2.1 모듈화 및 책임 분리
- **구버전**: `receive_enginedata_send_to_dartserver.dart` (624줄) - 단일 함수에 모든 로직
- **신버전**: 역할별 클래스로 분리
  - `EngineDataProcessor`: 전체 플로우 총괄
  - `ParkingStatusUpdater`: 주차 상태 반영
  - `StatisticsProcessor`: 기간별 통계 처리
  - `ParkingDataParser`: 데이터 파싱

#### 2.2 시간 경계 추적 개선
- **추가**: `_lastProcessTime` 필드로 직전 실행 시각 자체 추적
- **효과**: 수동 API 호출 시에도 시간 경계 감지 정상 작동
- **파일**: `bin/services/engine_data_processor.dart`

---

### 3. 카메라 API 전면 개편

#### 3.1 테이블 전환
- **변경 전**: `tb_camera` 테이블 사용
- **변경 후**: `rtsp_capture` 테이블로 전환
- **파일**: 
  - `pb.yaml`: 카메라 관련 쿼리 전면 수정
  - `bin/models/simple_camera_models.dart`: 필드명 변경 (`camera_name` → `rtsp_address`, `image_link` → `last_image_path`)
  - `bin/services/simple_camera_service.dart`: 새 필드명 기반 로직
  - `bin/routes/simple_camera_api.dart`: API 엔드포인트 수정

#### 3.2 쿼리 ID 변경
- `#S_Camera_All` → `#S_RtspCapture_All`
- `#S_Camera_ByTag` → `#S_RtspCapture_ByTag`
- `#I_Camera` → `#I_RtspCapture`
- `#U_Camera_ImageLink` → `#U_RtspCapture_ImagePath`
- `#D_Camera` 추가 (삭제 기능)

---

### 4. 차량 정보 API 확장

#### 4.1 누락된 엔드포인트 추가
- **추가**: `GET /api/v1/vehicle/info` - 전체 차량 정보 목록 조회
- **파일**: `bin/routes/vehicle_info_api.dart`
- **서비스**: `VehicleInfoService.getAllVehicleInfo()` 활용
- **쿼리**: `#get_all_vehicles` 사용

---

### 5. 기본 정보 API 개선

#### 5.1 lotDetails에 tag 필드 추가
- **추가**: `lotDetails` 배열의 각 항목에 `tag` 필드 포함
- **파일**: 
  - `pb.yaml`: `#S_LotInfo` 쿼리에 `tag` 컬럼 추가
  - `bin/models/auth_models.dart`: `LotDetailInfo` 모델에 `tag` 필드 추가
- **효과**: 클라이언트에서 각 주차 공간의 고유 태그 확인 가능

---

### 6. 데이터베이스 클라이언트 개선

#### 6.1 에러 로깅 강화
- **추가**: `executeStatement`와 `executeBatch`에서 ws4sqlite의 `result[i].error` 검사
- **효과**: SQL 실행 실패 시 구체적인 에러 메시지 확인 가능
- **파일**: `bin/services/database_client.dart`

---

### 7. 주차 상태 업데이트 최적화

#### 7.1 배치 처리 로직 추가
- **문제**: 400여 개 공간을 한 번에 배치로 전송 시 ws4sqlite 요청 크기 제한으로 실패
- **해결**: 40개씩 끊어서 전송하도록 수정
- **파일**: `bin/services/parking_status_updater.dart`
- **효과**: `tb_lot_status` 테이블에 정상적으로 데이터 적재

---

## 📊 아키텍처 변화

### 구버전 (절차형)
```
receiveEnginedataSendToDartserver()
├── 엔진 데이터 수신
├── 데이터 파싱
├── 주차 상태 업데이트
├── 시간별 통계 처리
├── 일별 통계 처리
├── 월별 통계 처리
└── 연별 통계 처리
```

### 신버전 (계층형)
```
EngineDataProcessor
├── ParkingDataParser (데이터 파싱)
├── ParkingStatusUpdater (상태 업데이트)
│   ├── saveRawData()
│   ├── updateParkingStatus()
│   └── processLprData()
└── StatisticsProcessor (통계 처리)
    ├── processHourlyStatistics()
    ├── processDailyStatistics()
    ├── processMonthlyStatistics()
    └── processYearlyStatistics()
```

---

## 🔧 주요 버그 수정

### 1. 통계 시간 경계 감지 버그
- **증상**: 통계가 집계되지 않음
- **원인**: `previousTime - 10초`로 비교하여 시간 변화 감지 실패
- **해결**: `previousTime`과 `currentTime` 직접 비교

### 2. 주차 상태 데이터 미적재
- **증상**: `tb_lot_status` 테이블에 데이터가 쌓이지 않음
- **원인**: 대량 배치 전송 시 요청 크기 제한
- **해결**: 40개씩 분할 전송

### 3. 그래프 통계 기간 필터링 오류
- **증상**: 시간별 통계가 모두 동일한 값
- **원인**: 기간 문자열에 이중 시간 접미어 추가
- **해결**: 기간 문자열을 그대로 전달

---

## 📁 파일 구조 개선

### 모델 (Models)
- `bin/models/parking_data.dart` - 주차 데이터 모델
- `bin/models/statistics_models.dart` - 통계 모델
- `bin/models/auth_models.dart` - 인증 및 기본 정보 모델
- `bin/models/simple_camera_models.dart` - 카메라 모델
- `bin/models/vehicle_info_models.dart` - 차량 정보 모델

### 서비스 (Services)
- `bin/services/engine_data_processor.dart` - 엔진 데이터 처리
- `bin/services/statistics_processor.dart` - 통계 처리
- `bin/services/parking_status_updater.dart` - 주차 상태 업데이트
- `bin/services/statistics_service.dart` - 통계 조회 서비스
- `bin/services/simple_camera_service.dart` - 카메라 서비스
- `bin/services/vehicle_info_service.dart` - 차량 정보 서비스
- `bin/services/database_client.dart` - 데이터베이스 클라이언트

### 라우터 (Routes)
- `bin/routes/statistics_api.dart` - 통계 API
- `bin/routes/engine_data.dart` - 엔진 데이터 API
- `bin/routes/simple_camera_api.dart` - 카메라 API
- `bin/routes/vehicle_info_api.dart` - 차량 정보 API
- `bin/routes/auth_api.dart` - 인증 API

### 유틸리티 (Utils)
- `bin/utils/date_utils.dart` - 날짜/시간 유틸리티

---

## 🎯 개선 효과

1. **코드 가독성 향상**: 역할별 클래스 분리로 유지보수 용이
2. **에러 처리 강화**: 구체적인 에러 메시지로 디버깅 시간 단축
3. **성능 최적화**: 배치 처리로 대량 데이터 처리 안정화
4. **API 일관성**: RESTful API 구조로 통일
5. **확장성**: 새로운 기능 추가 시 기존 코드 영향 최소화

---

## 📝 참고 사항

- 모든 변경사항은 `refactoring` 브랜치에 커밋됨
- 구버전 코드는 `bin/routes/receive_enginedata_send_to_dartserver.dart` 참고
- 데이터베이스 쿼리는 `pb.yaml`에 stored statement로 정의
- 테이블 스키마는 `pb.yaml`의 CREATE TABLE 문 참고

---

## 🔄 다음 단계 (권장)

1. 통계 데이터 검증: `processed_db`, `perday`, `permonth`, `peryear` 테이블 데이터 확인
2. 성능 모니터링: 배치 처리 크기 최적화 (현재 40개)
3. 에러 처리 개선: 더 구체적인 에러 메시지 및 복구 로직
4. 테스트 코드 작성: 통계 집계 로직 단위 테스트

