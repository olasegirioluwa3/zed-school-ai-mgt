enum ZedMessageRole {
  user,
  assistant,
}

class ZedChatMessage {
  final String id;
  final ZedMessageRole role;
  final String content;
  final DateTime timestamp;

  const ZedChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ZedChatMessage.fromJson(Map<String, dynamic> json) {
    return ZedChatMessage(
      id: json['id'] as String,
      role: _parseRole(json['role'] as String),
      content: json['content'] as String,
      timestamp: _parseDateTime(json['timestamp'] as String?),
    );
  }

  static ZedMessageRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return ZedMessageRole.user;
      case 'assistant':
        return ZedMessageRole.assistant;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }

  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}
