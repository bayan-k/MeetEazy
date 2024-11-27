import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/container_controller.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/meeting_counter.dart';
import 'package:meetingreminder/app/modules/homepage/controllers/timepicker_controller.dart';
import 'package:intl/intl.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final containerController = Get.find<ContainerController>();
  final timePickerController = Get.find<TimePickerController>();
  final meetingCounter = Get.find<MeetingCounter>();

  @override
  void initState() {
    super.initState();
    // Add listener to container controller for selected date changes
    ever(Get.find<ContainerController>().selectedDate, (date) {
      if (date != null) {
        _scrollToSelectedMeeting();
      }
    });
  }

  void _scrollToSelectedMeeting() {
    final controller = Get.find<ContainerController>();
    if (controller.containerList.isEmpty) return;

    // Find the index of the first meeting from selected date
    final selectedDate = controller.selectedDate.value;
    if (selectedDate == null) return;

    final index = controller.containerList.indexWhere(
      (meeting) => controller.isMeetingFromSelectedDate(meeting)
    );
    
    if (index != -1) {
      // Calculate approximate position (each card is about 160 pixels high + 12 margin)
      final position = index * 172.0;
      
      // Animate to the position
      controller.scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Meeting'),
          content: const Text('Are you sure you want to delete this meeting?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await containerController.deleteContainerData(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: GetBuilder<ContainerController>(
              builder: (controller) {
                if (controller.containerList.isEmpty) {
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
                          'No meetings scheduled',
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
                
                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Timeline',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B4DCA),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.purple[700], size: 16),
                                const SizedBox(width: 8),
                                Obx(() {
                                  final selectedDate = controller.selectedDate.value;
                                  return Text(
                                    selectedDate != null
                                        ? DateFormat('MMM d').format(selectedDate)
                                        : 'All Meetings',
                                    style: TextStyle(
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Meeting List
                    Expanded(
                      child: ListView.builder(
                        controller: controller.scrollController,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: MediaQuery.of(context).padding.bottom + 80,
                        ),
                        itemCount: controller.containerList.length,
                        itemBuilder: (context, index) {
                          final meeting = controller.containerList[index];
                          final isSelectedDateMeeting = controller.isMeetingFromSelectedDate(meeting);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelectedDateMeeting
                                    ? [Color(0xFF9B4DCA), Color(0xFFFF6B6B)]  // Purple to Coral for selected
                                    : [Colors.purple[100]!, Colors.purple[50]!], // Default colors
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelectedDateMeeting
                                      ? Color(0xFF9B4DCA).withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.1),
                                  spreadRadius: isSelectedDateMeeting ? 2 : 1,
                                  blurRadius: isSelectedDateMeeting ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline indicator with pulse animation
                                  Column(
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.8, end: 1.2),
                                        duration: const Duration(milliseconds: 1500),
                                        curve: Curves.easeInOut,
                                        builder: (context, scale, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue[300]!, Colors.blue[600]!],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.calendar_today,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (index != controller.containerList.length - 1)
                                        Container(
                                          width: 2,
                                          height: 120,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue[200]!,
                                                Colors.blue[100]!.withOpacity(0.5),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 15),
                                  
                                  // Meeting Card with hover effect
                                  Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onLongPress: () => _showDeleteDialog(context, index),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
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
                                                              color: Color(0xFF2E3147),
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.purple[50],
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: Colors.purple[200]!,
                                                              width: 1,
                                                            ),
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
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.access_time,
                                                            size: 16, color: Colors.purple[400]),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Start: ${meeting.value2}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.access_time,
                                                            size: 16, color: Colors.purple[400]),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'End: ${meeting.value3}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, 'Home', 'assets/images/icons/home-page.png', 0),
                  _buildNavItem(context, 'Timeline', 'assets/images/icons/clock(1).png', 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String iconPath, int index) {
    final controller = Get.find<BottomNavController>();
    
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 24 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF9B4DCA).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isSelected ? Color(0xFF9B4DCA) : Color(0xFF7C8DB5),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF9B4DCA),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
