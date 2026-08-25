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
      id: (json['id'] ?? json['_id'] ?? '')?.toString() ?? '',
      role: _parseRole((json['role'] ?? json['sender'])?.toString()),
      content: (json['content'] ?? json['message'] ?? json['text'] ?? json['reply'] ?? '')?.toString() ?? '',
      timestamp: _parseDateTime((json['timestamp'] ?? json['createdAt'] ?? json['created_at'])?.toString()),
    );
  }

  static ZedMessageRole _parseRole(String? role) {
    if (role == null) return ZedMessageRole.assistant;
    final r = role.toLowerCase();
    if (r == 'user' || r == 'student' || r == 'parent' || r == 'teacher' || r == 'admin') {
      return ZedMessageRole.user;
    }
    return ZedMessageRole.assistant;
  }

  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}

