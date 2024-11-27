import 'package:flutter/material.dart';
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
  
  // Add selected date tracker
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final ScrollController scrollController = ScrollController();

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

  void storeContainerData(ContainerData containerData) async {
    try {
      final box = await Hive.openBox<ContainerData>('containerBox');
      await box.add(containerData);
      containerList.add(containerData);
      update();
    } catch (e) {
      print("Error storing container data: $e");
    }
  }

  Future<void> loadContainerData() async {
    try {
      final loadedData = _box.values.toList();
      
      // Remove past meetings that are more than a day old
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      // Keep only future meetings and today's meetings
      final filteredData = loadedData.where((meeting) => 
        meeting.date.isAfter(yesterday)
      ).toList();
      
      // Delete past meetings from storage
      for (var i = 0; i < _box.length; i++) {
        final meeting = _box.getAt(i);
        if (meeting != null && meeting.date.isBefore(yesterday)) {
          await _box.deleteAt(i);
        }
      }
      
      // Sort meetings by date and time
      filteredData.sort((a, b) => a.date.compareTo(b.date));
      
      containerList.assignAll(filteredData);
      update();
    } catch (e) {
      print('Error loading data: $e');
      CustomSnackbar.showError('Failed to load meetings');
    }
  }

  Future<void> deleteContainerData(int index) async {
    try {
      // Get the meeting at the index
      final meeting = containerList[index];
      
      // Find the box index for this meeting
      int? boxIndex;
      for (var i = 0; i < _box.length; i++) {
        final boxMeeting = _box.getAt(i);
        if (boxMeeting != null && 
            boxMeeting.date == meeting.date && 
            boxMeeting.value1 == meeting.value1 && 
            boxMeeting.value2 == meeting.value2) {
          boxIndex = i;
          break;
        }
      }

      if (boxIndex != null) {
        await _box.deleteAt(boxIndex);
        await loadContainerData();
        update();
        CustomSnackbar.showSuccess('Meeting deleted successfully');
      } else {
        throw Exception('Meeting not found in storage');
      }
    } catch (e) {
      print('Error deleting data: $e');
      CustomSnackbar.showError('Failed to delete meeting: ${e.toString()}');
    }
  }

  List<ContainerData> getTodayMeetings() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return containerList.where((meeting) {
      return meeting.date.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
             meeting.date.isBefore(endOfDay.add(const Duration(minutes: 1)));
    }).toList();
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
    update();
  }

  void scrollToSelectedMeeting() {
    if (containerList.isEmpty || selectedDate.value == null) return;

    final index = containerList.indexWhere(
      (meeting) => isMeetingFromSelectedDate(meeting)
    );
    
    if (index != -1) {
      final position = index * 172.0;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<ContainerData> getSelectedDateMeetings() {
    if (selectedDate.value == null) return [];
    return containerList.where((meeting) {
      return meeting.date.year == selectedDate.value!.year &&
             meeting.date.month == selectedDate.value!.month &&
             meeting.date.day == selectedDate.value!.day;
    }).toList();
  }

  bool isMeetingFromSelectedDate(ContainerData meeting) {
    if (selectedDate.value == null) return false;
    return meeting.date.year == selectedDate.value!.year &&
           meeting.date.month == selectedDate.value!.month &&
           meeting.date.day == selectedDate.value!.day;
  }

  Future<void> addMinute(ContainerData containerData, String minute) async {
    try {
      containerData.minutes.add(minute);
      await containerData.save();
      update();
      CustomSnackbar.showSuccess('Minute added successfully');
    } catch (e) {
      print("Error adding minute: $e");
      CustomSnackbar.showError('Error adding minute');
    }
  }

  Future<void> deleteMinute(ContainerData containerData, int index) async {
    try {
      containerData.minutes.removeAt(index);
      await containerData.save();
      update();
      CustomSnackbar.showSuccess('Minute deleted successfully');
    } catch (e) {
      print("Error deleting minute: $e");
      CustomSnackbar.showError('Error deleting minute');
    }
  }

  Future<void> updateAgenda(ContainerData meeting, String newAgenda) async {
    try {
      final index = containerList.indexOf(meeting);
      if (index != -1) {
        meeting.agenda = newAgenda;
        await meeting.save();
        update();
        CustomSnackbar.showSuccess('Agenda updated successfully');
      }
    } catch (e) {
      print('Error updating agenda: $e');
      CustomSnackbar.showError('Failed to update agenda');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
