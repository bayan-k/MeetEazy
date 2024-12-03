import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../controllers/meeting_controller.dart';

class NotificationService extends GetxService {
  final MeetingController _meetingController = Get.find<MeetingController>();
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        // Get FCM token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _meetingController.registerDeviceToken(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _meetingController.registerDeviceToken(newToken);
        });

        // Handle received messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
          }
        });
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  Future<void> scheduleNotification({
    required String meetingId,
    required String title,
    required String body,
    required DateTime start_time,
  }) async {
    String? token = await _messaging.getToken();
    if (token != null) {
      await _meetingController.scheduleMeeting(
        meetingId: meetingId,
        title: title,
        body: body,
        start_time: start_time,
        deviceToken: token,
      );
    }
  }

  Future<void> cancelNotification(String meetingId) async {
    await _meetingController.cancelMeetingNotifications(meetingId);
  }

  Future<void> cancelAllNotifications(String meetingId) async {
    await _meetingController.cancelMeetingNotifications(meetingId);
  }
}
