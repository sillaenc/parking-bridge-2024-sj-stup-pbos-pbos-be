# 🚀 Smart Parking Backend Server API Documentation

## 📋 Overview

스마트 파킹 백엔드 서버는 주차장 관리, 실시간 모니터링, 사용자 인증, 통계 분석 등을 제공하는 RESTful API 서버입니다.

### 🏗️ Architecture
- **Framework**: Dart Shelf HTTP Server
- **Database**: SQLite (ws4sqlite 통신)
- **Authentication**: JWT Token
- **API Standard**: OpenAPI 3.0 / RESTful
- **File Storage**: Local File System

### 🌐 Base Information
- **Base URL**: `http://localhost:8080`
- **API Version**: `v1`
- **API Prefix**: `/api/v1`

### 📊 Current API Status
- **Total Endpoints**: 80+ API endpoints (확인됨)
- **Main Categories**: 15 API categories
- **Legacy Support**: Backward compatible APIs included
- **Documentation**: Swagger UI available at `/docs`
- **실제 테스트 완료**: 2025-09-24

---

## ✅ 정확한 API 엔드포인트 (Postman 사용)

### 🔐 인증 & 사용자 관리 (테스트 완료 ✅)
```
POST   /api/v1/auth/login              # 로그인 ✅
POST   /api/v1/auth/refresh            # 토큰 갱신 ✅
GET    /api/v1/auth/token              # 현재 토큰 정보 조회 ✅
GET    /api/v1/auth/protected          # 보호된 리소스 접근 테스트 ✅
GET    /api/v1/auth/health             # 인증 서비스 상태 ✅
GET    /api/v1/auth/info               # 인증 서비스 정보 ✅
GET    /api/v1/auth/base-info          # 주차장 기본 정보 ✅
GET    /api/v1/users                   # 사용자 목록 조회 ✅
GET    /api/v1/users/{account}         # 특정 사용자 조회 ✅
POST   /api/v1/users                   # 사용자 생성 ✅
PUT    /api/v1/users/{account}         # 사용자 정보 업데이트 ✅
PATCH  /api/v1/users/{account}/password # 비밀번호 변경 ✅
PATCH  /api/v1/users/{account}/password/reset # 비밀번호 리셋 ✅
DELETE /api/v1/users/{account}         # 사용자 삭제 ✅
GET    /api/v1/users/health            # 사용자 서비스 상태 ✅
GET    /api/v1/users/info              # 사용자 서비스 정보 ✅
```

### 📁 파일 & 주차 구역 관리 (테스트 완료 ✅)
```
GET    /api/v1/files                   # 모든 주차 구역 조회 ✅
POST   /api/v1/files                   # 파일 업로드 및 주차 구역 생성 ✅
GET    /api/v1/files/{name}            # 특정 주차 구역 조회 ✅
PUT    /api/v1/files/{name}            # 파일 업데이트 ✅
DELETE /api/v1/files/{name}            # 파일 삭제 ✅
PATCH  /api/v1/files/lots/{tag}/type   # 주차 공간 유형 변경 ✅
PATCH  /api/v1/files/lots/{tag}/status # 주차 상태 변경 ✅
GET    /api/v1/files/list              # 파일 시스템 파일 목록 ✅
POST   /api/v1/files/sync              # 수동 파일시스템 동기화 ✅
GET    /api/v1/files/health            # 파일시스템 상태 확인 ✅
GET    /api/v1/files/service-health    # 서비스 상태 확인 ✅
GET    /api/v1/files/info              # 서비스 정보 ✅
```

### ⚙️ 설정 관리
```
GET    /api/v1/settings/database/config    # DB 설정 조회
GET    /api/v1/settings/database/health    # DB 서비스 상태
PUT    /api/v1/settings/database/engine    # 엔진 DB 설정 업데이트
PUT    /api/v1/settings/database/display   # 디스플레이 DB 설정 업데이트
POST   /api/v1/settings/general             # 설정 키-값 저장
```

### 🏢 주차장 정보 & 전광판
```
GET    /api/v1/parking/information          # 주차장 기본 정보 조회
GET    /api/v1/parking/information/statistics  # 주차장 통계 정보
GET    /api/v1/parking/information/health   # 주차장 정보 서비스 상태
GET    /api/v1/parking/electric-signs       # 모든 전광판 조회
GET    /api/v1/parking/electric-signs/health # 전광판 서비스 상태
```

### 🎛️ 대시보드 & 디스플레이 (테스트 완료 ✅)
```
GET    /api/v1/central/dashboard        # 중앙 대시보드 데이터 ✅
GET    /api/v1/central/health           # 중앙 서비스 상태 ✅
GET    /api/v1/central/info             # 중앙 서비스 정보 ✅
GET    /api/v1/display                  # 디스플레이 API 정보 ✅
GET    /api/v1/display/health           # 디스플레이 서비스 상태 ✅
GET    /api/v1/display/info             # 디스플레이 서비스 정보 ✅
```

### 📊 통계 & 분석 API 전체 목록 (테스트 완료 ✅)

#### GET `/api/v1/statistics/daily` - 일별 통계 조회

**응답:**
```json
[
  {
    "hour_parking": 1,
    "recorded_hour": "2025-09-24 08"
  },
  {
    "hour_parking": 1,
    "recorded_hour": "2025-09-24 09"
  }
]
```

#### GET `/api/v1/statistics/daily/all` - 일별 전체 통계

**응답:**
```json
[
  {
    "uid": 1,
    "hour_parking": 1,
    "recorded_hour": "2025-09-24 08",
    "car_type": 1,
    "lot": 150
  }
]
```

#### GET `/api/v1/statistics/weekly` - 주별 통계 조회

**응답:**
```json
[
  {
    "day_parking": 1,
    "recorded_day": "2025-09-18"
  },
  {
    "day_parking": 1,
    "recorded_day": "2025-09-19"
  }
]
```

#### GET `/api/v1/statistics/monthly` - 월별 통계 조회

**응답:**
```json
[
  {
    "day_parking": 1,
    "recorded_day": "2025-08-24"
  },
  {
    "day_parking": 1,
    "recorded_day": "2025-09-01"
  }
]
```

#### GET `/api/v1/statistics/monthly/all` - 월별 전체 통계

**응답:**
```json
[
  {
    "uid": 1,
    "car_type": 1,
    "month_parking": 1,
    "recorded_month": "2025-09"
  }
]
```

#### GET `/api/v1/statistics/yearly` - 연별 통계 조회

**응답:**
```json
[
  {
    "month_parking": 1,
    "recorded_month": "2024-09"
  },
  {
    "month_parking": 1,
    "recorded_month": "2025-01"
  }
]
```

#### GET `/api/v1/statistics/yearly/all` - 연별 전체 통계

**응답:**
```json
[
  {
    "uid": 1,
    "car_type": 1,
    "month_parking": 1,
    "recorded_month": "2025-09"
  }
]
```

#### GET `/api/v1/statistics/several-years` - 다년도 통계 조회

**응답:**
```json
[
  {
    "day_parking": 1,
    "recorded_day": "2023-09-24"
  },
  {
    "day_parking": 1,
    "recorded_day": "2024-09-24"
  }
]
```

#### GET `/api/v1/statistics/several-years/all` - 다년도 전체 통계

**응답:**
```json
[
  {
    "uid": 1,
    "car_type": 1,
    "year_parking": 1,
    "recorded_year": "2024"
  }
]
```

#### POST `/api/v1/statistics/custom-period` - 사용자 정의 기간 통계

**요청:**
```json
{
  "startDay": "2024-11-19",
  "endDay": "2024-11-20"
}
```
**응답:**
```json
[
  {
    "day_parking": 1,
    "recorded_day": "2024-11-19"
  },
  {
    "day_parking": 1,
    "recorded_day": "2024-11-20"
  }
]
```

#### POST `/api/v1/statistics/graph` - 그래프용 통계 데이터

**요청:**
```json
{
  "startDay": "2025-09-24 08",
  "endDay": "2025-09-24 09"
}
```
**응답:**
```json
[
  {
    "recorded_hour": "2025-09-24 08",
    "car_type": 1,
    "floor": "B1",
    "count": 15
  },
  {
    "recorded_hour": "2025-09-24 08",
    "car_type": 2,
    "floor": "F1",
    "count": 8
  }
]
```

