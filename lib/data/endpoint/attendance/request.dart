class AttendancePagination {
  final int page;
  final int pageSize;
  final String? month;
  final String? year;

  AttendancePagination({
    this.page = 1,
    this.pageSize = 10,
    this.month,
    this.year,
  });

  Map<String, String> toQueryParams() {
    final query = {'page': page.toString(), 'pageSize': pageSize.toString()};
    final currentYear = year;
    if (currentYear != null && currentYear.isNotEmpty) {
      query["year"] = currentYear;
    }

    final currentMonth = month;
    if (currentMonth != null && currentMonth.isNotEmpty) {
      query["month"] = currentMonth;
    }
    return query;
  }
}
