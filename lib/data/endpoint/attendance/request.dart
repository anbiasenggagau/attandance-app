class AttendanceRequest {
  final int page;
  final int pageSize;

  AttendanceRequest({this.page = 1, this.pageSize = 10});

  Map<String, String> toQueryParams() {
    return {'page': page.toString(), 'pageSize': pageSize.toString()};
  }
}
