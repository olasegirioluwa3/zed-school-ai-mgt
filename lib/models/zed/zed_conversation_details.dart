import 'zed_chat_message.dart';

class ZedConversationDetails {
  final String conversationId;
  final String schoolId;
  final String userId;
  final List<ZedChatMessage> messages;
  final DateTime createdAt;

  const ZedConversationDetails({
    required this.conversationId,
    required this.schoolId,
    required this.userId,
    required this.messages,
    required this.createdAt,
  });

  factory ZedConversationDetails.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['messages'] ?? json['chat'] ?? json['history']) as List<dynamic>?;
    final messages = messagesList
            ?.whereType<Map<dynamic, dynamic>>()
            .map((m) => ZedChatMessage.fromJson(Map<String, dynamic>.from(m)))
            .toList() ??
        [];

    return ZedConversationDetails(
      conversationId: (json['conversationId'] ?? json['conversation_id'] ?? json['_id'] ?? json['id'] ?? '')?.toString() ?? '',
      schoolId: (json['schoolId'] ?? json['school_id'] ?? json['school'] ?? '')?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'] ?? json['user'] ?? '')?.toString() ?? '',
      messages: messages,
      createdAt: _parseDateTime((json['createdAt'] ?? json['created_at'])?.toString()),
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

