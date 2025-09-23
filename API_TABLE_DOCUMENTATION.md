# API Documentation Tables

## settings.dart(/settings)

**설정 관련 클래스**

- ('/'): settings table에 key, value column에 각각 key value 형식으로 정보를 upsert 하는 방식
- ('/get'): settings table에 key를 입력해서 해당하는걸 찾아서 response한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/settings/general | POST | STRING,JSON | {"key":"test","value":"jsonE타입의 문연가"} | 200 |
| http://localhost:8080/api/v1/settings/general/get | POST | String | {"key": "test"} | {"uid":1, "key":"test", "value": "EncodeJson 형식"} |

---

## auth_api.dart(/auth)

**인증 관련 클래스**

- 사용자 인증, 로그인, 로그아웃, 토큰 관리를 담당
- JWT 토큰 기반 인증 시스템

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/auth/login | POST | JSON | {"username":"admin","password":"password123"} | {"success":true,"data":{"token":"jwt_token","user":{"id":1,"username":"admin"}}} |
| http://localhost:8080/api/v1/auth/logout | POST | JSON | {"token":"jwt_token"} | {"success":true,"message":"Logout successful"} |
| http://localhost:8080/api/v1/auth/verify | GET | Header | Authorization: Bearer jwt_token | {"success":true,"valid":true,"user":{"id":1,"username":"admin"}} |
| http://localhost:8080/api/v1/auth/refresh | POST | JSON | {"refresh_token":"refresh_token"} | {"success":true,"data":{"access_token":"new_jwt_token"}} |

---

## user_management_api.dart(/users)

**사용자 관리 클래스**

- 사용자 CRUD 작업
- 사용자 권한 관리

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/users | GET | Query Params | ?page=1&limit=10&role=admin | {"success":true,"data":{"users":[...],"pagination":{"page":1,"total":25}}} |
| http://localhost:8080/api/v1/users | POST | JSON | {"username":"newuser","email":"user@example.com","password":"pass123","role":"user"} | {"success":true,"data":{"id":2,"username":"newuser","created_at":"2025-09-23T..."}} |
| http://localhost:8080/api/v1/users/{id} | GET | Path Param | id=1 | {"success":true,"data":{"id":1,"username":"admin","email":"admin@example.com"}} |
| http://localhost:8080/api/v1/users/{id} | PUT | JSON | {"username":"updated_user","email":"new@example.com"} | {"success":true,"message":"User updated successfully"} |
| http://localhost:8080/api/v1/users/{id} | DELETE | Path Param | id=1 | {"success":true,"message":"User deleted successfully"} |

---

## database_management_api.dart(/settings/database)

**데이터베이스 관리 클래스**

- 엔진 DB 및 디스플레이 DB 설정 관리
- 데이터베이스 연결 테스트

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/settings/database/config | GET | No Body | - | {"success":true,"data":{"engine_db":"localhost:8080","display_db":"localhost:8081"}} |
| http://localhost:8080/api/v1/settings/database/engine | PUT | JSON | {"host":"localhost","port":8080,"database":"engine_db"} | {"success":true,"message":"Engine database updated"} |
| http://localhost:8080/api/v1/settings/database/display | PUT | JSON | {"host":"localhost","port":8081,"database":"display_db"} | {"success":true,"message":"Display database updated"} |
| http://localhost:8080/api/v1/settings/database/test-connection | POST | JSON | {"type":"engine","host":"localhost","port":8080} | {"success":true,"data":{"connected":true,"response_time":"50ms"}} |
| http://localhost:8080/api/v1/settings/database/health | GET | No Body | - | {"success":true,"data":{"status":"healthy","connections":{"engine":"ok","display":"ok"}}} |

---

## parking_zone_management_api.dart(/settings/parking-zones)

**주차 구역 관리 클래스**

- 주차 구역 파일 업로드, 수정, 삭제
- 파일시스템 동기화 관리

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/settings/parking-zones | GET | No Body | - | {"success":true,"data":[{"parking_name":"zone1","file_address":"file/zone1.jpg"}]} |
| http://localhost:8080/api/v1/settings/parking-zones | POST | multipart/form-data | file=@parking_layout.jpg, filename=parking_layout.jpg | {"success":true,"message":"File uploaded successfully","data":{"filename":"parking_layout.jpg","fileSize":2048576}} |
| http://localhost:8080/api/v1/settings/parking-zones/{name} | GET | Path Param | name=parking_layout | {"success":true,"data":{"parking_name":"parking_layout","file_address":"file/parking_layout.jpg"}} |
| http://localhost:8080/api/v1/settings/parking-zones/{name} | PUT | multipart/form-data | file=@new_layout.jpg | {"success":true,"message":"File updated successfully"} |
| http://localhost:8080/api/v1/settings/parking-zones/{name} | DELETE | Path Param | name=parking_layout | {"success":true,"message":"Parking zone deleted successfully"} |
| http://localhost:8080/api/v1/settings/parking-zones/sync | POST | No Body | - | {"success":true,"data":{"totalFiles":4,"syncDurationMs":28,"status":"completed"}} |
| http://localhost:8080/api/v1/settings/parking-zones/health | GET | No Body | - | {"success":true,"data":{"status":"healthy","totalFiles":4,"totalSize":"50MB"}} |

