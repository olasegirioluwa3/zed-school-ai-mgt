class ZedLoginRequest {
  final String contact;
  final String password;

  const ZedLoginRequest({
    required this.contact,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'password': password,
    };
  }
}
