import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AttendanceLog());
}

class AttendanceLog extends StatefulWidget {
  const AttendanceLog({super.key});

  @override
  State<AttendanceLog> createState() => _AttendanceLogState();
}

class _AttendanceLogState extends State<AttendanceLog> {
  late String selectedMonth;
  late String selectedYear;
  final ScrollController _scrollController = ScrollController();

  final List<String> months = [
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
  final List<String> years = ['2024', '2025', '2026'];

  final List<AttendanceRecord> records = [
    AttendanceRecord(
      date: DateTime(2026, 8, 6),
      checkIn: DateTime(2026, 8, 6, 9, 0),
      checkOut: DateTime(2026, 8, 6, 17, 0),
      status: AttendanceStatus.leaves,
      statusDetail: 'Sick Leave',
    ),
    AttendanceRecord(
      date: DateTime(2026, 8, 5),
      checkIn: DateTime(2026, 8, 5, 9, 0),
      checkOut: null,
      status: AttendanceStatus.inProgress,
      statusDetail: 'No checkout yet',
    ),
    AttendanceRecord(
      date: DateTime(2026, 8, 5),
      checkIn: DateTime(2026, 8, 5, 19, 0),
      checkOut: DateTime(2026, 8, 5, 20, 0),
      status: AttendanceStatus.overtime,
      statusDetail: '+1 Hours',
    ),
    AttendanceRecord(
      date: DateTime(2026, 8, 4),
      checkIn: DateTime(2026, 8, 4, 9, 15),
      checkOut: DateTime(2026, 8, 4, 17, 0),
      status: AttendanceStatus.late,
      statusDetail: '15 mins',
    ),
    AttendanceRecord(
      date: DateTime(2026, 8, 3),
      checkIn: DateTime(2026, 8, 3, 9, 0),
      checkOut: DateTime(2026, 8, 3, 17, 0),
      status: AttendanceStatus.onTime,
    ),
    AttendanceRecord(
      date: DateTime(2026, 7, 31),
      checkIn: DateTime(2026, 7, 31, 9, 0),
      checkOut: DateTime(2026, 7, 31, 17, 0),
      status: AttendanceStatus.onTime,
    ),
    AttendanceRecord(
      date: DateTime(2026, 7, 30),
      checkIn: DateTime(2026, 7, 30, 9, 0),
      checkOut: DateTime(2026, 7, 30, 17, 0),
      status: AttendanceStatus.onTime,
    ),
    AttendanceRecord(
      date: DateTime(2026, 7, 29),
      checkIn: DateTime(2026, 7, 29, 9, 0),
      checkOut: DateTime(2026, 7, 29, 17, 0),
      status: AttendanceStatus.onTime,
    ),
    AttendanceRecord(
      date: DateTime(2026, 7, 28),
      checkIn: DateTime(2026, 7, 28, 9, 0),
      checkOut: DateTime(2026, 7, 28, 17, 0),
      status: AttendanceStatus.onTime,
    ),
    AttendanceRecord(
      date: DateTime(2026, 7, 27),
      checkIn: DateTime(2026, 7, 27, 9, 0),
      checkOut: DateTime(2026, 7, 27, 17, 0),
      status: AttendanceStatus.onTime,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    const double itemHeight = 110.0;

    // Get top card data as we scrolling
    int currentIndex = (_scrollController.offset / itemHeight).floor();
    currentIndex = currentIndex.clamp(0, records.length - 1);

    final record = records[currentIndex];
    final visibleMonth = record.monthString;
    final visibleYear = record.yearString;

    if (selectedMonth != visibleMonth || selectedYear != visibleYear) {
      setState(() {
        if (months.contains(visibleMonth)) selectedMonth = visibleMonth;
        if (years.contains(visibleYear)) selectedYear = visibleYear;
      });
    }
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Theme(
      data: ThemeData(
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: PopupMenuButton<String>(
        position: PopupMenuPosition.under,
        constraints: const BoxConstraints(maxHeight: 200, minWidth: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        onSelected: onChanged,
        itemBuilder: (BuildContext context) {
          return items.map((String item) {
            return PopupMenuItem<String>(
              value: item,
              height: 36,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Attendance Log",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      // Month Dropdown
                      _buildDropdownButton(
                        value: selectedMonth,
                        items: months,
                        onChanged: (val) {
                          setState(() => selectedMonth = val);
                        },
                      ),
                      const SizedBox(width: 8),
                      // Year Dropdown
                      _buildDropdownButton(
                        value: selectedYear,
                        items: years,
                        onChanged: (val) {
                          setState(() => selectedYear = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Attendance Log Section
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return AttendanceCard(record: records[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum AttendanceStatus { onTime, late, inProgress, overtime, leaves }

class AttendanceRecord {
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? statusDetail;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.statusDetail,
  });

  String get formattedDate => DateFormat('EEE, dd MMM yyyy').format(date);

  String get formattedCheckIn =>
      checkIn != null ? DateFormat('hh:mm a').format(checkIn!) : '--:--';

  String get formattedCheckOut =>
      checkOut != null ? DateFormat('hh:mm a').format(checkOut!) : '--:--';

  String get monthString => DateFormat('MMM').format(date);
  String get yearString => DateFormat('yyyy').format(date);
}

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${record.formattedCheckIn} - ${record.formattedCheckOut}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.formattedDate,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusBgColor(record.status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(record.status),
                  style: TextStyle(
                    color: _getStatusTextColor(record.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return 'On Time';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.inProgress:
        return 'In Progress';
      case AttendanceStatus.overtime:
        return 'Overtime';
      case AttendanceStatus.leaves:
        return 'Leaves';
    }
  }

  Color _getStatusBgColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const Color(0xFFD1F4E0);
      case AttendanceStatus.late:
        return const Color(0xFFFCE8E8);
      case AttendanceStatus.inProgress:
        return const Color(0xFFFEF0C7);
      case AttendanceStatus.overtime:
        return const Color(0xFFE0F2FE);
      case AttendanceStatus.leaves:
        return const Color(0xFFF3E8FF);
    }
  }

  Color _getStatusTextColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const Color(0xFF16A34A);
      case AttendanceStatus.late:
        return const Color(0xFFDC2626);
      case AttendanceStatus.inProgress:
        return const Color(0xFFD97706);
      case AttendanceStatus.overtime:
        return const Color(0xFF0284C7);
      case AttendanceStatus.leaves:
        return const Color(0xFF9333EA);
    }
  }
}
