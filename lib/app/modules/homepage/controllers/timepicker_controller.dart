import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/services/notification_service.dart';
import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';
import 'package:meetingreminder/shared_widgets/simple_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/shared_widgets/delete_dialog.dart';

@pragma('vm:entry-point')
void alarmCallback() {
  print('Alarm fired!');
}

class TimePickerController extends GetxController {
  final startTime = ''.obs;
  final endTime = ''.obs;
  final remarks = ''.obs;
  final formattedDate = ''.obs;
  final selectedDate = DateTime.now().obs;
  final TextEditingController remarkController = TextEditingController();
  late final NotificationService _notificationService;
  late final ContainerController containerController;
  int meetingID = 0;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      containerController = Get.find<ContainerController>();
      _notificationService = Get.find<NotificationService>();
      await _initializeNotifications();
      formattedDate.value = DateFormat('MMM d, y').format(DateTime.now());
    } catch (e) {
      CustomSnackbar.showError("Error initializing: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await AndroidAlarmManager.initialize();
    } catch (e) {
      CustomSnackbar.showError("Error initializing notifications: $e");
    }
  }

  Future<void> meetingSetter(BuildContext context, bool isStartTime) async {
    try {
      final currentTime = isStartTime ? startTime.value : endTime.value;
      
      await showDialog(
        context: context,
        builder: (context) => SimpleTimePicker(
          initialTime: currentTime,
          onTimeSelected: (time) {
            if (isStartTime) {
              startTime.value = time;
            } else {
              endTime.value = time;
            }
          },
        ),
      );
    } catch (e) {
      CustomSnackbar.showError("Error setting time: $e");
    }
  }

  Future<void> dateSetter(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime.now(),
        lastDate: DateTime(2025),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.purple[400]!,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedDate.value = picked;
        formattedDate.value = DateFormat('MMM d, y').format(picked);
        update();
      }
    } catch (e) {
      CustomSnackbar.showError("Error setting date: $e");
    }
  }

  void storeMeetingData() {
    try {
      if (startTime.value.isEmpty || endTime.value.isEmpty) {
        CustomSnackbar.showError("Please select both start and end times");
        return;
      }

      // Get meeting type or use default with counter
      String meetingType = remarkController.text.trim();
      if (meetingType.isEmpty) {
        meetingType = 'Meeting on ${DateFormat('MMM dd').format(selectedDate.value)}';
      }

      // Parse the start time
      final DateTime meetingDateTime = _parseTimeToDateTime(startTime.value);

      // Store the meeting data
      containerController.storeContainerData(
        'Meeting Type',
        meetingType,
        'Start Time',
        startTime.value,
        'End Time',
        endTime.value,
        meetingDateTime,
        formattedDate.value.isEmpty 
            ? DateFormat('MMM d, y').format(selectedDate.value)
            : formattedDate.value,
      );

      _resetForm();
      CustomSnackbar.showSuccess("Meeting scheduled successfully");
      Get.back();
    } catch (e) {
      CustomSnackbar.showError("Error storing meeting: $e");
    }
  }

  Future<void> handleDelete(int index) async {
    try {
      final bool? confirm = await showDeleteDialog(Get.context!);
      if (confirm == true) {
        await containerController.deleteContainerData(index);
        CustomSnackbar.showSuccess("Meeting deleted successfully");
      }
    } catch (e) {
      CustomSnackbar.showError("Error deleting meeting: $e");
    }
  }

  DateTime _parseTimeToDateTime(String timeStr) {
    try {
      final timeParts = timeStr.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      final int minute = int.parse(hourMin[1]);
      final String period = timeParts[1].toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        hour,
        minute,
      );
    } catch (e) {
      throw Exception('Invalid time format: $timeStr');
    }
  }

  void _resetForm() {
    remarkController.clear();
    startTime.value = '';
    endTime.value = '';
    formattedDate.value = DateFormat('MMM d, y').format(DateTime.now());
    selectedDate.value = DateTime.now();
  }

  void clearTimes() {
    startTime.value = '';
    endTime.value = '';
    remarks.value = '';
    remarkController.clear();
    meetingID = 0;
  }

  void confirmTimes() {
    Get.back();
  }

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }
}