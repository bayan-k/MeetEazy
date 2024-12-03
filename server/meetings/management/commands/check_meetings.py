from django.core.management.base import BaseCommand
from django.utils import timezone
from meetings.models import Meeting, DeviceToken
from firebase_admin import messaging
import firebase_admin
import time
from datetime import datetime, timedelta

class Command(BaseCommand):
    help = 'Check for meetings and send notifications/alarms'
    
    def __init__(self):
        super().__init__()
        self.batch_size = 50  # Process 50 notifications at a time
        self.retry_delay = 60  # Wait 60 seconds between retries
        self.max_retries = 3

    def send_batch_notifications(self, messages, device_tokens, retry_count=0):
        try:
            if not firebase_admin._apps:
                firebase_admin.initialize_app()

            # Split into smaller batches
            for i in range(0, len(messages), self.batch_size):
                batch = messages[i:i + self.batch_size]
                
                # Send batch with retry logic
                try:
                    message = messaging.MulticastMessage(
                        tokens=list(device_tokens),
                        notification=messaging.Notification(
                            title=batch[0].get('title'),
                            body=batch[0].get('body')
                        ) if 'title' in batch[0] else None,
                        data=batch[0].get('data')
                    )
                    response = messaging.send_multicast(message)
                    self.stdout.write(f"Successfully sent {len(batch)} notifications")
                    
                except messaging.QuotaExceededError as e:
                    if retry_count < self.max_retries:
                        self.stdout.write(f"Rate limit exceeded. Waiting {self.retry_delay} seconds...")
                        time.sleep(self.retry_delay)
                        return self.send_batch_notifications(batch, device_tokens, retry_count + 1)
                    else:
                        self.stderr.write(f"Max retries exceeded for batch: {e}")
                
                # Add delay between batches to avoid rate limits
                time.sleep(1)
                
        except Exception as e:
            self.stderr.write(f"Error in send_batch_notifications: {e}")

    def handle(self, *args, **options):
        try:
            current_time = timezone.now()
            
            # Get all pending notifications and alarms
            pending_notifications = Meeting.objects.filter(
                notification_time__lte=current_time,
                notification_sent=False
            )[:self.batch_size]

            pending_alarms = Meeting.objects.filter(
                alarm_time__lte=current_time,
                alarm_triggered=False
            )[:self.batch_size]

            device_tokens = DeviceToken.objects.values_list('token', flat=True)
            if not device_tokens:
                self.stdout.write('No device tokens registered')
                return

            # Prepare notification messages
            notification_messages = [
                {
                    'title': f"Meeting Reminder: {meeting.title}",
                    'body': f"Meeting starts in 5 minutes: {meeting.description}"
                }
                for meeting in pending_notifications
            ]

            # Prepare alarm messages
            alarm_messages = [
                {
                    'data': {
                        'type': 'alarm',
                        'meeting_id': str(meeting.meeting_id),
                        'title': meeting.title
                    }
                }
                for meeting in pending_alarms
            ]

            # Send notifications with rate limiting
            if notification_messages:
                self.send_batch_notifications(notification_messages, device_tokens)
                # Mark as sent
                for meeting in pending_notifications:
                    meeting.notification_sent = True
                    meeting.save()

            # Send alarms with rate limiting
            if alarm_messages:
                self.send_batch_notifications(alarm_messages, device_tokens)
                # Mark as triggered
                for meeting in pending_alarms:
                    meeting.alarm_triggered = True
                    meeting.save()

        except Exception as e:
            self.stderr.write(f"Error in check_meetings command: {e}")
