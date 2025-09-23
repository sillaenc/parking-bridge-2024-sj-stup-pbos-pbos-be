import requests
import json
import tempfile
import os

# 테스트할 서버 주소
base_url = "http://localhost:8080"

def create_test_file():
    """테스트용 임시 파일 생성"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        f.write("Test parking zone configuration\n")
        f.write("This is a test file for parking zone upload.\n")
        f.write("Created for API testing purposes.\n")
        return f.name

def test_file_upload_without_db():
    print("=== 데이터베이스 없이 파일 처리 로직 테스트 ===\n")
    
    # 테스트 파일 생성
    test_file_path = create_test_file()
    filename = "test_parking_zone"
    
    try:
        # 파일 업로드 테스트 (multipart/form-data)
        print("1. 파일 업로드 API 테스트")
        with open(test_file_path, 'rb') as f:
            files = {
                'file': ('test.txt', f, 'text/plain')
            }
            data = {
                'filename': filename
            }
            
            response = requests.post(
                f"{base_url}/api/v1/settings/parking-zones/",
                files=files,
                data=data
            )
            
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
        
        print("\n" + "="*50 + "\n")
        
        # 특정 파일 조회 테스트
        print("2. 특정 주차 구역 조회 테스트")
        response = requests.get(f"{base_url}/api/v1/settings/parking-zones/{filename}")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        print("\n" + "="*50 + "\n")
        
        # 파일 삭제 테스트  
        print("3. 파일 삭제 API 테스트")
        response = requests.delete(f"{base_url}/api/v1/settings/parking-zones/{filename}")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
    except Exception as e:
        print(f"Error during test: {e}")
    
    finally:
        # 임시 파일 정리
        if os.path.exists(test_file_path):
            os.unlink(test_file_path)
            print(f"\n임시 파일 정리 완료: {test_file_path}")

def test_legacy_api():
    print("\n=== 레거시 API 호환성 테스트 ===\n")
    
    # 레거시 파일 삭제 API 테스트
    print("1. 레거시 파일 삭제 API")
    try:
        data = {"filename": "test_file"}
        response = requests.post(
            f"{base_url}/api/v1/settings/parking-zones/legacy/deleteFile",
            json=data,
            headers={'Content-Type': 'application/json'}
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_file_upload_without_db()
    test_legacy_api()
