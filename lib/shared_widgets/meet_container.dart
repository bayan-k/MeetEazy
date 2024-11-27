import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/shared_widgets/delete_dialog.dart';
import 'package:meetingreminder/app/modules/meeting_details/views/meeting_details_page.dart';

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

  void _showMinutesDialog(BuildContext context, ContainerData containerData) {
    final TextEditingController minuteController = TextEditingController();
    final containerController = Get.find<ContainerController>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meeting Minutes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3A67),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minuteController,
                decoration: InputDecoration(
                  hintText: 'Enter minute point...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (minuteController.text.trim().isNotEmpty) {
                        containerController.addMinute(containerData, minuteController.text.trim());
                        minuteController.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    containerController.addMinute(containerData, value.trim());
                    minuteController.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
              Obx(() {
                final minutes = containerData.minutes;
                return minutes.isEmpty
                    ? Center(
                        child: Text(
                          'No minutes added yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: minutes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.circle, size: 8, color: Colors.purple[400]),
                            title: Text(minutes[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => containerController.deleteMinute(containerData, index),
                            ),
                          );
                        },
                      );
              }),
            ],
          ),
        ),
      ),
    );
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
            return GestureDetector(
              onTap: () => Get.to(() => MeetingDetailsPage(meeting: meeting)),
              child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meeting.value1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B3A67),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red[300],
                            size: 20,
                          ),
                          onPressed: () => handleDelete(meeting),
                          splashRadius: 24,
                          tooltip: 'Delete Meeting',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Time Details
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeRow(
                                Icons.access_time,
                                'Start: ${meeting.value2}',
                              ),
                              const SizedBox(height: 4),
                              _buildTimeRow(
                                Icons.access_time_filled,
                                'End: ${meeting.value3}',
                              ),
                            ],
                          ),
                        ),
                        // Add Minutes Button
                        IconButton(
                          onPressed: () => _showMinutesDialog(context, meeting),
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.note_add,
                                color: Color(0xFF9B4DCA),
                              ),
                              if (meeting.minutes.isNotEmpty)
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF9B4DCA),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      meeting.minutes.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (meeting.agenda.isNotEmpty) ...[
                      const Text(
                        'Agenda:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meeting.agenda,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${meeting.minutes.length} minutes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Tap to view details',
                          style: TextStyle(
                            color: Colors.purple[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    ),
  );
}

Widget _buildTimeRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, color: Colors.purple[400], size: 20),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