#### GET `/api/v1/statistics/health` - 통계 서비스 상태 확인

**응답:**
```json
{
  "status": "healthy",
  "timestamp": "2025-09-24T09:38:33.046011",
  "service": "statistics"
}
```

#### GET `/api/v1/statistics/info` - 통계 서비스 정보

**응답:**
```json
{
  "service": "Statistics API",
  "version": "1.0.0",
  "description": "주차장 통계 조회 서비스",
  "endpoints": {
    "GET /daily": "일별 통계 (전일 대비)",
    "GET /daily/all": "일별 전체 통계",
    "GET /weekly": "주별 통계",
    "GET /monthly": "월별 통계 (전월 대비)",
    "POST /custom-period": "사용자 정의 기간 통계",
    "POST /graph": "그래프용 통계"
  },
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 🚙 Vehicle Information API 전체 목록

#### GET `/api/v1/vehicle` - 차량 정보 목록 조회

**Query Parameters:**
- `page`: 페이지 번호
- `limit`: 페이지 크기  
- `license_plate`: 번호판 필터

**응답:**
```json
{
  "success": true,
  "data": {
    "vehicles": [
      {
        "id": 1,
        "license_plate": "ABC123",
        "owner": "홍길동",
        "phone": "010-1234-5678",
        "vehicle_type": "car",
        "tag": "N001",
        "enter_time": "2025-09-24T08:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 1
    }
  }
}
```

#### POST `/api/v1/vehicle` - 차량 정보 등록

**요청:**
```json
{
  "license_plate": "ABC123",
  "owner": "홍길동",
  "phone": "010-1234-5678",
  "vehicle_type": "car"
}
```
**응답:**
```json
{
  "success": true,
  "message": "Vehicle registered successfully",
  "data": {
    "id": 1,
    "license_plate": "ABC123",
    "owner": "홍길동"
  }
}
```

#### GET `/api/v1/vehicle/search` - 차량 검색

**Query Parameters:**
- `plate`: 번호판 (부분 검색 가능)

**응답:**
```json
{
  "success": true,
  "data": [
    {
      "tag": "N001",
      "floor": "B1",
      "point": "208, 536",
      "enter_time": "2025-09-24T08:30:00Z"
    }
  ]
}
```

#### GET `/api/v1/vehicle/health` - 차량 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "vehicle_info",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 📺 Billboard API 전체 목록

#### GET `/api/v1/billboard/floor/{floor}` - 층별 주차 정보 (전광판용)

**요청 예제:** `GET /api/v1/billboard/floor/B1`

**응답:**
```json
{
  "success": true,
  "message": "층별 주차 정보 조회 완료",
  "timestamp": "2025-09-24T09:38:36.755279",
  "data": {
    "floor": "B1",
    "parking_info": [
      {
        "lot_type": 1,
        "count": 12
      },
      {
        "lot_type": 2,
        "count": 4
      },
      {
        "lot_type": 5,
        "count": 3
      }
    ],
    "total_available": 19,
    "timestamp": "2025-09-24T09:38:36.755583"
  }
}
```

#### POST `/api/v1/billboard/floor` - 층별 주차 정보 조회 (POST 방식)

**요청:**
```json
{
  "floor": "B1"
}
```
**응답:**
```json
{
  "success": true,
  "message": "층별 주차 정보 조회 완료",
  "data": {
    "floor": "B1",
    "parking_info": [
      {
        "lot_type": 1,
        "count": 12
      }
    ],
    "total_available": 19
  }
}
```

#### GET `/api/v1/billboard/health` - 전광판 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "billboard",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

#### GET `/api/v1/billboard/info` - 전광판 서비스 정보

**응답:**
```json
{
  "success": true,
  "service": "Billboard API",
  "version": "1.0.0",
  "description": "전광판 표시 정보 조회 및 부분 시스템 제어 API",
  "endpoints": {
    "GET /": "API 기본 정보",
    "GET /floor/{floor}": "층별 주차 정보 조회",
    "POST /floor": "층별 주차 정보 조회 (POST 방식)",
    "POST /part-system/control": "부분 시스템 제어"
  },
  "features": [
    "층별 주차 정보 표시",
    "실시간 전광판 제어", 
    "부분 시스템 관리",
    "주차 공간 상태 모니터링"
  ]
}
```

### 🖥️ Display API 전체 목록

#### GET `/api/v1/display/info` - 디스플레이 정보 조회

**Query Parameters:**
- `floors`: 층 목록 (쉼표로 구분) - **필수**
- `floor`: 단일 층 지정

**요청 예제:** `GET /api/v1/display/info?floors=B1,F1`

**응답:**
```json
{
  "success": true,
  "message": "디스플레이 정보 조회 완료 (2개 층, 128개 항목)",
  "timestamp": "2025-09-24T09:38:44.331594",
  "data": {
    "floors": ["B1", "F1"],
    "display_info": [
      {
        "point": "208, 536",
        "asset": "nHorizontalDisplay.png"
      },
      {
        "point": "671, 600",
        "asset": "nHorizontalDisplay.png"
      },
      {
        "point": "1451, 355",
        "asset": "eVerticalDisplay.png"
      },
      {
        "point": "939, 301",
        "asset": "fVerticalDisplay.png"
      }
    ],
    "total_count": 128,
    "timestamp": "2025-09-24T09:38:44.331989"
  }
}
```

**실패 응답 (파라미터 누락):**
```json
{
  "success": false,
  "message": "floors 또는 floor 파라미터가 필요합니다.",
  "error": "MISSING_FLOORS_PARAMETER",
  "timestamp": "2025-09-24T09:38:40.350312"
}
```

#### GET `/api/v1/display/health` - 디스플레이 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "display",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 🔧 System Health API 전체 목록

#### GET `/api/v1/system/health` - 전체 시스템 상태 확인

**응답:**
```json
{
  "success": true,
  "message": "기본 시스템들이 자동으로 등록되었습니다.",
  "timestamp": "2025-09-24T09:14:50.664515",
  "data": {
    "systems": [
      {
        "name": "Auth Service",
        "is_alright": true,
        "status": "online"
      },
      {
        "name": "Database Service", 
        "is_alright": true,
        "status": "online"
      },
      {
        "name": "File System",
        "is_alright": true,
        "status": "online"
      },
      {
        "name": "Monitoring Service",
        "is_alright": true,
        "status": "online"
      }
    ],
    "total_systems": 4,
    "online_systems": 4,
    "offline_systems": 0,
    "online_percentage": "100.0",
    "overall_status": "healthy"
  }
}
```

#### GET `/api/v1/system/health/{systemName}` - 특정 시스템 상태 확인

**요청 예제:** `GET /api/v1/system/health/Auth Service`

**응답:**
```json
{
  "success": true,
  "message": "시스템 상태 확인 완료",
  "data": {
    "system_name": "Auth Service",
    "is_alright": true,
    "status": "online",
    "last_check": "2025-09-24T09:38:33.046011"
  }
}
```

#### GET `/api/v1/system/ping` - 간단한 생존 확인

**응답:**
```json
{
  "ping": "pong",
  "status": "healthy",
  "online_systems": 4,
  "total_systems": 4,
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 💡 LED Calculation API 전체 목록

#### POST `/api/v1/led/calculate` - LED 계산 실행

**요청:**
```json
{
  "brightness": 80,
  "color": "#FF5733",
  "pattern": "blink",
  "duration": 5000
}
```
**응답:**
```json
{
  "success": true,
  "message": "LED calculation completed",
  "data": {
    "pattern_id": "blink_001",
    "brightness": 80,
    "color": "#FF5733",
    "duration": 5000,
    "calculated_at": "2025-09-24T09:38:33.046011"
  }
}
```

#### GET `/api/v1/led/status` - LED 상태 조회

**응답:**
```json
{
  "success": true,
  "data": {
    "current_brightness": 80,
    "current_color": "#FF5733",
    "current_pattern": "blink",
    "is_active": true,
    "last_update": "2025-09-24T09:38:33.046011"
  }
}
```

#### GET `/api/v1/led/patterns` - 사용 가능한 패턴 목록

**응답:**
```json
{
  "success": true,
  "data": {
    "patterns": [
      "solid", "blink", "fade", "pulse", "rainbow"
    ],
    "default_pattern": "solid"
  }
}
```

#### PUT `/api/v1/led/config` - LED 설정 업데이트

**요청:**
```json
{
  "default_brightness": 70,
  "default_color": "#00FF00",
  "auto_adjust": true
}
```
**응답:**
```json
{
  "success": true,
  "message": "LED configuration updated",
  "data": {
    "default_brightness": 70,
    "default_color": "#00FF00",
    "auto_adjust": true
  }
}
```

#### GET `/api/v1/led/health` - LED 계산 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "led_calculation",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 🗄️ Resource Management API 전체 목록

#### GET `/api/v1/resources/usage` - 리소스 사용량 조회

**응답:**
```json
{
  "success": true,
  "data": {
    "memory_usage": "256MB",
    "disk_usage": "12GB",
    "cpu_usage": "15%",
    "active_connections": 25,
    "file_count": 1205,
    "database_size": "45MB",
    "timestamp": "2025-09-24T09:38:33.046011"
  }
}
```

#### GET `/api/v1/resources/cleanup` - 리소스 정리

**응답:**
```json
{
  "success": true,
  "message": "Resource cleanup completed",
  "data": {
    "cleaned_files": 15,
    "freed_space": "2.5MB",
    "cleanup_duration": "1.2s"
  }
}
```

#### POST `/api/v1/resources/optimize` - 리소스 최적화

**응답:**
```json
{
  "success": true,
  "message": "Resource optimization completed",
  "data": {
    "optimized_queries": 45,
    "memory_saved": "64MB",
    "performance_improvement": "12%"
  }
}
```

#### GET `/api/v1/resources/health` - 리소스 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "resource_management",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

### 🔧 Engine Data API 전체 목록

#### POST `/api/v1/engine/data` - 엔진 데이터 처리

**요청:**
```json
{
  "rawData": "base64_encoded_parking_sensor_data",
  "timestamp": "2025-09-24T09:00:00Z",
  "source": "parking_sensor_1"
}
```
**응답:**
```json
{
  "success": true,
  "message": "Engine data processed successfully",
  "data": {
    "processed": true,
    "parking_spaces_updated": 408,
    "data_id": 15168425,
    "processing_time": "0.5s",
    "updated_lots": [
      {"tag": "N001", "status": "occupied"},
      {"tag": "N002", "status": "available"}
    ]
  }
}
```

#### GET `/api/v1/engine/data/status` - 엔진 데이터 처리 상태

**응답:**
```json
{
  "success": true,
  "data": {
    "last_processing": "2025-09-24T09:37:55.540887",
    "total_processed": 15215791,
    "processing_rate": "2 seconds",
    "status": "active",
    "current_spaces": {
      "total": 408,
      "occupied": 321,
      "available": 87,
      "occupancy_rate": "78.7%"
    }
  }
}
```

#### GET `/api/v1/engine/data/health` - 엔진 데이터 서비스 상태

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "engine_data",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

---

## 🗂️ API Categories Overview

| Category | Base Path | Description | Status |
|----------|-----------|-------------|--------|
| **Authentication** | `/api/v1/auth/*` | 사용자 인증, JWT 토큰 관리 | ✅ Refactored |
| **User Management** | `/api/v1/users/*` | 사용자 CRUD 관리 | ✅ Refactored |
| **Settings** | `/api/v1/settings/*` | 시스템 설정 관리 | ✅ Refactored |
| **File Management** | `/api/v1/files/*` | 파일 업로드/관리, 주차구역 | ✅ Refactored |
| **Database Management** | `/api/v1/settings/database/*` | DB 설정 관리 | ✅ Refactored |
| **Engine Data** | `/api/v1/engine/*` | 엔진 데이터 처리 | ✅ Refactored |
| **Parking Information** | `/api/v1/parking/information/*` | 주차장 기본 정보 | ✅ Refactored |
| **Electric Signs** | `/api/v1/parking/electric-signs/*` | 전광판 관리 | ✅ Refactored |
| **Statistics** | `/api/v1/statistics/*` | 통계 및 분석 | ✅ Refactored |
| **Central Dashboard** | `/api/v1/central/*` | 중앙 대시보드 | ✅ Refactored |
| **Vehicle Information** | `/api/v1/vehicle/*` | 차량 정보 관리 | ✅ Refactored |
| **System Health** | `/api/v1/system/*` | 시스템 상태 모니터링 | ✅ Refactored |
| **Monitoring** | `/api/v1/monitoring/*` | 시스템 모니터링 | ✅ Refactored |
| **Resource Management** | `/api/v1/resources/*` | 리소스 관리 | ✅ Refactored |
| **Billboard** | `/api/v1/billboard/*` | 전광판 관리 | ✅ Refactored |
| **Display** | `/api/v1/display/*` | 디스플레이 관리 | ✅ Refactored |
| **LED Calculation** | `/api/v1/led/*` | LED 계산 | ✅ Refactored |

---

## 📋 API 사용 예제 및 입출력 형식

### 📊 주요 API 엔드포인트 사용 가이드

| API 엔드포인트 | 메서드 | 입력 형식 | 예제 입력 | 예제 출력 |
|---------------|--------|----------|-----------|-----------|
| `/api/v1/auth/login` | POST | JSON | `{"account":"admin","passwd":"password123"}` | `{"success":true,"message":"Login successful","data":{"token":"eyJhbGci...","user":{"id":1,"username":"admin"}}}` |
| `/api/v1/statistics/custom-period` | POST | JSON | `{"startDay":"2024-11-19","endDay":"2024-11-20"}` | `[{"hour_parking":1,"recorded_hour":"2025-09-24 08"}...]` |
| `/api/v1/statistics/graph` | POST | JSON | `{"startDay":"2025-09-24 08","endDay":"2025-09-24 09"}` | `[{"car_type":1,"hour_parking":1,"recorded_hour":"2025-09-24 08"}...]` |
| `/api/v1/files/lots/{tag}/type` | PATCH | JSON | `{"lot_type":2,"changed_tag":"N001_NEW"}` | `{"success":true,"message":"Lot type changed successfully"}` |
| `/api/v1/files/lots/{tag}/status` | PATCH | JSON | `{"isUsed":true}` | `{"success":true,"message":"Parking status changed successfully"}` |
| `/api/v1/users` | POST | JSON | `{"account":"newuser","passwd":"password123","passwdCheck":"password123","username":"새사용자","userlevel":1,"isActivated":1}` | `{"success":true,"message":"User created successfully","data":{"account":"newuser","username":"새사용자"}}` |
| `/api/v1/users/{account}/password` | PATCH | JSON | `{"passwd":"current123","passwdCheck":"current123","newpasswd":"new123"}` | `{"success":true,"message":"Password changed successfully"}` |
| `/api/v1/engine/data` | POST | JSON | `{"rawData":"base64_encoded_data","timestamp":"2025-09-24T09:00:00Z","source":"parking_sensor_1"}` | `{"success":true,"data":{"processed":true,"parking_spaces_updated":408,"data_id":15168425}}` |
| `/api/v1/led/calculate` | POST | JSON | `{"brightness":80,"color":"#FF5733","pattern":"blink","duration":5000}` | `{"success":true,"message":"LED calculation completed","data":{"pattern_id":"blink_001"}}` |
| `/api/v1/files` | POST | Multipart | `file=@parking_layout.jpg&filename=parking_layout.jpg` | `{"success":true,"message":"File uploaded successfully","data":{"parking_name":"parking_layout.jpg","file_address":"file/parking_layout.jpg"}}` |

### 🔍 실제 테스트된 응답 데이터

#### 중앙 대시보드 데이터 (GET `/api/v1/central/dashboard`)
```json
{
  "success": true,
  "message": "중앙 대시보드 데이터 조회 완료",
  "data": {
    "statistics": {
      "total_spaces": 408,
      "used_spaces": 305,
      "available_spaces": 103,
      "occupancy_rate": "74.8"
    },
    "floors": ["B1", "F1"],
    "lot_types": [1, 2, 3, 4, 5, 6, 7, 8, 9],
    "occupancy_data": [
      {"lot_type": 1, "floor": "B1", "count": 137},
      {"lot_type": 2, "floor": "B1", "count": 5}
    ],
    "timestamp": "2025-09-24T09:15:27.498990"
  }
}
```

#### 파일 목록 조회 (GET `/api/v1/files`)
```json
{
  "success": true,
  "message": "Parking zones retrieved successfully",
  "data": [
    {
      "parking_name": "B1.json",
      "file_address": "json_folder/B1.json"
    },
    {
      "parking_name": "large_image_zone",
      "file_address": "file/large_image_zone.jpg"
    },
    {
      "parking_name": "enhanced_video_zone",
      "file_address": "file/enhanced_video_zone.mp4"
    }
  ]
}
```

#### 시스템 상태 확인 (GET `/api/v1/system/health`)
```json
{
  "success": true,
  "message": "기본 시스템들이 자동으로 등록되었습니다.",
  "data": {
    "systems": [
      {"name": "Auth Service", "is_alright": true, "status": "online"},
      {"name": "Database Service", "is_alright": true, "status": "online"},
      {"name": "File System", "is_alright": true, "status": "online"}
    ],
    "total_systems": 4,
    "online_systems": 4,
    "offline_systems": 0,
    "online_percentage": "100.0",
    "overall_status": "healthy"
  }
}
```

#### 일별 통계 조회 (GET `/api/v1/statistics/daily`)
```json
[
  {
    "hour_parking": 1,
    "recorded_hour": "2025-09-24 08"
  },
  {
    "hour_parking": 1,
    "recorded_hour": "2025-09-24 08"
  }
]
```

---

## 🔐 Authentication APIs

모든 보호된 엔드포인트는 JWT 토큰이 필요합니다.

**Header Format:**
```http
Authorization: Bearer <jwt_token>
```

### 🔐 Authentication API 전체 목록

#### POST `/api/v1/auth/login` - 사용자 로그인

**요청:**
```json
{
  "account": "admin",
  "passwd": "password123"
}
```
**성공 응답:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "role": "admin"
    }
  }
}
```
**실패 응답:**
```json
{
  "success": false,
  "message": "Invalid account or password",
  "errorCode": "INVALID_CREDENTIALS"
}
```

#### POST `/api/v1/auth/refresh` - 토큰 갱신

**헤더:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
**응답:**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresAt": "2025-09-25T09:00:00Z"
  }
}
```

