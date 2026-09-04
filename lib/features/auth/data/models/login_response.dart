class LoginResponse {
  final String token;
  final String message;
  final int code;
  final String result;
  final dynamic data;

  LoginResponse({
    required this.token,
    required this.message,
    required this.code,
    required this.result,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      result: json['result'] ?? '',
      data: json['data'],
    );
  }
}
