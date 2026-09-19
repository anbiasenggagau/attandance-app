import 'dart:async';
import 'package:flutter/material.dart';

class LiveClockWidget extends StatelessWidget {
  final DateTime? timeStamp;
  const LiveClockWidget({super.key, this.timeStamp});

  // Generates a Stream emitting DateTime.now() every 1 second
  Stream<DateTime> _clockStream() {
    return Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a timeStamp is provided, render the static clock directly
    if (timeStamp != null) {
      return _buildClockUI(timeStamp!);
    }

    // Otherwise, listen to the live stream
    return StreamBuilder<DateTime>(
      stream: _clockStream(),
      initialData: DateTime.now(), // Display time immediately on render
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        return _buildClockUI(now);
      },
    );
  }

  Widget _buildClockUI(DateTime time) {
    final localTime = time.toLocal();

    // Format: HH:mm:ss
    final timeString =
        '${localTime.hour.toString().padLeft(2, '0')}:'
        '${localTime.minute.toString().padLeft(2, '0')}:'
        '${localTime.second.toString().padLeft(2, '0')}';

    // Format: Month DD YYYY Day
    final dateString =
        '${_monthName(localTime.month)} ${localTime.day.toString().padLeft(2, '0')} ${localTime.year} ${_weekdayName(localTime.weekday)}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeString,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2B), // Dark green text matching UI
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}
