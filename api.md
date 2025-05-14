# PBOS API 문서 (실제 라우터 기준)

## 개요
이 문서는 PBOS(Parking Building Operation System)의 RESTful API에 대한 상세한 설명을 제공합니다. 모든 API는 `/api/v1/` 접두사를 사용하며, JSON 형식으로 요청과 응답을 처리합니다.

## 기본 정보
- 기본 URL: `http://[서버주소]/api/v1`
- 응답 형식: JSON
- 인증: JWT 토큰 (Bearer 인증)

## 공통 응답 형식

### 성공 응답
```json
{
  "data": { ... },
  "timestamp": "2024-03-21T10:30:00Z"
}
```

### 에러 응답
```json
{
  "error": "에러 메시지",
  "details": "상세 에러 정보 (선택사항)",
  "status_code": 400
}
```

---

## 1. 계정/사용자 관련 API

### 계정 목록 조회
- **엔드포인트**: `GET /accounts`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "accounts": [
            {
                "uid": 1,
                "account": "test",
                "passwd": "756bc47cb5215dc3329ca7e1f7be33a2dad68990bb94b76d90aa07f4e44a233a",
                "username": "실험체",
                "userlevel": 0,
                "isActivated": 1
            }
        ],
        "total": 1
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:50:09.285067"
}
```

### 계정 상세 조회
- **엔드포인트**: `GET /accounts/{id}`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "uid": 1,
        "account": "test",
        "passwd": "756bc47cb5215dc3329ca7e1f7be33a2dad68990bb94b76d90aa07f4e44a233a",
        "username": "실험체",
        "userlevel": 0,
        "isActivated": 1
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:50:41.042254"
}
```

### 관리자 계정 생성
- **엔드포인트**: `POST /accounts/admin`
- **요청 본문**:
```json
{
  "account": "test2",
  "username": "관리자222",
  "passwd": "123123123"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "관리자 계정이 성공적으로 생성되었습니다",
        "account": "test2",
        "username": "관리자222"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:51:41.420663"
}
```

### 사용자 생성
- **엔드포인트**: `POST /accounts/settings`
- **요청 본문**:
```json
{
  "account": "newuser",
  "passwd": "password",
  "passwdCheck": "password",
  "username": "새사용자",
  "userlevel": 0,
  "isActivated": 1
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "사용자가 성공적으로 생성되었습니다",
        "account": "loweruser",
        "username": "미연시유저",
        "userlevel": 1,
        "isActivated": 1
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:05:25.707327"
}
```

### 사용자 정보 업데이트
- **엔드포인트**: `PUT /accounts/settings/{account}`
- **요청 본문**:
```json
{
  "username": "수정된이름",
  "userlevel": 1,
  "isActivated": 1
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "사용자 정보가 성공적으로 업데이트되었습니다",
        "account": "loweruser",
        "username": "썸포유저김종헌",
        "userlevel": 1,
        "isActivated": 1
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:06:39.471972"
}
```

### 비밀번호 변경
- **엔드포인트**: `PUT /accounts/settings/{account}/password`
- **요청 본문**:
```json
{
  "newpasswd": "1234",
  "passwd": "458472",
  "passwdCheck": "458472"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "비밀번호가 성공적으로 변경되었습니다",
        "account": "loweruser"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:08:16.596240"
}
```

### 사용자 관리(설정)
- **엔드포인트**: `GET /accounts/settings`
- **설명**: 전체 사용자 목록 조회
- **엔드포인트**: `PUT /accounts/settings/{account}`
- **설명**: 사용자 정보 업데이트
- **엔드포인트**: `PUT /accounts/settings/{account}/password`
- **설명**: 비밀번호 변경
- **엔드포인트**: `POST /accounts/settings`
- **설명**: 새 사용자 생성

---

## 2. 주차장 관련 API

### 주차장 목록 조회
- **엔드포인트**: `GET /parking-areas`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "parking_areas": [
            {
                "uid": 1,
                "parking_name": "B1.json",
                "file_address": "json_folder/B1.json",
                "floor": "B1"
            },
            {
                "uid": 2,
                "parking_name": "F1.json",
                "file_address": "json_folder/F1.json",
                "floor": "F1"
            }
        ],
        "timestamp": "2025-05-14T13:08:54.031155"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:08:54.031155"
}
```

### 주차장 카메라 구역 목록
- **엔드포인트**: `GET /parking-areas/cam`
- **응답**:
```json
{
  - 아직 미구현 상태입니다. 주차장 카메라 구역 목록 추가 코드는 미구현이며, 이를 위한 대규모 프로젝트가 필요합니다.
}
```

### 주차장 상태(로그인 메인)
- **엔드포인트**: `GET /parking-areas/status/information`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "information": [
            = 주차장 내용들
        ]
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:19:45.619067"
    }
}
```

