import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class FirebaseNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isAlarmPlaying = false.obs;

  Future<FirebaseNotificationService> init() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channels
    await _createNotificationChannels();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Load alarm sound
    await _audioPlayer.setSource(AssetSource('sounds/alarm.mp3'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    return this;
  }

  Future<void> _createNotificationChannels() async {
    // Meeting reminder channel
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        'meeting_reminders',
        'Meeting Reminders',
        description: 'Notifications for meeting reminders',
        importance: Importance.high,
      ),
    );

    // Meeting alarm channel
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        'meeting_alarms',
        'Meeting Alarms',
        description: 'Alarms for meeting start times',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm'),
      ),
    );
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap
    if (response.payload == 'alarm') {
      stopAlarm();
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notificationType = message.data['type'];

    if (notificationType == 'alarm') {
      // Show alarm notification and play sound
      await _showAlarmNotification(message);
      await playAlarm();
    } else {
      // Show regular notification
      await _showRegularNotification(message);
    }
  }

  Future<void> _showRegularNotification(RemoteMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Meeting Reminder',
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meeting_reminders',
          'Meeting Reminders',
          channelDescription: 'Notifications for meeting reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
        ),
      ),
    );
  }

  Future<void> _showAlarmNotification(RemoteMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Meeting Time!',
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meeting_alarms',
          'Meeting Alarms',
          channelDescription: 'Alarms for meeting start times',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('alarm'),
          playSound: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
          sound: 'alarm.wav',
        ),
      ),
      payload: 'alarm',
    );
  }

  Future<void> playAlarm() async {
    try {
      await _audioPlayer.resume();
      isAlarmPlaying.value = true;
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  Future<void> stopAlarm() async {
    try {
      await _audioPlayer.stop();
      isAlarmPlaying.value = false;
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['type'] == 'alarm') {
    // Show alarm notification for background messages
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Meeting Time!',
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meeting_alarms',
          'Meeting Alarms',
          channelDescription: 'Alarms for meeting start times',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('alarm'),
          playSound: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
          sound: 'alarm.wav',
        ),
      ),
      payload: 'alarm',
    );
  }
}
