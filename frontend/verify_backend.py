import requests
import json

BASE_URL = "http://localhost:8000"

def test_health():
    try:
        r = requests.get(f"{BASE_URL}/")
        print(f"Root endpoint: {r.status_code}")
        print(f"Response: {r.json()}")
        
        r2 = requests.get(f"{BASE_URL}/api/v1/rule-ai/health")
        print(f"Rule-AI Health: {r2.status_code}")
        print(f"Response: {r2.json()}")
        return True
    except Exception as e:
        print(f"Connection error: {e}")
        return False

if __name__ == "__main__":
    test_health()
