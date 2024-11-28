import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:meetingreminder/services/notification_service.dart';

class AlarmService extends GetxService {
  static AlarmService get to => Get.find();
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Track active alarms
  final RxMap<int, DateTime> _activeAlarms = <int, DateTime>{}.obs;
  
  // Getter for active alarms
  Map<int, DateTime> get activeAlarms => _activeAlarms;

  Future<void> initialize() async {
    try {
      final bool initialized = await AndroidAlarmManager.initialize();
      if (initialized) {
        print('Alarm Service initialized successfully');
      } else {
        print('Failed to initialize Alarm Service');
      }
    } catch (e) {
      print('Error initializing alarm service: $e');
      rethrow;
    }
  }

  Future<bool> scheduleAlarm({
    required int id,
    required DateTime alarmTime,
    required String title,
    required String description,
    bool isRecurring = false,
  }) async {
    try {
      // Validate alarm time
      final now = DateTime.now();
      var targetTime = DateTime(
        alarmTime.year,
        alarmTime.month,
        alarmTime.day,
        alarmTime.hour,
        alarmTime.minute,
      );
      
      // If the time has passed today and it's recurring, schedule for tomorrow
      if (targetTime.isBefore(now)) {
        if (isRecurring) {
          targetTime = targetTime.add(const Duration(days: 1));
        } else {
          print('Cannot schedule alarm for past time');
          return false;
        }
      }

      print('\n=== Scheduling Alarm ===');
      print('Alarm ID: $id');
      print('Alarm Time: $targetTime');
      print('Title: $title');
      print('Recurring: $isRecurring');
      
      final bool success = await AndroidAlarmManager.periodic(
        isRecurring ? const Duration(days: 1) : const Duration(days: 365),
        id,
        alarmCallback,
        params: {
          'title': title,
          'description': description,
          'id': id,
          'scheduledTime': targetTime.toIso8601String(),
          'isRecurring': isRecurring,
        },
        rescheduleOnReboot: true,
        wakeup: true,
        startAt: targetTime,
        allowWhileIdle: true,
      );

      if (success) {
        // Track the scheduled alarm
        _activeAlarms[id] = targetTime;
        print('Alarm scheduled successfully for ${targetTime.toString()}');
      } else {
        print('Failed to schedule alarm');
      }

      return success;
    } catch (e) {
      print('Error scheduling alarm: $e');
      return false;
    }
  }

  Future<void> cancelAlarm(int id) async {
    try {
      final bool cancelled = await AndroidAlarmManager.cancel(id);
      if (cancelled) {
        // Remove from active alarms
        _activeAlarms.remove(id);
        print('Alarm $id cancelled successfully');
      } else {
        print('Failed to cancel alarm $id');
      }
    } catch (e) {
      print('Error cancelling alarm: $e');
      rethrow;
    }
  }

  Future<void> cancelAllAlarms() async {
    try {
      for (final id in _activeAlarms.keys.toList()) {
        await cancelAlarm(id);
      }
      print('All alarms cancelled successfully');
    } catch (e) {
      print('Error cancelling all alarms: $e');
      rethrow;
    }
  }

  bool hasActiveAlarm(int id) => _activeAlarms.containsKey(id);
  
  DateTime? getAlarmTime(int id) => _activeAlarms[id];
}

@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
  try {
    print('Alarm triggered for meeting ID: $id');
    
    final scheduledTime = DateTime.parse(params['scheduledTime'] as String);
    final now = DateTime.now();
    final isRecurring = params['isRecurring'] as bool? ?? false;
    
    // For non-recurring alarms, check if it's still relevant and cancel if needed
    if (!isRecurring) {
      if (now.difference(scheduledTime).abs() > const Duration(minutes: 5)) {
        print('Skipping outdated non-recurring alarm');
        // Cancel the alarm since it's non-recurring
        final alarmService = Get.find<AlarmService>();
        await alarmService.cancelAlarm(id);
        return;
      }
    }
    
    // Play alarm sound
    await FlutterRingtonePlayer.playAlarm(
      looping: true,
      volume: 1.0,
      asAlarm: true,
    );

    // Show notification
    final notificationService = Get.find<NotificationService>();
    await notificationService.showNotification(
      id: id,
      title: params['title'] ?? 'Meeting Time!',
      body: params['description'] ?? 'Your meeting is starting now!',
    );

    // Stop alarm after 1 minute if not manually stopped
    await Future.delayed(const Duration(minutes: 1));
    await FlutterRingtonePlayer.stop();
  } catch (e) {
    print('Error in alarm callback: $e');
  }
}
