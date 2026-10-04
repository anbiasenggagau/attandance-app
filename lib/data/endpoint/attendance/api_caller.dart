import 'dart:convert';
import 'dart:typed_data';
import 'package:attandance/data/central_api_caller.dart';
import 'package:http/http.dart' as http;
import 'request.dart';
import 'response.dart';

class AttendanceApiCaller {
  final String baseUrl;
  final http.Client client;
  final String? Function() getToken;

  AttendanceApiCaller({
    required this.baseUrl,
    required this.getToken,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<AttendanceResponse> getAttendance(
    AttendancePagination? request,
  ) async {
    var uri = Uri.parse('$baseUrl/attendances');
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
      return AttendanceResponse.fromJson(jsonBody, response.statusCode);
    } else {
      final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
      throw Exception(errorMsg);
    }
  }

  Future<CurrentAttendance> getCurrentAttendance() async {
    try {
      var uri = Uri.parse('$baseUrl/attendances/today');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.get(uri, headers: headers);
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CurrentAttendance.fromJson(jsonBody, response.statusCode);
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
        throw Exception(errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      throw Exception(message);
    }
  }

  Future<Uint8List> getAttendancePhoto(String photoPath) async {
    final uri = Uri.parse('$baseUrl$photoPath');
    final token = getToken();

    final headers = <String, String>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(uri, headers: headers);
    final contentType = response.headers['content-type'] ?? '';

    if (contentType.contains('application/json')) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMsg = jsonBody['message'] ?? 'Failed to retrieve photo';
      throw Exception(errorMsg);
    }

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to load photo (Status Code: ${response.statusCode})',
      );
    }
  }

  Future<LogOption> getOptions() async {
    try {
      var uri = Uri.parse('$baseUrl/attendances/option');

      final currentToken = getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (currentToken != null && currentToken.isNotEmpty)
          'Authorization': 'Bearer $currentToken',
      };

      final response = await client.get(uri, headers: headers);
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LogOption.fromJson(jsonBody, response.statusCode);
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to fetch attendance';
        throw Exception(errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      throw Exception(message);
    }
  }

  Future<BaseResponse> postAttendance(PostAttendanceRequest requestBody) async {
    try {
      var uri = Uri.parse('$baseUrl/attendances');
      final request = http.MultipartRequest('POST', uri);

      final currentToken = getToken();
      request.headers["Content-Type"] = "application/json";
      if (currentToken != null && currentToken.isNotEmpty) {
        request.headers["Authorization"] = 'Bearer $currentToken';
      }

      await requestBody.toFormData(request);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostAttendanceResponse.fromJson(jsonBody, response.statusCode);
      } else {
        final errorMsg = jsonBody['message'] ?? 'Failed to post attendance';
        return BaseResponse(statusCode: response.statusCode, message: errorMsg);
      }
    } catch (e) {
      final message = "Failed to retrieve data: ${e.toString()} ";
      return BaseResponse(statusCode: 0, message: message);
    }
  }
}