#### GET `/api/v1/auth/token` - 현재 토큰 정보 조회

**헤더:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
**응답:**
```json
{
  "success": true,
  "message": "Token information retrieved",
  "data": {
    "account": "admin",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "isValid": true
  }
}
```

#### GET `/api/v1/auth/protected` - 보호된 리소스 접근 테스트

**헤더:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
**응답:**
```json
{
  "success": true,
  "message": "Authentication verified successfully",
  "data": {
    "accessGranted": true,
    "user": "admin",
    "tokenInfo": {
      "account": "admin",
      "isValid": true
    }
  }
}
```

#### GET `/api/v1/auth/base-info` - 주차장 기본 정보 조회

**응답:**
```json
{
  "success": true,
  "message": "Base information retrieved successfully",
  "data": {
    "name": "스마트 파킹장",
    "address": "서울시 강남구 테헤란로 123",
    "totalSpaces": 408,
    "floors": ["B1", "F1"]
  }
}
```

#### GET `/api/v1/auth/health` - 인증 서비스 상태 확인

**응답:**
```json
{
  "status": "healthy",
  "database": "connected",
  "responseTimeMs": 1,
  "timestamp": "2025-09-24T09:38:33.046011",
  "service": "AuthService",
  "jwtService": {
    "service": "JwtService",
    "version": "1.0.0",
    "description": "JWT token management service",
    "secretKeySource": "environment",
    "defaultExpiryHours": 24,
    "supportedOperations": [
      "createToken", "verifyToken", "validateToken", 
      "refreshToken", "extractBearerToken", "getAccountFromToken"
    ]
  }
}
```

