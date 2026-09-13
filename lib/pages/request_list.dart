import 'package:attandance/pages/request_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Status { approved, denied, pending }

void main() {
  runApp(const RequestList());
}

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
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

  final List<RequestRecord> records = [
    RequestRecord(
      date: DateTime(2026, 8, 30),
      startTime: DateTime(2026, 8, 6, 9, 0),
      endTime: DateTime(2026, 8, 6, 17, 0),
      requestType: RequestType.leaves,
      statusDetail: 'Sick Leave',
    ),
    RequestRecord(
      date: DateTime(2026, 8, 6),
      startTime: DateTime(2026, 8, 6, 9, 0),
      endTime: DateTime(2026, 8, 6, 17, 0),
      requestType: RequestType.leaves,
      statusDetail: 'Annual Leave',
    ),
    RequestRecord(
      date: DateTime(2026, 8, 6),
      startTime: DateTime(2026, 8, 6, 9, 0),
      endTime: DateTime(2026, 8, 6, 17, 0),
      requestType: RequestType.leaves,
      statusDetail: 'Sick Leave',
      currStatus: Status.approved,
    ),
    RequestRecord(
      date: DateTime(2026, 8, 5),
      startTime: DateTime(2026, 8, 5, 19, 0),
      endTime: DateTime(2026, 8, 5, 20, 0),
      requestType: RequestType.overtime,
      statusDetail: '+1 Hours',
    ),
    RequestRecord(
      date: DateTime(2026, 8, 4),
      startTime: DateTime(2026, 8, 6, 9, 0),
      endTime: DateTime(2026, 8, 6, 17, 0),
      requestType: RequestType.leaves,
      statusDetail: 'Sick Leave',
    ),
    RequestRecord(
      date: DateTime(2026, 8, 3),
      startTime: DateTime(2026, 8, 5, 19, 0),
      endTime: DateTime(2026, 8, 5, 20, 0),
      requestType: RequestType.overtime,
      statusDetail: '+1 Hours',
      currStatus: Status.approved,
    ),
    RequestRecord(
      date: DateTime(2026, 8, 2),
      startTime: DateTime(2026, 8, 6, 9, 0),
      endTime: DateTime(2026, 8, 6, 17, 0),
      requestType: RequestType.leaves,
      statusDetail: 'Sick Leave',
    ),
    RequestRecord(
      date: DateTime(2026, 8, 1),
      startTime: DateTime(2026, 8, 5, 19, 0),
      endTime: DateTime(2026, 8, 5, 20, 0),
      requestType: RequestType.overtime,
      statusDetail: '+1 Hours',
      currStatus: Status.denied,
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
    const double itemHeight = 94.0;

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
        constraints: BoxConstraints(maxHeight: 200, minWidth: 80),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            );
          }).toList();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Approval'),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          // Top Section
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                      SizedBox(width: 8),
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
              padding: EdgeInsets.all(16.0),
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

class RequestRecord {
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final RequestType requestType;
  final Status currStatus;
  final String? statusDetail;

  RequestRecord({
    required this.date,
    this.startTime,
    this.endTime,
    required this.requestType,
    this.currStatus = Status.pending,
    this.statusDetail,
  });

  String get formattedDate => DateFormat('EEE, dd MMM yyyy').format(date);

  String get formattedStartTime =>
      startTime != null ? DateFormat('hh:mm a').format(startTime!) : '--:--';

  String get formattedEndTime =>
      endTime != null ? DateFormat('hh:mm a').format(endTime!) : '--:--';

  String get monthString => DateFormat('MMM').format(date);
  String get yearString => DateFormat('yyyy').format(date);

  String get formattedDuration {
    if (startTime == null || endTime == null) {
      return '--';
    }

    final duration = endTime!.difference(startTime!);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }
}

class AttendanceCard extends StatelessWidget {
  final RequestRecord record;

  const AttendanceCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${record.formattedStartTime} - ${record.formattedEndTime}';

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (record.requestType == RequestType.leaves ||
                  record.requestType == RequestType.overtime) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetail(
                      pageType: RequestPageType.approval,
                      requestType: record.requestType,
                      status: record.currStatus,
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: EdgeInsets.all(16.0),
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
                            color: Theme.of(context).colorScheme.outlineVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          record.formattedDate,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(
                            record.requestType,
                            record.currStatus,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(record.requestType, record.currStatus),
                          style: TextStyle(
                            color: _getStatusTextColor(
                              record.requestType,
                              record.currStatus,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 6),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          record.formattedDuration,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 12),
      ],
    );
  }

  String _getStatusText(RequestType type, Status status) {
    final typeName = switch (type) {
      RequestType.overtime => 'Overtime',
      RequestType.leaves => 'Leaves',
    };

    final statusName = switch (status) {
      Status.approved => ':Approved',
      Status.denied => ':Denied',
      Status.pending => '',
    };

    return '$typeName$statusName';
  }

  Color _getStatusBgColor(RequestType type, Status status) {
    return switch (status) {
      Status.approved => const Color(0xFFDCFCE7), // Soft Green
      Status.denied => const Color(0xFFFCE8E8), // Soft Red
      Status.pending => switch (type) {
        RequestType.overtime => const Color(0xFFE0F2FE), // Sky Blue
        RequestType.leaves => const Color(0xFFF3E8FF), // Soft Purple
      },
    };
  }

  Color _getStatusTextColor(RequestType type, Status status) {
    return switch (status) {
      Status.approved => const Color(0xFF15803D), // Deep Green
      Status.denied => const Color(0xFFDC2626), // Dark Red
      Status.pending => switch (type) {
        RequestType.overtime => const Color(0xFF0284C7),
        RequestType.leaves => const Color(0xFF9333EA),
      },
    };
  }
}
