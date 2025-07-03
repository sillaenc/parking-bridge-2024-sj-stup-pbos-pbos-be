# PBOS Backend API 테스트 가이드

## 개요
이 문서는 PBOS Backend API를 테스트하는 방법과 실제 사용 예시를 제공합니다.

---

## 테스트 환경 설정

### 1. 서버 시작
```bash
cd pbos_be
dart pub get
dart run bin/main.dart
```

### 2. 서버 상태 확인
```bash
curl http://localhost:8080/api/v1/system/health
```

예상 응답:
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
      }
    ],
    "overall_status": true
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 인증 API 테스트

### 1. 로그인 테스트

#### 성공 케이스
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "admin",
    "password": "admin123"
  }'
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50IjoiYWRtaW4iLCJ1c2VybGV2ZWwiOjEsImlhdCI6MTcwNDEwNDQwMCwiZXhwIjoxNzA0MTkwODAwfQ.example",
    "user": {
      "uid": 1,
      "account": "admin",
      "username": "관리자",
      "userlevel": 1,
      "isActivated": true
    },
    "expiresAt": "2024-01-02T10:00:00Z"
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

#### 실패 케이스 (잘못된 비밀번호)
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "admin",
    "password": "wrong_password"
  }'
```

예상 응답 (401):
```json
{
  "success": false,
  "message": "계정 정보가 올바르지 않습니다.",
  "error": "AUTHENTICATION_FAILED",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. JWT 토큰 추출
로그인 응답에서 토큰을 추출하여 환경 변수로 설정:

```bash
# 로그인 후 토큰 저장
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"account":"admin","password":"admin123"}' | \
  jq -r '.data.token')

echo "Token: $TOKEN"
```

---

## 중앙 대시보드 API 테스트

### 1. 대시보드 데이터 조회
```bash
curl -X GET http://localhost:8080/api/v1/central/dashboard \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "중앙 대시보드 데이터 조회 완료",
  "data": {
    "statistics": {
      "total_spaces": 150,
      "used_spaces": 85,
      "available_spaces": 65,
      "occupancy_rate": "56.7"
    },
    "floors": ["B1", "B2", "1F", "2F"],
    "lot_types": [1, 2, 3],
    "occupancy_data": [
      {
        "lot_type": 1,
        "floor": "B1",
        "count": 35
      },
      {
        "lot_type": 2,
        "floor": "B1",
        "count": 8
      }
    ]
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 차량 정보 API 테스트

### 1. 태그별 차량 정보 조회 (GET)
```bash
curl -X GET "http://localhost:8080/api/v1/vehicle/by-tag?tag=A101" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2. 태그별 차량 정보 조회 (POST)
```bash
curl -X POST http://localhost:8080/api/v1/vehicle/by-tag \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tag": "A101"
  }'
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "차량 정보 조회 완료",
  "data": {
    "tag": "A101",
    "plate": "12가3456",
    "start_time": "2024-01-01T08:30:00Z",
    "point": "100,200",
    "has_vehicle": true
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 3. 번호판별 차량 위치 조회
```bash
curl -X GET "http://localhost:8080/api/v1/vehicle/by-plate?plate=12가" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "차량 위치 조회 완료",
  "data": [
    {
      "tag": "A101",
      "plate": "12가3456",
      "point": "100,200"
    },
    {
      "tag": "B205",
      "plate": "12가7890",
      "point": "300,150"
    }
  ],
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 전광판 API 테스트

### 1. 층별 주차 정보 조회 (GET)
```bash
curl -X GET http://localhost:8080/api/v1/billboard/floor/B1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2. 층별 주차 정보 조회 (POST)
```bash
curl -X POST http://localhost:8080/api/v1/billboard/floor \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "floor": "B1"
  }'