#### GET `/api/v1/auth/info` - 인증 서비스 정보 조회

**응답:**
```json
{
  "success": true,
  "message": "Service information retrieved",
  "data": {
    "service": "AuthService",
    "version": "1.0.0",
    "description": "Authentication and authorization service",
    "endpoints": {
      "login": "User authentication with JWT token generation",
      "getBaseInfo": "Retrieve parking lot base information",
      "validateAccess": "Validate JWT token for protected resources"
    },
    "passwordHashing": "Double SHA256 (legacy compatibility)",
    "supportedOperations": [
      "login", "getBaseInfo", "validateAccess", "getServiceHealth"
    ]
  }
}
```

### Legacy Authentication APIs

#### POST `/api/v1/auth/legacy/`
기존 로그인 API (레거시 호환)

#### GET `/api/v1/auth/legacy/base`
기존 기본 정보 API

#### GET `/api/v1/auth/accounts/check`
계정 확인 (레거시)

#### GET `/api/v1/auth/status`
인증 상태 조회 (레거시)

---

## 👥 User Management APIs

### 👥 User Management API 전체 목록

#### GET `/api/v1/users` - 모든 사용자 조회

**Query Parameters:**
- `page`: 페이지 번호 (default: 1)
- `limit`: 페이지 크기 (default: 10)
- `role`: 역할 필터 (admin, user)

