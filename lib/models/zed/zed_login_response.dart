class ZedLoginResponse {
  final String token;
  final String? userId;
  final String? userName;
  final String? userEmail;

  const ZedLoginResponse({
    required this.token,
    this.userId,
    this.userName,
    this.userEmail,
  });

  factory ZedLoginResponse.fromJson(Map<String, dynamic> json) {
    return ZedLoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }
}
