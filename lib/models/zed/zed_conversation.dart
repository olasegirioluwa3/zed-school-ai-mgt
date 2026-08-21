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
    return ZedConversation(
      conversationId: json['conversationId'] as String,
      title: json['title'] as String?,
      createdAt: _parseDateTime(json['createdAt'] as String?),
      updatedAt: _parseDateTime(json['updatedAt'] as String?),
      messageCount: json['messageCount'] as int? ?? 0,
    );
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