---

## statistics_api.dart(/statistics)

**통계 분석 클래스**

- 주차 통계, 수익 분석
- 시간별, 일별, 월별 집계

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/statistics/parking | GET | Query Params | ?startDate=2025-09-01&endDate=2025-09-30&granularity=day | {"success":true,"data":{"statistics":[{"date":"2025-09-23","avgOccupancy":82.1}]}} |
| http://localhost:8080/api/v1/statistics/camera-parking | GET | Query Params | ?startDate=2025-09-01&endDate=2025-09-30 | {"success":true,"data":{"camera_statistics":[{"camera_id":1,"detections":150}]}} |
| http://localhost:8080/api/v1/statistics/revenue | GET | Query Params | ?startDate=2025-09-01&endDate=2025-09-30 | {"success":true,"data":{"total_revenue":15000,"daily_average":500}} |
| http://localhost:8080/api/v1/statistics/summary | GET | No Body | - | {"success":true,"data":{"totalSpaces":408,"occupiedSpaces":335,"occupancyRate":82.1}} |

---

## engine_data.dart(/engine/data)

**엔진 데이터 처리 클래스**

- 실시간 주차 데이터 처리
- 센서 데이터 파싱 및 저장

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/engine/data | POST | JSON | {"rawData":"base64_encoded_data","timestamp":"2025-09-23T13:00:00Z","source":"sensor_1"} | {"success":true,"data":{"processed":true,"parking_spaces_updated":408,"data_id":15168425}} |
| http://localhost:8080/api/v1/engine/data/status | GET | No Body | - | {"success":true,"data":{"status":"processing","last_update":"2025-09-23T13:00:00Z","total_processed":15168425}} |
| http://localhost:8080/api/v1/engine/data/health | GET | No Body | - | {"success":true,"data":{"engine_status":"healthy","processing_rate":"2.0s","error_count":0}} |

---

## central_dashboard_api.dart(/central)

**중앙 대시보드 클래스**

- 실시간 대시보드 데이터
- 통합 모니터링 정보

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/central/dashboard | GET | No Body | - | {"success":true,"data":{"summary":{"totalSpaces":408,"occupancyRate":82.1},"realtime":{"activeConnections":25}}} |
| http://localhost:8080/api/v1/central/realtime | GET | No Body | - | {"success":true,"data":{"current_occupancy":335,"available_spaces":73,"last_update":"2025-09-23T13:00:00Z"}} |
| http://localhost:8080/api/v1/central/alerts | GET | Query Params | ?level=warning&limit=10 | {"success":true,"data":{"alerts":[{"level":"warning","message":"Camera 3 unstable","timestamp":"..."}]}} |

---

## vehicle_info_api.dart(/vehicle)

**차량 정보 관리 클래스**

- 차량 등록, 조회, 수정, 삭제
- 차량 출입 기록 관리

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/vehicle | GET | Query Params | ?page=1&limit=10&license_plate=ABC123 | {"success":true,"data":{"vehicles":[{"id":1,"license_plate":"ABC123","owner":"John"}]}} |
| http://localhost:8080/api/v1/vehicle | POST | JSON | {"license_plate":"ABC123","owner":"John Doe","phone":"010-1234-5678","vehicle_type":"car"} | {"success":true,"data":{"id":1,"license_plate":"ABC123","created_at":"2025-09-23T..."}} |
| http://localhost:8080/api/v1/vehicle/{id} | GET | Path Param | id=1 | {"success":true,"data":{"id":1,"license_plate":"ABC123","owner":"John Doe","phone":"010-1234-5678"}} |
| http://localhost:8080/api/v1/vehicle/{id} | PUT | JSON | {"owner":"Jane Doe","phone":"010-9876-5432"} | {"success":true,"message":"Vehicle information updated"} |
| http://localhost:8080/api/v1/vehicle/{id} | DELETE | Path Param | id=1 | {"success":true,"message":"Vehicle deleted successfully"} |

