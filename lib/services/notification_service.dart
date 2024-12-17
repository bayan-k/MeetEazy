import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/timepicker_controller.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final MeetScheduler scheduler = Get.find<MeetScheduler>();

  // A list to store existing meeting times as pairs of DateTime

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // fetch local timezone
      // final String localTimeZone =
      //     await FlutterNativeTimezone.getLocalTimezone();

      final kolkata = tz.getLocation('Asia/Kolkata');
      print('Local Timezone: $kolkata'); // Debugging
      // Set local timezone
      tz.setLocalLocation(kolkata);

      // Request permission to schedule exact alarms (Android 12+)
      await requestExactAlarmsPermission();

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
      final InitializationSettings initializationSettings =
          InitializationSettings(
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

  // Request Exact Alarms Permission for Android 12+
  Future<void> requestExactAlarmsPermission() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Directly request exact alarm permission for Android 12+
      print('Requesting exact alarms permission...');
      await androidPlugin.requestExactAlarmsPermission();
      print('Exact alarms permission requested');
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    }
  }

  Future<void> scheduleMeetingNotification(
      {required int id,
      required String title,
      required String description,
      required DateTime meetingStartTime,
      required DateTime meetingEndTime}) async {
    // await requestExactAlarmsPermission();

    try {
      if (scheduler.isTimeSlotAvailable(meetingStartTime, meetingEndTime)) {
        scheduler.meetings
            .add({'start': meetingStartTime, 'end': meetingEndTime});
        print(
            'Meeting scheduled from ${meetingStartTime} to ${meetingEndTime}');

        final notificationTime = meetingStartTime;
        final now = DateTime.now();

        // Debug prints
        print('Current time: $now');
        print('Meeting time: $meetingStartTime');
        print('Scheduled notification time: $notificationTime');

        // Check if the notification time hasn't passed yet
        if (notificationTime.isAfter(now)) {
          // Convert to TZDateTime ensuring proper timezone

          final location = tz.getLocation('Asia/Kolkata');
          final scheduledDate = tz.TZDateTime(
            location,
            meetingStartTime.year,
            meetingStartTime.month,
            meetingStartTime.day,
            meetingStartTime.hour,
            meetingStartTime.minute,
          );
          print(location);

          print('Timezone: ${location.name}');
          print('Scheduled TZ time: $scheduledDate');

          // Android notification details
          final AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
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
            usesChronometer: true,
            chronometerCountDown: true,
            showWhen: true,
            when: meetingStartTime.millisecondsSinceEpoch,
            styleInformation: BigTextStyleInformation(
              'Your meeting "$description" starts in 10 minutes!\n\nTime: ${_formatTime(meetingStartTime)}',
              htmlFormatBigText: true,
              contentTitle: 'Upcoming Meeting: $title',
              htmlFormatContentTitle: true,
            ),
          );

          // iOS notification details
          const DarwinNotificationDetails iosDetails =
              DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          );

          // Schedule the notification
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'Upcoming Meeting: $title',
            'Your meeting "$description" starts in 10 minutes!\n\nTime: ${_formatTime(meetingStartTime)}',
            scheduledDate,
            NotificationDetails(android: androidDetails, iOS: iosDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );

          print('Successfully scheduled notification for $scheduledDate');
        } else {
          print('Cannot schedule notification: Time has already passed');
          print('Attempted schedule time was: $notificationTime');
        }
      } else {
        print('Error: Time slot overlaps with an existing meeting!');
      }
      // Calculate notification time (10 minutes before meeting)
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
