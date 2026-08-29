import 'dart:io';
import 'package:attandance/widgets/live_clock.dart';
import 'package:flutter/material.dart';

enum AttendancePageType { attendance, detail }

enum AttendanceType { checkin, checkout }

class SubmitAttendance extends StatefulWidget {
  final AttendancePageType pageType;
  final AttendanceType? attendanceType;

  const SubmitAttendance({
    super.key,
    this.pageType = AttendancePageType.attendance,
    this.attendanceType,
  });

  @override
  State<SubmitAttendance> createState() => _SubmitAttendanceState();
}

class _SubmitAttendanceState extends State<SubmitAttendance> {
  File? _capturedImage;
  final double _latitude = -6.4025;
  final double _longitude = 106.7942;

  @override
  Widget build(BuildContext context) {
    final initialIndex = widget.attendanceType == AttendanceType.checkout
        ? 1
        : 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.pageType == AttendancePageType.attendance
                ? 'Submit Attendance'
                : 'Attendance Detail',
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF0F172A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0F172A),
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Check in'),
              Tab(text: 'Check out'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAttendanceForm(isCheckIn: true),
            _buildAttendanceForm(isCheckIn: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceForm({required bool isCheckIn}) {
    final bool showActionButtons =
        widget.pageType == AttendancePageType.attendance &&
        (widget.attendanceType == null ||
            (isCheckIn && widget.attendanceType == AttendanceType.checkin) ||
            (!isCheckIn && widget.attendanceType == AttendanceType.checkout));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          widget.pageType == AttendancePageType.detail
              ? LiveClockWidget(timeStamp: DateTime(2026, 8, 1, 9))
              : const LiveClockWidget(),

          // Image Box
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: _capturedImage != null
                  ? Image.file(_capturedImage!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'This will show your photo',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),

          // Capture / Recapture Photo Button
          if (showActionButtons)
            OutlinedButton.icon(
              onPressed: () {},
              icon: _capturedImage == null ? null : const Icon(Icons.refresh),
              label: Text(
                _capturedImage == null ? 'Capture Photo' : 'Recapture Photo',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

          // Location Info
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Point',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Lat: $_latitude', style: const TextStyle(fontSize: 16)),
                Text('Lng: $_longitude', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Submit Button
          if (showActionButtons)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isCheckIn ? 'Submit Check In' : 'Submit Check Out',
                style: const TextStyle(fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
