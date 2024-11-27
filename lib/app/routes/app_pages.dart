import 'package:get/get.dart';

import '../modules/homepage/bindings/homepage_binding.dart';
import '../modules/homepage/views/homepage_view.dart';
import '../modules/timeline/bindings/timeline_binding.dart';
import '../modules/timeline/views/timeline_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static var INITIAL = Routes.HOMEPAGE;

  static final routes = [
    GetPage(
      name: _Paths.HOMEPAGE,
      page: () => const HomePageView(),
      binding: HomePageBinding()
    ),
    GetPage(
      name: _Paths.TIMELINE,
      page: () => TimelineView(),
      binding: TimelineBinding(),
    ),
  ];
}
