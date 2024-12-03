import 'package:get/get.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/meeting_counter.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/timepicker_controller.dart';
import 'package:meetingreminder/controllers/meeting_controller.dart';
import 'package:meetingreminder/services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Controllers - Initialize First
    Get.put(MeetingController(), permanent: true);

    // Services - Initialize Second
    Get.put(NotificationService(), permanent: true);

    // Feature Controllers - Initialize Last
    Get.lazyPut<ContainerController>(
      () => ContainerController(),
      fenix: true,
    );

    Get.lazyPut<TimePickerController>(
      () => TimePickerController(),
      fenix: true,
    );

    Get.lazyPut<MeetingCounter>(
      () => MeetingCounter(),
      fenix: true,
    );

    Get.lazyPut<BottomNavController>(
      () => BottomNavController(),
      fenix: true,
    );
  }
}