**응답:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "username": "admin",
        "account": "admin",
        "userlevel": 2,
        "isActivated": 1,
        "created_at": "2025-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 25,
      "totalPages": 3
    }
  }
}
```

#### GET `/api/v1/users/{account}` - 특정 사용자 조회

**응답:**
```json
{
  "success": true,
  "message": "User retrieved successfully",
  "data": {
    "account": "admin",
    "username": "관리자",
    "userlevel": 2,
    "isActivated": 1
  }
}
```

#### POST `/api/v1/users` - 사용자 생성

**요청:**
```json
{
  "account": "newuser",
  "passwd": "password123",
  "passwdCheck": "password123",
  "username": "새로운 사용자",
  "userlevel": 1,
  "isActivated": 1
}
```
**성공 응답:**
```json
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "account": "newuser",
    "username": "새로운 사용자",
    "userlevel": 1,
    "isActivated": 1
  }
}
```
**실패 응답:**
```json
{
  "success": false,
  "message": "Account already exists",
  "errorCode": "DUPLICATE_ACCOUNT"
}
```

#### PUT `/api/v1/users/{account}` - 사용자 정보 업데이트

**요청:**
```json
{
  "username": "수정된 사용자명",
  "userlevel": 2,
  "isActivated": 1
}
```
**응답:**
```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "account": "testuser",
    "username": "수정된 사용자명",
    "userlevel": 2,
    "isActivated": 1
  }
}
```

#### PATCH `/api/v1/users/{account}/password` - 비밀번호 변경

**요청:**
```json
{
  "passwd": "currentPassword123",
  "passwdCheck": "currentPassword123",
  "newpasswd": "newPassword123"
}
```
**응답:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

#### PATCH `/api/v1/users/{account}/password/reset` - 비밀번호 리셋

**응답:**
```json
{
  "success": true,
  "message": "Password reset to default successfully"
}
```

#### DELETE `/api/v1/users/{account}` - 사용자 삭제

**요청:**
```json
{
  "passwd": "password123"
}
```
**응답:**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

#### GET `/api/v1/users/health` - 사용자 서비스 상태 확인

**응답:**
```json
{
  "success": true,
  "healthy": true,
  "service": "user_management",
  "timestamp": "2025-09-24T09:38:33.046011"
}
```

#### GET `/api/v1/users/info` - 사용자 서비스 정보

**응답:**
```json
{
  "service": "User Management API",
  "version": "1.0.0",
  "description": "RESTful API for user account management",
  "endpoints": {
    "GET /": "Get all users",
    "GET /{account}": "Get user by account",
    "POST /": "Create new user",
    "PUT /{account}": "Update user information",
    "PATCH /{account}/password": "Change user password",
    "PATCH /{account}/password/reset": "Reset user password to default",
    "DELETE /{account}": "Delete user account"
  }
}
```

### User Admin Management

#### POST `/api/v1/users/admin`
관리자 생성

#### Legacy User APIs

#### Various legacy user management endpoints
Legacy 호환성을 위한 기존 사용자 관리 API들

---

## ⚙️ Settings & Configuration APIs

### General Settings

#### POST `/api/v1/settings/general`
설정 키-값 쌍 저장 (Upsert 방식)

**Request Body:**
```json
{
  "key": "parking_fee",
  "value": {
    "hourly_rate": 2000,
    "daily_max": 15000
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Setting saved successfully"
}
```

#### POST `/api/v1/settings/general/get`
설정값 조회

**Request Body:**
```json
{
  "key": "parking_fee"
}
```

**Response:**
```json
{
  "uid": 1,
  "key": "parking_fee",
  "value": "{\"hourly_rate\":2000,\"daily_max\":15000}"
}
```

### Database Management

#### GET `/api/v1/settings/database/config`
현재 데이터베이스 설정 조회

**Response:**
```json
{
  "success": true,
  "message": "데이터베이스 설정을 성공적으로 조회했습니다.",
  "data": {
    "engineDb": "http://localhost:12321/engine_db",
    "displayDb": "http://localhost:12321/display_db"
  }
}
```

#### PUT `/api/v1/settings/database/engine`
엔진 DB 설정 업데이트

**Request Body:**
```json
{
  "engineDb": "http://localhost:12321/engine_db"
}
```

**Response:**
```json
{
  "success": true,
  "message": "엔진 데이터베이스 설정이 업데이트되었습니다.",
  "data": {
    "engineDb": "http://localhost:12321/engine_db"
  }
}
```

#### PUT `/api/v1/settings/database/display`
디스플레이 DB 설정 업데이트

**Request Body:**
```json
{
  "displayDb": "http://localhost:12321/display_db"
}
```

**Response:**
```json
{
  "success": true,
  "message": "디스플레이 데이터베이스 설정이 업데이트되었습니다.",
  "data": {
    "displayDb": "http://localhost:12321/display_db"
  }
}
```

#### PUT `/api/v1/settings/database/config`
전체 데이터베이스 설정 업데이트

**Request Body:**
```json
{
  "engineDb": "http://localhost:12321/engine_db",
  "displayDb": "http://localhost:12321/display_db"
}
```

**Response:**
```json
{
  "success": true,
  "message": "데이터베이스 설정이 업데이트되었습니다.",
  "data": {
    "engineDb": "http://localhost:12321/engine_db",
    "displayDb": "http://localhost:12321/display_db"
  }
}
```

#### POST `/api/v1/settings/database/test-connection`
데이터베이스 연결 테스트

#### GET `/api/v1/settings/database/health`
데이터베이스 서비스 상태 확인

#### GET `/api/v1/settings/database/info`
데이터베이스 서비스 정보

---

## 📁 File Management APIs

### 📁 File Management API 전체 목록

#### GET `/api/v1/files` - 모든 주차 구역 조회

**응답:**
```json
{
  "success": true,
  "message": "Parking zones retrieved successfully",
  "data": [
    {
      "parking_name": "B1.json",
      "file_address": "json_folder/B1.json"
    },
    {
      "parking_name": "large_image_zone",
      "file_address": "file/large_image_zone.jpg"
    },
    {
      "parking_name": "enhanced_video_zone",
      "file_address": "file/enhanced_video_zone.mp4"
    },
    {
      "parking_name": "manual_test",
      "file_address": "file/manual_test.pdf"
    }
  ]
}
```

#### GET `/api/v1/files/{name}`
특정 주차 구역 조회

#### POST `/api/v1/files`
파일 업로드 및 주차 구역 생성

| 항목 | 값 |
|------|-----|
| **메서드** | POST |
| **인증 필요** | ✅ |
| **Content-Type** | multipart/form-data |
| **최대 파일 크기** | 500MB |

**Request Form Data:**
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `file` | file | ✅ | 업로드할 파일 |
| `filename` | string | ✅ | 파일명 (확장자 포함) |

**지원 파일 형식:**
- **이미지**: jpg, jpeg, png, gif, bmp, webp, tiff, ico
- **비디오**: mp4, avi, mov, wmv, flv, webm, mkv, mpg, mpeg, m4v, 3gp
- **문서**: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, csv
- **데이터**: json, xml, yaml, yml
- **압축**: zip, rar, 7z, tar, gz

**cURL 예제:**
```bash
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <jwt_token>" \
  -F "file=@parking_layout.jpg" \
  -F "filename=parking_layout.jpg"
```

**Response (성공):**
```json
{
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "parking_name": "parking_layout.jpg",
    "file_address": "file/parking_layout.jpg"
  }
}
```

**Response (실패 - 파일 크기 초과):**
```json
{
  "success": false,
  "message": "File size exceeds maximum limit",
  "errorCode": "FILE_TOO_LARGE"
}
```

#### PUT `/api/v1/files/{name}`
파일 업데이트 및 주차 구역 업데이트

#### DELETE `/api/v1/files/{name}`
파일 삭제 및 주차 구역 삭제

**Response:**
```json
{
  "success": true,
  "message": "File deleted successfully"
}
```

### Parking Lot Management

#### PATCH `/api/v1/files/lots/{tag}/type`
주차 공간 유형 변경

#### PATCH `/api/v1/files/lots/{tag}/status`
주차 상태 변경

### File System Management

#### GET `/api/v1/files/list`
파일 시스템 파일 목록 조회

#### POST `/api/v1/files/sync`
수동 파일시스템 동기화

**Response:**
```json
{
  "success": true,
  "message": "파일시스템 동기화가 완료되었습니다.",
  "data": {
    "totalFiles": 4,
    "totalSize": 52428887,
    "totalSizeMB": "50.00",
    "supportedFiles": 4,
    "unsupportedFiles": 0,
    "syncDurationMs": 28,
    "syncedAt": "2025-09-23T13:20:07Z",
    "totalParkingZones": 7,
    "status": "completed"
  }
}
```

#### GET `/api/v1/files/health`
파일시스템 상태 확인

#### GET `/api/v1/files/info`
서비스 정보 조회

---

## 🏭 Engine Data Processing APIs

### Engine Data Endpoints

#### POST `/api/v1/engine/data`
엔진 데이터 처리

**Request Body:**
```json
{
  "rawData": "base64_encoded_engine_data",
  "timestamp": "2025-09-23T13:00:00Z",
  "source": "parking_sensor_1"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "processed": true,
    "parking_spaces_updated": 408,
    "data_id": 15168425
  }
}
```

#### GET `/api/v1/engine/data/status`
엔진 데이터 처리 상태 조회

#### GET `/api/v1/engine/data/health`
엔진 서비스 상태 확인

---

## 🏢 Parking Information APIs

### Base Information Management

#### GET `/api/v1/parking/information`
주차장 기본 정보 조회

#### POST `/api/v1/parking/information`
주차장 기본 정보 등록

#### PUT `/api/v1/parking/information`
주차장 기본 정보 업데이트

#### GET `/api/v1/parking/information/statistics`
주차장 통계 정보 조회

**Response:**
```json
{
  "success": true,
  "data": {
    "totalSpaces": 408,
    "occupiedSpaces": 335,
    "availableSpaces": 73,
    "occupancyRate": 82.1,
    "lastUpdated": "2025-09-23T13:00:00Z"
  }
}
```

#### GET `/api/v1/parking/information/full`
기본 정보 + 통계 조회

#### GET `/api/v1/parking/information/health`
서비스 상태 확인

#### GET `/api/v1/parking/information/info`
서비스 정보 조회

### Electric Signs Management

#### GET `/api/v1/parking/electric-signs`
모든 전광판 조회

#### GET `/api/v1/parking/electric-signs/{uid}`
특정 전광판 조회

#### POST `/api/v1/parking/electric-signs`
새 전광판 생성

#### PUT `/api/v1/parking/electric-signs/{uid}`
전광판 업데이트

#### DELETE `/api/v1/parking/electric-signs/{uid}`
전광판 삭제

#### GET `/api/v1/parking/electric-signs/statistics`
전광판 통계 조회

#### GET `/api/v1/parking/electric-signs/parking-lot/{parkingLot}`
주차장별 전광판 조회

#### GET `/api/v1/parking/electric-signs/health`
전광판 서비스 상태 확인

#### GET `/api/v1/parking/electric-signs/info`
전광판 서비스 정보

---

## 📊 Statistics & Analytics APIs

### Statistics Endpoints

#### GET `/api/v1/statistics/parking`
주차 통계 조회

**Query Parameters:**
- `startDate`: 시작 날짜 (YYYY-MM-DD)
- `endDate`: 종료 날짜 (YYYY-MM-DD)
- `granularity`: 집계 단위 (hour, day, month)

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "startDate": "2025-09-01",
      "endDate": "2025-09-30",
      "granularity": "day"
    },
    "statistics": [
      {
        "date": "2025-09-23",
        "totalSpaces": 408,
        "avgOccupancy": 82.1,
        "peakOccupancy": 95.2,
        "peakTime": "14:30:00"
      }
    ]
  }
}
```

