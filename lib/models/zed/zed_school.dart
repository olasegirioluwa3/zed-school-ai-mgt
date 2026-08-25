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
    // API returns MongoDB-style '_id'; fall back to 'id' for compatibility.
    final id = (json['_id'] ?? json['id']) as String? ?? '';
    return ZedSchool(
      id: id,
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
