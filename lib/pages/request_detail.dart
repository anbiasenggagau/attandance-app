import 'package:attandance/pages/request_list.dart';
import 'package:flutter/material.dart';

enum PageType { approval, detail }

class RequestDetail extends StatefulWidget {
  final PageType pageType;
  final Status status;
  const RequestDetail({
    super.key,
    this.pageType = PageType.detail,
    this.status = Status.pending,
  });

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
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
    final isPending = widget.status == Status.pending;
    final isApproved = widget.status == Status.approved;
    final isDenied = widget.status == Status.denied;

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Leave Type'),
            _buildValue(context, 'Annual Leave', icon: Icons.event_note),

            const SizedBox(height: 20),

            _buildLabel('From'),
            _buildValue(
              context,
              '26 Aug 2026, 08:00 AM',
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 10),

            _buildLabel('To'),
            _buildValue(
              context,
              '26 Aug 2026, 04:00 PM',
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: 20),

            _buildLabel('Approval To'),
            _buildValue(context, 'Human Resources', icon: Icons.approval),

            const SizedBox(height: 20),

            _buildLabel('Note'),
            _buildValue(
              context,
              'Working overtime to complete the monthly report.',
              maxLines: 4,
            ),
            const SizedBox(height: 40),

            widget.pageType == PageType.approval
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
                                    borderRadius: BorderRadius.circular(30),
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
                                    borderRadius: BorderRadius.circular(30),
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
