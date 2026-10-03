class RequestsPagination {
  final int page;
  final int pageSize;
  final String? month;
  final String? year;

  RequestsPagination({
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

class RequestsRequest {
  final int approvalListId;
  final String requestType;
  final String? leaveType;
  final String note;
  final DateTime startTime;
  final DateTime endTime;

  RequestsRequest({
    required this.approvalListId,
    required this.requestType,
    this.leaveType,
    required this.note,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'approvalListId': approvalListId,
    'requestType': requestType,
    'leaveType': leaveType,
    'note': note,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
  };
}
