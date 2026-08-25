class ZedConversation {
  final String conversationId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  const ZedConversation({
    required this.conversationId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ZedConversation.fromJson(Map<String, dynamic> json) {
    final rawCount = json['messageCount'] ?? json['message_count'] ?? json['count'];
    final count = rawCount is int
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '0') ?? 0;

    return ZedConversation(
      conversationId: (json['conversationId'] ?? json['conversation_id'] ?? json['_id'] ?? json['id'] ?? '')?.toString() ?? '',
      title: (json['title'] ?? json['name'] ?? json['subject'])?.toString(),
      createdAt: _parseDateTime((json['createdAt'] ?? json['created_at'])?.toString()),
      updatedAt: _parseDateTime((json['updatedAt'] ?? json['updated_at'])?.toString()),
      messageCount: count,
    );
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

