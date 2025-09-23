# pb.yaml 파일 관리 시스템 통합 가이드

## 📂 통합 단계

### 1단계: 백업 생성 (완료)
```bash
cp /Users/bjs/Desktop/project/db/pb.yaml /Users/bjs/Desktop/project/db/pb.yaml.backup
```

### 2단계: pb.yaml에 새로운 쿼리 추가
pb_file_management_queries.yaml의 `storedStatements` 섹션 내용을 
/Users/bjs/Desktop/project/db/pb.yaml의 `storedStatements` 섹션에 추가

### 3단계: pb.yaml에 새로운 테이블 추가
pb_file_management_queries.yaml의 `initStatements` 섹션 내용을
/Users/bjs/Desktop/project/db/pb.yaml의 `initStatements` 섹션에 추가

### 4단계: ws4sqlite 재시작
새로운 스키마가 적용되도록 ws4sqlite 서버 재시작

### 5단계: Dart 서비스 코드 업데이트
새로운 쿼리 ID들을 사용하도록 서비스 코드 수정

## ⚠️ 주의사항

1. **기존 데이터 유지**: 
   - 새로운 테이블 추가는 기존 데이터에 영향 없음
   - tb_parking_zone 테이블은 그대로 유지됨

2. **점진적 적용**:
   - 기존 API는 계속 작동
   - 새로운 파일 관리 API는 단계적으로 적용

3. **테스트 필수**:
   - 기존 주차구역 API 정상 작동 확인
   - 새로운 파일 관리 API 테스트

## 🔧 통합 후 사용 가능한 새로운 기능

- 다양한 파일 타입 지원 (이미지, 영상, 문서)
- 파일 메타데이터 관리
- 파일시스템 동기화
- 고아 파일 정리
- 카테고리별 파일 분류
- 1:N 관계 (주차구역 ↔ 파일)
