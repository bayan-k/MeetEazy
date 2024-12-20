import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetingreminder/controllers/container_controller.dart';
import 'package:meetingreminder/models/container.dart';

class MeetingTile extends StatelessWidget {
  final ContainerController containerController =
      Get.find<ContainerController>();

  final ContainerData meeting;
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  MeetingTile({
    required this.meeting,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildBoxDecoration(),
      child: Theme(
        data: _buildTheme(context),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _buildTileTitle(context),
          trailing: _buildTrailingActions(),
          children: [_buildExpansionContent(context)],
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isSelected
            ? [Color(0xFF9B4DCA), Color(0xFFFF6B6B)]
            : [Colors.purple[100]!, Colors.purple[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? Color(0xFF9B4DCA).withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          spreadRadius: isSelected ? 2 : 1,
          blurRadius: isSelected ? 8 : 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: isSelected ? Colors.white : Colors.purple[700]!,
      ),
    );
  }

  

  Widget _buildTileTitle(BuildContext context) {
    return Row(
      children: [
        _buildTimelineIndicator(),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMeetingInfo(context),
        ),
      ],
    );
  }

  Widget _buildTimelineIndicator() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [Colors.white, Colors.white70]
                      : [Color(0xFF9B4DCA), Color(0xFF9B4DCA).withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Colors.white.withOpacity(0.5)
                        : Color(0xFF9B4DCA).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [Colors.white, Colors.white70]
                  : [Color(0xFF9B4DCA), Color(0xFF9B4DCA).withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.value1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Color(0xFF2E3147),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: isSelected ? Colors.white70 : Colors.purple[300],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '${meeting.value2} - ${meeting.value3}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.2) : Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            meeting.formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.purple[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (meeting.minutes.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${meeting.minutes.length}',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.purple[700],
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        const SizedBox(width: 4),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.edit_note,
            color: isSelected ? Colors.white : Colors.purple[400],
            size: 20,
          ),
          onPressed: onEdit,
        ),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.delete_outline,
            color: isSelected ? Colors.white70 : Colors.red[400],
            size: 18,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _buildExpansionContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: meeting.minutes.isEmpty
          ? Center(
              child: Text(
                'No minutes added yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meeting.minutes.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.purple[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meeting.minutes[index],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2B3A67),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: () =>
                          containerController.deleteMinute(meeting, index),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
