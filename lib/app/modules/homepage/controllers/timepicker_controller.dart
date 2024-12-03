import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/services/notification_service.dart';
import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';
import 'package:meetingreminder/shared_widgets/text_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/shared_widgets/delete_dialog.dart';

@pragma('vm:entry-point')
// void alarmCallback() async {
//   try {
//     // Initialize notifications if needed
//     final notificationService = NotificationService();
//     await notificationService.initialize();
    
//     // Show the notification
//     await notificationService.showNotification(
//       id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title: "Meeting Reminder",
//       body: "Your meeting starts in 10 minutes!",
//     );
    
//     print('Alarm callback executed successfully');
//   } catch (e) {
//     print('Error in alarm callback: $e');
//   }
// }

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
        builder: (context) => TextTimePicker(
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

  void storeMeetingData(String agenda, List<String> meetingMinutes) {
    try {
      if (startTime.value.isEmpty || endTime.value.isEmpty) {
        CustomSnackbar.showError("Please select both start and end times");
        return;
      }

      // Parse the time string (e.g., "7:34 PM") into hours and minutes
      final startTimeParts = startTime.value.split(' ');
      final timeParts = startTimeParts[0].split(':');
      var hours = int.parse(timeParts[0]);
      final timeMinutes = int.parse(timeParts[1]);
      
      // Convert to 24-hour format if PM
      if (startTimeParts[1] == 'PM' && hours != 12) {
        hours += 12;
      }
      // Handle 12 AM special case
      if (startTimeParts[1] == 'AM' && hours == 12) {
        hours = 0;
      }

      // Create a new DateTime combining the selected date and time
      final meetingDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        hours,
        timeMinutes,
      );

      print('📅 Time Analysis:');
      print('1️⃣ Selected Time: ${startTime.value}');
      print('2️⃣ Parsed Hours: $hours');
      print('3️⃣ Parsed Minutes: $timeMinutes');
      print('4️⃣ Final DateTime: $meetingDateTime');

      final containerData = ContainerData(
        key1: "Meeting Type",
        value1: remarkController.text.isEmpty ? "General Meeting" : remarkController.text,
        key2: "Start Time",
        value2: startTime.value,
        key3: "End Time",
        value3: endTime.value,
        date: meetingDateTime,
        formattedDate: formattedDate.value,
        agenda: agenda,
        minutes: meetingMinutes,
      );

      containerController.storeContainerData(containerData);

      // // Show immediate notification
      // _notificationService.showNotification(
      //   id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      //   title: "Meeting Scheduled",
      //   body: "You will be notified 10 minutes before your meeting '${containerData.value1}' at ${startTime.value}",
      // );

      // // Schedule notification for 10 minutes before meeting
      // final meetingTime = _parseTimeToDateTime(startTime.value);
      // _notificationService.scheduleMeetingNotification(
      //   id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1, // Different ID for scheduled notification
      //   title: containerData.value1,
      //   description: agenda.isNotEmpty ? agenda : 'No agenda set',
      //   meetingTime: meetingTime,
      // );

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