#!/usr/bin/env python3
"""
pb.yaml 파일 관리 시스템 통합 스크립트
"""

import yaml
import shutil
from datetime import datetime

def integrate_pb_yaml():
    """pb.yaml에 새로운 파일 관리 시스템 통합"""
    
    # 파일 경로
    original_pb_path = "/Users/bjs/Desktop/project/db/pb.yaml"
    new_queries_path = "/Users/bjs/Desktop/project/refactoring/pbos_be/pb_file_management_queries.yaml"
    backup_path = f"/Users/bjs/Desktop/project/db/pb.yaml.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    print("🔄 pb.yaml 파일 관리 시스템 통합을 시작합니다...")
    
    try:
        # 1. 백업 생성
        print(f"📁 백업 생성: {backup_path}")
        shutil.copy2(original_pb_path, backup_path)
        
        # 2. 기존 pb.yaml 로드
        print("📖 기존 pb.yaml 로드 중...")
        with open(original_pb_path, 'r', encoding='utf-8') as f:
            original_content = f.read()
        
        # 3. 새로운 쿼리 파일 로드
        print("📖 새로운 쿼리 파일 로드 중...")
        with open(new_queries_path, 'r', encoding='utf-8') as f:
            new_queries_content = f.read()
        
        # 4. YAML 파싱
        original_data = yaml.safe_load(original_content)
        new_data = yaml.safe_load(new_queries_content)
        
        # 5. storedStatements 통합
        if 'storedStatements' in new_data:
            print(f"➕ {len(new_data['storedStatements'])}개의 새로운 쿼리 추가 중...")
            original_data['storedStatements'].extend(new_data['storedStatements'])
        
        # 6. initStatements 통합
        if 'initStatements' in new_data:
            print(f"➕ {len(new_data['initStatements'])}개의 새로운 테이블 스키마 추가 중...")
            original_data['initStatements'].extend(new_data['initStatements'])
        
        # 7. 통합된 내용 저장
        print("💾 통합된 pb.yaml 저장 중...")
        with open(original_pb_path, 'w', encoding='utf-8') as f:
            yaml.dump(original_data, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
        
        print("✅ pb.yaml 통합이 완료되었습니다!")
        print(f"✅ 백업 파일: {backup_path}")
        print("\n📋 다음 단계:")
        print("1. ws4sqlite 서버 재시작")
        print("2. 새로운 테이블 생성 확인")
        print("3. Dart 서비스 코드에서 새로운 쿼리 ID 사용")
        
        return True
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        print(f"🔄 백업에서 복원: cp {backup_path} {original_pb_path}")
        return False

if __name__ == "__main__":
    integrate_pb_yaml()
