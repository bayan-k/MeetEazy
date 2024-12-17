import 'package:get/get.dart';
import 'package:meetingreminder/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';

import 'package:meetingreminder/services/notification_service.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize ContainerController first as others might depend on it
    Get.put<ContainerController>(ContainerController(), permanent: true);

    // Then initialize other controllers
    Get.put<TimePickerController>(TimePickerController(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<BottomNavController>(BottomNavController(), permanent: true);
  }
}
