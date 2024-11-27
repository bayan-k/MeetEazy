import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleTimePicker extends StatefulWidget {
  final String initialTime;
  final Function(String) onTimeSelected;

  const SimpleTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<SimpleTimePicker> createState() => _SimpleTimePickerState();
}

class _SimpleTimePickerState extends State<SimpleTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late bool isPM;
  final List<String> quickTimes = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
    '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _initializeTime();
  }

  void _initializeTime() {
    try {
      if (widget.initialTime.isNotEmpty) {
        final parts = widget.initialTime.split(' ');
        if (parts.length != 2) throw Exception('Invalid time format');
        
        final timeParts = parts[0].split(':');
        if (timeParts.length != 2) throw Exception('Invalid time format');
        
        final hour = int.parse(timeParts[0]);
        if (hour < 1 || hour > 12) throw Exception('Invalid hour');
        
        final minute = int.parse(timeParts[1]);
        if (minute < 0 || minute > 59) throw Exception('Invalid minute');
        
        selectedHour = hour == 12 ? 0 : hour;
        selectedMinute = minute;
        isPM = parts[1].toUpperCase() == 'PM';
      } else {
        final now = TimeOfDay.now();
        selectedHour = now.hourOfPeriod;
        selectedMinute = now.minute;
        isPM = now.period == DayPeriod.pm;
      }
    } catch (e) {
      // Default to current time if parsing fails
      final now = TimeOfDay.now();
      selectedHour = now.hourOfPeriod;
      selectedMinute = now.minute;
      isPM = now.period == DayPeriod.pm;
    }
  }

  String _formatTime() {
    final hour = selectedHour == 0 ? 12 : selectedHour;
    final minute = selectedMinute.toString().padLeft(2, '0');
    final period = isPM ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildQuickTimeButton(String time) {
    final isSelected = _formatTime() == time;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF9B4DCA) : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          try {
            final parts = time.split(' ');
            final timeParts = parts[0].split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            if (hour >= 1 && hour <= 12 && minute >= 0 && minute <= 59) {
              setState(() {
                selectedHour = hour == 12 ? 0 : hour;
                selectedMinute = minute;
                isPM = parts[1] == 'PM';
              });
            }
          } catch (e) {
            // Ignore invalid time format
          }
        },
        child: Text(time),
      ),
    );
  }

  Widget _buildTimeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour
        Container(
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedHour,
              items: List.generate(12, (i) => i).map((hour) {
                final displayHour = hour == 0 ? 12 : hour;
                return DropdownMenuItem(
                  value: hour,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(displayHour.toString()),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedHour = value;
                    widget.onTimeSelected(_formatTime());
                  });
                }
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        // Minute
        Container(
          width: 70,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedMinute - (selectedMinute % 5), // Round to nearest 5
              items: List.generate(12, (i) => i * 5).map((minute) {
                return DropdownMenuItem(
                  value: minute,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(minute.toString().padLeft(2, '0')),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMinute = value;
                    widget.onTimeSelected(_formatTime());
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // AM/PM
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: isPM,
              items: const [
                DropdownMenuItem(
                  value: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('AM'),
                  ),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('PM'),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    isPM = value;
                    widget.onTimeSelected(_formatTime());
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTimeInput(),
            const SizedBox(height: 24),
            const Text(
              'Quick Select',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: quickTimes.map(_buildQuickTimeButton).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B4DCA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    widget.onTimeSelected(_formatTime());
                    Get.back();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
