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
- **Total Endpoints**: 145+ API endpoints
- **Main Categories**: 12 API categories
- **Legacy Support**: Backward compatible APIs included
- **Documentation**: Swagger UI available at `/docs`

---

## ✅ 정확한 API 엔드포인트 (Postman 사용)

### 🔐 인증 & 사용자 관리
```
POST   /api/v1/auth/login              # 로그인
GET    /api/v1/auth/health             # 인증 서비스 상태
GET    /api/v1/auth/base-info          # 주차장 기본 정보
GET    /api/v1/users                   # 사용자 목록 조회
POST   /api/v1/users                   # 사용자 생성
GET    /api/v1/users/health            # 사용자 서비스 상태
```

### 📁 파일 & 주차 구역 관리
```
GET    /api/v1/files                   # 모든 주차 구역 조회
POST   /api/v1/files                   # 파일 업로드 및 주차 구역 생성
GET    /api/v1/files/{name}            # 특정 주차 구역 조회
PUT    /api/v1/files/{name}            # 파일 업데이트
DELETE /api/v1/files/{name}            # 파일 삭제
GET    /api/v1/files/list              # 파일 시스템 파일 목록
POST   /api/v1/files/sync              # 수동 파일시스템 동기화
GET    /api/v1/files/health            # 파일 서비스 상태
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

### 🎛️ 대시보드 & 디스플레이
```
GET    /api/v1/central/dashboard        # 중앙 대시보드 데이터
GET    /api/v1/central/health           # 중앙 서비스 상태
GET    /api/v1/central/info             # 중앙 서비스 정보
GET    /api/v1/display                  # 디스플레이 API 정보
GET    /api/v1/display/health           # 디스플레이 서비스 상태
GET    /api/v1/display/info?floors=B1,F1 # 층별 디스플레이 정보
```

### 📊 통계 & 분석
```
GET    /api/v1/statistics/health        # 통계 서비스 상태
GET    /api/v1/statistics/parking       # 주차 통계 조회
GET    /api/v1/statistics/camera-parking # 카메라 주차 통계
```

### 🚙 차량 & 전광판
```
GET    /api/v1/vehicle/health           # 차량 서비스 상태
GET    /api/v1/billboard                # 전광판 API 정보
GET    /api/v1/billboard/health         # 전광판 서비스 상태
GET    /api/v1/billboard/info           # 전광판 서비스 정보
GET    /api/v1/billboard/floor/B1       # 층별 주차 정보 (전광판용)
```

### 🔧 시스템 & 모니터링
```
GET    /api/v1/system/health            # 시스템 전체 상태
GET    /api/v1/monitoring/health        # 모니터링 서비스 상태
GET    /api/v1/monitoring/ping          # 데이터베이스 생존 확인
GET    /api/v1/led/health              # LED 계산 서비스 상태
```

### 🗄️ 리소스 & 엔진
```
GET    /api/v1/resources/health         # 리소스 서비스 상태
GET    /api/v1/resources/usage          # 리소스 사용량 조회
GET    /api/v1/engine/data/health       # 엔진 데이터 서비스 상태
POST   /api/v1/engine/data              # 엔진 데이터 처리
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

## 🔐 Authentication APIs

### JWT Token Authentication
모든 보호된 엔드포인트는 JWT 토큰이 필요합니다.

**Header Format:**
```http
Authorization: Bearer <jwt_token>
```

### Authentication Endpoints

#### POST `/api/v1/auth/login`
사용자 로그인

**Request Body:**
```json
{
  "username": "admin",
  "password": "password123"
}
```

**Response:**
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

#### GET `/api/v1/auth/base-info`
주차장 기본 정보 조회

#### GET `/api/v1/auth/token`
현재 토큰 정보 조회

#### GET `/api/v1/auth/protected`
보호된 리소스 접근 테스트

#### POST `/api/v1/auth/refresh`
토큰 갱신

#### GET `/api/v1/auth/health`
인증 서비스 상태 확인

#### GET `/api/v1/auth/info`
인증 서비스 정보 조회

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

### User Management Endpoints

#### GET `/api/v1/users`
모든 사용자 조회

**Query Parameters:**
- `page`: 페이지 번호 (default: 1)
- `limit`: 페이지 크기 (default: 10)
- `role`: 역할 필터 (admin, user)

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "username": "admin",
        "email": "admin@example.com",
        "role": "admin",
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

#### GET `/api/v1/users/{account}`
특정 사용자 조회

#### POST `/api/v1/users`
사용자 생성

**Request Body:**
```json
{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123",
  "role": "user"
}
```

#### PUT `/api/v1/users/{account}`
사용자 정보 업데이트

#### PATCH `/api/v1/users/{account}/password`
비밀번호 변경

#### PATCH `/api/v1/users/{account}/password/reset`
비밀번호 리셋

#### DELETE `/api/v1/users/{account}`
사용자 삭제

#### GET `/api/v1/users/health`
사용자 서비스 상태 확인

#### GET `/api/v1/users/info`
사용자 서비스 정보

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

#### PUT `/api/v1/settings/database/engine`
엔진 DB 설정 업데이트

#### PUT `/api/v1/settings/database/display`
디스플레이 DB 설정 업데이트

#### PUT `/api/v1/settings/database/config`
전체 데이터베이스 설정 업데이트

#### POST `/api/v1/settings/database/test-connection`
데이터베이스 연결 테스트

#### GET `/api/v1/settings/database/health`
데이터베이스 서비스 상태 확인

#### GET `/api/v1/settings/database/info`
데이터베이스 서비스 정보

---

## 📁 File Management APIs

### File Management & Parking Zone

#### GET `/api/v1/files`
모든 주차 구역 조회

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "parking_name": "zone1",
      "file_address": "file/zone1.jpg"
    }
  ]
}
```

#### GET `/api/v1/files/{name}`
특정 주차 구역 조회

#### POST `/api/v1/files`
파일 업로드 및 주차 구역 생성

**Request:** `multipart/form-data`
- `file`: 파일 (최대 500MB)
- `filename`: 파일명

**Supported File Types:**
- **Images**: jpg, jpeg, png, gif, bmp, webp, tiff, ico
- **Videos**: mp4, avi, mov, wmv, flv, webm, mkv, mpg, mpeg, m4v, 3gp
- **Documents**: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, csv
- **Data**: json, xml, yaml, yml
- **Archives**: zip, rar, 7z, tar, gz

**Response:**
```json
{
  "success": true,
  "message": "File uploaded successfully",
  "data": {
    "filename": "parking_layout.jpg",
    "fileSize": 2048576,
    "fileType": "image",
    "uploadedAt": "2025-09-23T13:00:00Z"
  }
}
```

#### PUT `/api/v1/files/{name}`
파일 업데이트 및 주차 구역 업데이트

#### DELETE `/api/v1/files/{name}`
파일 삭제 및 주차 구역 삭제

### Parking Lot Management

#### PATCH `/api/v1/files/lots/{tag}/type`
주차 공간 유형 변경

#### PATCH `/api/v1/files/lots/{tag}/status`
주차 상태 변경

### File System Management

#### GET `/api/v1/files/files`
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

#### GET `/api/v1/files/filesystem-health`
파일시스템 상태 확인

#### GET `/api/v1/files/health`
서비스 상태 확인

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

**📋 문서 버전**: v1.0.0  
**📅 최종 업데이트**: 2025-09-23  
**🔄 API 버전**: v1  
**⚡ 총 엔드포인트**: 145+ APIs  
**🚀 서버**: Smart Parking Backend Server
