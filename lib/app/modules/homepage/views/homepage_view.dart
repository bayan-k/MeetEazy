import 'package:flutter/material.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/timepicker_controller.dart';
import 'package:meetingreminder/models/container.dart';
import 'package:meetingreminder/shared_widgets/meeting_setter_box.dart';
import 'package:meetingreminder/shared_widgets/confirm_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';  // Add this import for HapticFeedback
import 'dart:math' show pi, sin;  // Add this import for math functions

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final Rx<DateTime> _focusedDay = Rx<DateTime>(DateTime.now());
  DateTime? _selectedDay;
  final BottomNavController controller = Get.find<BottomNavController>();
  final TimePickerController timePickerController = Get.find<TimePickerController>();
  final ContainerController containerController = Get.find<ContainerController>();

  TextEditingController controller1 = TextEditingController();
  List<String> imageItems = [
    'assets/images/icons/home-page.png',
    'assets/images/icons/clock(1).png',
  ];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    // Reset selected date when homepage is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerController.selectedDate.value = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE5E5),  // Light pink
                  Color(0xFFFFF0F3),  // Soft rose
                  Color(0xFFFFF4E3),  // Warm cream
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting Planner',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B4DCA),  // Bright purple
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFF6B6B),  // Vibrant coral red
                            ),
                          ),
                        ],
                      ),
                      // Month Picker
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFB347).withOpacity(0.2),  // Sunny orange shadow
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Obx(() => DropdownButton<String>(
                          value: DateFormat.MMMM().format(_focusedDay.value),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9B4DCA)),  // Bright purple
                          underline: Container(),
                          items: _months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(
                                month,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              int monthIndex = _months.indexOf(newValue) + 1;
                              _focusedDay.value = DateTime(_focusedDay.value.year, monthIndex);
                            }
                          },
                        )),
                      ),
                    ],
                  ),
                ),
                
                // Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF9B4DCA).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Color(0xFFFF6B6B).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          // Background animation
                          Positioned.fill(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1500),
                              builder: (context, value, _) {
                                return CustomPaint(
                                  painter: BackgroundPainter(
                                    color1: Color(0xFFFFE5E5),
                                    color2: Color(0xFFFFF0F3),
                                    animation: value,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Calendar content with gesture detector
                          GestureDetector(
                            onTapDown: (details) {
                              // Add ripple effect on tap
                              HapticFeedback.mediumImpact();
                            },
                            onVerticalDragUpdate: (details) {
                              // Add resistance effect for vertical scroll
                              if (details.primaryDelta!.abs() > 10) {
                                HapticFeedback.selectionClick();
                              }
                            },
                            child: GetBuilder<ContainerController>(
                              builder: (controller) => TableCalendar(
                                firstDay: DateTime.utc(2023, 1, 1),
                                lastDay: DateTime.utc(2025, 12, 31),
                                focusedDay: _focusedDay.value,
                                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                calendarFormat: CalendarFormat.month,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                headerStyle: HeaderStyle(
                                  titleTextStyle: TextStyle(
                                    color: Color(0xFF9B4DCA),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF9B4DCA)),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF9B4DCA)),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  weekendTextStyle: TextStyle(color: Color(0xFFFF6B6B)),
                                  holidayTextStyle: TextStyle(color: Color(0xFFFF6B6B)),
                                  defaultTextStyle: TextStyle(color: Color(0xFF9B4DCA).withOpacity(0.8)),
                                  selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
                                  todayTextStyle: TextStyle(color: Color(0xFF9B4DCA), fontSize: 16),
                                  selectedDecoration: BoxDecoration(
                                    color: Color(0xFF9B4DCA),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF9B4DCA).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF9B4DCA),
                                      width: 2,
                                    ),
                                  ),
                                  markerDecoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.rectangle,
                                  ),
                                  markersAlignment: Alignment.bottomCenter,
                                  markerSize: 0,
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, date, events) {
                                    int meetingCount = containerController.containerList
                                        .where((event) => isSameDay(event.date, date))
                                        .length;
                                    bool isSelected = isSameDay(_selectedDay, date);
                                    
                                    if (meetingCount > 0) {
                                      return Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                              ? Colors.white.withOpacity(0.9)
                                              : Color(0xFFFF6B6B),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                  ? Colors.white.withOpacity(0.2)
                                                  : Color(0xFFFF6B6B).withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '$meetingCount',
                                            style: TextStyle(
                                              color: isSelected 
                                                ? Color(0xFF9B4DCA)
                                                : Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                  selectedBuilder: (context, date, _) {
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.elasticOut,
                                      builder: (context, value, _) {
                                        return Transform.scale(
                                          scale: 0.8 + (0.2 * value),
                                          child: Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF9B4DCA),
                                                  Color(0xFFFF6B6B),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFF9B4DCA).withOpacity(0.3 * value),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4 * value),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                duration: const Duration(milliseconds: 200),
                                                builder: (context, opacity, _) {
                                                  return Opacity(
                                                    opacity: opacity,
                                                    child: Text(
                                                      '${date.day}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  todayBuilder: (context, date, _) {
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, _) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Animated ring
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.8, end: 1.1),
                                                duration: const Duration(milliseconds: 1500),
                                                curve: Curves.easeInOut,
                                                builder: (context, scale, _) {
                                                  return Transform.scale(
                                                    scale: scale,
                                                    child: Container(
                                                      margin: const EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Color(0xFF9B4DCA).withOpacity(0.3),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              // Main container
                                              Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFFFFE5E5),
                                                      Color(0xFFFFF0F3),
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFF9B4DCA),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0xFF9B4DCA).withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${date.day}',
                                                    style: TextStyle(
                                                      color: Color(0xFF9B4DCA),
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  defaultBuilder: (context, date, _) {
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      builder: (context, value, _) {
                                        return Opacity(
                                          opacity: value,
                                          child: Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${date.day}',
                                                style: TextStyle(
                                                  color: Color(0xFF9B4DCA).withOpacity(0.8),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay.value = focusedDay;
                                  });
                                  
                                  // Check if the selected day has meetings
                                  final count = controller.getMeetingCountForDate(selectedDay);
                                  if (count > 0) {
                                    // Set selected date in controller
                                    controller.setSelectedDate(selectedDay);
                                    
                                    // Add haptic feedback
                                    HapticFeedback.mediumImpact();
                                    
                                    // Navigate to timeline view and trigger scroll after navigation
                                    Get.find<BottomNavController>().changeIndex(1);
                                    
                                    // Add a small delay to ensure the timeline view is rendered
                                    Future.delayed(Duration(milliseconds: 100), () {
                                      if (Get.find<BottomNavController>().selectedIndex.value == 1) {
                                        final timelineController = Get.find<ContainerController>();
                                        timelineController.scrollToSelectedMeeting();
                                      }
                                    });
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay.value = focusedDay;
                                  // Add page transition feedback
                                  HapticFeedback.selectionClick();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Today's Meetings Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Meetings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d').format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Today's Meetings List
                Expanded(
                  child: Obx(() {
                    final todayMeetings = containerController.getTodayMeetings();
                    if (todayMeetings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No meetings scheduled for today',
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
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom + 80, // Add padding for bottom bar
                      ),
                      itemCount: todayMeetings.length,
                      itemBuilder: (context, index) {
                        final meeting = todayMeetings[index];
                        return _buildMeetingCard(meeting, index);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          
          // Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(imageItems.length, (index) {
                    final isSelected = controller.selectedIndex.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeIndex(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              imageItems[index],
                              width: 24,
                              height: 24,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Text(
                                index == 0 ? 'Home' : 'Timeline',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const MeetingSetterBox(),
                );
              },
              backgroundColor: const Color(0xFF9B4DCA),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(ContainerData meeting, int index) {
    return GetBuilder<ContainerController>(
      builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[100]!,
              Colors.purple[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            colorScheme: ColorScheme.light(
              primary: Colors.purple[700]!,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              meeting.value1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF2E3147),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.purple[300],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${meeting.value2} - ${meeting.value3}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meeting.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (meeting.minutes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${meeting.minutes.length}',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_note,
                      color: Colors.purple[400],
                      size: 28,
                    ),
                    onPressed: () => _showMinutesDialog(context, meeting),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 24,
                    ),
                    onPressed: () => _handleDelete(context, index),
                  ),
                ],
              ),
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meeting Minutes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.purple[700],
                          ),
                        ),
                        TextButton.icon(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: Colors.purple[700],
                          ),
                          label: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.purple[700],
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.purple.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => _showMinutesDialog(context, meeting),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (meeting.minutes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No minutes added yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: meeting.minutes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Colors.purple[300],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    meeting.minutes[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(ContainerData meeting, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple[100]!,
                    Colors.purple[50]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  colorScheme: ColorScheme.light(
                    primary: Colors.purple[700]!,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.value1,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3147),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.purple[300],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${meeting.value2} - ${meeting.value3}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meeting.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (meeting.minutes.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${meeting.minutes.length}',
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_note,
                          color: Colors.purple[400],
                          size: 28,
                        ),
                        onPressed: () => _showMinutesDialog(context, meeting),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 24,
                        ),
                        onPressed: () => _handleDelete(context, index),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Meeting Minutes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.purple[700],
                                ),
                              ),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                  color: Colors.purple[700],
                                ),
                                label: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.purple.withOpacity(0.1),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _showMinutesDialog(context, meeting),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (meeting.minutes.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.note_alt_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No minutes added yet',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: meeting.minutes.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Colors.purple[300],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          meeting.minutes[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinutesList(ContainerData container) {
    return GetX<ContainerController>(
      builder: (controller) => ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: container.minutes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(container.minutes[index]),
          );
        },
      ),
    );
  }

  void _showMinutesDialog(BuildContext context, ContainerData meeting) {
    final textController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Add Minutes'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: 'Enter minutes'),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await Get.find<ContainerController>().addMinute(meeting, textController.text);
                Get.back();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _handleDelete(BuildContext context, int index) async {
    bool? confirm = await ConfirmDialog.show(context);
    if (confirm == true) {
      timePickerController.handleDelete(index);
    }
  }
}

class BackgroundPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double animation;

  BackgroundPainter({
    required this.color1,
    required this.color2,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    // Create animated wave pattern
    for (var i = 0; i < 3; i++) {
      final waveAnimation = (animation + (i * 0.2)) % 1.0;
      final y = size.height * (0.5 + (0.1 * sin(waveAnimation * pi * 2)));
      
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color1.withOpacity(0.1 * (i + 1)),
          color2.withOpacity(0.1 * (i + 1)),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      path.reset();
      path.moveTo(0, y);
      
      for (var x = 0.0; x <= size.width; x += size.width / 20) {
        path.lineTo(
          x,
          y + sin((x / size.width + waveAnimation) * pi * 4) * 10,
        );
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
