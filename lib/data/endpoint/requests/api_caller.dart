import 'dart:convert';
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
      final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
      throw Exception(errorMsg);
    }
  }

  Future<ApprovalList> getApprovals(RequestsRequest? request) async {
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
      final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
      throw Exception(errorMsg);
    }
  }

  Future<RecordOption> getOptions() async {
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
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
        throw Exception(errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      throw Exception(message);
    }
  }
}
