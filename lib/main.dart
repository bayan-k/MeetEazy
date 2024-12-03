import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:meetingreminder/app/core/initial_binding.dart';
import 'package:meetingreminder/app/routes/app_pages.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meetingreminder/services/api_service.dart';
import 'package:meetingreminder/services/logging_service.dart';

// Define top-level notification channel
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'meeting_alarms',
  'Meeting Alarms',
  description: 'Alarms for meeting start times',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// Create top-level notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAOP58Qk_kmRkG4PfuPKmwc-0DMkQC7ksE',
      appId: '1:27802718704:android:6bebc1fff5a6936e760d35',
      messagingSenderId: '27802718704',
      projectId: 'meeteazy-8a592',
      storageBucket: 'meeteazy-8a592.firebasestorage.app',
    ),
  );
  
  if (message.data['type'] == 'alarm') {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Meeting Time!',
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meeting_alarms',
          'Meeting Alarms',
          channelDescription: 'Alarms for meeting start times',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('alarm'),
          playSound: true,
          ongoing: true,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentBadge: true,
          presentAlert: true,
          sound: 'alarm.wav',
        ),
      ),
      payload: 'alarm',
    );
  }
}

Future<void> initHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ContainerDataAdapter());
  }
}

Future<void> initNotifications() async {
  // Create the notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize local notifications
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    ),
  );

  // Request iOS permissions
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

Future<void> testBackendConnection() async {
  final apiService = ApiService();
  final logger = LoggingService();
  
  try {
    final isConnected = await apiService.testConnection();
    if (isConnected) {
      logger.log('✅ Successfully connected to backend server');
    } else {
      logger.error('❌ Failed to connect to backend server');
    }
  } catch (e) {
    logger.error('❌ Error testing backend connection: $e');
  }
}

void main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');

    // Initialize Firebase with explicit options
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAOP58Qk_kmRkG4PfuPKmwc-0DMkQC7ksE',
        appId: '1:27802718704:android:6bebc1fff5a6936e760d35',
        messagingSenderId: '27802718704',
        projectId: 'meeteazy-8a592',
        storageBucket: 'meeteazy-8a592.firebasestorage.app',
      ),
    );
    print('Firebase initialized successfully');

    // Test backend connection
    await testBackendConnection();

    // Set the background message handler
    print('Setting up Firebase Messaging...');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('Background message handler set');

    // Initialize notifications
    print('Initializing notifications...');
    await initNotifications();
    print('Notifications initialized');

    // Initialize other services
    print('Initializing Android Alarm Manager...');
    await AndroidAlarmManager.initialize();
    print('Android Alarm Manager initialized');

    print('Initializing Hive...');
    await initHive();
    print('Hive initialized');

    print('Starting app...');
    runApp(
      GetMaterialApp(
        title: "MeeetEazy",
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  } catch (e, stackTrace) {
    print('Error in main: $e');
    print('Stack trace: $stackTrace');
  }
}