#### GET `/api/v1/statistics/camera-parking`
카메라 주차 통계 조회

#### GET `/api/v1/statistics/revenue`
수익 통계 조회

#### GET `/api/v1/statistics/summary`
통계 요약 정보

#### GET `/api/v1/statistics/health`
통계 서비스 상태 확인

#### GET `/api/v1/statistics/info`
통계 서비스 정보

---

## 🖥️ Central Dashboard APIs

### Dashboard Endpoints

#### GET `/api/v1/central/dashboard`
중앙 대시보드 데이터 조회

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "totalSpaces": 408,
      "occupiedSpaces": 335,
      "availableSpaces": 73,
      "occupancyRate": 82.1
    },
    "realtime": {
      "activeConnections": 25,
      "lastUpdate": "2025-09-23T13:00:00Z",
      "systemStatus": "healthy"
    },
    "alerts": [
      {
        "level": "warning",
        "message": "Camera 3 connection unstable",
        "timestamp": "2025-09-23T12:45:00Z"
      }
    ]
  }
}
```

#### GET `/api/v1/central/realtime`
실시간 데이터 조회

#### GET `/api/v1/central/alerts`
알림 목록 조회

#### GET `/api/v1/central/status`
중앙 시스템 상태 조회

#### GET `/api/v1/central/health`
중앙 서비스 상태 확인

#### GET `/api/v1/central/info`
중앙 서비스 정보

---

## 🚙 Vehicle Information APIs

### Vehicle Management

#### GET `/api/v1/vehicle`
차량 정보 목록 조회

**Query Parameters:**
- `page`: 페이지 번호
- `limit`: 페이지 크기
- `license_plate`: 번호판 필터

**Response:**
```json
{
  "success": true,
  "data": {
    "vehicles": [
      {
        "id": 1,
        "license_plate": "ABC123",
        "owner": "John Doe",
        "phone": "010-1234-5678",
        "vehicle_type": "car"
      }
    ]
  }
}
```

#### POST `/api/v1/vehicle`
차량 정보 등록

#### GET `/api/v1/vehicle/{id}`
특정 차량 정보 조회

#### PUT `/api/v1/vehicle/{id}`
차량 정보 수정

#### DELETE `/api/v1/vehicle/{id}`
차량 정보 삭제

#### GET `/api/v1/vehicle/search`
차량 검색

#### GET `/api/v1/vehicle/history/{id}`
차량 출입 기록

#### GET `/api/v1/vehicle/health`
차량 서비스 상태 확인

#### GET `/api/v1/vehicle/info`
차량 서비스 정보

---

## 🖥️ Display & Billboard APIs

### Billboard Management

#### GET `/api/v1/billboard`
전광판 목록 조회

#### POST `/api/v1/billboard`
전광판 생성

#### GET `/api/v1/billboard/{id}`
특정 전광판 조회

#### PUT `/api/v1/billboard/{id}`
전광판 정보 수정

#### DELETE `/api/v1/billboard/{id}`
전광판 삭제

#### GET `/api/v1/billboard/status`
전광판 상태 조회

#### GET `/api/v1/billboard/health`
전광판 서비스 상태 확인

### Display Management

#### GET `/api/v1/display`
디스플레이 목록 조회

#### POST `/api/v1/display`
디스플레이 생성

#### GET `/api/v1/display/{id}`
특정 디스플레이 조회

#### PUT `/api/v1/display/{id}`
디스플레이 설정 수정

#### DELETE `/api/v1/display/{id}`
디스플레이 삭제

#### GET `/api/v1/display/health`
디스플레이 서비스 상태 확인

#### GET `/api/v1/display/info`
디스플레이 서비스 정보

---

## 🔧 System Health & Monitoring APIs

### System Health Endpoints

#### GET `/api/v1/system/health`
시스템 전체 상태 확인

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "uptime": "72h 45m 30s",
    "version": "1.0.0",
    "services": {
      "database": "healthy",
      "fileSystem": "healthy",
      "authentication": "healthy",
      "engineData": "healthy"
    },
    "metrics": {
      "memoryUsage": "256MB",
      "diskUsage": "12GB",
      "cpuUsage": "15%"
    },
    "timestamp": "2025-09-23T13:00:00Z"
  }
}
```

#### GET `/api/v1/system/info`
시스템 정보 조회

#### GET `/api/v1/system/metrics`
시스템 메트릭 조회

#### GET `/api/v1/system/billboard`
시스템 전광판 상태

#### GET `/api/v1/system/display`
시스템 디스플레이 상태

#### GET `/api/v1/system/led-calendar`
LED 캘린더 상태

### Monitoring Endpoints

#### GET `/api/v1/monitoring/health`
전체 시스템 생존 상태 확인

#### POST `/api/v1/monitoring/health`
새로운 서비스 URL 등록

#### GET `/api/v1/monitoring/health/services`
등록된 서비스들의 생존 상태 확인

#### GET `/api/v1/monitoring/health/isalive`
서버 생존 확인 (레거시 호환)

#### GET `/api/v1/monitoring/ping`
데이터베이스 생존 확인

#### GET `/api/v1/monitoring/ping/database`
데이터베이스 상세 상태 확인

#### GET `/api/v1/monitoring/errors`
현재 오류 상태 조회

#### POST `/api/v1/monitoring/errors`
오류 보고

#### DELETE `/api/v1/monitoring/errors`
오류 목록 초기화

#### GET `/api/v1/monitoring/status`
전체 모니터링 상태 요약

#### GET `/api/v1/monitoring/logs`
로그 조회

#### GET `/api/v1/monitoring/performance`
성능 모니터링

#### GET `/api/v1/monitoring/info`
모니터링 서비스 정보

---

## 🗄️ Resource Management APIs

### Resource Endpoints

#### GET `/api/v1/resources/usage`
리소스 사용량 조회

#### GET `/api/v1/resources/cleanup`
리소스 정리

#### POST `/api/v1/resources/optimize`
리소스 최적화

#### GET `/api/v1/resources/status`
리소스 상태 조회

#### GET `/api/v1/resources/health`
리소스 서비스 상태 확인

#### GET `/api/v1/resources/info`
리소스 서비스 정보

---

## 🔗 LED Calculation APIs

### LED Calculation Endpoints

#### POST `/api/v1/led/calculate`
LED 계산 실행

**Request Body:**
```json
{
  "brightness": 80,
  "color": "#FF5733",
  "pattern": "blink",
  "duration": 5000
}
```

#### GET `/api/v1/led/status`
LED 상태 조회

#### GET `/api/v1/led/patterns`
사용 가능한 패턴 목록

#### PUT `/api/v1/led/config`
LED 설정 업데이트

#### GET `/api/v1/led/health`
LED 서비스 상태 확인

#### GET `/api/v1/led/info`
LED 서비스 정보

---

## 📱 Camera Parking APIs

### Camera Parking Settings

#### GET `/api/v1/settings/camera-parking`
카메라 주차 설정 조회

#### POST `/api/v1/settings/camera-parking`
카메라 주차 설정 등록

#### PUT `/api/v1/settings/camera-parking/{id}`
카메라 주차 설정 수정

#### DELETE `/api/v1/settings/camera-parking/{id}`
카메라 주차 설정 삭제

