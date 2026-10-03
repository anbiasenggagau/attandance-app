import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/data/endpoint/attendance/request.dart';
import 'package:attandance/data/endpoint/attendance/response.dart';
import 'package:attandance/pages/request_detail.dart';
import 'package:attandance/pages/submit_attendance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LogType { onTime, late, inProgress, overtime, leaves }

class AttendanceLog extends StatefulWidget {
  final int dataVersion;
  final bool isActive;

  const AttendanceLog({
    super.key,
    required this.dataVersion,
    required this.isActive,
  });

  @override
  State<AttendanceLog> createState() => _AttendanceLogState();
}

class _AttendanceLogState extends State<AttendanceLog> {
  final List<String> monthsName = [
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

  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  List<AttendanceRecord> _loadedRecords = [];
  Map<String, List<String>> _availableOptions = {};
  List<String> get years => _availableOptions.keys.toList();
  List<String> get months => _availableOptions[selectedYear] ?? [];
  late String selectedMonth;
  late String selectedYear;

  int _lastFetchedVersion = -1;
  final int _fetchThreshold = 10;
  final double _logCardHeight = 110;
  final int _pageSize = 20;

  // Window page trackers
  int _topPage = 1; // Tracks page at top boundary (for scrolling up)
  int _currentPage = 1; // Tracks page at bottom boundary (for scrolling down)

  bool _hasPrevPage = false;
  bool _hasNextPage = true;

  bool _isLoadingTop = false;
  bool _isLoadingMore = false;
  bool _isLoading = true;
  String? _errorMessage;

  CentralApiCaller apiCaller = CentralApiCaller();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = monthsName[now.month - 1];
    selectedYear = now.year.toString();

    _scrollController.addListener(_onScroll);
    _initializeOptionsAndData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttendanceLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndFetch();
  }

