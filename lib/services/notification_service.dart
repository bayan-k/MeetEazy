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

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'meeting_reminder',
        'Meeting Reminders',
        description: 'Notifications for upcoming meetings',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      // Create the channel on Android
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Initialize notification settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize notification settings for iOS
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'meeting_reminder',
            actions: [
              DarwinNotificationAction.plain('view', 'View Meeting'),
              DarwinNotificationAction.plain('snooze', 'Snooze'),
            ],
            options: {
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
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
            critical: true,
          );
          
      print('Notification service initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing notifications: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    }
  }

  Future<void> scheduleMeetingNotification({
    required int id,
    required String title,
    required String description,
    required DateTime meetingTime,
  }) async {
    try {
      // Calculate notification time (10 minutes before meeting)
      final notificationTime = meetingTime.subtract(const Duration(minutes: 10));
      final now = DateTime.now();

      // Debug prints
      print('Current time: $now');
      print('Meeting time: $meetingTime');
      print('Scheduled notification time: $notificationTime');

      // Check if the notification time hasn't passed yet
      if (notificationTime.isAfter(now)) {
        // Convert to TZDateTime
        final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

        // Android notification details
        final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'meeting_reminder',
          'Meeting Reminders',
          channelDescription: 'Notifications for upcoming meetings',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          autoCancel: false,
          ongoing: true,
          styleInformation: BigTextStyleInformation(
            'Your meeting "$description" starts in 10 minutes!\n\nTime: ${_formatTime(meetingTime)}',
            htmlFormatBigText: true,
            contentTitle: 'Upcoming Meeting: $title',
            htmlFormatContentTitle: true,
          ),
        );

        // iOS notification details
        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        // Schedule the notification
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Upcoming Meeting: $title',
          'Your meeting "$description" starts in 10 minutes!\n\nTime: ${_formatTime(meetingTime)}',
          scheduledDate,
          NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );

        print('Successfully scheduled notification for $scheduledDate');
      } else {
        print('Cannot schedule notification: Time has already passed');
        print('Attempted schedule time was: $notificationTime');
      }
    } catch (e, stackTrace) {
      print('Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
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
      'meeting_reminder',
      'Meeting Reminders',
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
