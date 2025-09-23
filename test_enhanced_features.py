import requests
import json

base_url = "http://localhost:8080"

def test_enhanced_file_features():
    print("=== 향상된 파일 관리 기능 테스트 ===\n")
    
    # 1. 서비스 정보 확인 (새로운 기능들 포함)
    print("1. 향상된 서비스 정보 확인")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/info")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            info = response.json()
            print(f"Version: {info.get('version', 'Unknown')}")
            print(f"Description: {info.get('description', 'Unknown')}")
            print(f"Max file size: {info.get('maxFileSize', 'Unknown')}")
            print(f"Supported file types: {len(info.get('supportedFileTypes', []))}개")
            print(f"New features: {info.get('features', [])}")
            print(f"New endpoints: sync, filesystem-health")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "="*60 + "\n")
    
    # 2. 파일시스템 상태 확인
    print("2. 파일시스템 상태 확인")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/filesystem-health")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            health = response.json()
            if health.get('success'):
                data = health.get('data', {})
                print(f"파일시스템 존재: {data.get('exists', False)}")
                print(f"전체 파일 수: {data.get('totalFiles', 0)}개")
                print(f"전체 크기: {data.get('totalSizeMB', 0)}MB")
                print(f"지원 파일: {data.get('supportedFiles', 0)}개")
                print(f"미지원 파일: {data.get('unsupportedFiles', 0)}개")
                print(f"고아 파일: {data.get('orphanedFiles', 0)}개")
                print(f"시스템 건강성: {data.get('isHealthy', False)}")
            else:
                print(f"Error: {health.get('message', 'Unknown error')}")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "="*60 + "\n")
    
    # 3. 수동 파일시스템 동기화 테스트
    print("3. 수동 파일시스템 동기화 테스트")
    try:
        response = requests.post(f"{base_url}/api/v1/settings/parking-zones/sync")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            sync_result = response.json()
            if sync_result.get('success'):
                data = sync_result.get('data', {})
                print(f"동기화 완료!")
                print(f"동기화 시간: {data.get('syncDurationMs', 0)}ms")
                print(f"DB 레코드: {data.get('totalParkingZones', 0)}개")
                print(f"파일시스템 파일: {data.get('totalFiles', 0)}개")
                print(f"동기화된 시각: {data.get('syncedAt', 'Unknown')}")
            else:
                print(f"동기화 실패: {sync_result.get('message', 'Unknown error')}")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "="*60 + "\n")
    
    # 4. 지원되는 파일 형식 확인
    print("4. 지원되는 파일 형식 확인")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/info")
        if response.status_code == 200:
            info = response.json()
            supported_types = info.get('supportedFileTypes', [])
            
            # 카테고리별로 분류
            image_types = [ext for ext in supported_types if ext in ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'ico']]
            video_types = [ext for ext in supported_types if ext in ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', 'mpg', 'mpeg', 'm4v', '3gp']]
            doc_types = [ext for ext in supported_types if ext in ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']]
            data_types = [ext for ext in supported_types if ext in ['json', 'xml', 'txt', 'csv', 'yaml', 'yml']]
            archive_types = [ext for ext in supported_types if ext in ['zip', 'rar', '7z', 'tar', 'gz']]
            
            print(f"총 지원 형식: {len(supported_types)}개")
            print(f"이미지: {len(image_types)}개 - {', '.join(image_types)}")
            print(f"영상: {len(video_types)}개 - {', '.join(video_types)}")
            print(f"문서: {len(doc_types)}개 - {', '.join(doc_types)}")
            print(f"데이터: {len(data_types)}개 - {', '.join(data_types)}")
            print(f"압축: {len(archive_types)}개 - {', '.join(archive_types)}")
            
        else:
            print(f"Error getting supported types")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_enhanced_file_features()
