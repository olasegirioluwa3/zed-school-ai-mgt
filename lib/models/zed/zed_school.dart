class ZedSchool {
  final String id;
  final String name;
  final String? logoUrl;

  const ZedSchool({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory ZedSchool.fromJson(Map<String, dynamic> json) {
    return ZedSchool(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
