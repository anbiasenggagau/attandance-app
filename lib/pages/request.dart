import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/data/endpoint/requests/request.dart';
import 'package:attandance/data/endpoint/requests/response.dart';
import 'package:attandance/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Request extends StatefulWidget {
  final ValueChanged<int>? onRequestCountChanged;
  const Request({super.key, this.onRequestCountChanged});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedLeaveType;
  String? _selectedApproval;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _noteController = TextEditingController();

  CentralApiCaller apiCaller = CentralApiCaller();

  List<RequestOptionApprovalList> _approvalList = [];
  List<String> _leaveTypes = [];
  List<String> get _approvalDepartments =>
      _approvalList.map((val) => val.listName).toList();

  @override
  void initState() {
    super.initState();
    _initializeOptions();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _initializeOptions();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> _initializeOptions() async {
    try {
      final response = await apiCaller.request.getRequestOptions();
      final options = response.data;

      if (options == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = "No request options available.";
        });
        return;
      }

      setState(() {
        _approvalList = options.approvalList;
        _leaveTypes = options.leaveType;
        _isLoading = false;
      });

      widget.onRequestCountChanged?.call(options.outStandingReq);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _postRequest() async {
    if (_fromDate == null ||
        _toDate == null ||
        _selectedApproval == null ||
        (_currentIndex == 0 && _selectedLeaveType == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fill the mandatory field"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedApprovalList = _approvalList.firstWhere(
      (item) => item.listName == _selectedApproval,
    );
    final requestType = _currentIndex == 0 ? "Leaves" : "Overtime";
    final leaveType = requestType == "Leaves" ? _selectedLeaveType : null;
    final note = _noteController.text;
    final startTime = _fromDate!;
    final endTime = _toDate!;

    final request = RequestsRequest(
      approvalListId: selectedApprovalList.id,
      requestType: requestType,
      leaveType: leaveType,
      note: note,
      startTime: startTime,
      endTime: endTime,
    );

    final resp = await apiCaller.request.postRequest(request);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.message), backgroundColor: Colors.red),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.message),
          backgroundColor: Colors.lightGreen,
        ),
      );

      setState(() {
        _noteController.clear();
        _fromDate = null;
        _toDate = null;
        _selectedApproval = null;
        _selectedLeaveType = null;
      });
      globalDataSync.notifyDataChanged();
    }
  }

  Future<void> _selectDateTime(
    BuildContext context, {
    required bool isFrom,
  }) async {
    // If user tries to pick "To" before setting "From", ask them to set "From" first
    if (!isFrom && _fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select "From" date & time first.'),
        ),
      );
      return;
    }

    // 1. Determine minimum allowed date and initial date
    final DateTime now = DateTime.now();
    final DateTime firstDate = (!isFrom && _fromDate != null)
        ? DateTime(
            _fromDate!.year,
            _fromDate!.month,
            _fromDate!.day,
          ) // Start of _fromDate day
        : DateTime(2020);

    DateTime initialDate;
    if (isFrom) {
      initialDate = _fromDate ?? now;
    } else {
      initialDate = _toDate ?? _fromDate ?? now;
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      }
    }

    // 2. Pick Date (Dates before _fromDate are greyed out)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate, // <-- Disables all calendar days before _fromDate
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // 3. Pick Time
    if (!mounted) return;

    // Set default initial time
    TimeOfDay initialTime = TimeOfDay.fromDateTime(
      isFrom ? (_fromDate ?? now) : (_toDate ?? _fromDate ?? now),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0F172A)),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 4. Combine Date & Time
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 5. Validation Check for Time
    if (!isFrom && _fromDate != null && finalDateTime.isBefore(_fromDate!)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '"To" date & time cannot be before "From" date & time.',
          ),
        ),
      );
      return;
    }

    setState(() {
      if (isFrom) {
        _fromDate = finalDateTime;
        // Reset _toDate if it is now earlier than the new _fromDate
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = null;
        }
      } else {
        _toDate = finalDateTime;
      }
    });
  }

  InputDecoration _commonInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.outlineVariant,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.inverseSurface,
          width: 1.5,
        ),
      ),
    );
  }

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

  Widget _buildFormDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, layoutConstraints) {
        return Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            constraints: BoxConstraints(
              minWidth: layoutConstraints.maxWidth,
              maxWidth: layoutConstraints.maxWidth,
              maxHeight: 250,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            onSelected: onChanged,
            itemBuilder: (BuildContext context) {
              return items.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  height: 48,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: value == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                      color: value == null
                          ? Theme.of(context).colorScheme.outlineVariant
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm({required bool isLeave}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render Leave Type ONLY if we are on the Leave tab
          if (isLeave) ...[
            _buildLabel('Leave Type'),
            _buildFormDropdown(
              hint: 'Select leave type',
              value: _selectedLeaveType,
              items: _leaveTypes,
              onChanged: (val) {
                setState(() => _selectedLeaveType = val);
              },
            ),
            const SizedBox(height: 20),
          ],

          // Datetime Picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('From'),
              InkWell(
                onTap: () => _selectDateTime(context, isFrom: true),
                borderRadius: BorderRadius.circular(30),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _formatDate(_fromDate),
                    ),
                    decoration: _commonInputDecoration('Select Date').copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildLabel('To'),
              InkWell(
                onTap: () => _selectDateTime(context, isFrom: false),
                borderRadius: BorderRadius.circular(30),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _formatDate(_toDate),
                    ),
                    decoration: _commonInputDecoration('Select Date').copyWith(
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Approval List
          _buildLabel('Send Approval To'),
          _buildFormDropdown(
            hint: 'Select approval list',
            value: _selectedApproval,
            items: _approvalDepartments,
            onChanged: (val) {
              setState(() => _selectedApproval = val);
            },
          ),
          const SizedBox(height: 20),

          // Optional Note
          _buildLabel('Note (Optional)'),
          TextFormField(
            controller: _noteController,
            maxLines: 4,
            decoration: _commonInputDecoration(
              isLeave
                  ? 'Add a note or reason for leave...'
                  : 'Add a note or reason for overtime...',
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 40),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _postRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null && _errorMessage != "") {
      content = Center(
        child: Column(
          children: [
            Text('Error: $_errorMessage'),
            IconButton.filledTonal(
              onPressed: () {
                _onRefresh();
              },
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Data",
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0F172A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0F172A),
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Leave'),
            Tab(text: 'Overtime'),
          ],
        ),
      ),
      body:
          content ??
          TabBarView(
            controller: _tabController,
            children: [_buildForm(isLeave: true), _buildForm(isLeave: false)],
          ),
    );
  }
}
