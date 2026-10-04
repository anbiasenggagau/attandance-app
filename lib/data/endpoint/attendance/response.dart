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
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String logType;
  final String createdAt;
  final AttendanceDetail? checkInDetail;
  final AttendanceDetail? checkOutDetail;

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
    this.checkInDetail,
    this.checkOutDetail,
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
      checkInDetail: json['checkInDetail'] != null
          ? AttendanceDetail.fromJson(
              json['checkInDetail'] as Map<String, dynamic>,
            )
          : null,
      checkOutDetail: json['checkOutDetail'] != null
          ? AttendanceDetail.fromJson(
              json['checkOutDetail'] as Map<String, dynamic>,
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
  final bool hasPrevPage;
  final bool hasNextPage;

  AttendanceResponse({
    required super.statusCode,
    required super.message,
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    this.hasPrevPage = false,
    this.hasNextPage = false,
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
      hasPrevPage: json['hasPrevPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

class CurrentAttendance extends BaseResponse {
  final AttendanceItem? data;

  CurrentAttendance({
    required super.statusCode,
    required super.message,
    this.data,
  });

  factory CurrentAttendance.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    return CurrentAttendance(
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? AttendanceItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LogOption extends BaseResponse {
  final Map<String, List<String>>? data;

  LogOption({required super.statusCode, required super.message, this.data});

  factory LogOption.fromJson(Map<String, dynamic> json, int statusCode) {
    Map<String, List<String>>? parsedData;

    if (json["data"] != null && json["data"] is Map) {
      parsedData = (json["data"] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
    }

    return LogOption(
      statusCode: statusCode,
      message: json["message"] as String? ?? "",
      data: parsedData,
    );
  }
}

class PostAttendanceResponse extends BaseResponse {
  final AttendanceItem? data;

  PostAttendanceResponse({
    required super.statusCode,
    required super.message,
    this.data,
  });

  factory PostAttendanceResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    return PostAttendanceResponse(
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? AttendanceItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
