import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/pages/request_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum RequestPageType { approval, detail }

enum RequestType { overtime, leaves }

class RequestDetail extends StatefulWidget {
  final RequestPageType pageType;
  final RequestType requestType;

  final int id;

  const RequestDetail({
    super.key,
    this.pageType = RequestPageType.detail,
    required this.requestType,

    required this.id,
  });

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  bool _isLoading = true;

  late String requestorName;
  late String? leaveType;
  late DateTime fromDate;
  late DateTime toDate;
  late String approvalList;
  late String note;
  late Status status;

  late bool isPending;
  late bool isApproved;
  late bool isDenied;

  CentralApiCaller apiCaller = CentralApiCaller();

  Future<void> _initializeData() async {
    final resp = await apiCaller.request.getRequestDetail(widget.id);

    if (resp.statusCode != 200) {
      return;
    }

    Status mappedStatus = Status.values.firstWhere(
      (e) => e.name.toLowerCase() == resp.data!.requestStatus.toLowerCase(),
      orElse: () => Status.pending,
    );

    requestorName = resp.data!.requestorName;
    leaveType = resp.data!.leaveType;
    fromDate = resp.data!.startTime;
    toDate = resp.data!.endTime;
    approvalList = resp.data!.approvalListName;
    note = resp.data!.note ?? "";
    status = mappedStatus;

    isPending = status == Status.pending;
    isApproved = status == Status.approved;
    isDenied = status == Status.denied;

    setState(() {
      _isLoading = false;
    });
  }

  String _formatDate(DateTime dateTime) {
    // Convert to UTC first, then shift by +7 hours
    final utcPlus7 = dateTime.toUtc().add(const Duration(hours: 7));

    // Formats as '26 Aug 2026, 08:00 AM'
    return DateFormat('dd MMM yyyy, hh:mm a').format(utcPlus7);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
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

  Widget _buildValue(
    BuildContext context,
    String value, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
            ),
          ),

          if (icon != null) ...[
            const SizedBox(width: 12),
            Icon(icon, size: 18, color: Colors.grey),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Detail")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.requestType == RequestType.leaves) ...[
                    _buildLabel('Leave Type'),
                    _buildValue(context, leaveType!, icon: Icons.event_note),
                  ],

                  const SizedBox(height: 20),

                  _buildLabel("Requestor Name"),
                  _buildValue(context, requestorName, icon: Icons.person),

                  const SizedBox(height: 20),

                  _buildLabel('From'),
                  _buildValue(
                    context,
                    _formatDate(fromDate),
                    icon: Icons.calendar_today,
                  ),

                  const SizedBox(height: 10),

                  _buildLabel('To'),
                  _buildValue(
                    context,
                    _formatDate(toDate),
                    icon: Icons.calendar_today,
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Approval To'),
                  _buildValue(context, approvalList, icon: Icons.approval),

                  const SizedBox(height: 20),

                  _buildLabel('Note'),
                  _buildValue(context, note, maxLines: 4),
                  const SizedBox(height: 40),

                  widget.pageType == RequestPageType.approval
                      ? SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  // Deny Button
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isPending
                                          ? () {
                                              // Handle deny action
                                            }
                                          : null, // Disables button when not pending
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: BorderSide(
                                          color: isPending || isDenied
                                              ? Colors.red
                                              : Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        isDenied ? 'Denied' : 'Deny',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Approve Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isPending
                                          ? () {
                                              // Handle approve action
                                            }
                                          : null, // Disables button when not pending
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isApproved ? 'Approved' : 'Approve',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}
