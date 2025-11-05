#!/bin/bash

echo "=== 데이터 존재 확인 ==="
echo ""

echo "1. 최근 1년 데이터 조회 (2024-01-01 ~ 2025-12-31):"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2024-01-01", "endDate": "2025-12-31"}' \
  -s | jq 'length' 2>/dev/null || echo "데이터 없음"

echo ""
echo "2. 2024년 전체 데이터:"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2024-01-01", "endDate": "2024-12-31"}' \
  -s | jq '. | length' 2>/dev/null || echo "0"

echo ""
echo "3. 2025년 전체 데이터:"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2025-01-01", "endDate": "2025-12-31"}' \
  -s | jq '. | length' 2>/dev/null || echo "0"

echo ""
echo "4. 샘플 데이터 조회 (최근 데이터 3개):"
curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDate": "2020-01-01", "endDate": "2025-12-31"}' \
  -s | jq '.[-3:]' 2>/dev/null || echo "[]"

echo ""
echo "5. 일별 통계 조회 (/daily - 어제 vs 오늘):"
curl -X GET http://localhost:8080/api/v1/statistics/daily \
  -H "Content-Type: application/json" \
  -s | jq '. | length' 2>/dev/null || echo "0"
