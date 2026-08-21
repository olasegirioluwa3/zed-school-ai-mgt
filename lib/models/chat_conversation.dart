import 'chat_message.dart';

class ChatConversation {
  final String id;
  final String schoolId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatConversation copyWith({
    String? id,
    String? schoolId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final conversationDate = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);

    if (conversationDate == today) {
      return 'Today';
    } else if (conversationDate == yesterday) {
      return 'Yesterday';
    } else if (conversationDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'Previous 7 days';
    } else {
      return 'Older';
    }
  }
}
