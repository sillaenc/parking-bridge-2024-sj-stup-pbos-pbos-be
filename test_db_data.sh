#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔍 DB 데이터 직접 확인${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# DB URL (실제 환경에 맞게 수정)
DB_URL="http://localhost:8080/api/db/query"

echo -e "${YELLOW}📊 1. processed_db 테이블 데이터 확인 (최근 48시간)${NC}"
curl -s -X POST "$DB_URL" \
  -H "Content-Type: application/json" \
  -d '{
  "transaction": [{
    "query": "SELECT recorded_hour, lot, car_type, hour_parking, COUNT(*) as cnt FROM processed_db WHERE recorded_hour >= datetime('\''now'\'', '\''-2 days'\'', '\''localtime'\'') GROUP BY recorded_hour, car_type ORDER BY recorded_hour DESC LIMIT 50"
  }]
}' | jq '.'

echo ""
echo -e "${YELLOW}📊 2. 특정 날짜(2025-11-12) 시간별 통계 확인${NC}"
curl -s -X POST "$DB_URL" \
  -H "Content-Type: application/json" \
  -d '{
  "transaction": [{
    "query": "SELECT recorded_hour, car_type, COUNT(*) as count, SUM(hour_parking) as total_parked FROM processed_db WHERE recorded_hour LIKE '\''2025-11-12%'\'' GROUP BY recorded_hour, car_type ORDER BY recorded_hour, car_type"
  }]
}' | jq '.'

echo ""
echo -e "${YELLOW}📊 3. S_graph 쿼리와 동일한 실제 데이터 (JOIN 포함)${NC}"
curl -s -X POST "$DB_URL" \
  -H "Content-Type: application/json" \
  -d '{
  "transaction": [{
    "query": "SELECT t.recorded_hour, t.car_type, l.floor, COUNT(*) AS count FROM processed_db t LEFT JOIN tb_lots l ON t.lot = l.uid WHERE t.hour_parking = 1 AND t.recorded_hour >= '\''2025-11-11 00'\'' AND t.recorded_hour <= '\''2025-11-12 23'\'' GROUP BY t.recorded_hour, t.car_type, l.floor ORDER BY t.recorded_hour, t.car_type, l.floor LIMIT 100"
  }]
}' | jq '.'

echo ""
echo -e "${YELLOW}📊 4. recorded_hour별 총 개수 확인 (시간대별 데이터 변화 확인)${NC}"
curl -s -X POST "$DB_URL" \
  -H "Content-Type: application/json" \
  -d '{
  "transaction": [{
    "query": "SELECT recorded_hour, COUNT(DISTINCT lot) as unique_lots, SUM(hour_parking) as total_parked FROM processed_db WHERE recorded_hour LIKE '\''2025-11-12%'\'' GROUP BY recorded_hour ORDER BY recorded_hour"
  }]
}' | jq '.'

echo ""
echo -e "${YELLOW}📊 5. 가장 최근 데이터 10개 확인${NC}"
curl -s -X POST "$DB_URL" \
  -H "Content-Type: application/json" \
  -d '{
  "transaction": [{
    "query": "SELECT * FROM processed_db ORDER BY recorded_hour DESC LIMIT 10"
  }]
}' | jq '.'

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ DB 데이터 확인 완료${NC}"
echo -e "${GREEN}========================================${NC}"

