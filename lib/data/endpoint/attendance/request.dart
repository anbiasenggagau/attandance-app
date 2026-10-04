import 'dart:io';

import 'package:http/http.dart' as http;

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

class PostAttendanceRequest {
  final File image;
  final double latitude;
  final double longitude;
  final String attendanceType;

  PostAttendanceRequest({
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.attendanceType,
  });

  Future<void> toFormData(http.MultipartRequest request) async {
    request.fields["latitude"] = latitude.toString();
    request.fields["longitude"] = longitude.toString();
    request.fields["attendanceType"] = attendanceType;

    final imageFile = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(imageFile);
  }
}
