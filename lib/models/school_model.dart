class SchoolModel {
  final String id;
  final String schoolName;
  final String? logoUrl;

  SchoolModel({
    required this.id,
    required this.schoolName,
    this.logoUrl,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      schoolName: json['schoolName'] ?? json['name'] ?? 'Unknown School',
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'logoUrl': logoUrl,
    };
  }
}
