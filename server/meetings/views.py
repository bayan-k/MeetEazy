from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.utils import timezone
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import messaging, credentials
from .models import Meeting, MeetingAlarm, DeviceToken
from .serializers import MeetingSerializer, MeetingAlarmSerializer
from rest_framework.views import APIView
import os
import json
from django.views.decorators.csrf import csrf_exempt
import pytz

# Initialize Firebase Admin SDK with the existing credentials file
cred = credentials.Certificate(os.path.join(os.path.dirname(os.path.dirname(__file__)), 'firebase_credentials.json'))
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

# Create your views here.

class MeetingViewSet(viewsets.ModelViewSet):
    queryset = Meeting.objects.all()
    serializer_class = MeetingSerializer

    def create(self, request, *args, **kwargs):
        try:
            # Log incoming request data
            print("=== Received meeting creation request ===")
            print(f"Data: {request.data}")
            
            # Extract data from request
            data = request.data.copy()
            
            # Ensure required fields are present
            required_fields = ['meeting_id', 'title', 'start_time']
            for field in required_fields:
                if field not in data:
                    print(f"ERROR: Missing required field: {field}")
                    return Response(
                        {'error': f'Missing required field: {field}'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Set notification_time to 5 minutes before start_time if not provided
            if 'notification_time' not in data and 'start_time' in data:
                start_time = datetime.fromisoformat(data['start_time'].replace('Z', '+00:00'))
                data['notification_time'] = (start_time - timedelta(minutes=5)).isoformat()
            
            print("=== Processing times ===")
            print(f"Start time: {data.get('start_time')}")
            print(f"Notification time: {data.get('notification_time')}")
            
            # Create serializer with the data
            serializer = self.get_serializer(data=data)
            if not serializer.is_valid():
                print(f"ERROR: Serializer validation errors: {serializer.errors}")
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
            # Save the meeting
            meeting = serializer.save()
            print("SUCCESS: Meeting saved successfully")
            
            # Always schedule an alarm
            self._schedule_alarm(meeting)
            print("SUCCESS: Alarm scheduled")
            
            self._send_notification(meeting, "Meeting Scheduled")
            print("SUCCESS: Notification sent")
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            print(f"ERROR: Error creating meeting: {str(e)}")
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def perform_update(self, serializer):
        try:
            meeting = serializer.save()
            # Delete existing alarms and create new ones
            meeting.alarms.all().delete()
            self._schedule_alarm(meeting)
            self._send_notification(meeting, "Meeting Updated")
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def _schedule_alarm(self, meeting):
        try:
            # Use notification_time if present, otherwise 5 minutes before start_time
            alarm_time = meeting.notification_time if meeting.notification_time else (meeting.start_time - timedelta(minutes=5))
            
            print(f"=== Scheduling alarm for meeting {meeting.meeting_id} ===")
            print(f"Alarm time: {alarm_time}")
            
            alarm = MeetingAlarm.objects.create(
                meeting=meeting,
                scheduled_time=alarm_time,
                is_triggered=False,
                is_sent=False
            )
            print(f"SUCCESS: Alarm created successfully: {alarm}")
            
        except Exception as e:
            print(f"ERROR: Error scheduling alarm: {str(e)}")
            raise

    def _send_notification(self, meeting, action):
        try:
            # Get all active device tokens
            device_tokens = DeviceToken.objects.filter(is_active=True)
            
            for token in device_tokens:
                notification_data = {
                    'title': f'{action}: {meeting.title}',
                    'body': f'Meeting scheduled for {meeting.start_time}',
                    'data': {
                        'meeting_id': meeting.meeting_id,
                        'action': action.lower().replace(' ', '_')
                    }
                }
                
                send_fcm_notification(
                    token.token,
                    notification_data['title'],
                    notification_data['body'],
                    notification_data['data']
                )
        except Exception as e:
            # Log the error but don't stop the meeting creation/update
            print(f"Error sending notification: {e}")

    @action(detail=True, methods=['post'])
    def subscribe_to_notifications(self, request, pk=None):
        """Subscribe a device to meeting notifications"""
        meeting = self.get_object()
        device_token = request.data.get('device_token')

        if not device_token:
            return Response(
                {'error': 'device_token is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            messaging.subscribe_to_topic(
                [device_token], 
                f'meeting_{meeting.id}'
            )
            return Response({'status': 'subscribed'})
        except Exception as e:
            return Response(
                {'error': str(e)}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class DeviceTokenView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            token = request.data.get('token')
            if not token:
                return Response(
                    {'error': 'Token is required'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            DeviceToken.objects.update_or_create(
                token=token,
                defaults={'is_active': True}
            )
            return Response({'status': 'Token registered'})
        except Exception as e:
            return Response(
                {'error': 'Failed to register token'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class DeviceTokenViewSet(viewsets.ModelViewSet):
    queryset = DeviceToken.objects.all()
    
    def create(self, request):
        token = request.data.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            DeviceToken.objects.update_or_create(
                token=token,
                defaults={'last_used': timezone.now()}
            )
            return Response({'status': 'Token registered'})
        except Exception as e:
            return Response(
                {'error': 'Failed to register token'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

def send_fcm_notification(token, title, body, data=None):
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            data=data or {},
            token=token,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    sound='alarm',
                    priority='max',
                    channel_id='meeting_alarms'
                )
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='alarm.wav',
                        badge=1
                    )
                )
            )
        )
        
        response = messaging.send(message)
        return response
    except Exception as e:
        print(f"Error sending FCM message: {e}")
        raise

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def schedule_meeting_notification(request):
    try:
        data = request.data
        meeting_id = data.get('meeting_id')
        title = data.get('title')
        body = data.get('body')
        scheduled_time = data.get('scheduled_time')
        device_token = data.get('device_token')

        if not all([meeting_id, title, body, scheduled_time, device_token]):
            return Response(
                {'error': 'Missing required fields'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Parse the scheduled time
        try:
            scheduled_dt = datetime.fromisoformat(scheduled_time.replace('Z', '+00:00'))
        except ValueError:
            return Response(
                {'error': 'Invalid datetime format'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Schedule the notification
        try:
            # Store the meeting notification in the database
            meeting = Meeting.objects.create(
                meeting_id=meeting_id,
                title=title,
                description=body,
                scheduled_time=scheduled_dt
            )

            # Send immediate confirmation
            send_fcm_notification(
                device_token,
                "Meeting Scheduled",
                f"Meeting '{title}' scheduled for {scheduled_dt.strftime('%Y-%m-%d %H:%M')}"
            )

            return Response({
                'message': 'Meeting notification scheduled successfully',
                'meeting_id': meeting_id,
                'scheduled_time': scheduled_dt.isoformat()
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response(
                {'error': f'Failed to schedule notification: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def send_notification(request):
    try:
        # Get all meetings that need notifications now
        current_time = timezone.now()
        pending_notifications = Meeting.objects.filter(
            notification_time__lte=current_time,
            notification_sent=False
        )

        # Get all registered device tokens
        device_tokens = DeviceToken.objects.values_list('token', flat=True)

        if not device_tokens:
            return Response({'message': 'No devices registered'})

        for meeting in pending_notifications:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=f"Meeting Reminder: {meeting.title}",
                    body=f"Meeting starts in 5 minutes: {meeting.description}"
                ),
                tokens=list(device_tokens)
            )

            # Send notification
            response = messaging.send_multicast(message)
            
            # Mark as sent
            meeting.notification_sent = True
            meeting.save()

        return Response({'status': 'Notifications sent'})
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def trigger_alarm(request):
    try:
        current_time = timezone.now()
        
        # Check both direct meeting alarms and meeting alarm records
        pending_meeting_alarms = Meeting.objects.filter(
            alarm_time__lte=current_time,
            alarm_triggered=False
        )
        
        pending_alarm_records = MeetingAlarm.objects.filter(
            scheduled_time__lte=current_time,
            is_sent=False
        ).select_related('meeting')

        device_tokens = DeviceToken.objects.values_list('token', flat=True)

        if not device_tokens:
            return Response({'message': 'No devices registered'}, status=status.HTTP_400_BAD_REQUEST)

        tokens_list = list(device_tokens)
        triggered_count = 0

        # Handle direct meeting alarms
        for meeting in pending_meeting_alarms:
            try:
                message = messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=f"Meeting Alarm: {meeting.title}",
                        body=f"Your meeting is starting now!"
                    ),
                    data={
                        'type': 'alarm',
                        'meeting_id': str(meeting.meeting_id),
                        'title': meeting.title
                    },
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            sound='alarm',
                            priority='max',
                            channel_id='meeting_alarms'
                        )
                    ),
                    tokens=tokens_list
                )
                
                response = messaging.send_multicast(message)
                if response.success_count > 0:
                    meeting.alarm_triggered = True
                    meeting.save()
                    triggered_count += 1
                    
            except Exception as e:
                print(f"Error sending alarm for meeting {meeting.id}: {str(e)}")

        # Handle meeting alarm records
        for alarm in pending_alarm_records:
            try:
                message = messaging.MulticastMessage(
                    notification=messaging.Notification(
                        title=f"Meeting Alarm: {alarm.meeting.title}",
                        body=f"Your meeting is starting now!"
                    ),
                    data={
                        'type': 'alarm',
                        'meeting_id': str(alarm.meeting.meeting_id),
                        'title': alarm.meeting.title
                    },
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            sound='alarm',
                            priority='max',
                            channel_id='meeting_alarms'
                        )
                    ),
                    tokens=tokens_list
                )
                
                response = messaging.send_multicast(message)
                if response.success_count > 0:
                    alarm.is_sent = True
                    alarm.save()
                    triggered_count += 1
                    
            except Exception as e:
                print(f"Error sending alarm record {alarm.id}: {str(e)}")

        if triggered_count > 0:
            return Response({'status': f'Successfully triggered {triggered_count} alarms'})
        else:
            return Response({'message': 'No pending alarms found'}, status=status.HTTP_404_NOT_FOUND)
            
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])
def cancel_meeting_notification(request):
    try:
        data = request.data
        meeting_id = data.get('meeting_id')
        device_token = data.get('device_token')

        if not all([meeting_id, device_token]):
            return Response(
                {'error': 'Missing required fields'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Find and delete the meeting
        try:
            meeting = Meeting.objects.get(meeting_id=meeting_id)
            meeting_title = meeting.title
            meeting.delete()

            # Send cancellation confirmation
            send_fcm_notification(
                device_token,
                "Meeting Cancelled",
                f"Meeting '{meeting_title}' has been cancelled"
            )

            return Response({
                'message': 'Meeting cancelled successfully',
                'meeting_id': meeting_id
            }, status=status.HTTP_200_OK)

        except Meeting.DoesNotExist:
            return Response(
                {'error': 'Meeting not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            return Response(
                {'error': f'Failed to cancel meeting: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['GET'])
@permission_classes([AllowAny])
def test_connection(request):
    """
    A simple endpoint to test the connection between frontend and backend
    """
    return Response({
        'status': 'success',
        'message': 'Backend connection successful',
        'timestamp': timezone.now()
    }, status=status.HTTP_200_OK)
