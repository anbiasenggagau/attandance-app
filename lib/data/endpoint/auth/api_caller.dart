import 'dart:convert';
import 'package:http/http.dart' as http;
import 'request.dart';
import 'response.dart';

class AuthApiCaller {
  final String baseUrl;
  final http.Client client;

  AuthApiCaller({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(
        jsonDecode(response.body),
        response.statusCode,
      );
    } else {
      final errorMsg = jsonDecode(response.body)['message'] ?? 'Login failed';
      throw Exception(errorMsg);
    }
  }
}
