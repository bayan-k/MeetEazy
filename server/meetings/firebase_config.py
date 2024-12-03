import firebase_admin
from firebase_admin import credentials
import os

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        # Check if already initialized
        firebase_admin.get_app()
    except ValueError:
        # Get the path to your Firebase service account key
        cred_path = os.getenv('FIREBASE_CREDENTIALS_PATH', 'path/to/your/serviceAccountKey.json')
        
        if not os.path.exists(cred_path):
            raise FileNotFoundError(
                "Firebase credentials file not found. Please set FIREBASE_CREDENTIALS_PATH "
                "environment variable to point to your serviceAccountKey.json file."
            )
            
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
