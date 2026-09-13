import 'package:attandance/data/central_api_caller.dart';

class RequestData {
  final int id;
  final String requestType;
  final String requestStatus;
  final String note;
  final String createdAt;

  RequestData({
    required this.id,
    required this.requestType,
    required this.requestStatus,
    required this.note,
    required this.createdAt,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      id: json['id'] as int? ?? 0,
      requestType: json['requestType'] as String? ?? '',
      requestStatus: json['requestStatus'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class AttendanceDetail {
  final num latitude;
  final num longitude;
  final String photo;

  AttendanceDetail({
    required this.latitude,
    required this.longitude,
    required this.photo,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      latitude: json['latitude'] as num? ?? 0,
      longitude: json['longitude'] as num? ?? 0,
      photo: json['photo'] as String? ?? '',
    );
  }
}

class AttendanceItem {
  final int id;
  final RequestData? requestData;
  final int userId;
  final String userName;
  final String date;
  final DateTime? checkIn; // Typed as DateTime?
  final DateTime? checkOut; // Typed as DateTime?
  final String logType;
  final String createdAt;
  final AttendanceDetail? attendanceDetail;

  AttendanceItem({
    required this.id,
    this.requestData,
    required this.userId,
    required this.userName,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.logType,
    required this.createdAt,
    this.attendanceDetail,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'] as int? ?? 0,
      requestData: json['requestData'] != null
          ? RequestData.fromJson(json['requestData'] as Map<String, dynamic>)
          : null,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      checkIn: json['checkIn'] != null
          ? DateTime.tryParse(json['checkIn'] as String)
          : null,
      checkOut: json['checkOut'] != null
          ? DateTime.tryParse(json['checkOut'] as String)
          : null,
      logType: json['logType'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      attendanceDetail: json['attendanceDetail'] != null
          ? AttendanceDetail.fromJson(
              json['attendanceDetail'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class AttendanceResponse extends BaseResponse {
  final List<AttendanceItem> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  AttendanceResponse({
    required super.statusCode,
    required super.message,
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory AttendanceResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    final list =
        (json['data'] as List<dynamic>?)
            ?.map(
              (item) => AttendanceItem.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return AttendanceResponse(
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      data: list,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
