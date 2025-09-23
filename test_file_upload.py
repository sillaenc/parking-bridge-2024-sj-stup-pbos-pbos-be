import requests
import json

# 테스트할 서버 주소
base_url = "http://localhost:8080"

def test_file_api():
    print("=== 파일 업로드/삭제 API 테스트 ===\n")
    
    # 1. 서비스 정보 확인
    print("1. 서비스 정보 확인")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/info")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            info = response.json()
            print(f"Service: {info.get('service', 'Unknown')}")
            print(f"Supported file types: {info.get('supportedFileTypes', 'Unknown')}")
            print(f"Max file size: {info.get('maxFileSize', 'Unknown')}")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "="*50 + "\n")
    
    # 2. 현재 주차 구역 목록 조회
    print("2. 현재 주차 구역 목록 조회")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text[:500]}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n" + "="*50 + "\n")
    
    # 3. 파일 시스템 파일 목록 조회
    print("3. 파일 시스템 파일 목록 조회")
    try:
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/files")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text[:500]}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_file_api()
