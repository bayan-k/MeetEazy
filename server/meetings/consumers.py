import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import Meeting, DeviceToken
from django.utils import timezone

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['device_id']
        self.room_group_name = f'notifications_{self.room_name}'

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()
        
        # Register device
        await self.register_device(self.room_name)

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message_type = text_data_json.get('type')
        
        if message_type == 'acknowledge':
            meeting_id = text_data_json.get('meeting_id')
            await self.handle_acknowledgment(meeting_id)

    async def notification(self, event):
        # Send notification to WebSocket
        await self.send(text_data=json.dumps({
            'type': 'notification',
            'title': event['title'],
            'body': event['body'],
            'meeting_id': event['meeting_id']
        }))

    async def alarm(self, event):
        # Send alarm to WebSocket
        await self.send(text_data=json.dumps({
            'type': 'alarm',
            'title': event['title'],
            'body': event['body'],
            'meeting_id': event['meeting_id']
        }))

    @database_sync_to_async
    def register_device(self, device_id):
        DeviceToken.objects.update_or_create(
            token=device_id,
            defaults={'last_used': timezone.now()}
        )

    @database_sync_to_async
    def handle_acknowledgment(self, meeting_id):
        try:
            meeting = Meeting.objects.get(meeting_id=meeting_id)
            meeting.notification_sent = True
            meeting.save()
        except Meeting.DoesNotExist:
            pass
