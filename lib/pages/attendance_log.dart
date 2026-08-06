import 'package:flutter/material.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  String selectedMonth = 'Jan';
  String selectedYear = '2026';

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
              height: 36, // Compact height per item
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
            borderRadius: BorderRadius.circular(
              30,
            ), // Fully circular pill border
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double colWidth = constraints.maxWidth / 4;

                // Helper function to build uniform left-aligned cells with horizontal padding
                Widget buildCell(String text) {
                  return Container(
                    width: colWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ), // Spacing from left & right cell edges
                    alignment: Alignment.centerLeft, // Left-align text
                    child: Text(text, softWrap: true),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: 0,
                    headingRowColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    headingTextStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    dataTextStyle: const TextStyle(fontSize: 11),
                    columns: [
                      DataColumn(label: buildCell("Date")),
                      DataColumn(label: buildCell("Clock In")),
                      DataColumn(label: buildCell("Clock Out")),
                      DataColumn(label: buildCell("Working Hours")),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(buildCell("01 Jan 2026")),
                          DataCell(buildCell("09:00")),
                          DataCell(buildCell("17:00")),
                          DataCell(buildCell("8 Hours")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(buildCell("02 Jan 2026")),
                          DataCell(buildCell("09:00")),
                          DataCell(buildCell("17:00")),
                          DataCell(buildCell("8 Hours")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(buildCell("03 Jan 2026")),
                          DataCell(buildCell("09:00")),
                          DataCell(buildCell("17:00")),
                          DataCell(buildCell("8 Hours")),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
