import 'package:get/get.dart';

class ResponsiveHelper {
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  //scale factors

  static double get widthScale => Get.width / baseWidth;
  static double get heightScale => Get.height / baseHeight;

  // Font size scaling

  static double fontSize(double size) => size * Get.textScaleFactor;

  // Spacing scaling (for padding/margin)

  static double spacing(double value) => value * widthScale;

  // Widget size scaling

  static double size(double value) => value * widthScale;

  // Example: Responsive radius

  static double radius(double value) => value * widthScale;
  

}
