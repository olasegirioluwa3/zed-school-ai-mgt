class ZedChatResponse {
  final String conversationId;
  final String message;
  final Map<String, dynamic>? additionalData;

  const ZedChatResponse({
    required this.conversationId,
    required this.message,
    this.additionalData,
  });

  factory ZedChatResponse.fromJson(Map<String, dynamic> json) {
    // Support both camelCase and alternate field names the API may return
    final conversationId = (json['conversationId'] ??
            json['conversation_id'] ??
            json['_id'] ??
            json['id'] ??
            '')
        ?.toString() ??
        '';

    String message = '';
    if (json['message'] is String) {
      message = json['message'] as String;
    } else if (json['message'] is Map &&
        (json['message'] as Map)['content'] is String) {
      message = (json['message'] as Map)['content'] as String;
    } else if (json['reply'] is String) {
      message = json['reply'] as String;
    } else if (json['response'] is String) {
      message = json['response'] as String;
    } else if (json['content'] is String) {
      message = json['content'] as String;
    } else if (json['text'] is String) {
      message = json['text'] as String;
    } else if (json['data'] is String) {
      message = json['data'] as String;
    } else {
      final raw = json['message'] ??
          json['reply'] ??
          json['response'] ??
          json['content'] ??
          json['text'] ??
          json['answer'];
      message = raw?.toString() ?? '';
    }

    Map<String, dynamic>? additionalData;
    if (json['additionalData'] is Map) {
      additionalData = Map<String, dynamic>.from(json['additionalData'] as Map);
    }

    return ZedChatResponse(
      conversationId: conversationId,
      message: message,
      additionalData: additionalData,
    );
  }
}

