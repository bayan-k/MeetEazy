import 'dart:convert';
import 'package:get/get.dart';
import 'package:meetingreminder/services/meeting_service.dart';
import 'package:meetingreminder/services/logging_service.dart';

class MeetingController extends GetxController {
  final MeetingService _meetingService = MeetingService();
  final LoggingService _logger = LoggingService();
  
  var meetings = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    try {
      isLoading(true);
      final result = await _meetingService.getMeetings();
      meetings.value = List<Map<String, dynamic>>.from(result);
      error.value = '';
    } catch (e) {
      error.value = 'Failed to fetch meetings: $e';
      _logger.error(error.value);
    } finally {
      isLoading(false);
    }
  }

  Future<void> createMeeting(Map<String, dynamic> meetingData) async {
    try {
      isLoading(true);
      await _meetingService.createMeeting(meetingData);
      await fetchMeetings(); // Refresh the list
      error.value = '';
    } catch (e) {
      error.value = 'Failed to create meeting: $e';
      _logger.error(error.value);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateMeeting(int meetingId, Map<String, dynamic> meetingData) async {
    try {
      isLoading(true);
      await _meetingService.updateMeeting(meetingId, meetingData);
      await fetchMeetings(); // Refresh the list
      error.value = '';
    } catch (e) {
      error.value = 'Failed to update meeting: $e';
      _logger.error(error.value);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteMeeting(int meetingId) async {
    try {
      isLoading(true);
      await _meetingService.deleteMeeting(meetingId);
      await fetchMeetings(); // Refresh the list
      error.value = '';
    } catch (e) {
      error.value = 'Failed to delete meeting: $e';
      _logger.error(error.value);
    } finally {
      isLoading(false);
    }
  }

  Future<void> scheduleMeeting({
    required String meetingId,
    required String title,
    required String body,
    required DateTime start_time,
    required String deviceToken,
  }) async {
    try {
      isLoading(true);
      await _meetingService.createMeeting({
        'meeting_id': meetingId,
        'title': title,
        'body': body,
        'start_time': start_time.toUtc().toIso8601String(),
        'device_token': deviceToken,
      });
      error.value = '';
    } catch (e) {
      error.value = 'Failed to schedule meeting: $e';
      _logger.error(error.value);
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> registerDeviceToken(String token) async {
    try {
      await _meetingService.subscribeToNotifications(token);
      error.value = '';
    } catch (e) {
      error.value = 'Failed to register device token: $e';
      _logger.error(error.value);
      rethrow;
    }
  }

  Future<void> cancelMeetingNotifications(String meetingId) async {
    try {
      await _meetingService.cancelMeetingNotifications(meetingId);
      error.value = '';
    } catch (e) {
      error.value = 'Failed to cancel notifications: $e';
      _logger.error(error.value);
      rethrow;
    }
  }
}