  void _checkAndFetch() {
    if (widget.isActive && widget.dataVersion != _lastFetchedVersion) {
      _lastFetchedVersion = widget.dataVersion;
      _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    final now = DateTime.now();

    setState(() {
      selectedMonth = monthsName[now.month - 1];
      selectedYear = now.year.toString();

      _topPage = 1;
      _currentPage = 1;
      _hasPrevPage = false;
      _hasNextPage = true;
      _isLoadingTop = false;
      _isLoadingMore = false;
      _isLoading = true;
      _errorMessage;

      _loadedRecords.clear(); // Reset list if paginating
    });

    await _initializeOptionsAndData();
  }

  Future<void> _initializeOptionsAndData() async {
    try {
      final response = await apiCaller.attendance.getOptions();
      final options = response.data;

      if (options == null || options.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = "No attendance options available.";
        });
        return;
      }

      _availableOptions = options;

      final now = DateTime.now();
      final currentYearStr = now.year.toString();
      selectedYear = _availableOptions.containsKey(currentYearStr)
          ? currentYearStr
          : _availableOptions.keys.first;

      final currentMonthStr = monthsName[now.month - 1];
      final availableMonthsForYear = _availableOptions[selectedYear] ?? [];

      if (availableMonthsForYear.contains(currentMonthStr)) {
        selectedMonth = currentMonthStr;
      } else {
        selectedMonth = availableMonthsForYear.isNotEmpty
            ? availableMonthsForYear.last
            : currentMonthStr;
      }

      await _onFilterChanged(newMonth: selectedMonth, newYear: selectedYear);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onYearSelected(String newYear) {
    if (newYear == selectedYear) return;

    final availableMonthsInNewYear = _availableOptions[newYear] ?? [];
    String newMonth = selectedMonth;

    if (!availableMonthsInNewYear.contains(selectedMonth) &&
        availableMonthsInNewYear.isNotEmpty) {
      newMonth = availableMonthsInNewYear.last;
    }

    _onFilterChanged(newMonth: newMonth, newYear: newYear);
  }

  Future<void> _onFilterChanged({String? newMonth, String? newYear}) async {
    final targetMonth = newMonth ?? selectedMonth;
    final targetYear = newYear ?? selectedYear;

    setState(() {
      if (newMonth != null) selectedMonth = newMonth;
      if (newYear != null) selectedYear = newYear;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiResponse = await apiCaller.attendance.getAttendance(
        AttendancePagination(
          pageSize: _pageSize,
          month: targetMonth,
          year: targetYear,
        ),
      );

      final newRecords = apiResponse.data
          .map((item) => AttendanceRecord.fromApiItem(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _loadedRecords = newRecords;

        // Synchronize both top and bottom window anchors to target page
        _topPage = apiResponse.page;
        _currentPage = apiResponse.page;

        _hasPrevPage = apiResponse.hasPrevPage;
        _hasNextPage = apiResponse.hasNextPage;
        _isLoading = false;
      });

      _scrollToTargetMonth(targetMonth, targetYear);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _scrollToTargetMonth(String targetMonth, String targetYear) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients || _loadedRecords.isEmpty) return;

      final targetIndex = _loadedRecords.indexWhere(
        (r) => r.monthString == targetMonth && r.yearString == targetYear,
      );

      if (targetIndex != -1) {
        const double topPadding = 16.0;
        final double targetOffset = topPadding + (targetIndex * _logCardHeight);
        final jumpTo = targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.jumpTo(jumpTo);
      } else {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  /// Downward Pagination (Fetches older records)
  Future<void> _loadMoreRecords() async {
    if (_isLoadingMore || !_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final apiResponse = await apiCaller.attendance.getAttendance(
        AttendancePagination(page: nextPage, pageSize: _pageSize),
      );

      final newRecords = apiResponse.data
          .map((item) => AttendanceRecord.fromApiItem(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _currentPage = nextPage; // Advance bottom page anchor
        _loadedRecords.addAll(newRecords);
        _isLoadingMore = false;
        _hasNextPage = apiResponse.hasNextPage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Upward Pagination (Fetches newer records and adjusts scroll position)
  Future<void> _loadPrevRecords() async {
    if (_isLoadingTop || !_hasPrevPage) return;

    _isLoadingTop = true;

    try {
      final prevPage = _topPage - 1;
      final apiResponse = await apiCaller.attendance.getAttendance(
        AttendancePagination(page: prevPage, pageSize: _pageSize),
      );

      final newRecords = apiResponse.data
          .map((item) => AttendanceRecord.fromApiItem(item))
          .toList();

      if (!mounted) return;

      final double addedHeight = newRecords.length * _logCardHeight;
      final double currentOffset = _scrollController.offset;

      setState(() {
        _topPage = prevPage; // Retreat top page anchor
        _loadedRecords.insertAll(0, newRecords);
        _hasPrevPage = apiResponse.hasPrevPage;
        _isLoadingTop = false;
      });

      // Shift scroll offset down by height of inserted records to keep viewport stable
      _scrollController.jumpTo(currentOffset + addedHeight);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTop = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadedRecords.isEmpty) return;

    const double topPadding = 16.0;
    final double adjustedOffset = (_scrollController.offset - topPadding).clamp(
      0.0,
      double.infinity,
    );

    int currentIndex = (adjustedOffset / _logCardHeight).floor();
    currentIndex = currentIndex.clamp(0, _loadedRecords.length - 1);

    // Sync Header Dropdowns
    final record = _loadedRecords[currentIndex];
    if (selectedMonth != record.monthString ||
        selectedYear != record.yearString) {
      setState(() {
        if (months.contains(record.monthString)) {
          selectedMonth = record.monthString;
        }
        if (years.contains(record.yearString)) {
          selectedYear = record.yearString;
        }
      });
    }

    // Scroll Upward Trigger
    if (currentIndex <= _fetchThreshold && _hasPrevPage) {
      _loadPrevRecords();
    }

    // Scroll Downward Trigger
    if (currentIndex >= _loadedRecords.length - _fetchThreshold &&
        _hasNextPage) {
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

    return RefreshIndicator(
      onRefresh: _onRefresh, // Triggers when user pulls down at top of list
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                      // const Icon(Icons.refresh_rounded, size: 16),
                      // const SizedBox(width: 8),
                      _buildDropdownButton(
                        value: selectedMonth,
                        items: months,
                        onChanged: (val) => _onFilterChanged(newMonth: val),
                      ),
                      const SizedBox(width: 8),
                      _buildDropdownButton(
                        value: selectedYear,
                        items: years,
                        onChanged: (val) => _onYearSelected(val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildLogContent()),
        ],
      ),
    );
  }
}

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

  factory AttendanceRecord.fromApiItem(AttendanceItem item) {
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

  String get formattedDate => DateFormat(
    'EEE, dd MMM yyyy',
  ).format(date.toUtc().add(const Duration(hours: 7)));

  String get formattedCheckIn => checkIn != null
      ? DateFormat(
          'hh:mm a',
        ).format(checkIn!.toUtc().add(const Duration(hours: 7)))
      : '--:--';

  String get formattedCheckOut => checkOut != null
      ? DateFormat(
          'hh:mm a',
        ).format(checkOut!.toUtc().add(const Duration(hours: 7)))
      : '--:--';

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

    const double kCardItemHeight = 98.0;
    const double kCardBottomMargin = 12.0;

    return SizedBox(
      height: kCardItemHeight + kCardBottomMargin,
      child: Column(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final status = record.status;

                  // Simplified navigation logic
                  if (status == LogType.leaves || status == LogType.overtime) {
                    final requestType = status == LogType.leaves
                        ? RequestType.leaves
                        : RequestType.overtime;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestDetail(
                          requestType: requestType,
                          id: record.requestData!.id,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubmitAttendance(
                          pageType: AttendancePageType.detail,
                          checkInDetail: record.checkInDetail,
                          checkOutDetail: record.checkOutDetail,
                        ),
                      ),
                    );
                  }
                },
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Time & Date
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeString,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.inverseSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Column: Status & Duration
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBgColor(
                                record.status,
                                record.requestData,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getStatusText(record.status, record.requestData),
                              maxLines: 1,
                              style: TextStyle(
                                color: _getStatusTextColor(
                                  record.status,
                                  record.requestData,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record.formattedDuration,
                            maxLines: 1,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: kCardBottomMargin),
        ],
      ),
    );
  }

  String _getStatusText(LogType status, RequestData? requestData) {
    // If requestData exists, display as RequestType:CurrentStatus (e.g., Leaves:Denied)
    if (requestData != null) {
      return '${requestData.requestType}:${requestData.requestStatus}';
    }

    String result = "";
    switch (status) {
      case LogType.onTime:
        result += 'On Time';
        break;
      case LogType.late:
        result += 'Late';
        break;
      case LogType.inProgress:
        result += 'In Progress';
        break;
      case LogType.overtime:
        result += 'Overtime';
        break;
      case LogType.leaves:
        result += 'Leaves';
        break;
    }

    return result;
  }

  Color _getStatusBgColor(LogType status, RequestData? requestData) {
    final bool pending =
        requestData != null && requestData.requestStatus == "Pending";

    // Turn background red only if Denied
    if (requestData?.requestStatus == 'Denied') {
      return const Color(0xFFFCE8E8); // Light red background
    }

    if (pending && (status == LogType.overtime || status == LogType.leaves)) {
      return const Color(0xFFE2E8F0);
    }

    switch (status) {
      case LogType.onTime:
        return const Color(0xFFD1F4E0);
      case LogType.late:
        return const Color(0xFFFCE8E8);
      case LogType.inProgress:
        return const Color(0xFFFEF0C7);
      case LogType.overtime:
        return const Color(0xFFE0F2FE);
      case LogType.leaves:
        return const Color(0xFFF3E8FF);
    }
  }

  Color _getStatusTextColor(LogType status, RequestData? requestData) {
    final bool pending =
        requestData != null && requestData.requestStatus == "Pending";

    // Turn text red only if Denied
    if (requestData?.requestStatus == 'Denied') {
      return const Color(0xFFDC2626); // Red text
    }

    if (pending && (status == LogType.overtime || status == LogType.leaves)) {
      return const Color(0xFF475569);
    }

    switch (status) {
      case LogType.onTime:
        return const Color(0xFF16A34A);
      case LogType.late:
        return const Color(0xFFDC2626);
      case LogType.inProgress:
        return const Color(0xFFD97706);
      case LogType.overtime:
        return const Color(0xFF0284C7);
      case LogType.leaves:
        return const Color(0xFF9333EA);
    }
  }
}
