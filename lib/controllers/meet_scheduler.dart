import 'package:get/get.dart';

class MeetScheduler extends GetxController {
  final List<Map<String, DateTime>> meetings = [];

  // Function to check for overlapping meetings
  bool isTimeSlotAvailable(DateTime newStart, DateTime newEnd) {
    for (var meeting in meetings) {
      DateTime existingStart = meeting['start']!;
      DateTime existingEnd = meeting['end']!;

      // Check for overlap condition
      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        return false; // Overlap found
      }
    }
    return true; // No overlap
  }
}
