import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/models/container.dart';

import 'package:meetingreminder/shared_widgets/custom_snackbar.dart';

class MeetingDetailsPage extends StatefulWidget {
  final ContainerData meeting;

  const MeetingDetailsPage({Key? key, required this.meeting}) : super(key: key);

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final ContainerController containerController = Get.find<ContainerController>();
  final TextEditingController minuteController = TextEditingController();

  @override
  void dispose() {
    minuteController.dispose();
    super.dispose();
  }

  Future<void> _addMinute() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Meeting Minute'),
        content: TextField(
          controller: minuteController,
          decoration: const InputDecoration(
            hintText: 'Enter meeting minute...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (minuteController.text.trim().isNotEmpty) {
                await containerController.addMinute(
                  widget.meeting,
                  minuteController.text.trim(),
                );
                minuteController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        backgroundColor: Colors.purple[400],
      ),
      body: Obx(() {
        // Find the updated meeting data
        final updatedMeeting = containerController.containerList.firstWhere(
          (m) => m.date == widget.meeting.date && m.value1 == widget.meeting.value1,
          orElse: () => widget.meeting,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting Title
              Text(
                updatedMeeting.value1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Meeting Time
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.purple[400]),
                  const SizedBox(width: 8),
                  Text(
                    '${updatedMeeting.value2} - ${updatedMeeting.value3}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Agenda
              if (updatedMeeting.agenda.isNotEmpty) ...[
                const Text(
                  'Agenda',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    updatedMeeting.agenda,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Minutes Section
              if (updatedMeeting.minutes.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Meeting Minutes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B3A67),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: updatedMeeting.minutes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.purple[400]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              updatedMeeting.minutes[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2B3A67),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              // Minutes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Meeting Minutes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.purple[400]),
                    onPressed: _addMinute,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (updatedMeeting.minutes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No minutes added yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: updatedMeeting.minutes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(updatedMeeting.minutes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => containerController.deleteMinute(
                            updatedMeeting,
                            index,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
