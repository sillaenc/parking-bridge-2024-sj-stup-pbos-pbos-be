#!/bin/bash

echo "==================================="
echo "통계 API 테스트 스크립트"
echo "==================================="
echo ""

# 서버 URL
SERVER="http://localhost:8080"

echo "1️⃣ 테스트: POST /api/v1/statistics/custom-period (신규 파라미터)"
echo "   Request: {\"startDate\": \"2025-11-04\", \"endDate\": \"2025-11-05\"}"
echo ""
curl -X POST $SERVER/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2025-11-04", "endDate": "2025-11-05"}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "2️⃣ 테스트: POST /api/v1/statistics/custom-period (레거시 호환)"
echo "   Request: {\"startDay\": \"2025-11-04\", \"endDay\": \"2025-11-05\"}"
echo ""
curl -X POST $SERVER/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "3️⃣ 테스트: POST /api/v1/statistics/graph (신규 파라미터)"
echo "   Request: {\"startDate\": \"2025-11-04\", \"endDate\": \"2025-11-05\"}"
echo "   Note: 시간이 자동 추가됨 (00시~23시)"
echo ""
curl -X POST $SERVER/api/v1/statistics/graph \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2025-11-04", "endDate": "2025-11-05"}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "4️⃣ 테스트: POST /api/v1/statistics/graph (레거시 호환)"
echo "   Request: {\"startDay\": \"2025-11-04\", \"endDay\": \"2025-11-05\"}"
echo ""
curl -X POST $SERVER/api/v1/statistics/graph \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "5️⃣ 테스트: 파라미터 누락 (400 에러 확인)"
echo "   Request: {}"
echo ""
curl -X POST $SERVER/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "6️⃣ 비교: 레거시 API /statistics/cam_parking_area/searchDay"
echo "   Request: {\"startDay\": \"2025-11-04\", \"endDay\": \"2025-11-05\"}"
echo ""
curl -X POST $SERVER/statistics/cam_parking_area/searchDay \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -s | jq '.' || echo "No response or invalid JSON"
echo ""
echo ""

echo "==================================="
echo "테스트 완료"
echo "==================================="
