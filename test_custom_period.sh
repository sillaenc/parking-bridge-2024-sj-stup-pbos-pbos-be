#!/bin/bash

echo "=== Testing /api/v1/statistics/custom-period API ==="
echo ""
echo "Request Body:"
echo '{"startDay": "2025-11-04", "endDay": "2025-11-05"}'
echo ""
echo "Sending POST request..."
echo ""

curl -X POST http://localhost:8080/api/v1/statistics/custom-period \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -v

echo ""
echo ""
echo "=== Testing legacy /statistics/cam_parking_area/searchDay API ==="
echo ""

curl -X POST http://localhost:8080/statistics/cam_parking_area/searchDay \
  -H "Content-Type: application/json" \
  -d '{"startDay": "2025-11-04", "endDay": "2025-11-05"}' \
  -v
