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
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initializeBox();
    selectedDate = Rx<DateTime>(DateTime.now());
    scrollController = ScrollController();
    _notificationService = Get.find<NotificationService>();
    getMeetingCountMap();
    update();
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
      print(containerData);
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
        print(!meetingDate.isBefore(today));
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
      final meetingDate =
          DateTime(meeting.date.year, meeting.date.month, meeting.date.day);
      return meetingDate.isAtSameMomentAs(today);
    }).toList();
  }

  void setSelectedDate(DateTime? date) {
    try {
      Future.microtask(() {
        selectedDate.value = date ?? DateTime.now();
        if (date != null) {
          // Only scroll if a date is selected
          scrollToSelectedMeeting();
        }
        update();
      });
    } catch (e) {
      print('Error in setSelectedDate: $e');
    }
  }

  void scrollToSelectedMeeting() {
    if (containerList.isEmpty || selectedDate.value == null) return;

    final index = containerList
        .indexWhere((meeting) => isMeetingFromSelectedDate(meeting));

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

  Future<bool> isSlotAvailable(
      DateTime newStart, DateTime newEnd, DateTime selectedDate) async {
    // Ensure valid time range
    if (newStart.isAfter(newEnd) || newStart.isAtSameMomentAs(newEnd)) {
      // CustomSnackbar.showError('Invalid time range');
      return false;
    }
    await loadContainerData();

    // for (var meeting in containerList) {
    //   print('_________${meeting.date}________________________');
    // }
    // Ensure containerList is up-to-date if it depends on async operations

    if (_box == null) {
      print('Box is not initialized');
      return false;
    }
    // Check against existing meetings
    for (var meeting in containerList) {
      final existingDate = DateTime(
        meeting.date.year,
        meeting.date.month,
        meeting.date.day,
      );
      final newSelectedDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      print('__________________existingDate__{$existingDate}________________');
      print(
          '_________________selectedDate______$newSelectedDate.__________________');

      if (existingDate.isAtSameMomentAs(newSelectedDate)) {
        final existingStart =
            _parseTimeToDateTime(meeting.value2, meeting.date);
        final existingEnd = _parseTimeToDateTime(meeting.value3, meeting.date);
        printStartAndEndTimes();

        // meeting.value2;
        print('Checking overlap:');
        print('New: $newStart - $newEnd');
        print('Existing: $existingStart - $existingEnd');

        // Check for overlap
        if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart) ||
            newStart.isAtSameMomentAs(existingStart) ||
            newEnd.isAtSameMomentAs(existingEnd) ||
            newStart.isAtSameMomentAs(existingEnd) ||
            newEnd.isAtSameMomentAs(newStart)) {
          // CustomSnackbar.showError(
          //     'Time slot overlaps with an existing meeting');
          return false;
        }
      }
    }

    // Slot is available
    return true;
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

      // Update UI immediately
      update();

      // Refresh data in background
      loadContainerData();

      CustomSnackbar.showSuccess('Minute added successfully');
    } catch (e) {
      print('Error adding minute: $e');
      CustomSnackbar.showError('Failed to add minute');
    }
  }

  DateTime _parseTimeToDateTime(String timeStr, DateTime meetingDate) {
    try {
      final timeParts = timeStr.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      final int minute = int.parse(hourMin[1]);
      final String period = timeParts[1].toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        hour,
        minute,
      );
    } catch (e) {
      throw Exception('Invalid time format: $e');
    }
  }

  Future<void> deleteMinute(ContainerData meeting, int index) async {
    try {
      if (_box == null) {
        await initializeBox();
      }

      meeting.minutes.removeAt(index);
      await meeting.save();

      // Update UI immediately
      update();

      // Refresh data in background
      loadContainerData();

      CustomSnackbar.showSuccess('Minute deleted successfully');
    } catch (e) {
      print('Error deleting minute: $e');
      CustomSnackbar.showError('Failed to delete minute');
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

  void printStartAndEndTimes() {
    // Check if the container list is empty
    if (containerList.isEmpty) {
      print("No meetings available.");
      return;
    }

    // Iterate over the containerList and print start and end times
    final startEndTimes = containerList.map((meeting) {
      return {
        "startTime": meeting.value2,
        "endTime": meeting.value3,
      };
    }).toList();

    print("Start and End Times: $startEndTimes");
  }

  @override
  void onClose() {
    _box?.close();
    scrollController.dispose();
    super.onClose();
  }
}
