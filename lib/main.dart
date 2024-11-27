import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meetingreminder/app/core/initial_binding.dart';
import 'package:meetingreminder/app/routes/app_pages.dart';
import 'package:meetingreminder/models/container.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ContainerDataAdapter());
  }
  await Hive.openBox<ContainerData>('ContainerData');
  await Hive.openBox('settings');
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await AndroidAlarmManager.initialize();
    
    // Initialize Hive first
    await initHive();
    
    runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meeting Reminder',
        initialBinding: InitialBinding(),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  } catch (e) {
    print('Error during initialization: $e');
    rethrow;
  }
}
