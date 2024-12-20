import 'package:get/get.dart';
import 'package:meetingreminder/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';

import 'package:meetingreminder/services/notification_service.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    // Only find existing controllers, don't recreate them
    // Initialize ContainerController first as others might depend on it
    if (!Get.isRegistered<ContainerController>()) {
      Get.put<ContainerController>(ContainerController(), permanent: true);
    }

    if (!Get.isRegistered<TimePickerController>()) {
      Get.put<TimePickerController>(TimePickerController(), permanent: true);
    }
    // Then initialize other controllers

    if (!Get.isRegistered<NotificationService>()) {
      Get.put<NotificationService>(NotificationService(), permanent: true);
    }

    if (!Get.isRegistered<BottomNavController>()) {
      Get.put<BottomNavController>(BottomNavController(), permanent: true);
    }
  }
}
