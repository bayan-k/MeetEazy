import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/services/notification_service.dart';

class ContainerController extends GetxController {
  var containerList = <ContainerData>[].obs;
  final String boxName = 'ContainerData';
  late Box<ContainerData> _box;
  late final NotificationService _notificationService;

  @override
  void onInit() {
    super.onInit();
    _initBox();
    _notificationService = Get.find<NotificationService>();
  }

  Future<void> _initBox() async {
    try {
      _box = Hive.box<ContainerData>(boxName);
      await loadContainerData();
    } catch (e) {
      print('Error initializing box: $e');
      CustomSnackbar.showError('Error initializing data storage');
    }
  }

  int getMeetingCountForDate(DateTime date) {
    return containerList.where((meeting) {
      return meeting.date.year == date.year &&
             meeting.date.month == date.month &&
             meeting.date.day == date.day;
    }).length;
  }

  Map<DateTime, int> getMeetingCountMap() {
    final countMap = <DateTime, int>{};
    for (var meeting in containerList) {
      final date = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
      );
      countMap[date] = (countMap[date] ?? 0) + 1;
    }
    return countMap;
  }

  Future<void> storeContainerData(
    String key1,
    String value1,
    String key2,
    String value2,
    String key3,
    String value3,
    DateTime date,
    String formattedDate,
  ) async {
    try {
      // Create the container data
      final containerData = ContainerData(
        key1: key1,
        value1: value1,
        key2: key2,
        value2: value2,
        key3: key3,
        value3: value3,
        date: date,
        formattedDate: formattedDate,
      );

      // Add to Hive box
      final int key = await _box.add(containerData);
      await loadContainerData();

      // Parse the time strings to create proper DateTime
      final timeStrings = [value2, value3]; // Start and end times
      final startTimeStr = value2;
      
      // Parse time string (assuming format like "2:30 PM")
      final timeParts = startTimeStr.split(' ');
      final time = timeParts[0].split(':');
      int hours = int.parse(time[0]);
      final minutes = int.parse(time[1]);
      final isPM = timeParts[1].toUpperCase() == 'PM';

      // Convert to 24-hour format
      if (isPM && hours != 12) {
        hours += 12;
      } else if (!isPM && hours == 12) {
        hours = 0;
      }

      // Create DateTime with the correct time
      final meetingDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hours,
        minutes,
      );

      // Schedule notification
      await _notificationService.scheduleMeetingNotification(
        id: key,  // Using Hive object key as notification ID
        title: value1,
        description: "Meeting at ${value2}",
        meetingTime: meetingDateTime,
      );

      update();
      CustomSnackbar.showSuccess('Meeting added successfully');
      
      // Show immediate confirmation
      await _notificationService.showNotification(
        id: -key, // Use negative key to avoid conflict with scheduled notification
        title: 'Meeting Scheduled',
        body: 'You will be notified 30 minutes before the meeting at ${value2}',
      );
    } catch (e) {
      print('Error storing container data: $e');
      CustomSnackbar.showError('Error adding meeting');
    }
  }

  Future<void> loadContainerData() async {
    try {
      final loadedData = _box.values.toList();
      
      // Sort meetings by date and time
      loadedData.sort((a, b) => a.date.compareTo(b.date));
      
      containerList.assignAll(loadedData); // Use assignAll instead of value
      update(); // Force UI update
    } catch (e) {
      print('Error loading data: $e');
      CustomSnackbar.showError('Failed to load meetings');
    }
  }

  Future<void> deleteContainerData(int index) async {
    try {
      await _box.deleteAt(index);
      await loadContainerData();
      update(); // Force UI update
      CustomSnackbar.showSuccess('Meeting deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
      CustomSnackbar.showError('Failed to delete meeting: ${e.toString()}');
    }
  }

  List<ContainerData> getTodayMeetings() {
    final now = DateTime.now();
    return containerList.where((meeting) {
      return meeting.date.year == now.year &&
             meeting.date.month == now.month &&
             meeting.date.day == now.day;
    }).toList();
  }

  @override
  void onClose() {
    // Don't cancel all notifications when controller closes
    // Only cancel when explicitly requested
    _box.close();
    super.onClose();
  }
}
