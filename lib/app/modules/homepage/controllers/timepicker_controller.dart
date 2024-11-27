import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/meeting_counter.dart';
import 'package:meetingreminder/services/notification_service.dart';
import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

void alarmCallback() {
  print("Alarm Triggered!");
  // Optional: Show a notification here if you want to alert the user.
}

class TimePickerController extends GetxController {
  // Observables for start and end time
  TimeOfDay selectedTime = TimeOfDay.now();
  
  late final ContainerController containerController;
  late final MeetingCounter meetingCounter;
  late final NotificationService _notificationService;

  var startTime = ''.obs;
  var endTime = ''.obs;
  var remarks = ''.obs;
  int meetingID = 0;

  var meeting = <Map<String, String>>[].obs;
  var remarkController = TextEditingController().obs;
  var selectedDate = DateTime.now().obs;
  var formattedDate = ''.obs;

  Future<void> meetingSetter(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final String formattedTime = formatToAmPm(pickedTime);

      if (isStartTime) {
        startTime.value = formattedTime;
        DateTime now = DateTime.now();
        DateTime alarmTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // If the time is in the past, schedule for the next day
        if (alarmTime.isBefore(now)) {
          alarmTime = alarmTime.add(const Duration(days: 1));
        }

        // Set the alarm
        await AndroidAlarmManager.periodic(
          const Duration(days: 1),
          meetingID,
          alarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          startAt: alarmTime,
        );

        // Show notification
        await _notificationService.showNotification(
          id: meetingID,
          title: 'Meeting Reminder',
          body: 'You have a meeting at $formattedTime',
        );
      } else {
        endTime.value = formattedTime;
      }
    }
  }

  String formatToAmPm(TimeOfDay time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String period = hour < 12 ? 'AM' : 'PM';
    final String formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString();
    final String formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }

  Future<void> dateSetter(BuildContext context) async {
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
  }

  void storeMeetingData() {
    if (startTime.value.isEmpty || endTime.value.isEmpty) {
      CustomSnackbar.showError("Please select both start and end times");
      return;
    }

    // Get meeting type or use default with counter
    String meetingType = remarkController.value.text.trim();
    if (meetingType.isEmpty) {
      // Format the date as 'MMM -dd'
      meetingType = 'Meeting on ${DateFormat('MMM -dd').format(selectedDate.value)}';
    }

    // Parse the start time
    final startTimeParts = startTime.value.split(' ');
    final startHourMin = startTimeParts[0].split(':');
    int startHour = int.parse(startHourMin[0]);
    final int startMinute = int.parse(startHourMin[1]);
    if (startTimeParts[1] == 'PM' && startHour != 12) {
      startHour += 12;
    } else if (startTimeParts[1] == 'AM' && startHour == 12) {
      startHour = 0;
    }

    // Create DateTime with the correct time
    final meetingDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      startHour,
      startMinute,
    );

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

    remarkController.value.clear();
    startTime.value = '';
    endTime.value = '';
    formattedDate.value = DateFormat('MMM d, y').format(DateTime.now());
    selectedDate.value = DateTime.now();
    
    CustomSnackbar.showSuccess("Meeting scheduled successfully");
    Get.back();
  }

  void clearTimes() {
    startTime.value = '';
    endTime.value = '';
    remarks.value = '';
    meetingID = 0;
  }

  void confirmTimes() {
    Get.back(); // Close the dialog
  }

  // Function to handle meeting deletion
  Future<void> handleDelete(int index) async {
    try {
      await containerController.deleteContainerData(index);
      // Clear the current meeting data
      startTime.value = '';
      endTime.value = '';
      remarks.value = '';
      remarkController.value.clear();
      CustomSnackbar.showSuccess('Meeting deleted successfully');
    } catch (e) {
      CustomSnackbar.showError('Failed to delete meeting: ${e.toString()}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    containerController = Get.find<ContainerController>();
    meetingCounter = Get.find<MeetingCounter>();
    _notificationService = Get.find<NotificationService>();
    formattedDate.value = DateFormat('dd-MM-yyyy').format(selectedDate.value);
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }
}