# PBOS Backend API Documentation (OpenAPI 3.0)

## 개요
PBOS (Parking Backend Operation System) RESTful API 문서입니다. 이 문서는 리팩토링된 3계층 구조 (Model-Service-API)의 새로운 API들을 설명합니다.

- **버전**: 2.0.0 (리팩토링 완료)
- **Base URL**: `http://localhost:8080`
- **API Prefix**: `/api/v1/`
- **Content-Type**: `application/json`

---

## 인증 (Authentication) API

### 1. 사용자 로그인
**POST** `/api/v1/auth/login`

사용자 계정으로 로그인하여 JWT 토큰을 발급받습니다.

#### Request Body
```json
{
  "account": "string",     // 사용자 계정 (필수)
  "password": "string"     // 비밀번호 (필수)
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "uid": 1,
      "account": "admin",
      "username": "관리자",
      "userlevel": 1,
      "isActivated": true
    },
    "expiresAt": "2024-01-01T12:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

#### Error Responses
- **400 Bad Request**: 잘못된 요청 형식
- **401 Unauthorized**: 잘못된 계정 정보
- **503 Service Unavailable**: 데이터베이스 연결 오류

### 2. 주차장 기본 정보 조회
**GET** `/api/v1/auth/base-info`

#### Success Response (200)
```json
{
  "success": true,
  "message": "기본 정보 조회 완료",
  "data": {
    "base_info": {
      "name": "스마트 주차장",
      "address": "서울시 강남구...",
      "latitude": "37.1234",
      "longitude": "127.5678",
      "manager": "홍길동",
      "phone_number": "02-1234-5678"
    },
    "parking_config": {
      "total_pixels": {"x": 1920, "y": 1080},
      "lot_types": [
        {"uid": 1, "lot_type": "N", "tag": "일반", "isUsed": true},
        {"uid": 2, "lot_type": "D", "tag": "장애인", "isUsed": true}
      ]
    }
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 중앙 대시보드 (Central Dashboard) API

### 1. 대시보드 데이터 조회
**GET** `/api/v1/central/dashboard`

주차장 전체 현황과 통계 정보를 조회합니다.

#### Success Response (200)
```json
{
  "success": true,
  "message": "중앙 대시보드 데이터 조회 완료",
  "data": {
    "statistics": {
      "total_spaces": 100,
      "used_spaces": 45,
      "available_spaces": 55,
      "occupancy_rate": "45.0"
    },
    "floors": ["B1", "B2", "1F"],
    "lot_types": [1, 2, 3],
    "occupancy_data": [
      {
        "lot_type": 1,
        "floor": "B1",
        "count": 20
      },
      {
        "lot_type": 2,
        "floor": "B1", 
        "count": 5
      }
    ]
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 서비스 상태 확인
**GET** `/api/v1/central/health`

#### Success Response (200)
```json
{
  "success": true,
  "healthy": true,
  "service": "central_dashboard",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 차량 정보 (Vehicle Info) API

### 1. 태그별 차량 정보 조회 (GET)
**GET** `/api/v1/vehicle/by-tag?tag={tag}`

#### Query Parameters
- `tag` (required): 주차 태그 (예: "A101")

#### Success Response (200)
```json
{
  "success": true,
  "message": "차량 정보 조회 완료",
  "data": {
    "tag": "A101",
    "plate": "12가3456",
    "start_time": "2024-01-01T09:30:00Z",
    "point": "100,200",
    "has_vehicle": true
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 태그별 차량 정보 조회 (POST)
**POST** `/api/v1/vehicle/by-tag`

#### Request Body
```json
{
  "tag": "A101"
}
```

#### Success Response (200)
Same as GET method above.

### 3. 번호판별 차량 위치 조회 (GET)
**GET** `/api/v1/vehicle/by-plate?plate={plate}`

#### Query Parameters
- `plate` (required): 차량 번호판 (부분 검색 가능)

#### Success Response (200)
```json
{
  "success": true,
  "message": "차량 위치 조회 완료",
  "data": [
    {
      "tag": "A101",
      "plate": "12가3456",
      "point": "100,200"
    }
  ],
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 4. 번호판별 차량 위치 조회 (POST)
**POST** `/api/v1/vehicle/by-plate`

#### Request Body
```json
{
  "plate": "12가"
}
```

#### Success Response (200)
Same as GET method above.

---

## 전광판 (Billboard) API

### 1. 층별 주차 정보 조회 (GET)
**GET** `/api/v1/billboard/floor/{floor}`

#### Path Parameters
- `floor` (required): 층 정보 (예: "B1", "1F")

#### Success Response (200)
```json
{
  "success": true,
  "message": "층별 주차 정보 조회 완료",
  "data": {
    "floor": "B1",
    "parking_info": [
      {
        "lot_type": 1,
        "type_name": "일반",
        "count": 25
      },
      {
        "lot_type": 2,
        "type_name": "장애인",
        "count": 3
      }
    ],
    "total_available": 28
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 층별 주차 정보 조회 (POST)
**POST** `/api/v1/billboard/floor`

#### Request Body
```json
{
  "floor": "B1"
}
```

#### Success Response (200)
Same as GET method above.

### 3. 부분 시스템 제어
**POST** `/api/v1/billboard/part-system/control`

활성화된 엔드포인트들에 제어 명령을 전송합니다.

#### Request Body
```json
{
  "value": "override_value"
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "모든 부분 시스템 제어 완료",
  "data": {
    "endpoints": [
      "http://192.168.1.10:8080",
      "http://192.168.1.11:8080"
    ],
    "value": "override_value",
    "success_count": 2,
    "total_count": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 디스플레이 (Display) API

### 1. 디스플레이 정보 조회 (GET)
**GET** `/api/v1/display/info?floors={floors}`

#### Query Parameters
- `floors` (required): 쉼표로 구분된 층 목록 (예: "B1,B2,1F")

#### Success Response (200)
```json
{
  "success": true,
  "message": "디스플레이 정보 조회 완료",
  "data": {
    "floors": ["B1", "B2"],
    "display_data": {
      "B1": [
        {
          "point": "100,200",
          "asset": "display_asset_1"
        }
      ],
      "B2": [
        {
          "point": "150,250",
          "asset": "display_asset_2"
        }
      ]
    }
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 디스플레이 정보 조회 (POST)
**POST** `/api/v1/display/info`

#### Request Body
```json
{
  "floors": "B1,B2,1F"
}
```

#### Success Response (200)
Same as GET method above.

### 3. 대량 디스플레이 업데이트
**POST** `/api/v1/display/bulk-update`

#### Request Body
```json
{
  "updates": [
    {
      "tag": "D001",
      "lot_type": 1,
      "point": "100,200",
      "asset": "new_asset",
      "floor": "B1"
    },
    {
      "tag": "D002",
      "lot_type": 2,
      "point": "150,250",
      "asset": "new_asset_2",
      "floor": "B2"
    }
  ]
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "대량 디스플레이 업데이트 완료",
  "data": {
    "processed_count": 2,
    "success_count": 2,
    "failed_count": 0,
    "results": [
      {
        "tag": "D001",
        "success": true,
        "message": "업데이트 완료"
      },
      {
        "tag": "D002", 
        "success": true,
        "message": "업데이트 완료"
      }
    ]
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## LED 계산 (LED Calculation) API

### 1. LED 계산 조회
**GET** `/api/v1/led/calculation`

카메라별 주차 공간 사용률을 계산하여 LED 색상을 결정합니다.

#### Success Response (200)
```json
{
  "success": true,
  "message": "LED 계산 완료",
  "data": {
    "cameras": [
      {
        "camera": "CAM001",
        "tag_count": 10,
        "used_count": 7,
        "usage_rate": 70.0,
        "led_color": "red"
      },
      {
        "camera": "CAM002",
        "tag_count": 8,
        "used_count": 3,
        "usage_rate": 37.5,
        "led_color": "green"
      }
    ],
    "total_cameras": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 시스템 상태 (System Health) API

### 1. 전체 시스템 상태 확인
**GET** `/api/v1/system/health`

#### Success Response (200)
```json
{
  "success": true,
  "message": "시스템 상태 조회 완료",
  "data": {
    "systems": [
      {
        "name": "database",
        "status": true,
        "message": "정상"
      },
      {
        "name": "camera_system",
        "status": true,
        "message": "정상"
      }
    ],
    "overall_status": true
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 특정 시스템 상태 확인
**GET** `/api/v1/system/health/{systemName}`

#### Path Parameters
- `systemName` (required): 확인할 시스템 이름

#### Success Response (200)
```json
{
  "success": true,
  "message": "시스템 상태 확인 완료",
  "data": {
    "system_name": "database",
    "status": true,
    "last_checked": "2024-01-01T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 사용자 관리 (User Management) API

### 1. 사용자 목록 조회
**GET** `/api/v1/users`

#### Success Response (200)
```json
{
  "success": true,
  "message": "사용자 목록 조회 완료",
  "data": {
    "users": [
      {
        "account": "admin",
        "username": "관리자",
        "userlevel": 1,
        "isActivated": true
      },
      {
        "account": "user1",
        "username": "사용자1",
        "userlevel": 2,
        "isActivated": true
      }
    ],
    "total_count": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 사용자 생성
**POST** `/api/v1/users`

#### Request Body
```json
{
  "account": "newuser",
  "password": "password123",
  "username": "새 사용자",
  "userlevel": 2,
  "isActivated": true
}
```

#### Success Response (201)
```json
{
  "success": true,
  "message": "사용자 생성 완료",
  "data": {
    "account": "newuser",
    "username": "새 사용자",
    "userlevel": 2,
    "isActivated": true,
    "created_at": "2024-01-01T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 3. 사용자 수정
**PUT** `/api/v1/users/{account}`

#### Path Parameters
- `account` (required): 수정할 사용자 계정

#### Request Body
```json
{
  "username": "수정된 이름",
  "userlevel": 3,
  "isActivated": false
}
```

#### Success Response (200)
```json
{
  "success": true,
  "message": "사용자 정보 수정 완료",
  "data": {
    "account": "newuser",
    "username": "수정된 이름", 
    "userlevel": 3,
    "isActivated": false,
    "updated_at": "2024-01-01T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 주차 구역 관리 (Parking Zone Management) API

### 1. 주차 구역 목록 조회
**GET** `/api/v1/parking/zones`

#### Success Response (200)
```json
{
  "success": true,
  "message": "주차 구역 목록 조회 완료",
  "data": {
    "zones": [
      {
        "uid": 1,
        "parking_name": "A구역",
        "file_address": "/path/to/zone_a.json",
        "floor": "B1"
      },
      {
        "uid": 2,
        "parking_name": "B구역", 
        "file_address": "/path/to/zone_b.json",
        "floor": "B2"
      }
    ],
    "total_count": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 주차 구역 생성
**POST** `/api/v1/parking/zones`

#### Request Body
```json
{
  "parking_name": "C구역",
  "file_address": "/path/to/zone_c.json",
  "floor": "1F"
}
```

#### Success Response (201)
```json
{
  "success": true,
  "message": "주차 구역 생성 완료",
  "data": {
    "uid": 3,
    "parking_name": "C구역",
    "file_address": "/path/to/zone_c.json", 
    "floor": "1F",
    "created_at": "2024-01-01T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 전광판 관리 (Electric Signs) API

### 1. 전광판 목록 조회
**GET** `/api/v1/electric-signs`

#### Success Response (200)
```json
{
  "success": true,
  "message": "전광판 목록 조회 완료",
  "data": {
    "signs": [
      {
        "uid": 1,
        "parking_lot": "주차장 A"
      },
      {
        "uid": 2,
        "parking_lot": "주차장 B"
      }
    ],
    "total_count": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 전광판 생성
**POST** `/api/v1/electric-signs`

#### Request Body
```json
{
  "uid": 3,
  "parking_lot": "주차장 C"
}
```

#### Success Response (201)
```json
{
  "success": true,
  "message": "전광판 생성 완료",
  "data": {
    "uid": 3,
    "parking_lot": "주차장 C",
    "created_at": "2024-01-01T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 통계 (Statistics) API

### 1. 일별 통계 조회
**GET** `/api/v1/statistics/daily?date={date}`

#### Query Parameters
- `date` (optional): 조회할 날짜 (YYYY-MM-DD 형식, 기본값: 오늘)

#### Success Response (200)
```json
{
  "success": true,
  "message": "일별 통계 조회 완료",
  "data": {
    "date": "2024-01-01",
    "hourly_data": [
      {
        "hour": "09",
        "parking_count": 45,
        "car_type": 1,
        "floor": "B1"
      },
      {
        "hour": "10",
        "parking_count": 52,
        "car_type": 1,
        "floor": "B1"
      }
    ],
    "total_parking_events": 97
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 주별 통계 조회
**GET** `/api/v1/statistics/weekly?week={week}`

#### Query Parameters
- `week` (optional): 조회할 주 (YYYY-WW 형식, 기본값: 이번 주)

#### Success Response (200)
```json
{
  "success": true,
  "message": "주별 통계 조회 완료",
  "data": {
    "week": "2024-01",
    "daily_data": [
      {
        "date": "2024-01-01",
        "parking_count": 120,
        "car_type": 1
      },
      {
        "date": "2024-01-02",
        "parking_count": 115,
        "car_type": 1
      }
    ],
    "total_week_parking": 235
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 공통 에러 응답

### Error Response Format
```json
{
  "success": false,
  "message": "에러 메시지",
  "error": "ERROR_CODE",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### HTTP Status Codes
- **200 OK**: 성공
- **201 Created**: 생성 성공
- **400 Bad Request**: 잘못된 요청
- **401 Unauthorized**: 인증 실패
- **403 Forbidden**: 권한 없음
- **404 Not Found**: 리소스 없음
- **500 Internal Server Error**: 서버 오류
- **503 Service Unavailable**: 서비스 불가

### 주요 에러 코드
- `MISSING_PARAMETER`: 필수 파라미터 누락
- `INVALID_FORMAT`: 잘못된 데이터 형식
- `DATABASE_ERROR`: 데이터베이스 오류
- `AUTHENTICATION_FAILED`: 인증 실패
- `AUTHORIZATION_FAILED`: 권한 부족
- `RESOURCE_NOT_FOUND`: 리소스 없음
- `VALIDATION_FAILED`: 유효성 검사 실패

---

## 레거시 호환성

### 기존 API 엔드포인트 (Deprecated)
기존 클라이언트 호환성을 위해 다음 레거시 엔드포인트들을 지원합니다:

- `POST /login_setting` → `POST /api/v1/auth/login`
- `GET /central` → `GET /api/v1/central/dashboard`
- `POST /pabi/tag` → `POST /api/v1/vehicle/by-tag`
- `POST /pabi/car` → `POST /api/v1/vehicle/by-plate`
- `POST /billboard` → `POST /api/v1/billboard/floor`
- `GET /display` → `GET /api/v1/display/info`
- `GET /led_cal` → `GET /api/v1/led/calculation`
- `GET /ping` → `GET /api/v1/system/health`

**⚠️ 주의**: 레거시 엔드포인트는 향후 버전에서 제거될 예정입니다. 새로운 `/api/v1/` 엔드포인트 사용을 권장합니다.

---

## 요청/응답 예시

### cURL 예시

#### 로그인
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"account":"admin","password":"password"}'
```

#### 중앙 대시보드 조회
```bash
curl -X GET http://localhost:8080/api/v1/central/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

#### 차량 정보 조회
```bash
curl -X GET "http://localhost:8080/api/v1/vehicle/by-tag?tag=A101" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 개발자 노트

### API 설계 원칙
1. **RESTful**: HTTP 메서드와 상태 코드를 올바르게 사용
2. **일관성**: 모든 API가 동일한 응답 형식 사용
3. **버전 관리**: URL 경로에 버전 정보 포함 (`/api/v1/`)
4. **에러 처리**: 명확한 에러 메시지와 코드 제공
5. **보안**: JWT 토큰 기반 인증 시스템

### 개발 환경 설정
1. Dart SDK 3.0+ 설치
2. `dart pub get` 실행
3. `.env` 파일 설정
4. `dart run bin/main.dart` 실행

### 테스트
```bash
# API 서버 실행
dart run bin/main.dart

# 건강 상태 확인
curl http://localhost:8080/api/v1/system/health

# 특정 서비스 상태 확인  
curl http://localhost:8080/api/v1/central/health
```

---

*마지막 업데이트: 2024-01-01*
*API 버전: v2.0.0 (리팩토링 완료)* 