#!/usr/bin/env bash
set -euo pipefail

# PBOS Nest 자동 세팅 스크립트 (Ubuntu 20.04/22.04 기준)
# - 홈 디렉터리에 pbos_nest 폴더가 있다고 가정
# - Node 25.x, Postgres, FFmpeg 설치 후 빌드/마이그레이션/서비스 등록

APP_USER="${SUDO_USER:-$USER}"
APP_HOME="$(eval echo ~${APP_USER})"
APP_DIR="${APP_HOME}/pbos_nest"
SERVICE_NAME="pbos-nest"
NODE_VERSION_SETUP_SCRIPT="https://deb.nodesource.com/setup_25.x"

echo "==> App user: ${APP_USER}"
echo "==> App dir: ${APP_DIR}"

if [[ ! -d "${APP_DIR}" ]]; then
  echo "폴더가 없습니다: ${APP_DIR}"
  exit 1
fi

cd "${APP_DIR}"

echo "==> 패키지 업데이트 및 필수 도구 설치"
sudo apt update
sudo apt install -y curl ca-certificates gnupg build-essential software-properties-common

echo "==> Node.js 25.x 설치"
curl -fsSL "${NODE_VERSION_SETUP_SCRIPT}" | sudo -E bash -
sudo apt install -y nodejs

echo "==> FFmpeg 설치"
sudo apt install -y ffmpeg

echo "==> PostgreSQL 설치 (기본 리포지터리 사용)"
sudo apt install -y postgresql postgresql-client

echo "==> Postgres 유저/DB 생성 (없을 때만)"
sudo -u postgres psql <<'SQL'
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'pbos') THEN
      CREATE ROLE pbos LOGIN PASSWORD 'pbos';
   END IF;
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'pbos') THEN
      CREATE DATABASE pbos OWNER pbos;
   END IF;
END$$;
ALTER DATABASE pbos SET timezone TO 'Asia/Seoul';
SQL

echo "==> .env 생성/업데이트"
if [[ ! -f .env ]]; then
  cp .env.example .env
fi

# 기본 DATABASE_URL, PGTZ 보강 (기존 값이 없을 때만)
if ! grep -q "^DATABASE_URL=" .env; then
  echo "DATABASE_URL=postgresql://pbos:pbos@localhost:5432/pbos" >> .env
fi
if ! grep -q "^PGTZ=" .env; then
  echo "PGTZ=Asia/Seoul" >> .env
fi

echo "==> npm 패키지 설치"
npm install

echo "==> Prisma 마이그레이션/시드"
npx prisma migrate deploy
npx prisma db seed || true

echo "==> 빌드"
npm run build

echo "==> systemd 서비스 등록"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
sudo tee "${SERVICE_FILE}" >/dev/null <<EOF
[Unit]
Description=PBOS NestJS Service
After=network.target postgresql.service

[Service]
Type=simple
User=${APP_USER}
WorkingDirectory=${APP_DIR}
EnvironmentFile=${APP_DIR}/.env
ExecStart=$(which node) ${APP_DIR}/dist/main.js
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}"
sudo systemctl restart "${SERVICE_NAME}"
sudo systemctl status --no-pager "${SERVICE_NAME}"

echo "==> 완료"
