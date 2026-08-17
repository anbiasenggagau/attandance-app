import 'dart:async';
import 'package:flutter/material.dart';

class LiveClockWidget extends StatelessWidget {
  const LiveClockWidget({super.key});

  // Generates a Stream emitting DateTime.now() every 1 second
  Stream<DateTime> _clockStream() {
    return Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockStream(),
      initialData: DateTime.now(), // Display time immediately on render
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        // Format: HH:mm:ss
        final timeString =
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}';

        // Format: Month DD YYYY Day
        final dateString =
            '${_monthName(now.month)} ${now.day.toString().padLeft(2, '0')} ${now.year} ${_weekdayName(now.weekday)}';

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
      },
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
