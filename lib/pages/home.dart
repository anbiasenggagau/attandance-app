import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/main.dart';
import 'package:attandance/pages/submit_attendance.dart';
import 'package:attandance/widgets/clock_action_button.dart';
import 'package:attandance/widgets/live_clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  bool _isLoading = true;
  String? _errorMessage;

  AttendanceInfo checkIn = AttendanceInfo();
  AttendanceInfo checkOut = AttendanceInfo();
  AttendanceType attendanceType = AttendanceType.checkin;

  CentralApiCaller apiCaller = CentralApiCaller();

  @override
  void initState() {
    super.initState();
    globalDataSync.addListener(_onRefresh);
    _getCurrentAttendance();
  }

  @override
  void dispose() {
    globalDataSync.removeListener(_onRefresh);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _getCurrentAttendance();
  }

  Future<void> _getCurrentAttendance() async {
    try {
      final apiResponse = await apiCaller.attendance.getCurrentAttendance();
      final data = apiResponse.data;

      if (data != null) {
        attendanceType = AttendanceType.checkout;
        checkIn = AttendanceInfo(
          latitude: data.checkInDetail!.latitude,
          longitude: data.checkInDetail!.longitude,
          photo: data.checkInDetail!.photo,
          time: data.checkIn,
        );
        if (data.checkOut != null) {
          checkOut = AttendanceInfo(
            latitude: data.checkOutDetail!.latitude,
            longitude: data.checkOutDetail!.longitude,
            photo: data.checkOutDetail!.photo,
            time: data.checkOut,
          );
        } else {
          checkOut = AttendanceInfo();
        }
      } else {
        attendanceType = AttendanceType.checkin;
        checkIn = AttendanceInfo();
        checkOut = AttendanceInfo();
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = "Failed to retrieve data";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMetric(
      BuildContext context,
      String label,
      String value,
      IconData icon,
    ) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    Widget containerChild;
    if (_isLoading) {
      containerChild = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      containerChild = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              IconButton.filledTonal(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Data",
              ),
            ],
          ),
        ),
      );
    } else {
      containerChild = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Attendance",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  checkIn.time == null ? "Submit Attendance" : "In Progress",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildMetric(
                context,
                "Check In",
                checkIn.time == null
                    ? "--:--"
                    : DateFormat("HH:mm").format(checkIn.time!.toLocal()),
                Icons.login,
              ),
              buildMetric(
                context,
                "Check Out",
                checkOut.time == null
                    ? "--:--"
                    : DateFormat("HH:mm").format(checkOut.time!.toLocal()),
                Icons.logout,
              ),
              buildMetric(
                context,
                "Location",
                "Jakarta",
                Icons.location_on_outlined,
              ),
            ],
          ),
        ],
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Part: Live Clock
          Container(
            margin: const EdgeInsets.all(16),
            child: const LiveClockWidget(),
          ),

          // Middle Bottom Part: Current Day
          Container(
            margin: const EdgeInsets.all(16),
            width: screenSize.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: containerChild,
          ),

          // Clock Action Button
          !_isLoading && _errorMessage == null
              ? Container(
                  margin: const EdgeInsets.all(16),
                  child: ClockActionButton(
                    icon: Icons.touch_app_outlined,
                    label: attendanceType == AttendanceType.checkout
                        ? "Check Out"
                        : "Check In",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitAttendance(
                            attendanceType: attendanceType,
                            checkInDetail: checkIn,
                            checkOutDetail: checkOut,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
