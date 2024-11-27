import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/shared_widgets/delete_dialog.dart';

Widget buildContainer(BuildContext context) {
  final ContainerController containerController = Get.find<ContainerController>();

  Future<void> handleDelete(ContainerData meeting) async {
    final bool? confirm = await showDeleteDialog(context);
    if (confirm == true) {
      // Find the actual index in the full list
      final index = containerController.containerList.indexOf(meeting);
      if (index != -1) {
        await containerController.deleteContainerData(index);
      }
    }
  }

  return Positioned(
    bottom: 70,
    left: 30,
    child: SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width - 60,
      child: Obx(() {
        // Get only today's meetings
        final todayMeetings = containerController.getTodayMeetings();
        
        if (todayMeetings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No meetings today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: containerController.scrollController,
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          itemCount: todayMeetings.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final meeting = todayMeetings[index];
            return Container(
              height: 240,
              width: 200,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () => handleDelete(meeting),
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -8,
                        top: -8,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[300],
                            size: 20,
                          ),
                          onPressed: () => handleDelete(meeting),
                          splashRadius: 24,
                          tooltip: 'Delete Meeting',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.event_note,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    meeting.value1,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Time: ${meeting.value2}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'End Time: ${meeting.value3}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  meeting.formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    ),
  );
}
