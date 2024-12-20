import 'package:flutter/material.dart';
import 'package:meetingreminder/models/container.dart';

class MeetingCard extends StatelessWidget {
  final ContainerData meeting;
  final int index;
  final Future<void> Function(BuildContext, int) onDelete;
  final void Function(BuildContext, ContainerData) onEdit;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          title: _buildTitle(meeting),
          subtitle: _buildSubtitle(meeting),
          trailing: _buildTrailing(context),
          children: [_buildDetails(context)],
        ),
      ),
    );
  }

  Widget _buildTitle(ContainerData meeting) {
    return Text(
      meeting.value1,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Color(0xFF2E3147),
      ),
    );
  }

  Widget _buildSubtitle(ContainerData meeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.purple[300], size: 16),
            const SizedBox(width: 8),
            Text(
              '${meeting.value2} - ${meeting.value3}',
              style: TextStyle(color: Colors.grey[700]),
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
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return SizedBox(
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
            icon: Icon(Icons.edit_note, color: Colors.purple[400], size: 28),
            onPressed: () => onEdit(context, meeting),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 24),
            onPressed: () => onDelete(context, index),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Container(
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
                icon: Icon(Icons.add_circle_outline,
                    size: 20, color: Colors.purple[700]),
                label: Text(
                  'Add',
                  style: TextStyle(color: Colors.purple[700]),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => onEdit(context, meeting),
              ),
            ],
          ),
          const SizedBox(height: 16),
          meeting.minutes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.note_alt_outlined,
                            size: 48, color: Colors.grey[400]),
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
              : _buildMinutesList(meeting),
        ],
      ),
    );
  }

  Widget _buildMinutesList(ContainerData meeting) {
    return ListView.builder(
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
                child: Icon(Icons.circle, size: 6, color: Colors.purple[300]),
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
    );
  }
}
