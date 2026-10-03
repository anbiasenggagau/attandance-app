import 'package:attandance/data/central_api_caller.dart';

class UserHeader {
  final int id;
  final String username;
  final String name;

  UserHeader({required this.id, required this.username, required this.name});

  factory UserHeader.fromJson(Map<String, dynamic> json) {
    return UserHeader(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class LoginResponse extends BaseResponse {
  final String token;
  final UserHeader user;

  LoginResponse({
    required super.statusCode,
    required super.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return LoginResponse(
      statusCode: statusCode,
      message: json['message'] as String? ?? '',
      token: json['token'] as String? ?? '',
      user: UserHeader.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