### 주차장 설정(로그인 설정)
- **엔드포인트**: `POST /parking-areas/settings/auth`
- **설명**: 로그인 인증
- **엔드포인트**: `GET /parking-areas/settings/base-info`
- **설명**: 기본 정보 조회
- **엔드포인트**: `GET /parking-areas/settings/verify`
- **설명**: JWT 토큰 검증

---

## 3. 통계 관련 API

### 전체 일일 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-day-all`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
            {
                "hour_parking": 1,
                "recorded_hour": "2025-05-13 14"
            },
            {
                "hour_parking": 1,
                "recorded_hour": "2025-05-13 14"
            },
            ...
                ],
        "date": "2025-05-14 0",
        "timestamp": "2025-05-14T13:26:01.465180"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T13:26:01.465691"
}
```

### 특정 일자 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-day`
- **설명**: 어제와 오늘 0시부터 현재 시간까지의 통계를 조회합니다.
- **응답**:
```json
{
  "status": "success",
  "data": {
    "statistics": [
      { "hour_parking": 1, "recorded_hour": "2025-05-13 14" },
      { "hour_parking": 1, "recorded_hour": "2025-05-13 15" },
      { "hour_parking": 1, "recorded_hour": "2025-05-14 0" },
      { "hour_parking": 1, "recorded_hour": "2025-05-14 1" },
      ...
      { "hour_parking": 1, "recorded_hour": "2025-05-14 15" }
    ],
    "date": "2025-05-14 0",
    "timestamp": "2025-05-14T15:26:01.465180"
  },
  "message": "성공적으로 처리되었습니다",
  "timestamp": "2025-05-14T15:26:01.465691"
}
```

### 주간 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-week`
- **요청 파라미터**:
  - `date` (string, 선택): 기준 날짜 (예: `2025-05-14`)
- **요청 예시**:
```
GET /api/v1/statistics/parking-areas/one-week?date=2025-05-14
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "start_date": "2025-05-04",
        "end_date": "2025-05-14",
        "timestamp": "2025-05-14T14:11:01.840155"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:11:01.840155"
}
```

### 기간별 통계 검색
- **엔드포인트**: `POST /statistics/parking-areas/search`
- **요청 본문**:
```json
{
  "startDay": "2025-05-01",
  "endDay": "2025-05-14"
}
```
- **응답**:
```json
{
  "status": "success",
  "data": {
    "statistics": [
      { "date": "2025-05-01", "parking": 5 },
      { "date": "2025-05-02", "parking": 7 }
    ],
    "start_date": "2025-05-01",
    "end_date": "2025-05-14",
    "timestamp": "2025-05-14T13:26:01.465180"
  },
  "message": "성공적으로 처리되었습니다",
  "timestamp": "2025-05-14T13:26:01.465691"
}
```

### 기간별 그래프 데이터 검색
- **엔드포인트**: `POST /statistics/parking-areas/search-graph`
- **요청 본문**:
```json
{
  "startDay": "2025-05-01",
  "endDay": "2025-05-14"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "start_date": "2025-05-13",
        "end_date": "2025-05-15",
        "timestamp": "2025-05-14T14:12:07.764909"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:12:07.765420"
}
```

### 전체 월간 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-month-all`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "timestamp": "2025-05-14T14:13:04.665765"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:13:04.665774"
}
```

### 특정 월 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-month`
- **설명**: 현재 날짜 기준으로 월간 통계를 조회합니다.
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [],
        "start_date": "2025-04-01",
        "end_date": "2025-05-14",
        "timestamp": "2025-05-14T14:13:27.768156"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:13:27.768156"
}
```

### 전체 연간 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-year-all`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "timestamp": "2025-05-14T14:13:50.333861"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:13:50.334371"
}
```

### 특정 연도 통계
- **엔드포인트**: `GET /statistics/parking-areas/one-year`
- **설명**: 현재 날짜 기준으로 연간 통계를 조회합니다.
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "start_date": "2024-05",
        "end_date": "2025-05",
        "timestamp": "2025-05-14T14:14:07.870186"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:14:07.870186"
}
```

