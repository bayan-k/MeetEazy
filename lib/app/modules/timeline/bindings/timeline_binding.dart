import 'package:get/get.dart';
import 'package:meetingreminder/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/controllers/meeting_counter_controller.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';

import '../controllers/timeline_controller.dart';

class TimelineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimelineController>(
      () => TimelineController(),
    );

    // Reuse existing instances from homepage
    if (!Get.isRegistered<ContainerController>()) {
      Get.put<ContainerController>(ContainerController(), permanent: true);
    }
    
    if (!Get.isRegistered<BottomNavController>()) {
      Get.put<BottomNavController>(BottomNavController(), permanent: true);
    }
    
    if (!Get.isRegistered<MeetingCounter>()) {
      Get.put<MeetingCounter>(MeetingCounter(), permanent: true);
    }
    
    if (!Get.isRegistered<TimePickerController>()) {
      Get.put<TimePickerController>(TimePickerController(), permanent: true);
    }
  }
}
