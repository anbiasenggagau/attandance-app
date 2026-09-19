import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/data/endpoint/attendance/request.dart';
import 'package:attandance/data/endpoint/attendance/response.dart';
import 'package:attandance/pages/request_detail.dart';
import 'package:attandance/pages/submit_attendance.dart';
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
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );
  List<AttendanceRecord> _loadedRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 20;

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

  CentralApiCaller apiCaller = CentralApiCaller();

  Future<void> _initializeData() async {
    try {
      final data = await _getRecords();
      if (!mounted) return;

      setState(() {
        _loadedRecords = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreRecords() async {
    // Prevent duplicate API calls while loading or if end of data is reached
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newRecords = await _getRecords(page: nextPage, pageSize: _pageSize);

      if (!mounted) return;

      setState(() {
        _currentPage = nextPage;
        _loadedRecords.addAll(newRecords);
        _isLoadingMore = false;

        // Stop fetching if API returned fewer items than page size
        if (newRecords.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<List<AttendanceRecord>> _getRecords({
    int page = 1,
    int pageSize = _pageSize,
  }) async {
    try {
      final apiResponse = await apiCaller.attendance.getAttendance(
        AttendanceRequest(page: page, pageSize: pageSize),
      );

      return apiResponse.data
          .map((item) => AttendanceRecord.fromApiItem(item))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occured'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();

    _scrollController.addListener(_onScroll);

    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadedRecords.isEmpty) return;
    const double itemHeight = 94.0;

    // Get top card data as we scrolling
    int currentIndex = (_scrollController.offset / itemHeight).floor();
    currentIndex = currentIndex.clamp(0, _loadedRecords.length - 1);

    final record = _loadedRecords[currentIndex];
    final visibleMonth = record.monthString;
    final visibleYear = record.yearString;

    if (selectedMonth != visibleMonth || selectedYear != visibleYear) {
      setState(() {
        if (months.contains(visibleMonth)) selectedMonth = visibleMonth;
        if (years.contains(visibleYear)) selectedYear = visibleYear;
      });
    }

    const int fetchThreshold = 10;
    if (currentIndex >= _loadedRecords.length - fetchThreshold) {
      _loadMoreRecords();
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

  Widget _buildLogContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_loadedRecords.isEmpty) {
      return const Center(child: Text('No attendance records found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: _loadedRecords.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _loadedRecords.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return AttendanceCard(record: _loadedRecords[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Attendance Log",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
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
          Expanded(child: _buildLogContent()),
        ],
      ),
    );
  }
}

enum LogType { onTime, late, inProgress, overtime, leaves }

class AttendanceRecord {
  final int id;
  final int userId;
  final String userName;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final LogType status;
  final bool pending;
  final String? statusDetail;
  final RequestData? requestData;
  final AttendanceInfo checkInDetail;
  final AttendanceInfo checkOutDetail;
  final DateTime? createdAt;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.pending = false,
    this.statusDetail,
    this.requestData,
    required this.checkInDetail,
    required this.checkOutDetail,
    this.createdAt,
  });

  // Mapper factory from AttendanceItem -> AttendanceRecord
  factory AttendanceRecord.fromApiItem(AttendanceItem item) {
    // Parse date (Handles 'yyyy-MMM-dd' or standard ISO 8601 string)
    DateTime parsedDate =
        DateTime.tryParse(item.date) ??
        _parseDateString(item.date) ??
        DateTime.now();

    // Map logType String to LogType Enum
    LogType mappedStatus = LogType.values.firstWhere(
      (e) => e.name.toLowerCase() == item.logType.toLowerCase(),
      orElse: () => LogType.inProgress,
    );

    // Determine pending status from requestData
    bool isPending = item.requestData?.requestStatus.toLowerCase() == 'pending';

    return AttendanceRecord(
      id: item.id,
      userId: item.userId,
      userName: item.userName,
      date: parsedDate,
      checkIn: item.checkIn,
      checkOut: item.checkOut,
      status: mappedStatus,
      pending: isPending,
      statusDetail: item.requestData?.note,
      requestData: item.requestData,
      checkInDetail: item.checkInDetail == null
          ? AttendanceInfo()
          : AttendanceInfo(
              time: item.checkIn,
              photo: item.checkInDetail!.photo,
              latitude: item.checkInDetail!.latitude,
              longitude: item.checkInDetail!.longitude,
            ),
      checkOutDetail: item.checkOutDetail == null
          ? AttendanceInfo()
          : AttendanceInfo(
              time: item.checkOut,
              photo: item.checkOutDetail!.photo,
              latitude: item.checkOutDetail!.latitude,
              longitude: item.checkOutDetail!.longitude,
            ),
      createdAt: item.createdAt.isNotEmpty
          ? DateTime.tryParse(item.createdAt)
          : null,
    );
  }

  static DateTime? _parseDateString(String dateStr) {
    try {
      return DateFormat('yyyy-MMM-dd').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  String get formattedDate => DateFormat('EEE, dd MMM yyyy').format(date);

  String get formattedCheckIn =>
      checkIn != null ? DateFormat('hh:mm a').format(checkIn!) : '--:--';

  String get formattedCheckOut =>
      checkOut != null ? DateFormat('hh:mm a').format(checkOut!) : '--:--';

  String get monthString => DateFormat('MMM').format(date);
  String get yearString => DateFormat('yyyy').format(date);

  String get formattedDuration {
    if (checkIn == null || checkOut == null) {
      return '--';
    }

    final duration = checkOut!.difference(checkIn!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}m';
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${record.formattedCheckIn} - ${record.formattedCheckOut}';

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (record.status == LogType.leaves ||
                  record.status == LogType.overtime) {
                RequestType requestType;
                if (record.status == LogType.leaves) {
                  requestType = RequestType.leaves;
                } else {
                  requestType = RequestType.overtime;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestDetail(requestType: requestType),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitAttendance(
                      pageType: AttendancePageType.detail,
                      checkInDetail: record.checkInDetail,
                      checkOutDetail: record.checkOutDetail,
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
                            record.status,
                            record.pending,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(record.status, record.pending),
                          style: TextStyle(
                            color: _getStatusTextColor(
                              record.status,
                              record.pending,
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

  String _getStatusText(LogType status, bool pending) {
    String result = "";
    switch (status) {
      case LogType.onTime:
        result += 'On Time';
      case LogType.late:
        result += 'Late';
      case LogType.inProgress:
        result += 'In Progress';
      case LogType.overtime:
        result += 'Overtime';
      case LogType.leaves:
        result += 'Leaves';
    }

    if (pending) {
      result += ":Pending";
    }

    return result;
  }

  Color _getStatusBgColor(LogType status, bool pending) {
    if (pending && (status == LogType.overtime || status == LogType.leaves)) {
      return Color(0xFFE2E8F0);
    }

    switch (status) {
      case LogType.onTime:
        return Color(0xFFD1F4E0);
      case LogType.late:
        return Color(0xFFFCE8E8);
      case LogType.inProgress:
        return Color(0xFFFEF0C7);
      case LogType.overtime:
        return Color(0xFFE0F2FE);
      case LogType.leaves:
        return Color(0xFFF3E8FF);
    }
  }

  Color _getStatusTextColor(LogType status, bool pending) {
    if (pending && (status == LogType.overtime || status == LogType.leaves)) {
      return Color(0xFF475569);
    }

    switch (status) {
      case LogType.onTime:
        return Color(0xFF16A34A);
      case LogType.late:
        return Color(0xFFDC2626);
      case LogType.inProgress:
        return Color(0xFFD97706);
      case LogType.overtime:
        return Color(0xFF0284C7);
      case LogType.leaves:
        return Color(0xFF9333EA);
    }
  }
}
