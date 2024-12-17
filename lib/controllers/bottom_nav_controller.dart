import 'package:get/get.dart';
import 'package:meetingreminder/app/routes/app_pages.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    if (selectedIndex.value == index) return; // Don't navigate if already on the page
    
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.offNamed(Routes.HOMEPAGE); // Use offNamed to prevent stack buildup
        break;
      case 1:
        Get.offNamed(Routes.TIMELINE); // Use offNamed to prevent stack buildup
        break;
      default:
        Get.offNamed(Routes.HOMEPAGE);
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with the correct index based on current route
    ever(selectedIndex, (index) {
      update(); // Ensure UI updates when index changes
    });
  }
}