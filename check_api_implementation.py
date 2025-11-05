#!/usr/bin/env python3
"""
Swagger 문서의 API 엔드포인트와 실제 구현을 비교하는 스크립트
"""

import re
import yaml
from pathlib import Path
from collections import defaultdict

# 프로젝트 루트
PROJECT_ROOT = Path(__file__).parent
ROUTES_DIR = PROJECT_ROOT / 'bin' / 'routes'
SWAGGER_FILE = PROJECT_ROOT / 'swagger_complete.yaml'

def extract_swagger_endpoints():
    """Swagger 문서에서 모든 엔드포인트 추출"""
    with open(SWAGGER_FILE, 'r', encoding='utf-8') as f:
        swagger = yaml.safe_load(f)
    
    endpoints = {}
    for path, methods in swagger.get('paths', {}).items():
        if path.startswith('/api/v1/'):
            for method, details in methods.items():
                if method.lower() in ['get', 'post', 'put', 'delete', 'patch']:
                    key = f"{method.upper()} {path}"
                    summary = details.get('summary', '')
                    tags = details.get('tags', ['unknown'])
                    endpoints[key] = {
                        'path': path,
                        'method': method.upper(),
                        'summary': summary,
                        'tags': tags,
                        'implemented': False
                    }
    
    return endpoints

def extract_implemented_routes():
    """실제 구현된 라우트 추출"""
    implemented = set()
    
    # 모든 API 파일 읽기
    for file_path in ROUTES_DIR.glob('*.dart'):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # router.get('/path', ...), router.post('/path', ...) 등 찾기
        patterns = [
            r"router\.(get|post|put|delete|patch)\(['\"]([^'\"]+)['\"]",
            r"router\.(mount)\(['\"]([^'\"]+)['\"]",
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content)
            for method, path in matches:
                if method != 'mount':
                    # 경로 파라미터 변환 (Dart -> OpenAPI 형식)
                    # <param> -> {param}
                    converted_path = re.sub(r'<([^>]+)>', r'{\1}', path)
                    implemented.add((method.upper(), converted_path))
    
    return implemented

