from django.db import models
from django.utils import timezone
import uuid

# Create your models here.

class DeviceToken(models.Model):
    token = models.CharField(max_length=500, unique=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.token

class Meeting(models.Model):
    meeting_id = models.CharField(max_length=100)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_time = models.DateTimeField()
    notification_time = models.DateTimeField(null=True, blank=True)  # Made nullable
    alarm_time = models.DateTimeField(null=True, blank=True)  # Made nullable
    notification_sent = models.BooleanField(default=False)
    alarm_triggered = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        # Auto-set notification and alarm times if not provided
        if self.start_time and not self.notification_time:
            self.notification_time = self.start_time - timezone.timedelta(minutes=5)
        if self.start_time and not self.alarm_time:
            self.alarm_time = self.start_time
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.title} ({self.meeting_id})"

    class Meta:
        ordering = ['start_time']

class MeetingAlarm(models.Model):
    meeting = models.ForeignKey(Meeting, on_delete=models.CASCADE, related_name='alarms')
    scheduled_time = models.DateTimeField()
    is_triggered = models.BooleanField(default=False)
    is_sent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Alarm for {self.meeting.title}"
