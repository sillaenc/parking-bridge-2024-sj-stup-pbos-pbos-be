# 스마트파킹 백엔드 서버 (Dart)

## 개요
이 프로젝트는 sillaENC 스마트파킹 시스템의 백엔드 서버로, Dart 기반 RESTful API를 제공합니다. 주차장, 계정, 통계, 디스플레이 등 다양한 기능을 지원하며, 실시간 데이터 관리와 통합을 목표로 합니다.

---

## 주요 기능

- **계정/사용자 관리**: 회원가입, 로그인, 권한 관리, 비밀번호 변경 등
- **주차장 관리**: 주차장 정보, 카메라 구역, 상태, 설정 등
- **statistics API**: 일/주/월/년/기간별 주차 통계 제공
- **display/billboard**: 전광판, LED, 빌보드 등 디스플레이 장치 관리
- **system setting**: DB 주소, 기본 정보, 중앙 제어 등 시스템 관리
- **health check**: 서버 상태, 엔드포인트 관리

---

## 프로젝트 구조

```
.
├── bin/
│   ├── main.dart                # 서버 진입점
│   ├── routes/                  # 각종 API 라우트(Dart 파일)
│   └── data/                    # DB 주소 등 데이터 관리
├── json_folder/                 # 주차장 등 JSON 데이터
├── display/                     # 디스플레이 관련 데이터
├── api.md                       # 전체 API 명세서
├── pubspec.yaml                 # 의존성 및 환경설정
├── .env-example                 # 환경변수 예시 파일
└── README.md                    # 프로젝트 설명서
```

---

## 실행 방법

1. **프로젝트 클론 및 의존성 설치**
   ```bash
   git clone [레포주소]
   cd [프로젝트폴더]
   dart pub get
   ```

2. **환경변수(.env) 설정**
   - `.env-example` 파일을 참고하여 `.env` 파일을 생성하고 DB 주소 등 환경변수를 입력하세요.

3. **서버 실행**
   - VSCode: 폴더를 열고 `main.dart`에서 실행 버튼 클릭
   - 터미널:  
     ```bash
     dart run bin/main.dart
     ```

---

## 주요 의존성

- Dart SDK ^3.3.1
- shelf, shelf_router, shelf_static (REST API 서버)
- http, dio (HTTP 통신)
- dotenv (환경변수)
- drift, postgres (DB 연동)
- intl, crypto 등

자세한 버전은 `pubspec.yaml` 참고

---

## 환경설정

- `.env` 파일에 DB 주소 등 환경변수 입력
- 예시:
  ```
  displayDbAddr=http://localhost:포트/파일명
  engineDbAddr=http://주소:IP/파일명
  ```

---

## API 문서

- `api.md` 파일에 전체 엔드포인트, 요청/응답 예시, 파라미터, 에러 코드 등 상세 명세가 있습니다.

---

## 기타

- `json_folder/` : 주차장 등 JSON 리소스
- `display/` : 전광판, 디스플레이 관련 데이터
- `bin/routes/` : 모든 API 라우트(Dart 파일)
- `bin/data/` : DB 주소, 데이터 관리

---

필요에 따라 프로젝트 특성에 맞게 항목을 추가/수정하셔도 됩니다.