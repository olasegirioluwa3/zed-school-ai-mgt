class School {
  final String id;
  final String name;
  final String? logoUrl;

  const School({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  School copyWith({
    String? id,
    String? name,
    String? logoUrl,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
