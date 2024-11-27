import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/services/notification_service.dart';

class ContainerController extends GetxController {
  RxList<ContainerData> containerList = RxList<ContainerData>();
  RxList<ContainerData> todayMeetings = RxList<ContainerData>();
  final String boxName = 'containerBox';
  Box<ContainerData>? _box;
  late final NotificationService _notificationService;
  
  // Add selected date tracker
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initializeBox();
    _notificationService = Get.find<NotificationService>();
  }

  Future<void> initializeBox() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<ContainerData>(boxName);
      } else {
        _box = Hive.box<ContainerData>(boxName);
      }
      await loadContainerData();
    } catch (e) {
      print('Error initializing box: $e');
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
      if (_box == null) {
        await initializeBox();
      }
      await _box!.add(containerData);
      containerList.add(containerData);
      update();
      CustomSnackbar.showSuccess('Meeting saved successfully');
    } catch (e) {
      print("Error storing container data: $e");
      CustomSnackbar.showError('Error saving meeting');
    }
  }

  Future<void> loadContainerData() async {
    try {
      if (_box == null) {
        await initializeBox();
      }
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get valid meetings
      var meetings = _box!.values.where((meeting) {
        var meetingDate = DateTime(
          meeting.date.year,
          meeting.date.month,
          meeting.date.day,
        );
        return !meetingDate.isBefore(today);
      }).toList();

      // Update container list
      containerList.value = meetings;

      // Update today meetings
      todayMeetings.value = meetings.where((meeting) {
        var meetingDate = DateTime(
          meeting.date.year,
          meeting.date.month,
          meeting.date.day,
        );
        return meetingDate.isAtSameMomentAs(today);
      }).toList();

      // Clean up old meetings
      for (var i = _box!.length - 1; i >= 0; i--) {
        var meeting = _box!.getAt(i);
        if (meeting != null) {
          var meetingDate = DateTime(
            meeting.date.year,
            meeting.date.month,
            meeting.date.day,
          );
          if (meetingDate.isBefore(today)) {
            await _box!.deleteAt(i);
          }
        }
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> deleteContainerData(int index) async {
    try {
      // Get the meeting at the index
      final meeting = containerList[index];
      
      // Find the box index for this meeting
      int? boxIndex;
      for (var i = 0; i < _box!.length; i++) {
        final boxMeeting = _box!.getAt(i);
        if (boxMeeting != null && 
            boxMeeting.date == meeting.date && 
            boxMeeting.value1 == meeting.value1 && 
            boxMeeting.value2 == meeting.value2) {
          boxIndex = i;
          break;
        }
      }

      if (boxIndex != null) {
        await _box!.deleteAt(boxIndex);
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
    final today = DateTime(now.year, now.month, now.day);
    
    return containerList.where((meeting) {
      final meetingDate = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day
      );
      return meetingDate.isAtSameMomentAs(today);
    }).toList();
  }

  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
    if (date != null) {
      // Only scroll if a date is selected
      scrollToSelectedMeeting();
    }
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

  Future<void> addMinute(ContainerData meeting, String minute) async {
    try {
      if (_box == null) {
        await initializeBox();
      }

      if (meeting.minutes == null) {
        meeting.minutes = [];
      }
      
      meeting.minutes.add(minute);
      await meeting.save();
      
      // Force refresh lists
      await loadContainerData();
    } catch (e) {
      print('Error adding minute: $e');
    }
  }

  Future<void> deleteMinute(ContainerData meeting, int index) async {
    try {
      if (_box == null) {
        await initializeBox();
      }

      meeting.minutes.removeAt(index);
      await meeting.save();
      
      // Force refresh lists
      await loadContainerData();
    } catch (e) {
      print('Error deleting minute: $e');
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
    _box?.close();
    scrollController.dispose();
    super.onClose();
  }
}
