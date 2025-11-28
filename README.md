# PBOS Nest Backend

NestJS + PostgreSQL로 이관한 PBOS 백엔드입니다. 기존 `pbos_be_v2`(Dart + ws4sqlite/SQLite)에서 177개 API를 유지하면서 모듈/DI/DTO/Swagger/Prisma를 도입했습니다.

## 핵심 개념
- **스키마 우선**: `prisma/schema.prisma`로 DB 스키마와 제약/인덱스를 정의하고 `prisma migrate/seed`로 재현.
- **호환성 유지**: `swagger_complete.yaml`에서 엔드포인트를 추출해 스텁 생성(`scripts/generate-stubs.js`, `scripts/generate-controller-stubs.js`), `/docs-complete` Swagger 경로와 와일드카드 CORS로 레거시 동작을 맞춤.
- **모듈 경계**: 도메인별 모듈(`auth`, `parking`, `stats`, `files`, `rtsp`, `display`, `billboard`, `system`, `monitoring`, `users`, `vehicle` 등)로 Controller → Service → Prisma 접근 계층을 분리.
- **운영/배포 고려**: PostgreSQL 컨테이너 제공(`docker-compose.yml`), `.env` 기반 설정(DATABASE_URL/JWT/RTSP/FFmpeg), Swagger 문서를 기본 포함.

## 기술 스택
- **런타임/프레임워크**: Node.js 18+, NestJS 10 (Express)
- **ORM**: Prisma 5 (PostgreSQL, 개발용 SQLite 호환 가능)
- **API 문서**: @nestjs/swagger, Swagger UI
- **인증**: @nestjs/jwt + Passport
- **스케줄러**: @nestjs/schedule
- **RTSP 캡처**: FFmpeg child_process 래핑

## 폴더 구조(발췌)
```
pbos_nest/
├── src/
│   ├── main.ts               # Nest 부트스트랩, CORS/Swagger 설정
│   ├── app.module.ts         # 모듈 집약, Config/Prisma/Schedule 등록
│   └── modules/              # 도메인별 모듈(auth, parking, stats, rtsp 등)
├── prisma/
│   ├── schema.prisma         # DB 스키마
│   └── seed.ts               # 시드 스크립트 (prisma.seed)
├── scripts/                  # Swagger→엔드포인트/컨트롤러 스텁 생성
├── generated/                # Swagger 기반 엔드포인트/stub 산출물
├── docker-compose.yml        # 로컬 PostgreSQL
├── package.json
└── tsconfig*.json
```

## 빠른 실행
1) **의존성**: `npm install`
2) **DB 준비**: `docker compose up -d postgres` (기본 계정/DB: `pbos/pbos`)
3) **환경 변수**: `.env` 생성
```
DATABASE_URL="postgresql://pbos:pbos@localhost:5432/pbos?schema=public"
JWT_SECRET="changeme"
RTSP_BATCH_SIZE=20
FFMPEG_TIMEOUT_MS=30000
```
4) **마이그레이션/시드**:
```
npm run prisma:migrate
npm run prisma:seed    # 필요 시
```
5) **개발 서버**: `npm run start:dev` (기본 포트 3000)
6) **API 문서**: http://localhost:3000/docs-complete (동일 문서 /docs 별칭)

## NPM 스크립트
- `start:dev`: ts-node-dev로 핫리로드 실행
- `build`: 타입스크립트 빌드(`dist/`)
- `prisma:generate`: Prisma 클라이언트 생성
- `prisma:migrate`: `prisma migrate deploy`
- `prisma:seed`: `prisma/seed.ts` 실행
- `gen:stubs`: `swagger_complete.yaml`에서 엔드포인트 JSON 생성
- `gen:controllers`: 엔드포인트 JSON을 기반으로 모듈별 컨트롤러 스텁 생성

## API 가이드
- **Base Path**: `/api/v1/*`
- **Swagger**: `/docs-complete`, `/docs`
- **인증**: Bearer JWT (AuthModule에서 `@nestjs/jwt` 활용)
- **DTO/검증**: `class-validator` + 글로벌 `ValidationPipe` (`src/main.ts`)
- **예시 모듈**:
  - Auth/Users: 로그인, 토큰 조회, 사용자 관리
  - Parking/Stats: 주차 구역/공간/통계
  - Files: `tb_files`, `tb_parking_zone_files` 기반 파일 메타 관리
  - RTSP: `rtsp_capture` 테이블 기반, 이미지 업로드/조회/수동 캡처
  - Display/Billboard/LED: 전광판·LED 관련 엔드포인트
  - Monitoring/System/Resources: 상태/핑/리소스 조회

## DB 스키마 & ERD 개요 (Prisma)
- **인증/설정**: `tb_users`(User), `settings`(Setting), `base`(BaseInfo), `ping`
- **주차 도메인**:
  - 구조: `tb_parking_zone`(ParkingZone) ↔ `tb_parking_zone_files`(ParkingZoneFile) ↔ `tb_files`(FileEntry)
  - 공간/타입: `tb_lot_type`(LotType) ↔ `tb_lots`(Lot) ↔ `tb_lot_status`(LotStatus)
  - 디스플레이/전광판: `display`(Display), `multiple_signs`(MultipleSigns), `tb_parking_surface`(ParkingSurface)
  - 통계: `processed_db`, `perday`, `permonth`, `peryear`, `rawdata`
- **RTSP/카메라**: `rtsp_capture`(RtspCapture), `tb_camera`(Camera)
- **제약/인덱스**: Prisma 스키마에 UNIQUE/INDEX 명시; LotType↔Lot, ParkingZone↔FileEntry FK 선언

## RTSP 캡처 파이프라인 (`src/modules/rtsp/rtsp.service.ts`)
- FFmpeg를 child_process로 실행(`captureWithFfmpeg`), `RTSP_BATCH_SIZE`만큼 주소 중복을 제거한 뒤 배치 실행.
- 캡처 파일 경로: `camera/captures/` 아래 태그/주소 기반 파일명 생성, DB `lastImagePath`에 기록.
- 이미지 API: `/api/v1/rtsp/cameras/:tag/image` 조회/업로드/갱신, `/api/v1/rtsp/trigger` 수동 캡처 트리거.

## 마이그레이션 참고
- 마이그레이션 전반 계획은 루트 `MIGRATION_PLAN.md`를 따릅니다.
- `swagger_complete.yaml`(pbos_be_v2) → `generated/endpoints.json` → 모듈별 스텁으로 변환 후 도메인별 구현을 채워넣는 흐름입니다.
- 데이터 이관: SQLite 덤프 → staging → 타입 변환 → 본 테이블 적재 후 건수/샘플 비교(진행 필요).

## 유용한 파일
- `src/main.ts`, `src/app.module.ts` : 부트스트랩/모듈 등록
- `prisma/schema.prisma` : DB 스키마
- `scripts/generate-stubs.js`, `scripts/generate-controller-stubs.js` : Swagger 기반 스텁 생성
- `src/modules/rtsp/rtsp.service.ts`, `src/modules/rtsp/rtsp.stub.controller.ts` : RTSP 구현 예
- `docker-compose.yml` : 로컬 PostgreSQL
