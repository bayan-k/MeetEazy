import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';


class MeetingSetterBox extends StatefulWidget {
  const MeetingSetterBox({Key? key}) : super(key: key);

  @override
  State<MeetingSetterBox> createState() => _MeetingSetterBoxState();
}

class _MeetingSetterBoxState extends State<MeetingSetterBox> {
  final timePickerController = Get.find<TimePickerController>();
  final TextEditingController agendaController = TextEditingController();
  final RxList<String> minutes = <String>[].obs;
  

  void _showMinutesDialog() {
    final TextEditingController minuteController = TextEditingController();
    
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
                        minutes.add(minuteController.text.trim());
                        minuteController.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    minutes.add(value.trim());
                    minuteController.clear();
                  }
                },
              ),
              const SizedBox(height: 16),
              Obx(() => minutes.isEmpty
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
                            onPressed: () => minutes.removeAt(index),
                          ),
                        );
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    agendaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event, color: Color(0xFF9B4DCA), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Meeting',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3A67),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Meeting Type Input
              const Text(
                'Meeting Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3A67),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timePickerController.remarkController,
                decoration: InputDecoration(
                  hintText: 'Meeting Type (Optional)',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFF4E3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB347),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFB347),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF9B4DCA),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Agenda TextField
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: agendaController,
                  decoration: InputDecoration(
                    labelText: 'Meeting Agenda (Optional)',
                    hintText: 'Enter meeting agenda...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24),

              // Date Selection
              const Text(
                'Meeting Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3A67),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => timePickerController.dateSetter(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF9B4DCA).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF9B4DCA), size: 20),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        timePickerController.formattedDate.value.isEmpty
                            ? 'Select date'
                            : timePickerController.formattedDate.value,
                        style: const TextStyle(
                          color: Color(0xFF9B4DCA),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B3A67),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => timePickerController.meetingSetter(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF9B4DCA).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Color(0xFF9B4DCA), size: 20),
                                const SizedBox(width: 8),
                                Obx(() => Text(
                                  timePickerController.startTime.value.isEmpty
                                      ? 'Select time'
                                      : timePickerController.startTime.value,
                                  style: const TextStyle(
                                    color: Color(0xFF9B4DCA),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B3A67),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => timePickerController.meetingSetter(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5E5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF9B4DCA).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: Color(0xFF9B4DCA), size: 20),
                                const SizedBox(width: 8),
                                Obx(() => Text(
                                  timePickerController.endTime.value.isEmpty
                                      ? 'Select time'
                                      : timePickerController.endTime.value,
                                  style: const TextStyle(
                                    color: Color(0xFF9B4DCA),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _showMinutesDialog,
                icon: const Icon(Icons.list_alt),
                label: const Text('Add Meeting Minutes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9B4DCA),
                  side: const BorderSide(color: Color(0xFF9B4DCA)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => minutes.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '${minutes.length} minute${minutes.length == 1 ? '' : 's'} added',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox()),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      timePickerController.clearTimes();
                      Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B4DCA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      timePickerController.storeMeetingData(
                        agendaController.text.trim(),
                        minutes.toList(),
                      );
                    },
                    child: const Text(
                      'Save Meeting',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