#### GET `/api/v1/settings/camera-parking/health`
카메라 주차 서비스 상태 확인

#### GET `/api/v1/settings/camera-parking/info`
카메라 주차 서비스 정보

---

## 📊 Statistics & Analytics

### Statistics Endpoints

#### GET `/api/v1/statistics/parking`
주차 통계 조회

**Query Parameters:**
- `startDate`: 시작 날짜 (YYYY-MM-DD)
- `endDate`: 종료 날짜 (YYYY-MM-DD)
- `granularity`: 집계 단위 (hour, day, month)

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "startDate": "2025-09-01",
      "endDate": "2025-09-30",
      "granularity": "day"
    },
    "statistics": [
      {
        "date": "2025-09-23",
        "totalSpaces": 408,
        "avgOccupancy": 82.1,
        "peakOccupancy": 95.2,
        "peakTime": "14:30:00"
      }
    ]
  }
}
```

#### GET `/api/v1/statistics/camera-parking`
카메라 주차 통계 조회

#### GET `/api/v1/statistics/revenue`
수익 통계 조회

---

## 🖥️ Display & Billboard

### Billboard Management

#### GET `/api/v1/billboard`
전광판 목록 조회

#### POST `/api/v1/billboard`
전광판 생성

#### GET `/api/v1/billboard/{id}`
특정 전광판 조회

#### PUT `/api/v1/billboard/{id}`
전광판 정보 수정

#### DELETE `/api/v1/billboard/{id}`
전광판 삭제

### Display Management

#### GET `/api/v1/display`
디스플레이 목록 조회

#### POST `/api/v1/display`
디스플레이 생성

#### GET `/api/v1/display/{id}`
특정 디스플레이 조회

#### PUT `/api/v1/display/{id}`
디스플레이 설정 수정

---

## 🚙 Vehicle Information

### Vehicle Management

#### GET `/api/v1/vehicle`
차량 정보 목록 조회

#### POST `/api/v1/vehicle`
차량 정보 등록

#### GET `/api/v1/vehicle/{id}`
특정 차량 정보 조회

#### PUT `/api/v1/vehicle/{id}`
차량 정보 수정

#### DELETE `/api/v1/vehicle/{id}`
차량 정보 삭제

---

## 🎛️ Central Dashboard

### Dashboard Endpoints

#### GET `/api/v1/central/dashboard`
중앙 대시보드 데이터 조회

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "totalSpaces": 408,
      "occupiedSpaces": 335,
      "availableSpaces": 73,
      "occupancyRate": 82.1
    },
    "realtime": {
      "activeConnections": 25,
      "lastUpdate": "2025-09-23T13:00:00Z",
      "systemStatus": "healthy"
    },
    "alerts": [
      {
        "level": "warning",
        "message": "Camera 3 connection unstable",
        "timestamp": "2025-09-23T12:45:00Z"
      }
    ]
  }
}
```

#### GET `/api/v1/central/realtime`
실시간 데이터 조회

#### GET `/api/v1/central/alerts`
알림 목록 조회

---

## 🔧 System Health & Monitoring

### Health Check Endpoints

#### GET `/api/v1/system/health`
시스템 전체 상태 확인

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "uptime": "72h 45m 30s",
    "version": "1.0.0",
    "services": {
      "database": "healthy",
      "fileSystem": "healthy",
      "authentication": "healthy",
      "engineData": "healthy"
    },
    "metrics": {
      "memoryUsage": "256MB",
      "diskUsage": "12GB",
      "cpuUsage": "15%"
    },
    "timestamp": "2025-09-23T13:00:00Z"
  }
}
```

#### GET `/api/v1/system/info`
시스템 정보 조회

#### GET `/api/v1/system/metrics`
시스템 메트릭 조회

### Monitoring Endpoints

#### GET `/api/v1/monitoring/logs`
로그 조회

#### GET `/api/v1/monitoring/performance`
성능 모니터링

#### GET `/api/v1/monitoring/errors`
오류 로그 조회

---

## 🗄️ Database & Resource Management

### Database Management

#### GET `/api/v1/settings/database/config`
현재 데이터베이스 설정 조회

#### PUT `/api/v1/settings/database/engine`
엔진 DB 설정 업데이트

#### PUT `/api/v1/settings/database/display`
디스플레이 DB 설정 업데이트

#### GET `/api/v1/settings/database/health`
데이터베이스 서비스 상태 확인

### Resource Management

#### GET `/api/v1/resources/usage`
리소스 사용량 조회

#### GET `/api/v1/resources/cleanup`
리소스 정리

---

## 🔗 LED Calculation

### LED Calculation Endpoints

#### POST `/api/v1/led/calculate`
LED 계산 실행

**Request Body:**
```json
{
  "brightness": 80,
  "color": "#FF5733",
  "pattern": "blink",
  "duration": 5000
}
```

#### GET `/api/v1/led/status`
LED 상태 조회

---

## 📝 Error Handling

### Standard Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "errorCode": "ERROR_CODE",
  "timestamp": "2025-09-23T13:00:00Z",
  "details": {
    "field": "Specific error details"
  }
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `AUTH_REQUIRED` | Authentication required |
| `AUTH_INVALID` | Invalid credentials |
| `AUTH_EXPIRED` | Token expired |
| `PERMISSION_DENIED` | Insufficient permissions |
| `VALIDATION_ERROR` | Request validation failed |
| `NOT_FOUND` | Resource not found |
| `FILE_TOO_LARGE` | File size exceeds limit |
| `UNSUPPORTED_FORMAT` | Unsupported file format |
| `DATABASE_ERROR` | Database operation failed |
| `INTERNAL_ERROR` | Internal server error |

### HTTP Status Codes

| Status | Description |
|--------|-------------|
| `200` | Success |
| `201` | Created |
| `400` | Bad Request |
| `401` | Unauthorized |
| `403` | Forbidden |
| `404` | Not Found |
| `413` | Payload Too Large |
| `422` | Unprocessable Entity |
| `500` | Internal Server Error |

---

## 🚀 Getting Started

### 1. Authentication
```bash
# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

### 2. File Upload
```bash
# Upload parking zone file
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <token>" \
  -F "file=@parking_layout.jpg" \
  -F "filename=parking_layout.jpg"
```

### 3. Get Statistics
```bash
# Get parking statistics
curl -X GET "http://localhost:8080/api/v1/statistics/parking?startDate=2025-09-01&endDate=2025-09-30" \
  -H "Authorization: Bearer <token>"
```

### 4. System Health Check
```bash
# Check system health
curl -X GET http://localhost:8080/api/v1/system/health \
  -H "Authorization: Bearer <token>"
```

---

## 📊 File Management Features

### File System Synchronization
The system automatically maintains consistency between the file system and database:

- **Orphaned Record Cleanup**: Removes database records for deleted files
- **Missing File Detection**: Adds database entries for new files
- **Automatic Sync**: Periodic synchronization every operation
- **Manual Sync**: On-demand synchronization via API

### Supported File Operations
- **Upload**: Multi-format file upload with validation
- **Download**: Secure file serving
- **Update**: File replacement with history
- **Delete**: Safe deletion with cleanup
- **Sync**: Bi-directional synchronization

---

## 🌐 Legacy APIs

### Legacy 호환성 API들

프로젝트에는 기존 클라이언트와의 호환성을 위해 다수의 레거시 API들이 포함되어 있습니다:

#### Authentication Legacy APIs
- `POST /api/v1/auth/legacy/` - 기존 로그인 방식
- `GET /api/v1/auth/legacy/base` - 기존 기본 정보 조회
- `GET /api/v1/auth/accounts/check` - 계정 확인
- `GET /api/v1/auth/status` - 인증 상태

#### User Management Legacy APIs
- 다양한 기존 사용자 관리 엔드포인트들

#### Parking Zone Legacy APIs
- 기존 주차 구역 관리 API들

#### Display/Billboard Legacy APIs
- 기존 디스플레이 및 전광판 관리 API들

---

## 🚫 Error Handling

### 표준 에러 응답 형식

모든 API는 다음과 같은 표준 에러 응답 형식을 사용합니다:

