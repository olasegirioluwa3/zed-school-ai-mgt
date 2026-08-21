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
    return ZedChatResponse(
      conversationId: json['conversationId'] as String,
      message: json['message'] as String,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
}