### 전체 다년간 통계
- **엔드포인트**: `GET /statistics/parking-areas/several-years-all`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [
          ...
        ],
        "timestamp": "2025-05-14T14:14:30.060604"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:14:30.061604"
}
```

### 특정 기간 다년간 통계
- **엔드포인트**: `GET /statistics/parking-areas/several-years`
- **설명**: 현재 날짜 기준으로 다년간 통계를 조회합니다.
- **응답**:
```json
{
    "status": "success",
    "data": {
        "statistics": [],
        "start_date": "2025-4-14",
        "end_date": "2025-5-14",
        "timestamp": "2025-05-14T14:14:41.150852"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:14:41.151852"
}
```

---

## 4. 디스플레이/전광판 관련 API

### 디스플레이 상태 조회
- **엔드포인트**: `POST /displays/status`
- **요청 본문**:
```json
{
  "floor": "F1"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "floors": [
            "F1"
        ],
        "parking_status": [
            {
                "point": "208, 536",
                "asset": "nHorizontalDisplay.png"
            },
            ...
            {
                "point": "1054, 2202",
                "asset": "lHorizontalDisplay.png"
            }
        ]
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T14:16:59.468259"
}
```

### 전광판 목록 조회
- **엔드포인트**: `GET /displays/electric-signs`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "electric_signs": [
          ... 현 프로젝트에서 미구현상태.
        ],
        "timestamp": "2025-05-14T17:09:27.212722"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:09:27.212722"
}
```

### 전광판 정보 수정/추가/삭제
- **엔드포인트**: `PUT /displays/electric-signs/{uid}`
- **요청 본문**:
```json
{
  "location": "1층 입구",
  "status": "active"
}
```
- **응답**:
```json
{
  -현 프로젝트에서 미구현 상태. 구현 시 추후 수정
}
```

- **엔드포인트**: `POST /displays/electric-signs/{uid}`
- **요청 본문**:
```json
{
  "location": "1층 입구",
  "status": "active"
}
```
- **응답**:
```json
{
  -현 프로젝트에서 미구현 상태. 구현 시 추후 수정
}
```

- **엔드포인트**: `DELETE /displays/electric-signs/{uid}`
- **응답**:
```json
{
  -현 프로젝트에서 미구현 상태. 구현 시 추후 수정
}
```

### 빌보드(층별 주차장 정보)
- **엔드포인트**: `POST /displays/billboard/floor`
- **요청 본문**:
```json
{
  "floor": "F1"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "floor": "F1",
        "parking_lots": [
            {
                "lot_type": 1,
                "count": 68
            },
            {
                "lot_type": 2,
                "count": 6
            },
            {
                "lot_type": 7,
                "count": 11
            },
            {
                "lot_type": 8,
                "count": 10
            },
            {
                "lot_type": 9,
                "count": 2
            }
        ]
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:11:53.401285"
}
```

### LED 상태 조회
- **엔드포인트**: `GET /displays/led-calibration/status`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "led_status": [
            {
                "camera": "A01",
                "color": "green"
            },
            {
                "camera": "A02",
                "color": "red"
            },
            {
                "camera": "A03",
                "color": "red"
            },
            ...
            {
                "camera": "G06",
                "color": "red"
            }
        ],
        "timestamp": "2025-05-14T17:12:19.823706"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:12:19.823706"
}
```

---

## 5. 시스템/설정 관련 API

### 시스템 설정 업데이트
- **엔드포인트**: `PUT /system/settings`
- **요청 본문**:
```json
{
  "key": "machine_display",
  "value": "썸포유저저 김종헌"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "설정이 성공적으로 업데이트되었습니다",
        "key": "machine_display",
        "value": "썸포유저저 김종헌",
        "timestamp": "2025-05-14T17:18:14.485577"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:18:14.485577"
}
```

### DB 설정 정보 조회
- **엔드포인트**: `GET /system/db-management`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "db_settings": {
            "uid": 1,
            "engine_db_addr": "http://ip주소:포트/db명(sqlite기준)",
            "engine_db_id": null,
            "engine_db_passwd": null,
            "display_db_addr": "http://ip주소:포트/db명(sqlite기준) or localhost:포트/db명(sqlite기준)",
            "display_db_id": null,
            "display_db_passwd": null
        },
        "timestamp": "2025-05-14T17:13:22.584309"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:13:22.584309"
}
```

### DB 엔진/디스플레이 주소 변경
- **엔드포인트**: `PUT /system/db-management/engine`
- **요청 본문**:
```json
{
  "engineDb": "http://ip주소:포트/db명(sqlite기준)"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "엔진 DB 설정이 성공적으로 업데이트되었습니다",
        "engine_db": "http://ip주소:포트/db명(sqlite기준)",
        "timestamp": "2025-05-14T17:19:56.033600"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:19:56.034110"
}
```

