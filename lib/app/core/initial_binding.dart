import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meetingreminder/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/controllers/container_controller.dart';

import 'package:meetingreminder/controllers/meeting_counter_controller.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';

import 'package:meetingreminder/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Get.put<MeetScheduler>(MeetScheduler(), permanent: true);
      Get.put<NotificationService>(NotificationService(), permanent: true);

      // Initialize NotificationService first
      Get.put<ContainerController>(ContainerController(), permanent: true);

      // Initialize ContainerController

      // Initialize MeetingCounter
      Get.put<MeetingCounter>(MeetingCounter(), permanent: true);

      // Initialize BottomNavController
      Get.put<BottomNavController>(BottomNavController(), permanent: true);

      // Initialize TimePickerController last as it depends on other controllers
      final timePickerController = TimePickerController();
      Get.put<TimePickerController>(timePickerController, permanent: true);

      timePickerController.selectedDate.value = DateTime.now();
      timePickerController.formattedDate.value =
          DateFormat('MMM d, y').format(DateTime.now());

                                

    } catch (e) {
      print('Error in InitialBinding: $e');
      rethrow;
    }
  }
}
