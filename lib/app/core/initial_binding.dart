import 'package:get/get.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/meeting_counter.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/timepicker_controller.dart';
import 'package:meetingreminder/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Initialize NotificationService first
      Get.put<NotificationService>(NotificationService(), permanent: true);
      
      // Initialize ContainerController
      Get.put<ContainerController>(ContainerController(), permanent: true);
      
      // Initialize MeetingCounter
      Get.put<MeetingCounter>(MeetingCounter(), permanent: true);
      
      // Initialize BottomNavController
      Get.put<BottomNavController>(BottomNavController(), permanent: true);
      
      // Initialize TimePickerController last as it depends on other controllers
      Get.put<TimePickerController>(TimePickerController(), permanent: true);
    } catch (e) {
      print('Error in InitialBinding: $e');
      rethrow;
    }
  }
}
