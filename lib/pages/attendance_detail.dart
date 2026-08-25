import 'package:flutter/material.dart';

class AttendanceDetail extends StatefulWidget {
  const AttendanceDetail({super.key});

  @override
  State<AttendanceDetail> createState() => _AttendanceDetailState();
}

class _AttendanceDetailState extends State<AttendanceDetail> {
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildValue(
    BuildContext context,
    String value, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
            ),
          ),

          if (icon != null) ...[
            const SizedBox(width: 12),
            Icon(icon, size: 18, color: Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Pending',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 13),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Leave Type'),
            _buildValue(context, 'Annual Leave', icon: Icons.event_note),

            const SizedBox(height: 20),

            _buildLabel('From'),
            _buildValue(
              context,
              '26 Aug 2026, 08:00 AM',
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 10),

            _buildLabel('To'),
            _buildValue(
              context,
              '26 Aug 2026, 04:00 PM',
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 20),

            _buildLabel('Approval To'),
            _buildValue(context, 'Human Resources', icon: Icons.approval),

            const SizedBox(height: 20),

            _buildLabel('Note'),
            _buildValue(
              context,
              'Working overtime to complete the monthly report.',
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
