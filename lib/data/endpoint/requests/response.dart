import 'package:attandance/data/central_api_caller.dart';

class RequestItem {
  final int id;
  final String requestorId;
  final String requestorName;
  final int approvalListId;
  final String approvalListName;
  final String requestType;
  final String requestStatus;
  final String leaveType;
  final String? note;
  final String date;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  RequestItem({
    required this.id,
    required this.requestorId,
    required this.requestorName,
    required this.approvalListId,
    required this.approvalListName,
    required this.requestType,
    required this.requestStatus,
    required this.leaveType,
    this.note,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      id: json['id'] as int? ?? 0,
      requestorId: json['requestorId']?.toString() ?? '',
      requestorName: json['requestorName'] as String? ?? '',
      approvalListId: json['approvalListId'] as int? ?? 0,
      approvalListName: json['approvalListName'] as String? ?? '',
      requestType: json['requestType'] as String? ?? '',
      requestStatus: json['requestStatus'] as String? ?? '',
      leaveType: json['leaveType'] as String? ?? '',
      note: json['note'] as String? ?? '',
      date: json['date'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ApprovalList extends BaseResponse {
  final List<RequestItem> data;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasPrevPage;
  final bool hasNextPage;

  ApprovalList({
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

  factory ApprovalList.fromJson(Map<String, dynamic> json, int statusCode) {
    final list =
        (json['data'] as List<dynamic>?)
            ?.map((item) => RequestItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return ApprovalList(
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

class RequestDetailResponse extends BaseResponse {
  final RequestItem? data;

  RequestDetailResponse({
    required super.statusCode,
    required super.message,
    this.data,
  });

  factory RequestDetailResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    return RequestDetailResponse(
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? RequestItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RecordOption extends BaseResponse {
  final Map<String, List<String>>? data;

  RecordOption({
    required super.statusCode,
    required super.message,
    this.data,
  }); // Added semicolon here

  factory RecordOption.fromJson(Map<String, dynamic> json, int statusCode) {
    Map<String, List<String>>? parsedData;

    if (json["data"] != null && json["data"] is Map) {
      parsedData = (json["data"] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      );
    }

    return RecordOption(
      statusCode: statusCode,
      message: json["message"] as String? ?? "",
      data: parsedData,
    );
  }
}

class RequestOption extends BaseResponse {
  final RequestOptionData? data;

  RequestOption({required super.statusCode, required super.message, this.data});

  factory RequestOption.fromJson(Map<String, dynamic> json, int statusCode) {
    if (json["data"] != null) {
      return RequestOption(
        statusCode: statusCode,
        message: json["message"],
        data: RequestOptionData.fromJson(json["data"]),
      );
    }
    return RequestOption(statusCode: statusCode, message: json["message"]);
  }
}

class RequestOptionData {
  final List<RequestOptionApprovalList> approvalList;
  final List<String> leaveType;
  final int outStandingReq;

  RequestOptionData({
    required this.approvalList,
    required this.leaveType,
    required this.outStandingReq,
  });

  factory RequestOptionData.fromJson(Map<String, dynamic> json) {
    final list =
        (json['approvalLists'] as List<dynamic>?)
            ?.map(
              (item) => RequestOptionApprovalList.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    final List<String> leaveType = List<String>.from(json['leaveType']);
    return RequestOptionData(
      approvalList: list,
      leaveType: leaveType,
      outStandingReq: json['outStandingReq'],
    );
  }
}

class RequestOptionApprovalList {
  final int id;
  final String listName;

  RequestOptionApprovalList({required this.id, required this.listName});

  factory RequestOptionApprovalList.fromJson(Map<String, dynamic> json) {
    return RequestOptionApprovalList(
      id: json["id"],
      listName: json["listName"],
    );
  }
}
