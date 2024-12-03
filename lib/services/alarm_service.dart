import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:meetingreminder/services/logging_service.dart';

class AlarmService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LoggingService _logger = LoggingService();
  final RxBool isPlaying = false.obs;
  
  Future<void> initialize() async {
    try {
      // Load alarm sound
      await _audioPlayer.setSource(AssetSource('sounds/alarm.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the alarm
      _logger.log('Alarm service initialized with sound file');
    } catch (e) {
      _logger.error('Failed to initialize alarm service: $e');
      rethrow;
    }
  }

  Future<void> playAlarm() async {
    try {
      await _audioPlayer.resume();
      isPlaying.value = true;
      _showAlarmDialog();
      _logger.log('Alarm started playing');
    } catch (e) {
      _logger.error('Error playing alarm: $e');
      rethrow;
    }
  }

  Future<void> stopAlarm() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close alarm dialog
      }
      _logger.log('Alarm stopped');
    } catch (e) {
      _logger.error('Error stopping alarm: $e');
      rethrow;
    }
  }

  void _showAlarmDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Meeting Time!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.alarm_on,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text('Your meeting is starting now'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: stopAlarm,
            child: const Text('Dismiss'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
// 
// error error error ...why are u not think ut of box ....what type of error it is pls use a sperate controller for this backend purpose