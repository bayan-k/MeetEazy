# MeetEazy Server

Django-based backend server for MeetEazy application with Firebase integration for meeting notifications.

## Setup Instructions

1. Create and activate virtual environment:
```bash
python -m venv venv
source venv/Scripts/activate  # On Windows
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Generate a service account key (JSON file)
   - Place the JSON file in a secure location
   - Update the FIREBASE_CREDENTIALS_PATH in .env file

4. Configure environment variables:
   - Copy .env.example to .env
   - Update the variables in .env file

5. Run database migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

6. Create superuser (optional):
```bash
python manage.py createsuperuser
```

7. Run the development server:
```bash
python manage.py runserver
```

## API Endpoints

### Meetings
- GET /api/meetings/ - List all meetings
- POST /api/meetings/ - Create a new meeting
- GET /api/meetings/{id}/ - Get meeting details
- PUT /api/meetings/{id}/ - Update meeting
- DELETE /api/meetings/{id}/ - Delete meeting
- POST /api/meetings/{id}/subscribe_to_notifications/ - Subscribe to meeting notifications

## Meeting Notifications

The server uses Firebase Cloud Messaging (FCM) to send notifications for upcoming meetings. When a meeting is created or updated:

1. An alarm is scheduled for the meeting
2. A notification will be sent to subscribed devices before the meeting starts
3. Devices can subscribe to notifications for specific meetings

## Environment Variables

- DEBUG: Enable/disable debug mode
- DJANGO_SECRET_KEY: Django secret key
- FIREBASE_CREDENTIALS_PATH: Path to Firebase service account key
- ALLOWED_HOSTS: Comma-separated list of allowed hosts
