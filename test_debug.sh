#!/bin/bash

echo "=== 디버깅 테스트 ==="
echo ""

echo "1. 레거시 API 테스트 (비교용):"
curl -X POST http://localhost:8080/statistics/cam_parking_area/searchDay \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "2. 신규 API 테스트 (startDate):"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2025-11-04", "endDate": "2025-11-05"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "3. 신규 API 테스트 (startDay - 레거시 호환):"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "4. 오늘 날짜로 테스트:"
TODAY=$(date +%Y-%m-%d)
echo "Today: $TODAY"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d "{\"startDate\": \"$TODAY\", \"endDate\": \"$TODAY\"}" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
