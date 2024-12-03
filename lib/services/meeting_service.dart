import 'package:meetingreminder/services/api_service.dart';
import 'package:meetingreminder/services/logging_service.dart';

class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final ApiService _apiService = ApiService();
  final LoggingService _logger = LoggingService();

  // Get all meetings
  Future<List<dynamic>> getMeetings() async {
    try {
      final response = await _apiService.get('/api/meetings/');
      return response as List<dynamic>;
    } catch (e) {
      _logger.error('Failed to get meetings: $e');
      rethrow;
    }
  }

  // Create a new meeting
  Future<Map<String, dynamic>> createMeeting(Map<String, dynamic> meetingData) async {
    try {
      final response = await _apiService.post(
        '/api/meetings/',
        meetingData,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Failed to create meeting: $e');
      rethrow;
    }
  }

  // Update a meeting
  Future<Map<String, dynamic>> updateMeeting(int meetingId, Map<String, dynamic> meetingData) async {
    try {
      final response = await _apiService.put(
        '/api/meetings/$meetingId/',
        meetingData,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Failed to update meeting: $e');
      rethrow;
    }
  }

  // Delete a meeting
  Future<void> deleteMeeting(int meetingId) async {
    try {
      await _apiService.delete('/api/meetings/$meetingId/');
    } catch (e) {
      _logger.error('Failed to delete meeting: $e');
      rethrow;
    }
  }

  // Schedule meeting notification
  Future<void> scheduleMeetingNotification(Map<String, dynamic> notificationData) async {
    try {
      await _apiService.post('/api/schedule/', notificationData);
    } catch (e) {
      _logger.error('Failed to schedule notification: $e');
      rethrow;
    }
  }

  // Cancel meeting notifications
  Future<void> cancelMeetingNotifications(String meetingId) async {
    try {
      await _apiService.delete('/api/cancel/$meetingId/');
    } catch (e) {
      _logger.error('Failed to cancel notifications: $e');
      rethrow;
    }
  }

  // Register device token
  Future<void> subscribeToNotifications(String token) async {
    try {
      await _apiService.post('/api/device-tokens/', {'token': token});
    } catch (e) {
      _logger.error('Failed to register device token: $e');
      rethrow;
    }
  }
}
