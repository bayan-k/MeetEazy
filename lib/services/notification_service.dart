import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Set local timezone
      final String timeZoneName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Initialize notification settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize notification settings for iOS with permission requests
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Combine platform-specific settings
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      // Request permissions for iOS
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Handle notification taps
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    }
  }

  // Schedule a meeting notification
  Future<void> scheduleMeetingNotification({
    required int id,
    required String title,
    required String description,
    required DateTime meetingTime,
  }) async {
    try {
      // Calculate notification time (30 minutes before meeting)
      final notificationTime = meetingTime.subtract(const Duration(minutes: 30));

      // Convert to TZDateTime
      final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

      // Check if the notification time hasn't passed yet
      if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
        // Android notification details with custom sound and full-screen intent
        final AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'meeting_channel',
          'Meeting Notifications',
          channelDescription: 'Notifications for upcoming meetings',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          enableLights: true,
          fullScreenIntent: true,
          styleInformation: BigTextStyleInformation(''),
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          category: AndroidNotificationCategory.alarm,
        );

        // iOS notification details with custom sound
        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.aiff',
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        // Combine platform-specific details
        NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        // Cancel any existing notification with the same ID
        await cancelNotification(id);

        // Schedule the notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Upcoming Meeting: $title',
          'Your meeting "$description" starts in 30 minutes!\n\nTime: ${_formatTime(meetingTime)}',
          scheduledDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        print('Notification scheduled for: ${scheduledDate.toString()}');
      } else {
        print('Notification time has already passed: ${scheduledDate.toString()}');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'meeting_channel',
      'Meeting Notifications',
      channelDescription: 'Channel for meeting notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