```

예상 응답 (200):
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
        "count": 45
      },
      {
        "lot_type": 2,
        "type_name": "장애인",
        "count": 8
      },
      {
        "lot_type": 3,
        "type_name": "경차",
        "count": 12
      }
    ],
    "total_available": 65
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 3. 부분 시스템 제어
```bash
curl -X POST http://localhost:8080/api/v1/billboard/part-system/control \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "value": "emergency_override"
  }'
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "모든 부분 시스템 제어 완료",
  "data": {
    "endpoints": [
      "http://192.168.1.10:8080",
      "http://192.168.1.11:8080"
    ],
    "value": "emergency_override",
    "success_count": 2,
    "total_count": 2
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 디스플레이 API 테스트

### 1. 디스플레이 정보 조회 (GET)
```bash
curl -X GET "http://localhost:8080/api/v1/display/info?floors=B1,B2,1F" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2. 디스플레이 정보 조회 (POST)
```bash
curl -X POST http://localhost:8080/api/v1/display/info \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "floors": "B1,B2,1F"
  }'
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "디스플레이 정보 조회 완료",
  "data": {
    "floors": ["B1", "B2", "1F"],
    "display_data": {
      "B1": [
        {
          "point": "100,200",
          "asset": "display_B1_001"
        },
        {
          "point": "300,200",
          "asset": "display_B1_002"
        }
      ],
      "B2": [
        {
          "point": "150,180",
          "asset": "display_B2_001"
        }
      ],
      "1F": []
    }
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 3. 대량 디스플레이 업데이트
```bash
curl -X POST http://localhost:8080/api/v1/display/bulk-update \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "updates": [
      {
        "tag": "D001",
        "lot_type": 1,
        "point": "100,200",
        "asset": "new_display_asset_1",
        "floor": "B1"
      },
      {
        "tag": "D002",
        "lot_type": 2,
        "point": "300,200",
        "asset": "new_display_asset_2",
        "floor": "B1"
      }
    ]
  }'
```

예상 응답 (200):
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

## LED 계산 API 테스트

### 1. LED 계산 조회
```bash
curl -X GET http://localhost:8080/api/v1/led/calculation \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

예상 응답 (200):
```json
{
  "success": true,
  "message": "LED 계산 완료",
  "data": {
    "cameras": [
      {
        "camera": "CAM001",
        "tag_count": 20,
        "used_count": 15,
        "usage_rate": 75.0,
        "led_color": "red"
      },
      {
        "camera": "CAM002",
        "tag_count": 18,
        "used_count": 6,
        "usage_rate": 33.3,
        "led_color": "green"
      },
      {
        "camera": "CAM003",
        "tag_count": 15,
        "used_count": 10,
        "usage_rate": 66.7,
        "led_color": "yellow"
      }
    ],
    "total_cameras": 3
  },
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 사용자 관리 API 테스트

### 1. 사용자 목록 조회
```bash
curl -X GET http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

### 2. 새 사용자 생성
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "account": "testuser",
    "password": "testpass123",
    "username": "테스트 사용자",
    "userlevel": 2,
    "isActivated": true
  }'
```

### 3. 사용자 정보 수정
```bash
curl -X PUT http://localhost:8080/api/v1/users/testuser \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "수정된 테스트 사용자",
    "userlevel": 3,
    "isActivated": true
  }'
```

### 4. 사용자 삭제
```bash
curl -X DELETE http://localhost:8080/api/v1/users/testuser \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

---

## 에러 케이스 테스트

### 1. 인증 없이 보호된 엔드포인트 접근
```bash
curl -X GET http://localhost:8080/api/v1/central/dashboard \
  -H "Content-Type: application/json"
```

예상 응답 (401):
```json
{
  "success": false,
  "message": "인증이 필요합니다.",
  "error": "AUTHENTICATION_REQUIRED",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 2. 잘못된 토큰으로 접근
```bash
curl -X GET http://localhost:8080/api/v1/central/dashboard \
  -H "Authorization: Bearer invalid_token" \
  -H "Content-Type: application/json"
```

예상 응답 (401):
```json
{
  "success": false,
  "message": "유효하지 않은 토큰입니다.",
  "error": "INVALID_TOKEN",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 3. 필수 파라미터 누락
```bash
curl -X GET "http://localhost:8080/api/v1/vehicle/by-tag" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

예상 응답 (400):
```json
{
  "success": false,
  "message": "tag 파라미터가 필요합니다.",
  "error": "MISSING_TAG_PARAMETER",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

### 4. 존재하지 않는 리소스 접근
```bash
curl -X GET http://localhost:8080/api/v1/billboard/floor/NON_EXISTENT_FLOOR \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

예상 응답 (404):
```json
{
  "success": false,
  "message": "해당 층의 주차 정보를 찾을 수 없습니다.",
  "error": "FLOOR_NOT_FOUND",
  "timestamp": "2024-01-01T10:00:00Z"
}
```

---

## 성능 테스트

### 1. 동시 요청 테스트 (Apache Bench)
```bash
# 10개 동시 연결로 100개 요청
ab -n 100 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/v1/central/dashboard
```

### 2. 대량 데이터 처리 테스트
```bash
# 대량 디스플레이 업데이트 (50개 항목)
curl -X POST http://localhost:8080/api/v1/display/bulk-update \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "updates": [
      {"tag": "D001", "lot_type": 1, "point": "100,200", "asset": "asset1", "floor": "B1"},
      {"tag": "D002", "lot_type": 1, "point": "120,200", "asset": "asset2", "floor": "B1"},
      // ... 50개 항목
    ]
  }'
```

---

## 자동화 테스트 스크립트

### Bash 스크립트 예시
```bash
#!/bin/bash

# API 테스트 자동화 스크립트
API_BASE="http://localhost:8080"

echo "=== PBOS Backend API 테스트 시작 ==="

# 1. 서버 상태 확인
echo "1. 서버 상태 확인..."
curl -s $API_BASE/api/v1/system/health | jq .

# 2. 로그인
echo "2. 로그인..."
TOKEN=$(curl -s -X POST $API_BASE/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"account":"admin","password":"admin123"}' | \
  jq -r '.data.token')

if [ "$TOKEN" == "null" ]; then
  echo "로그인 실패!"
  exit 1
fi

echo "로그인 성공! Token: ${TOKEN:0:20}..."

# 3. 중앙 대시보드 테스트
echo "3. 중앙 대시보드 테스트..."
curl -s -X GET $API_BASE/api/v1/central/dashboard \
  -H "Authorization: Bearer $TOKEN" | jq .success

# 4. 차량 정보 테스트
echo "4. 차량 정보 테스트..."
curl -s -X GET "$API_BASE/api/v1/vehicle/by-tag?tag=A101" \
  -H "Authorization: Bearer $TOKEN" | jq .success

# 5. 전광판 테스트
echo "5. 전광판 테스트..."
curl -s -X GET $API_BASE/api/v1/billboard/floor/B1 \
  -H "Authorization: Bearer $TOKEN" | jq .success

echo "=== API 테스트 완료 ==="
```

### Python 테스트 스크립트 예시
```python
#!/usr/bin/env python3
import requests
import json
import sys

API_BASE = "http://localhost:8080"

def test_api():
    print("=== PBOS Backend API 테스트 시작 ===")
    
    # 1. 서버 상태 확인
    print("1. 서버 상태 확인...")
    response = requests.get(f"{API_BASE}/api/v1/system/health")
    print(f"Status: {response.status_code}")
    
    # 2. 로그인
    print("2. 로그인...")
    login_data = {
        "account": "admin",
        "password": "admin123"
    }
    response = requests.post(f"{API_BASE}/api/v1/auth/login", json=login_data)
    
    if response.status_code != 200:
        print("로그인 실패!")
        return False
    
    token = response.json()["data"]["token"]
    headers = {"Authorization": f"Bearer {token}"}
    print(f"로그인 성공! Token: {token[:20]}...")
    
    # 3. 중앙 대시보드 테스트
    print("3. 중앙 대시보드 테스트...")
    response = requests.get(f"{API_BASE}/api/v1/central/dashboard", headers=headers)
    print(f"Dashboard: {response.json()['success']}")
    
    # 4. 차량 정보 테스트
    print("4. 차량 정보 테스트...")
    response = requests.get(f"{API_BASE}/api/v1/vehicle/by-tag", 
                          params={"tag": "A101"}, headers=headers)
    print(f"Vehicle Info: {response.json()['success']}")
    
    print("=== API 테스트 완료 ===")
    return True

if __name__ == "__main__":
    success = test_api()
    sys.exit(0 if success else 1)
```

---

## 문제 해결

### 일반적인 문제들

#### 1. 서버 연결 실패
```bash
curl: (7) Failed to connect to localhost port 8080: Connection refused
```
**해결방법**: 서버가 실행 중인지 확인
```bash
dart run bin/main.dart
```

#### 2. 토큰 만료
```json
{
  "success": false,
  "message": "토큰이 만료되었습니다.",
  "error": "TOKEN_EXPIRED"
}
```
**해결방법**: 새로 로그인하여 토큰 갱신

#### 3. 데이터베이스 연결 오류
```json
{
  "success": false,
  "message": "데이터베이스 연결 오류",
  "error": "DATABASE_CONNECTION_ERROR"
}
```
**해결방법**: `pb.yaml` 설정 및 ws4sqlite 서버 상태 확인

---

## 추가 도구

### Postman 컬렉션
Postman을 사용하는 경우, 위의 모든 요청을 포함한 컬렉션을 생성할 수 있습니다.

### Insomnia 컬렉션
Insomnia를 사용하는 경우도 마찬가지로 요청 컬렉션을 구성할 수 있습니다.

### API 모니터링
운영 환경에서는 다음과 같은 모니터링을 설정하는 것을 권장합니다:
- Health check 엔드포인트 주기적 호출
- 응답 시간 모니터링
- 에러율 추적

---

*테스트 가이드 버전: v2.0.0*
*마지막 업데이트: 2024-01-01* 