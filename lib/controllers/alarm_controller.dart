import 'package:get/get.dart';
import 'package:meetingreminder/services/alarm_service.dart';
import 'package:meetingreminder/services/meeting_service.dart';
import 'package:meetingreminder/services/logging_service.dart';

class AlarmController extends GetxController {
  final AlarmService _alarmService = Get.find<AlarmService>();
  final MeetingService _meetingService = MeetingService();
  final LoggingService _logger = LoggingService();

  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAlarmService();
  }

  Future<void> _initializeAlarmService() async {
    try {
      await _alarmService.initialize();
      _logger.log('Alarm service initialized successfully');
    } catch (e) {
      error.value = 'Failed to initialize alarm service: $e';
      _logger.error(error.value);
    }
  }

  Future<void> scheduleAlarm({
    required String meetingId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String deviceToken,
  }) async {
    try {
      isLoading(true);
      error.value = '';

      // Schedule the meeting notification on the backend
      await _meetingService.scheduleMeetingNotification({
        'meeting_id': meetingId,
        'title': title,
        'body': body,
        'scheduled_time': scheduledTime.toUtc().toIso8601String(),
        'device_token': deviceToken,
      });

      _logger.log('Alarm scheduled successfully for meeting: $meetingId');
    } catch (e) {
      error.value = 'Failed to schedule alarm: $e';
      _logger.error(error.value);
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelAlarm(String meetingId) async {
    try {
      isLoading(true);
      error.value = '';

      // Cancel the meeting notification on the backend
      await _meetingService.cancelMeetingNotifications(meetingId);
      
      // Stop any currently playing alarm
      if (_alarmService.isPlaying.value) {
        await _alarmService.stopAlarm();
      }

      _logger.log('Alarm cancelled successfully for meeting: $meetingId');
    } catch (e) {
      error.value = 'Failed to cancel alarm: $e';
      _logger.error(error.value);
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> triggerAlarm() async {
    try {
      error.value = '';
      await _alarmService.playAlarm();
      _logger.log('Alarm triggered successfully');
    } catch (e) {
      error.value = 'Failed to trigger alarm: $e';
      _logger.error(error.value);
    }
  }

  Future<void> stopAlarm() async {
    try {
      error.value = '';
      await _alarmService.stopAlarm();
      _logger.log('Alarm stopped successfully');
    } catch (e) {
      error.value = 'Failed to stop alarm: $e';
      _logger.error(error.value);
    }
  }
}
