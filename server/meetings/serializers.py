from rest_framework import serializers
from .models import Meeting, MeetingAlarm, DeviceToken

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ['id', 'token', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']

class MeetingAlarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = MeetingAlarm
        fields = ['id', 'scheduled_time', 'is_triggered', 'created_at']
        read_only_fields = ['is_triggered', 'created_at']

class MeetingSerializer(serializers.ModelSerializer):
    alarms = MeetingAlarmSerializer(many=True, read_only=True)
    
    class Meta:
        model = Meeting
        fields = [
            'id', 'meeting_id', 'title', 'description', 'start_time',
            'notification_time', 'alarm_time', 'notification_sent',
            'alarm_triggered', 'created_at', 'updated_at', 'alarms'
        ]
        read_only_fields = ['created_at', 'updated_at', 'notification_sent', 'alarm_triggered']
