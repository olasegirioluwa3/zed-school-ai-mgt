import 'dart:async';
import '../models/chat_message.dart';

abstract class SchoolAiService {
  Future<AiResponse> sendMessage({
    required String schoolId,
    required String message,
    required List<ChatMessage> conversation,
  });
  
  Stream<AiResponseChunk> sendMessageStream({
    required String schoolId,
    required String message,
    required List<ChatMessage> conversation,
  });
}

class AiResponseChunk {
  final String content;
  final bool isComplete;
  final bool isError;

  AiResponseChunk({
    required this.content,
    this.isComplete = false,
    this.isError = false,
  });
}

class AiResponse {
  final String content;
  final bool isLoading;
  final bool isError;
  final bool requiresConfirmation;
  final String? confirmationAction;
  final List<String>? confirmationButtons;

  AiResponse({
    required this.content,
    this.isLoading = false,
    this.isError = false,
    this.requiresConfirmation = false,
    this.confirmationAction,
    this.confirmationButtons,
  });
}

class MockSchoolAiService implements SchoolAiService {
  @override
  Future<AiResponse> sendMessage({
    required String schoolId,
    required String message,
    required List<ChatMessage> conversation,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final lowerMessage = message.toLowerCase();

    // Mock responses based on common school administration queries
    if (lowerMessage.contains('how many students') && lowerMessage.contains('paid')) {
      return AiResponse(
        content: '32 students in SSS 3 have paid their school fees for the current term.',
      );
    }

    if (lowerMessage.contains('new students') || lowerMessage.contains('who are the new')) {
      return AiResponse(
        content: 'There are 4 new students in JSS 3:\n1. Adebayo Ayomide\n2. Chinedu Okafor\n3. Sarah Johnson\n4. Musa Ibrahim',
      );
    }

    if (lowerMessage.contains('enroll') || lowerMessage.contains('promote')) {
      // Extract student name from message (simple extraction)
      final studentName = _extractStudentName(message);
      final targetClass = _extractTargetClass(message);
      
      return AiResponse(
        content: 'I found $studentName. You\'re asking me to enroll the student into $targetClass. Would you like me to proceed?',
        requiresConfirmation: true,
        confirmationAction: message,
        confirmationButtons: ['Cancel', 'Confirm'],
      );
    }

    if (lowerMessage.contains('how many students')) {
      return AiResponse(
        content: 'There are 40 students in SSS 3.',
      );
    }

    if (lowerMessage.contains('who has not paid') || lowerMessage.contains('outstanding fees')) {
      return AiResponse(
        content: '8 students in SSS 3 have not paid their school fees:\n1. John Doe\n2. Jane Smith\n3. Michael Brown\n4. Emily Davis\n5. David Wilson\n6. Sarah Taylor\n7. James Anderson\n8. Lisa Thomas',
      );
    }

    if (lowerMessage.contains('total amount') || lowerMessage.contains('how much')) {
      return AiResponse(
        content: 'The total amount of school fees collected this term is ₦1,280,000.',
      );
    }

    if (lowerMessage.contains('teachers')) {
      return AiResponse(
        content: 'There are 25 teachers in the school.',
      );
    }

    if (lowerMessage.contains('class teacher')) {
      return AiResponse(
        content: 'Mrs. Adewale is the class teacher for JSS 3.',
      );
    }

    if (lowerMessage.contains('attendance')) {
      return AiResponse(
        content: 'Today\'s attendance for SSS 2:\nPresent: 35 students\nAbsent: 5 students',
      );
    }

    if (lowerMessage.contains('absent')) {
      return AiResponse(
        content: '5 students were absent today in SSS 2:\n1. Peter John\n2. Mary Grace\n3. Samuel Ade\n4. Blessing Oke\n5. Emmanuel Chinaza',
      );
    }

    // Default response
    return AiResponse(
      content: 'I understand you\'re asking about school administration. Could you please provide more specific details about what you\'d like to know or do?',
    );
  }

  @override
  Stream<AiResponseChunk> sendMessageStream({
    required String schoolId,
    required String message,
    required List<ChatMessage> conversation,
  }) async* {
    // Simulate streaming response
    final response = await sendMessage(
      schoolId: schoolId,
      message: message,
      conversation: conversation,
    );
    
    // Stream the response word by word
    final words = response.content.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      yield AiResponseChunk(
        content: words.sublist(0, i + 1).join(' ') + (i < words.length - 1 ? ' ' : ''),
        isComplete: i == words.length - 1,
      );
    }
  }

  String _extractStudentName(String message) {
    // Simple extraction - in real app, use proper NLP
    final words = message.split(' ');
    for (int i = 0; i < words.length - 1; i++) {
      if (words[i].toLowerCase() == 'enroll' || words[i].toLowerCase() == 'promote') {
        if (i + 1 < words.length) {
          return words[i + 1];
        }
      }
    }
    return 'the student';
  }

  String _extractTargetClass(String message) {
    // Simple extraction - in real app, use proper NLP
    final words = message.split(' ');
    for (int i = 0; i < words.length - 1; i++) {
      if (words[i].toLowerCase() == 'into' || words[i].toLowerCase() == 'to') {
        if (i + 1 < words.length) {
          return words[i + 1];
        }
      }
    }
    return 'the specified class';
  }
}
