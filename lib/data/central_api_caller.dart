import 'package:attandance/data/endpoint/attendance/api_caller.dart';
import 'package:attandance/data/endpoint/auth/api_caller.dart';
import 'package:attandance/data/endpoint/requests/api_caller.dart';
import 'package:attandance/main.dart';
import 'package:attandance/pages/login.dart';
import 'package:attandance/storage/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CentralApiCaller {
  static CentralApiCaller? _instance;
  final String baseUrl = "https://attendance.senggagau.uk";
  final http.Client httpClient;
  String? jwtToken;

  late final AuthApiCaller auth;
  late final AttendanceApiCaller attendance;
  late final RequestApiCaller request;

  CentralApiCaller._internal() : httpClient = AuthInterceptorClient() {
    auth = AuthApiCaller(baseUrl: baseUrl, client: httpClient);
    attendance = AttendanceApiCaller(
      baseUrl: baseUrl,
      client: httpClient,
      getToken: () => jwtToken,
    );
    request = RequestApiCaller(
      baseUrl: baseUrl,
      client: httpClient,
      getToken: () => jwtToken,
    );
  }

  factory CentralApiCaller() {
    _instance ??= CentralApiCaller._internal();
    return _instance!;
  }

  Future<String?> setToken(String? token) async {
    if (token == null) {
      var tokenStorage = await TokenStorage.getToken();
      if (tokenStorage != null && tokenStorage.isNotEmpty) {
        jwtToken = tokenStorage;
      }
    } else {
      jwtToken = token;
    }

    return jwtToken;
  }
}

class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      _handleUnauthorized();
    }

    return response;
  }

  void _handleUnauthorized() async {
    await TokenStorage.deleteToken();
    CentralApiCaller().jwtToken = null;

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}

class BaseResponse {
  final int statusCode;
  final String message;

  BaseResponse({required this.statusCode, required this.message});
}