def check_router_config():
    """router_config.dart에서 마운트된 경로 확인"""
    router_config_path = ROUTES_DIR / 'router_config.dart'
    mounted_paths = {}
    
    with open(router_config_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # _router.mount('$API_PREFIX/...' 패턴 찾기
    mount_pattern = r"_router\.mount\(['\"](\$API_PREFIX)?([^'\"]+)['\"]"
    matches = re.findall(mount_pattern, content)
    
    for prefix, path in matches:
        if prefix or path.startswith('/api/v1'):
            clean_path = path.replace('$API_PREFIX', '/api/v1')
            mounted_paths[clean_path] = True
    
    return mounted_paths

def match_endpoints(swagger_endpoints, implemented_routes, mounted_paths):
    """Swagger 엔드포인트와 실제 구현 매칭"""
    
    for key, endpoint in swagger_endpoints.items():
        method = endpoint['method']
        path = endpoint['path']
        
        # 정확한 매칭 확인
        if (method, path) in implemented_routes:
            endpoint['implemented'] = True
            continue
        
        # 마운트 경로 기반 매칭
        for mounted_path in mounted_paths.keys():
            # 마운트 경로로 시작하는지 확인
            if path.startswith(mounted_path):
                # 남은 부분의 경로
                remaining_path = path[len(mounted_path):]
                if not remaining_path:
                    remaining_path = '/'
                elif not remaining_path.startswith('/'):
                    remaining_path = '/' + remaining_path
                
                # 남은 경로가 구현되어 있는지 확인
                for impl_method, impl_path in implemented_routes:
                    if impl_method == method:
                        # 경로 매칭 (파라미터 무시)
                        if impl_path == remaining_path or \
                           impl_path.replace('/<', '/{').replace('>', '}') == remaining_path or \
                           remaining_path.replace('/{', '/<').replace('}', '>') == impl_path:
                            endpoint['implemented'] = True
                            break
                
                if endpoint['implemented']:
                    break
    
    return swagger_endpoints

def generate_report(endpoints):
    """보고서 생성"""
    
    # 카테고리별로 분류
    by_category = defaultdict(list)
    for key, endpoint in endpoints.items():
        category = endpoint['tags'][0] if endpoint['tags'] else 'unknown'
        by_category[category].append((key, endpoint))
    
    # 통계
    total = len(endpoints)
    implemented = sum(1 for e in endpoints.values() if e['implemented'])
    missing = total - implemented
    
    print("=" * 80)
    print("📊 API 구현 상태 전수조사 결과")
    print("=" * 80)
    print(f"\n총 엔드포인트: {total}개")
    print(f"✅ 구현됨: {implemented}개 ({implemented/total*100:.1f}%)")
    print(f"❌ 미구현: {missing}개 ({missing/total*100:.1f}%)")
    print("\n" + "=" * 80)
    
    # 미구현 엔드포인트만 카테고리별로 출력
    print("\n❌ 미구현 API 목록 (카테고리별)\n")
    
    missing_by_category = {}
    for category, items in sorted(by_category.items()):
        missing_items = [(k, e) for k, e in items if not e['implemented']]
        if missing_items:
            missing_by_category[category] = missing_items
    
    for category, items in sorted(missing_by_category.items()):
        print(f"\n📁 [{category}] - {len(items)}개 미구현")
        print("-" * 80)
        for key, endpoint in items:
            print(f"  • {endpoint['method']} {endpoint['path']}")
            print(f"    └─ {endpoint['summary']}")
    
    # 구현된 엔드포인트 요약 (카테고리별)
    print("\n" + "=" * 80)
    print("\n✅ 구현된 API 요약 (카테고리별)\n")
    
    for category, items in sorted(by_category.items()):
        implemented_items = [(k, e) for k, e in items if e['implemented']]
        total_items = len(items)
        impl_count = len(implemented_items)
        
        if impl_count > 0:
            percentage = impl_count / total_items * 100
            status = "✅" if percentage == 100 else "⚠️"
            print(f"{status} [{category}]: {impl_count}/{total_items} ({percentage:.1f}%)")
    
    print("\n" + "=" * 80)
    
    # 상세 누락 목록을 파일로 저장
    output_file = PROJECT_ROOT / 'api_implementation_report.txt'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("=" * 80 + "\n")
        f.write("API 구현 상태 전수조사 상세 보고서\n")
        f.write("=" * 80 + "\n\n")
        
        f.write(f"총 엔드포인트: {total}개\n")
        f.write(f"구현됨: {implemented}개 ({implemented/total*100:.1f}%)\n")
        f.write(f"미구현: {missing}개 ({missing/total*100:.1f}%)\n\n")
        
        f.write("=" * 80 + "\n")
        f.write("미구현 API 상세 목록\n")
        f.write("=" * 80 + "\n\n")
        
        for category, items in sorted(missing_by_category.items()):
            f.write(f"\n[{category}] - {len(items)}개 미구현\n")
            f.write("-" * 80 + "\n")
            for key, endpoint in items:
                f.write(f"{endpoint['method']} {endpoint['path']}\n")
                f.write(f"  Summary: {endpoint['summary']}\n")
                f.write(f"  Tags: {', '.join(endpoint['tags'])}\n\n")
    
    print(f"\n📄 상세 보고서가 생성되었습니다: {output_file}")
    print("=" * 80)

def main():
    print("🔍 API 구현 상태 전수조사 시작...\n")
    
    # 1. Swagger 엔드포인트 추출
    print("1️⃣ Swagger 문서에서 엔드포인트 추출 중...")
    swagger_endpoints = extract_swagger_endpoints()
    print(f"   → {len(swagger_endpoints)}개 엔드포인트 발견\n")
    
    # 2. 실제 구현된 라우트 추출
    print("2️⃣ 실제 구현된 라우트 추출 중...")
    implemented_routes = extract_implemented_routes()
    print(f"   → {len(implemented_routes)}개 라우트 발견\n")
    
    # 3. 라우터 설정에서 마운트 경로 확인
    print("3️⃣ 라우터 설정에서 마운트 경로 확인 중...")
    mounted_paths = check_router_config()
    print(f"   → {len(mounted_paths)}개 마운트 경로 발견\n")
    
    # 4. 매칭 및 비교
    print("4️⃣ 엔드포인트 매칭 및 비교 중...\n")
    matched_endpoints = match_endpoints(swagger_endpoints, implemented_routes, mounted_paths)
    
    # 5. 보고서 생성
    generate_report(matched_endpoints)

if __name__ == '__main__':
    main()

