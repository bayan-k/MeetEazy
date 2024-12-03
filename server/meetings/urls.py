from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    MeetingViewSet,
    DeviceTokenView,
    schedule_meeting_notification,
    cancel_meeting_notification,
    test_connection,
)

router = DefaultRouter()
router.register(r'meetings', MeetingViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('schedule/', schedule_meeting_notification, name='schedule-meeting'),
    path('cancel/', cancel_meeting_notification, name='cancel-meeting'),
    path('device-tokens/', DeviceTokenView.as_view(), name='device-token'),
    path('test-connection/', test_connection, name='test_connection'),
]