---

## system_health_api.dart(/system)

**시스템 상태 관리 클래스**

- 시스템 헬스 체크
- 성능 모니터링

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/system/health | GET | No Body | - | {"success":true,"data":{"status":"healthy","uptime":"72h 45m","services":{"database":"ok","fileSystem":"ok"}}} |
| http://localhost:8080/api/v1/system/info | GET | No Body | - | {"success":true,"data":{"version":"1.0.0","server":"Smart Parking Backend","started_at":"2025-09-20T..."}} |
| http://localhost:8080/api/v1/system/metrics | GET | No Body | - | {"success":true,"data":{"memory_usage":"256MB","disk_usage":"12GB","cpu_usage":"15%"}} |

---

## monitoring_api.dart(/monitoring)

**모니터링 클래스**

- 로그 조회 및 분석
- 성능 모니터링

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/monitoring/logs | GET | Query Params | ?level=error&limit=50&startDate=2025-09-01 | {"success":true,"data":{"logs":[{"level":"error","message":"DB connection failed","timestamp":"..."}]}} |
| http://localhost:8080/api/v1/monitoring/performance | GET | Query Params | ?metric=response_time&interval=1h | {"success":true,"data":{"metrics":[{"timestamp":"...","response_time":"120ms"}]}} |
| http://localhost:8080/api/v1/monitoring/errors | GET | Query Params | ?limit=20 | {"success":true,"data":{"errors":[{"error_code":"DB_ERROR","count":5,"last_occurrence":"..."}]}} |

---

## base_information_api.dart(/parking/information)

**주차장 기본 정보 클래스**

- 주차장 기본 정보 관리
- 주차장 통계 조회

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output |
|----------------|----------|----------------|---------------|----------------|
| http://localhost:8080/api/v1/parking/information | GET | No Body | - | {"success":true,"data":{"name":"Smart Parking","total_spaces":408,"location":"Seoul"}} |
| http://localhost:8080/api/v1/parking/information | POST | JSON | {"name":"Smart Parking","total_spaces":408,"location":"Seoul","contact":"02-1234-5678"} | {"success":true,"message":"Parking information created"} |
| http://localhost:8080/api/v1/parking/information | PUT | JSON | {"name":"Updated Parking","contact":"02-9876-5432"} | {"success":true,"message":"Parking information updated"} |
| http://localhost:8080/api/v1/parking/information/statistics | GET | No Body | - | {"success":true,"data":{"total_spaces":408,"occupied":335,"available":73,"occupancy_rate":82.1}} |
| http://localhost:8080/api/v1/parking/information/full | GET | No Body | - | {"success":true,"data":{"info":{...},"statistics":{...}}} |

---

## Error Response Format

**모든 API의 표준 에러 응답 형식**

| HTTP Status | Error Type | Example Response |
|-------------|------------|------------------|
| 400 | Bad Request | {"success":false,"message":"Invalid request data","errorCode":"VALIDATION_ERROR"} |
| 401 | Unauthorized | {"success":false,"message":"Authentication required","errorCode":"AUTH_REQUIRED"} |
| 403 | Forbidden | {"success":false,"message":"Insufficient permissions","errorCode":"PERMISSION_DENIED"} |
| 404 | Not Found | {"success":false,"message":"Resource not found","errorCode":"NOT_FOUND"} |
| 413 | Payload Too Large | {"success":false,"message":"File size exceeds 500MB limit","errorCode":"FILE_TOO_LARGE"} |
| 500 | Internal Server Error | {"success":false,"message":"Internal server error","errorCode":"INTERNAL_ERROR"} |

---

## Common Request Headers

**인증이 필요한 API에서 사용하는 공통 헤더**

| Header Name | Value Format | Example |
|-------------|--------------|---------|
| Authorization | Bearer {jwt_token} | Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... |
| Content-Type | application/json | application/json |
| Accept | application/json | application/json |

---

## File Upload Specifications

**파일 업로드 관련 상세 정보**

| Property | Value | Description |
|----------|-------|-------------|
| Max File Size | 500MB | 최대 파일 크기 제한 |
| Supported Formats | jpg, jpeg, png, gif, bmp, webp, tiff, ico, mp4, avi, mov, wmv, flv, webm, mkv, mpg, mpeg, m4v, 3gp, pdf, doc, docx, xls, xlsx, ppt, pptx, json, xml, txt, csv, yaml, yml, zip, rar, 7z, tar, gz | 지원되는 파일 형식 |
| Upload Method | multipart/form-data | 업로드 방식 |
| Storage Location | /file directory | 파일 저장 위치 |
