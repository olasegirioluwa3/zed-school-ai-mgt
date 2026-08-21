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
    final messagesList = json['messages'] as List<dynamic>?;
    final messages = messagesList
            ?.map((m) => ZedChatMessage.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return ZedConversationDetails(
      conversationId: json['conversationId'] as String,
      schoolId: json['schoolId'] as String,
      userId: json['userId'] as String,
      messages: messages,
      createdAt: _parseDateTime(json['createdAt'] as String?),
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
