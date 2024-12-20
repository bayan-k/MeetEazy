import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meetingreminder/controllers/bottom_nav_controller.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/controllers/meeting_counter_controller.dart';
import 'package:meetingreminder/controllers/timepicker_controller.dart';
import 'package:meetingreminder/shared_widgets/meeting_tile_timeline.dart';
import 'package:meetingreminder/utils/dialog_utils.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final ContainerController containerController =
      Get.find<ContainerController>();
  final BottomNavController bottomNavController =
      Get.find<BottomNavController>();
  final MeetingCounter meetingCounter = Get.find<MeetingCounter>();
  final TimePickerController timePickerController =
      Get.find<TimePickerController>();

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

    final index = controller.containerList
        .indexWhere((meeting) => controller.isMeetingFromSelectedDate(meeting));

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

  // Future<void> _showDeleteDialog(BuildContext context, int index) async {
  //   final bool? confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.red[50],
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Icon(
  //                 Icons.delete_outline,
  //                 color: Colors.red[400],
  //                 size: 24,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             const Text(
  //               'Delete Meeting',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Are you sure you want to delete this meeting?',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               'This action cannot be undone.',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.grey[500],
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(false),
  //             style: TextButton.styleFrom(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //             ),
  //             child: Text(
  //               'Cancel',
  //               style: TextStyle(
  //                 color: Colors.grey[600],
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () => Navigator.of(context).pop(true),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red[400],
  //               foregroundColor: Colors.white,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //             child: const Text(
  //               'Delete',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  //       );
  //     },
  //   );

  //   if (confirm == true) {
  //     await containerController.deleteContainerData(index);
  //   }
  // }

  // void _showMinutesDialog(BuildContext context, ContainerData meeting) {
  //   final TextEditingController minuteController = TextEditingController();
  //   final containerController = Get.find<ContainerController>();

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: Container(
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Text(
  //                   'Meeting Minutes',
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: Color(0xFF2B3A67),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: const Icon(Icons.close),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             TextField(
  //               controller: minuteController,
  //               decoration: InputDecoration(
  //                 hintText: 'Enter minute point...',
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 suffixIcon: IconButton(
  //                   icon: const Icon(Icons.add),
  //                   onPressed: () {
  //                     if (minuteController.text.trim().isNotEmpty) {
  //                       containerController.addMinute(
  //                           meeting, minuteController.text.trim());
  //                       minuteController.clear();
  //                     }
  //                   },
  //                 ),
  //               ),
  //               onSubmitted: (value) {
  //                 if (value.trim().isNotEmpty) {
  //                   containerController.addMinute(meeting, value.trim());
  //                   minuteController.clear();
  //                 }
  //               },
  //             ),
  //             const SizedBox(height: 16),
  //             GetBuilder<ContainerController>(
  //               builder: (controller) {
  //                 final minutes = meeting.minutes;
  //                 return minutes.isEmpty
  //                     ? Center(
  //                         child: Text(
  //                           'No minutes added yet',
  //                           style: TextStyle(
  //                             color: Colors.grey[600],
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       )
  //                     : SizedBox(
  //                         height: MediaQuery.of(context).size.height * 0.3,
  //                         child: ListView.builder(
  //                           shrinkWrap: true,
  //                           itemCount: minutes.length,
  //                           itemBuilder: (context, index) {
  //                             return ListTile(
  //                               contentPadding: EdgeInsets.zero,
  //                               leading: Icon(Icons.circle,
  //                                   size: 8, color: Colors.purple[400]),
  //                               title: Text(minutes[index]),
  //                               trailing: IconButton(
  //                                 icon: const Icon(Icons.delete_outline,
  //                                     color: Colors.red),
  //                                 onPressed: () => containerController
  //                                     .deleteMinute(meeting, index),
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       );
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: GetBuilder<ContainerController>(
              builder: (controller) {
                if (containerController.containerList.isEmpty) {
                  return _emptyMeetingData();
                }

                return _buildMeetingTiles();
              },
            ),
          ),
          _bottomBarTimelineView(),

          // Bottom Navigation Bar
        ],
      ),
    );
  }

  Widget _buildMeetingTiles() {
    return Column(
      children: [
        _timelineHeader(), // Header
        // Meeting List
        Expanded(
          child: ListView.builder(
            controller: containerController.scrollController,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            itemCount: containerController.containerList.length,
            itemBuilder: (context, index) {
              final meeting = containerController.containerList[index];

              return MeetingTile(
                  meeting: meeting,
                  isSelected:
                      containerController.isMeetingFromSelectedDate(meeting),
                  onEdit: () => DialogUtils.showMinutesDialog(
                      context: context, meeting: meeting),
                  // _showMinutesDialog(context, meeting),
                  onDelete: () => DialogUtils.showDeleteDialog(
                      context: context, index: index)
                  //  _showDeleteDialog(context, index),
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _bottomBarTimelineView() {
    return Positioned(
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
            _buildNavItem(
                context, 'Home', 'assets/images/icons/home-page.png', 0),
            _buildNavItem(
                context, 'Timeline', 'assets/images/icons/clock(1).png', 1),
          ],
        ),
      ),
    );
  }

  Widget _timelineHeader() {
    return Container(
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
                  final selectedDate = containerController.selectedDate.value;
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
    );
  }

  Widget _emptyMeetingData() {
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

  Widget _buildNavItem(
      BuildContext context, String title, String iconPath, int index) {
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
            color: isSelected
                ? Color(0xFF9B4DCA).withOpacity(0.15)
                : Colors.transparent,
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
    // Reset selected date when leaving timeline view
    // Use addPostFrameCallback to ensure the widget tree is not locked
    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerController.setSelectedDate(null);
    });
    super.dispose();
  }
}
