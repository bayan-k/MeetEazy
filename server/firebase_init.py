import firebase_admin
from firebase_admin import credentials
import os

def initialize_firebase():
    try:
        # Get the absolute path to the credentials file
        current_dir = os.path.dirname(os.path.abspath(__file__))
        cred_path = os.path.join(current_dir, 'firebase_credentials.json')
        
        if not os.path.exists(cred_path):
            raise FileNotFoundError(f"Firebase credentials file not found at {cred_path}")
            
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("Firebase initialized successfully")
    except Exception as e:
        print(f"Error initializing Firebase: {str(e)}")
        raise
