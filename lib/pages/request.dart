import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  String? _selectedLeaveType;
  String? _selectedApproval;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _noteController = TextEditingController();

  // Enum List
  final List<String> _leaveTypes = [
    'Annual Leave',
    'Sick Leave',
    'Maternity Leave',
    'Unpaid Leave',
  ];

  final List<String> _approvalDepartments = [
    'Direct Manager',
    'Finance Department',
    'General Affairs (GA)',
    'Human Resources (HR)',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Future<void> _selectDateTime(
    BuildContext context, {
    required bool isFrom,
  }) async {
    final DateTime initialDate = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? _fromDate ?? DateTime.now());

    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
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

    // 2. Pick Time
    if (!mounted) return;
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);
    final TimeOfDay? pickedTime = await showTimePicker(
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

    // 3. Combine them
    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isFrom) {
        _fromDate = finalDateTime;
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
              onPressed: () {},
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          bottom: const TabBar(
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
        body: TabBarView(
          children: [_buildForm(isLeave: true), _buildForm(isLeave: false)],
        ),
      ),
    );
  }
}