```json
{
  "success": false,
  "message": "Error description",
  "errorCode": "ERROR_CODE",
  "timestamp": "2025-09-23T13:00:00Z"
}
```

### HTTP 상태 코드

| Status Code | Description | Usage |
|-------------|-------------|-------|
| 200 | OK | 성공적인 요청 |
| 201 | Created | 리소스 생성 성공 |
| 400 | Bad Request | 잘못된 요청 데이터 |
| 401 | Unauthorized | 인증 필요 |
| 403 | Forbidden | 권한 부족 |
| 404 | Not Found | 리소스를 찾을 수 없음 |
| 413 | Payload Too Large | 파일 크기 초과 (500MB 제한) |
| 422 | Unprocessable Entity | 유효하지 않은 데이터 |
| 500 | Internal Server Error | 내부 서버 오류 |

### 공통 에러 코드

| Error Code | Description |
|------------|-------------|
| `VALIDATION_ERROR` | 데이터 검증 실패 |
| `AUTH_REQUIRED` | 인증 필요 |
| `PERMISSION_DENIED` | 권한 부족 |
| `NOT_FOUND` | 리소스 없음 |
| `FILE_TOO_LARGE` | 파일 크기 초과 |
| `UNSUPPORTED_FILE_TYPE` | 지원하지 않는 파일 형식 |
| `DATABASE_ERROR` | 데이터베이스 오류 |
| `FILE_SYSTEM_ERROR` | 파일 시스템 오류 |
| `INTERNAL_ERROR` | 내부 서버 오류 |

---

## 🔑 인증 가이드

### JWT 토큰 사용법

1. **로그인하여 토큰 획득:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}'
```

2. **응답에서 토큰 추출:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

3. **토큰을 사용하여 보호된 API 호출:**
```bash
curl -X GET http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## 📋 실용 가이드

### 파일 업로드 예제

**주차 구역 이미지 업로드:**
```bash
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <jwt_token>" \
  -F "file=@parking_layout.jpg" \
  -F "filename=parking_layout.jpg"
```

**대용량 비디오 파일 업로드:**
```bash
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <jwt_token>" \
  -F "file=@security_camera.mp4" \
  -F "filename=security_camera.mp4"
```

### 파일시스템 동기화

**수동 동기화 실행:**
```bash
curl -X POST http://localhost:8080/api/v1/files/sync \
  -H "Authorization: Bearer <jwt_token>"
```

### 통계 데이터 조회

**월간 주차 통계:**
```bash
curl -X GET "http://localhost:8080/api/v1/statistics/parking?startDate=2025-09-01&endDate=2025-09-30&granularity=day" \
  -H "Authorization: Bearer <jwt_token>"
```

**사용자 정의 기간 통계:**
```bash
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"startDay":"2024-11-19","endDay":"2024-11-20"}'
```

**그래프용 통계 데이터:**
```bash
curl -X POST http://localhost:8080/api/v1/statistics/graph \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"startDay":"2025-09-24 08","endDay":"2025-09-24 09"}'
```

### 시스템 상태 모니터링

**전체 시스템 상태 확인:**
```bash
curl -X GET http://localhost:8080/api/v1/system/health \
  -H "Authorization: Bearer <jwt_token>"
```

---

## 🔄 Real-time Features

### WebSocket Connections (개발 중)
현재 HTTP REST API로 구현되어 있으나, 향후 실시간 데이터를 위한 WebSocket 지원이 계획되어 있습니다:
- Real-time parking space updates
- Live dashboard data
- Instant alert notifications
- System status monitoring

### Periodic Tasks
시스템은 다음과 같은 주기적 작업을 수행합니다:
- Engine data processing (every 2 seconds)
- File system synchronization (every 20 seconds)  
- Health monitoring (every 30 seconds)
- Statistics calculation (every 5 minutes)

---

## 📈 Performance & Scalability

### 파일 관리 성능
- **최대 파일 크기**: 500MB
- **지원 파일 형식**: 25+ 종류 (이미지, 비디오, 문서, 아카이브)
- **동시 업로드**: 다중 파일 동시 처리 지원
- **파일시스템 동기화**: 자동 및 수동 동기화

### 데이터베이스 성능
- **SQLite + ws4sqlite**: 빠른 응답 시간
- **트랜잭션 지원**: 데이터 일관성 보장
- **인덱싱**: 주요 쿼리 최적화
- **Connection pooling**: 연결 관리 최적화

### API 응답 시간
- **평균 응답 시간**: < 100ms
- **파일 업로드**: 파일 크기에 따라 변동
- **통계 쿼리**: 데이터 양에 따라 변동
- **실시간 모니터링**: 지속적인 성능 추적

### Optimization Features
- Database connection pooling
- File caching system
- Async processing
- Memory management
- Request rate limiting

### Monitoring & Alerts
- Performance metrics collection
- Error tracking and logging
- Resource usage monitoring  
- Automated alert system

---

## 🛠️ Development & Maintenance

### API Versioning
- Current version: `v1`
- Backward compatibility maintained
- Legacy endpoints available
- Gradual migration path

### Documentation
- OpenAPI 3.0 specification
- Swagger UI available at `/docs`
- Complete API reference
- Interactive testing interface

---

## 🔗 관련 링크 및 도구

- **Swagger UI**: `http://localhost:8080/docs`
- **OpenAPI Spec**: `http://localhost:8080/swagger.yaml`
- **Health Check**: `http://localhost:8080/api/v1/system/health`
- **API Status**: `http://localhost:8080/api/v1/monitoring/status`

---

## 📞 지원 및 문의

API와 관련된 문의사항이나 기술 지원이 필요한 경우:
- **시스템 상태**: `/api/v1/system/health` 엔드포인트 확인
- **에러 로그**: `/api/v1/monitoring/errors` 엔드포인트 확인  
- **성능 모니터링**: `/api/v1/monitoring/performance` 엔드포인트 활용

---

## 🛠️ 추가 실제 사용 예제

### 파일 업로드 및 관리

**이미지 파일 업로드:**
```bash
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <jwt_token>" \
  -F "file=@parking_layout.jpg" \
  -F "filename=parking_layout.jpg"
```

**비디오 파일 업로드:**
```bash
curl -X POST http://localhost:8080/api/v1/files \
  -H "Authorization: Bearer <jwt_token>" \
  -F "file=@security_camera.mp4" \
  -F "filename=security_camera.mp4"
```

**주차 공간 유형 변경:**
```bash
curl -X PATCH http://localhost:8080/api/v1/files/lots/N001/type \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"lot_type":2,"changed_tag":"D001"}'
```

**주차 상태 변경:**
```bash
curl -X PATCH http://localhost:8080/api/v1/files/lots/N001/status \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"isUsed":true}'
```

### 사용자 관리

**새 사용자 생성:**
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "account": "newuser",
    "passwd": "password123",
    "passwdCheck": "password123",
    "username": "새로운 사용자",
    "userlevel": 1,
    "isActivated": 1
  }'
```

**비밀번호 변경:**
```bash
curl -X PATCH http://localhost:8080/api/v1/users/newuser/password \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "passwd": "password123",
    "passwdCheck": "password123",
    "newpasswd": "newpassword456"
  }'
```

### LED 제어

**LED 계산 실행:**
```bash
curl -X POST http://localhost:8080/api/v1/led/calculate \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "brightness": 80,
    "color": "#FF5733",
    "pattern": "blink",
    "duration": 5000
  }'
```

### 실시간 데이터

**실시간 중앙 대시보드:**
```bash
curl -X GET http://localhost:8080/api/v1/central/dashboard \
  -H "Authorization: Bearer <jwt_token>"
```

**실시간 일별 통계:**
```bash
curl -X GET http://localhost:8080/api/v1/statistics/daily \
  -H "Authorization: Bearer <jwt_token>"
```

---

**📋 문서 버전**: v2.0.0 (실제 테스트 반영)  
**📅 최종 업데이트**: 2025-09-24  
**🔄 API 버전**: v1  
**⚡ 총 엔드포인트**: 80+ APIs (실제 확인됨)  
**🚀 서버**: Smart Parking Backend Server
**✅ 테스트 상태**: 모든 주요 API 실제 테스트 완료
