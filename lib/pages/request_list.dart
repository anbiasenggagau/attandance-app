import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/data/endpoint/requests/request.dart';
import 'package:attandance/data/endpoint/requests/response.dart';
import 'package:attandance/main.dart';
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

  List<RequestRecord> _loadedRecords = [];
  Map<String, List<String>> _availableOptions = {};
  List<String> get years => _availableOptions.keys.toList();
  List<String> get months => _availableOptions[selectedYear] ?? [];
  late String selectedMonth;
  late String selectedYear;

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
    globalDataSync.addListener(_initializeOptionsAndData);

    final now = DateTime.now();
    selectedMonth = monthsName[now.month - 1];
    selectedYear = now.year.toString();

    _scrollController.addListener(_onScroll);
    _initializeOptionsAndData();
  }

  @override
  void dispose() {
    globalDataSync.removeListener(_initializeOptionsAndData);
    _scrollController.dispose();
    super.dispose();
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
      final response = await apiCaller.request.getRecordOptions();
      final options = response.data;

      if (options == null || options.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = "No request options available.";
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
      final apiResponse = await apiCaller.request.getApprovals(
        RequestsPagination(
          pageSize: _pageSize,
          month: targetMonth,
          year: targetYear,
        ),
      );

      final newRecords = apiResponse.data
          .map((item) => RequestRecord.fromApiItem(item))
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
      final apiResponse = await apiCaller.request.getApprovals(
        RequestsPagination(page: nextPage, pageSize: _pageSize),
      );

      final newRecords = apiResponse.data
          .map((item) => RequestRecord.fromApiItem(item))
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
      final apiResponse = await apiCaller.request.getApprovals(
        RequestsPagination(page: prevPage, pageSize: _pageSize),
      );

      final newRecords = apiResponse.data
          .map((item) => RequestRecord.fromApiItem(item))
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

  Widget _buildApprovalsContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_loadedRecords.isEmpty) {
      return const Center(child: Text('No approvals found.'));
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
                        onChanged: (val) => _onFilterChanged(newMonth: val),
                      ),
                      SizedBox(width: 8),
                      // Year Dropdown
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

          Expanded(child: _buildApprovalsContent()),
        ],
      ),
    );
  }
}

class RequestRecord {
  final int id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final RequestType requestType;
  final Status currStatus;
  final String? statusDetail;

  RequestRecord({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    required this.requestType,
    this.currStatus = Status.pending,
    this.statusDetail,
  });

  factory RequestRecord.fromApiItem(RequestItem item) {
    DateTime parsedDate =
        DateTime.tryParse(item.date) ??
        _parseDateString(item.date) ??
        DateTime.now();

    Status mappedStatus = Status.values.firstWhere(
      (e) => e.name.toLowerCase() == item.requestStatus.toLowerCase(),
      orElse: () => Status.pending,
    );

    RequestType mappedType = RequestType.values.firstWhere(
      (e) => e.name.toLowerCase() == item.requestType.toLowerCase(),
      orElse: () => RequestType.leaves,
    );

    return RequestRecord(
      id: item.id,
      date: parsedDate,
      startTime: item.startTime,
      endTime: item.endTime,
      requestType: mappedType,
      currStatus: mappedStatus,
      statusDetail: item.note,
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
                      id: record.id,
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
