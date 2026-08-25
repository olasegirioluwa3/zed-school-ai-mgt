class ZedUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String? profilePicture;
  final String? coverPicture;
  final String? dateOfBirth;
  final String? gender;
  final String? role;
  final String? status;
  final String? walletId;

  const ZedUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profilePicture,
    this.coverPicture,
    this.dateOfBirth,
    this.gender,
    this.role,
    this.status,
    this.walletId,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ZedUser.fromJson(Map<String, dynamic> json) {
    return ZedUser(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      coverPicture: json['coverPicture'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      walletId: json['walletId'] as String?,
    );
  }
}

class ZedLoginResponse {
  final String token;
  final String message;
  final ZedUser? user;
  final bool isBirthdayToday;

  // Convenience getters for backwards compatibility
  String? get userId => user?.id;
  String? get userName => user?.username.isNotEmpty == true ? user!.username : user?.fullName;
  String? get userEmail => user?.email;

  const ZedLoginResponse({
    required this.token,
    this.message = '',
    this.user,
    this.isBirthdayToday = false,
  });

  factory ZedLoginResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['data'] is Map<String, dynamic> &&
                (json['data'] as Map<String, dynamic>)['user'] is Map<String, dynamic>
            ? (json['data'] as Map<String, dynamic>)['user'] as Map<String, dynamic>
            : (json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null));

    final token = json['token'] as String? ??
        (json['data'] is Map<String, dynamic> ? (json['data'] as Map<String, dynamic>)['token'] as String? : null) ??
        '';

    return ZedLoginResponse(
      token: token,
      message: json['message'] as String? ?? '',
      user: userData != null ? ZedUser.fromJson(userData) : null,
      isBirthdayToday: json['isBirthdayToday'] as bool? ?? false,
    );
  }
}
