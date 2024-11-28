import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TextTimePicker extends StatefulWidget {
  final String initialTime;
  final Function(String) onTimeSelected;

  const TextTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TextTimePicker> createState() => _TextTimePickerState();
}

class _TextTimePickerState extends State<TextTimePicker> {
  late TextEditingController hourController;
  late TextEditingController minuteController;
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
        
        hourController = TextEditingController(text: hour.toString());
        minuteController = TextEditingController(text: minute.toString().padLeft(2, '0'));
        isPM = parts[1].toUpperCase() == 'PM';
      } else {
        final now = TimeOfDay.now();
        hourController = TextEditingController(
          text: (now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod).toString()
        );
        minuteController = TextEditingController(
          text: now.minute.toString().padLeft(2, '0')
        );
        isPM = now.period == DayPeriod.pm;
      }
    } catch (e) {
      // Default to current time if parsing fails
      final now = TimeOfDay.now();
      hourController = TextEditingController(
        text: (now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod).toString()
      );
      minuteController = TextEditingController(
        text: now.minute.toString().padLeft(2, '0')
      );
      isPM = now.period == DayPeriod.pm;
    }
  }

  String _formatTime() {
    final hour = hourController.text;
    final minute = minuteController.text.padLeft(2, '0');
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
                hourController.text = hour.toString();
                minuteController.text = minute.toString().padLeft(2, '0');
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
        SizedBox(
          width: 50,
          child: TextField(
            controller: hourController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                final hour = int.parse(value);
                if (hour < 1) hourController.text = '1';
                if (hour > 12) hourController.text = '12';
              }
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(':', style: TextStyle(fontSize: 20)),
        ),
        // Minute
        SizedBox(
          width: 50,
          child: TextField(
            controller: minuteController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                final minute = int.parse(value);
                if (minute > 59) minuteController.text = '59';
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        // AM/PM Toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => setState(() => isPM = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: !isPM ? const Color(0xFF9B4DCA) : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  child: Text(
                    'AM',
                    style: TextStyle(
                      color: !isPM ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => isPM = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPM ? const Color(0xFF9B4DCA) : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Text(
                    'PM',
                    style: TextStyle(
                      color: isPM ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
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

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }
}
