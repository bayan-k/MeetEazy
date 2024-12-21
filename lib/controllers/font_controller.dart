import 'package:get/get.dart';

class FontController extends GetxController {
  double baseScale = 1.0;
  double get fontScale => baseScale * Get.textScaleFactor;
}
