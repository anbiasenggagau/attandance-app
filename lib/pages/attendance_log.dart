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
    final screenSize = MediaQuery.of(context).size;

    Widget BuildMetric(
      BuildContext context,
      String label,
      String value,
      IconData icon,
    ) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        child: const Icon(Icons.linked_camera),
      ),
      body: Column(
        children: [
          // Top Part: Filter Data Option
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

          // Middle Top Part: Main Table Log
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 296),
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

                Widget buildCell(String text) {
                  return Container(
                    width: colWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.centerLeft,
                    child: Text(text, softWrap: true),
                  );
                }

                final columns = [
                  DataColumn(label: buildCell("Date")),
                  DataColumn(label: buildCell("Clock In")),
                  DataColumn(label: buildCell("Clock Out")),
                  DataColumn(label: buildCell("Working Hours")),
                ];

                return Column(
                  children: [
                    DataTable(
                      horizontalMargin: 0,
                      columnSpacing: 0,
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      headingTextStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                      dataTextStyle: const TextStyle(fontSize: 11),
                      columns: columns,
                      rows: [],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowHeight: 0,
                          horizontalMargin: 0,
                          columnSpacing: 0,
                          dataTextStyle: const TextStyle(fontSize: 11),
                          columns: columns,
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
                            DataRow(
                              cells: [
                                DataCell(buildCell("04 Jan 2026")),
                                DataCell(buildCell("09:00")),
                                DataCell(buildCell("17:00")),
                                DataCell(buildCell("8 Hours")),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(buildCell("05 Jan 2026")),
                                DataCell(buildCell("09:00")),
                                DataCell(buildCell("17:00")),
                                DataCell(buildCell("8 Hours")),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(buildCell("06 Jan 2026")),
                                DataCell(buildCell("09:00")),
                                DataCell(buildCell("17:00")),
                                DataCell(buildCell("8 Hours")),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(buildCell("07 Jan 2026")),
                                DataCell(buildCell("09:00")),
                                DataCell(buildCell("17:00")),
                                DataCell(buildCell("8 Hours")),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Middle Bottom Part: Current Day
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: screenSize.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Attendance",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "In Progress",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BuildMetric(context, "Clock In", "09:00", Icons.login),
                    BuildMetric(context, "Clock Out", "--", Icons.logout),
                    BuildMetric(
                      context,
                      "Location",
                      "Tokyo",
                      Icons.location_on_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