- **엔드포인트**: `PUT /system/db-management/display`
- **요청 본문**:
```json
{
  "display_db_addr": "주소"
}
```
- **응답**:
```json
{
  "message": "디스플레이 DB 주소가 변경되었습니다",
  "display_db_addr": "주소",
  "timestamp": "2024-03-21T10:30:00Z"
}
```

### 기본 정보 생성/조회
- **엔드포인트**: `POST /system/base-info`
- **요청 본문**:
```json
{
  "name": "빌딩명",
  "address": "서울시 강남구",
  "latitude": 37.1234,
  "longitude": 127.1234,
  "manager": "홍길동",
  "phonenumber": "010-1234-5678"
}
```
- **응답**:
```json
{
    "status": "success",
    "data": {
        "message": "기본 정보가 성공적으로 생성되었습니다",
        "name": "빌딩명",
        "address": "서울시 강남구",
        "latitude": 37.1234,
        "longitude": 127.1234,
        "manager": "홍길동",
        "phoneNumber": "010-1234-5678"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:25:06.464343"
}
```

- **엔드포인트**: `GET /system/base-info`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "base_information": {
            "uid": 1,
            "name": "빌딩명",
            "address": "서울시 강남구",
            "latitude": "37.1234",
            "longitude": "127.1234",
            "manager": "홍길동",
            "phone_number": "010-1234-5678"
        },
        "parking_statistics": {
            "total_lots": 408,
            "used_lots": 291
        }
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T17:25:20.043643"
}
```

### 중앙 제어 시스템 상태 조회
- **엔드포인트**: `GET /system/central`
- **응답**:
```json
{
  - 현재 해당 파트는 중앙 서버 개발 후에 재개발 예정으로 현재는 잠정 개발 중단 상태
}
```

### 차량 정보(PABI)
- **엔드포인트**: `GET /system/pabi/tag/{tag}`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "vehicle_info": {
            "tag": "B1_A01_1_N001",
            "plate": "67하2019",
            "startTime": "2025-05-14 09:15:48"
        },
        "timestamp": "2025-05-14T11:48:13.411014"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:48:13.411524"
}
```
- **엔드포인트**: `GET /system/pabi/plate/{plate}`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "tag_info": [
            {
                "tag": "B1_A01_1_N001",
                "plate": "67하2019",
                "point": "445, 520"
            }
        ],
        "timestamp": "2025-05-14T11:46:51.909186"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:46:51.915186"
}
```

### 리소스(주차장)
- **엔드포인트**: `GET /system/resource/parking-lots`
- **응답**:
```json
{
  "parking_lots": [
    {
      "uid": 1,
      "location": "B1",
      "status": "occupied"
    }
  ],
  "timestamp": "2024-03-21T10:30:00Z"
}
```

---

## 6. 상태/헬스체크 관련 API

### 서버 상태 확인
- **엔드포인트**: `GET /health/ping`
- **응답**:
```json
{
  "status": "active",
  "server_info": {
    "version": "1.0.0",
    "uptime": "10:30:00"
  },
  "timestamp": "2024-03-21T10:30:00Z"
}
```

### isalive(엔드포인트 관리)
- **엔드포인트**: `POST /health/isalive/endpoints`
- **요청 본문**:
```json
{
  "key": "displayDbAddr",
  "value": "http://localhost:12321/pb"
}
```
- **응답**:
```json
{
  "message": "엔드포인트가 추가되었습니다",
  "key": "displayDbAddr",
  "value": "http://localhost:12321/pb",
  "timestamp": "2024-03-21T10:30:00Z"
}
```

- **엔드포인트**: `GET /health/isalive/endpoints`
- **응답**:
```json
{
  "endpoints": [
    {
      "key": "displayDbAddr",
      "value": "http://localhost:12321/pb"
    }
  ],
  "timestamp": "2024-03-21T10:30:00Z"
}
```

- **엔드포인트**: `GET /health/isalive`
- **응답**:
```json
{
    "status": "success",
    "data": {
        "status": "alive",
        "timestamp": "2025-05-14T11:07:24.517057"
    },
    "message": "성공적으로 처리되었습니다",
    "timestamp": "2025-05-14T11:07:24.517057"
}
```

---

## 7. 기타

- 각 API의 상세 요청/응답 예시는 실제 라우터 파일의 구현을 참고하여 추가 작성 필요
- 누락된 엔드포인트나 추가 설명이 필요한 부분은 실제 코드와 동기화하여 계속 보완

---

**이 문서는 main.dart의 실제 라우터 구조와 각 라우터 파일의 엔드포인트를 기준으로 작성되었습니다.**

필요시 각 API별 상세 예시와 파라미터, 응답 예시를 추가로 보완할 수 있습니다. 