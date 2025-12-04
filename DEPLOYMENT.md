# PBOS Nest 배포 가이드

## 필수 사양
- OS: Linux (Ubuntu 20.04+/CentOS7+) 또는 macOS
- Node.js: 25.2.1  
  - 확인: `node -v`
- npm: `npm -v`
- PostgreSQL: 14 (서버/클라이언트 모두 필요)
  - 클라이언트 유틸 포함 설치( `psql`, `pg_dump` 필수 )
- FFmpeg: `ffmpeg` 바이너리 필요 (RTSP 캡처)
- Git(또는 소스 전달 수단)

## 설치 명령 예시
### Ubuntu/Debian
```bash
sudo apt update
sudo apt install -y curl ca-certificates gnupg
# Node 20 (예시)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs build-essential
# PostgreSQL 클라이언트/서버
sudo apt install -y postgresql postgresql-client
# FFmpeg
sudo apt install -y ffmpeg
```

### RHEL/CentOS
```bash
sudo yum install -y epel-release
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo -E bash -
sudo yum install -y nodejs gcc-c++ make
sudo yum install -y postgresql postgresql-server postgresql-contrib
sudo yum install -y ffmpeg
```

### macOS (Homebrew)
```bash
brew install node@20 postgresql ffmpeg
```

## 준비 파일/디렉터리
- 소스 코드 전체 (Git clone 또는 아카이브)
- 필수: `.env` (직접 작성 또는 `.env.example` 복사 후 수정)
- 필요 시 사전 빌드 산출물: `dist/` (직접 빌드 가능하면 불필요)
- Prisma 마이그레이션 파일(`prisma/migrations/`) 포함

## 환경 변수 (.env) 주요 항목
- `DATABASE_URL=postgresql://user:pass@host:5432/dbname`
- `PORT=3000`
- `JWT_SECRET=...`
- `PGTZ=Asia/Seoul` (세션 타임존 강제)
- `FFMPEG_PATH=ffmpeg` (또는 절대경로)
- RTSP: `RTSP_INTERVAL`, `RTSP_BATCH_SIZE`, `RTSP_CYCLE_DELAY_MS`, `FFMPEG_TIMEOUT_MS`
- 통계 정리/백업(옵션):
  - `STATS_TRUNCATE_TABLES=rawdata,tb_lot_status`
  - `STATS_TRUNCATE_CRON=0 2 0 * * *`  # 매일 00:02
  - `STATS_BACKUP_CRON=0 30 2 * * *`   # 매일 02:30
  - `STATS_BACKUP_DIR=db_backups`
  - `STATS_BACKUP_KEEP=7`

## DB 초기화 (빈 DB 기준)
```bash
npm install
npx prisma migrate deploy      # 스키마 생성 (timestamptz 포함)
npx prisma db seed             # 필요 시 시드
```

### 기존 UTC 데이터가 없는 새 DB에서 KST로 시작하려면
- 위 migrate만 실행하면 Prisma 스키마에 정의된 `timestamptz`로 테이블 생성.
- DB 타임존도 고정 권장:
  ```sql
  ALTER DATABASE dbname SET timezone TO 'Asia/Seoul';
  ```

### 기존 데이터가 있고 UTC→KST 변환이 필요할 때 (참고)
- 타입 변경 전 백업 필수.
- 예: `ALTER TABLE tb_lot_status ALTER COLUMN added TYPE timestamptz USING added AT TIME ZONE 'UTC';`
- 동일 패턴으로 `processed_db.recorded_hour`, `perday.recorded_day`, `permonth.recorded_month`, `peryear.recorded_year`, `rawdata.timestamp`, `tb_lots."startTime"` 등 변환.

## 빌드 및 실행
```bash
npm run build          # dist/ 생성
node dist/main.js      # 직접 실행
# 또는
npm run start:dev      # 개발용 (ts-node-dev)
```

## systemd 서비스 예시 (Linux)
`/etc/systemd/system/pbos-nest.service`
```
[Unit]
Description=PBOS NestJS Service
After=network.target

[Service]
Type=simple
User=pbos      # 실행 유저
WorkingDirectory=/opt/pbos_nest   # 소스 위치
EnvironmentFile=/opt/pbos_nest/.env
ExecStart=/usr/bin/node /opt/pbos_nest/dist/main.js
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```
서비스 반영:
```bash
sudo systemctl daemon-reload
sudo systemctl enable pbos-nest
sudo systemctl start pbos-nest
sudo systemctl status pbos-nest
```

## 백업/정리 작업
- 통계 백업 스케줄: `STATS_BACKUP_*` 설정 시 `pg_dump`를 사용해 주기적 백업 수행(경로 생성 후 보관 개수 관리).
- rawdata/lot_status 정리: `STATS_TRUNCATE_*` 설정 시 지정 테이블을 주기적으로 TRUNCATE.
- `pg_dump`가 PATH에 있어야 백업 동작.

## 기타
- RTSP 캡처 이미지 경로: 상대경로이면 `process.cwd()` 기준.
- PrismaService는 앱 시작 시 `SET TIME ZONE 'Asia/Seoul'`을 실행해 세션 타임존을 KST로 고정.
- Docker 배포도 가능: node 런타임 + 위 단계(install/migrate/build)를 Dockerfile에 작성 후 컨테이너 실행. Postgres는 별도 컨테이너/호스트 필요.
