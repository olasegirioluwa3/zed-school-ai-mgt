class UserModel {
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  UserModel({
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
    };
  }
}
