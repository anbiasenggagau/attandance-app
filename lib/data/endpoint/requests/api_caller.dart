import 'dart:convert';
import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/data/endpoint/requests/request.dart';
import 'package:attandance/data/endpoint/requests/response.dart';
import 'package:http/http.dart' as http;

class RequestApiCaller {
  final String baseUrl;
  final http.Client client;
  final String? Function() getToken;

  RequestApiCaller({
    required this.baseUrl,
    required this.getToken,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<RequestDetailResponse> getRequestDetail(int id) async {
    var uri = Uri.parse('$baseUrl/requests/$id');

    final currentToken = getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (currentToken != null && currentToken.isNotEmpty)
        'Authorization': 'Bearer $currentToken',
    };

    final response = await client.get(uri, headers: headers);
    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return RequestDetailResponse.fromJson(jsonBody, response.statusCode);
    } else {
      final errorMsg = jsonBody['message'] ?? 'Failed to fetch request';
      throw Exception(errorMsg);
    }
  }

  Future<ApprovalList> getApprovals(RequestsPagination? request) async {
    var uri = Uri.parse('$baseUrl/requests/approvals');
    if (request != null) {
      uri = uri.replace(queryParameters: request.toQueryParams());
    }

    final currentToken = getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (currentToken != null && currentToken.isNotEmpty)
        'Authorization': 'Bearer $currentToken',
    };

    final response = await client.get(uri, headers: headers);
    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return ApprovalList.fromJson(jsonBody, response.statusCode);
    } else {
      final errorMsg = jsonBody['message'] ?? 'Failed to fetch approval';
      throw Exception(errorMsg);
    }
  }

  Future<RecordOption> getRecordOptions() async {
    try {
      var uri = Uri.parse('$baseUrl/requests/approvals/option');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.get(uri, headers: headers);
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return RecordOption.fromJson(jsonBody, response.statusCode);
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch option';
        throw Exception(errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      throw Exception(message);
    }
  }

  Future<RequestOption> getRequestOptions() async {
    try {
      var uri = Uri.parse('$baseUrl/requests/option');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.get(uri, headers: headers);
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return RequestOption.fromJson(jsonBody, response.statusCode);
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch option';
        throw Exception(errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      throw Exception(message);
    }
  }

  Future<BaseResponse> postRequest(RequestsRequest request) async {
    try {
      var uri = Uri.parse('$baseUrl/requests');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BaseResponse(
          message: jsonBody["message"],
          statusCode: response.statusCode,
        );
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch request';
        return BaseResponse(statusCode: response.statusCode, message: errorMsg);
      }
    } catch (e) {
      final message = "Failed to post data: ${e.toString()} ";
      return BaseResponse(statusCode: 0, message: message);
    }
  }

  Future<BaseResponse> postApproval(RequestsApproval request) async {
    try {
      var uri = Uri.parse('$baseUrl/requests/approvals');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BaseResponse(
          message: jsonBody["message"],
          statusCode: response.statusCode,
        );
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch request';
        return BaseResponse(statusCode: response.statusCode, message: errorMsg);
      }
    } catch (e) {
      final message = "Failed to post data: ${e.toString()} ";
      return BaseResponse(statusCode: 0, message: message);
    }
  }
}
