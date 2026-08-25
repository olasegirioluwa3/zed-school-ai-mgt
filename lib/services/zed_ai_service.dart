import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/zed/zed_chat_response.dart';
import '../models/zed/zed_conversation.dart';
import '../models/zed/zed_conversation_details.dart';
import '../models/zed/zed_api_exception.dart';

abstract class ZedAiService {
  Future<ZedChatResponse> sendMessage({
    required String schoolId,
    required String message,
    String? conversationId,
  });

  Future<List<ZedConversation>> getConversations({
    required String schoolId,
  });

  Future<ZedConversationDetails> getConversation({
    required String schoolId,
    required String conversationId,
  });

  Future<void> deleteConversation({
    required String schoolId,
    required String conversationId,
  });
}

class ZedAiServiceImpl implements ZedAiService {
  final http.Client _client;
  final String _baseUrl;

  ZedAiServiceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.zedAiBaseUrl;

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Add authorization header if token is available
    if (ApiConfig.authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
    }
    
    return headers;
  }

  @override
  Future<ZedChatResponse> sendMessage({
    required String schoolId,
    required String message,
    String? conversationId,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.chatEndpoint}');
    
    final body = <String, dynamic>{
      'schoolId': schoolId,
      'message': message,
    };
    
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversationId'] = conversationId;
    }

    try {
      final response = await _client
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      // Log the full response for debugging
      debugPrint('=== AI Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw body: ${response.body}');
      debugPrint('==================');

      final dynamic decoded = jsonDecode(response.body);

      // Check HTTP status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'Failed to send message (${response.statusCode})';
        String? errorDetails;
        if (decoded is Map) {
          errorMsg = decoded['message']?.toString() ??
              decoded['error']?.toString() ??
              errorMsg;
          errorDetails = decoded['errorDetails']?.toString() ??
              decoded['details']?.toString();
        }
        throw ZedApiException(
          errorMsg,
          errorDetails: errorDetails,
          statusCode: response.statusCode,
        );
      }

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final status = map['status'];
        if (status != null &&
            status != 'success' &&
            status != true &&
            status != 200) {
          throw ZedApiException(
            map['message']?.toString() ?? 'Request failed',
            errorDetails: map['errorDetails']?.toString(),
            statusCode: response.statusCode,
          );
        }

        // The data payload can be in map['data'] (as Map or String) or at top-level
        if (map['data'] is Map) {
          final data = Map<String, dynamic>.from(map['data'] as Map);
          if (!data.containsKey('conversationId') && map.containsKey('conversationId')) {
            data['conversationId'] = map['conversationId'];
          }
          return ZedChatResponse.fromJson(data);
        } else if (map['data'] is String) {
          return ZedChatResponse(
            conversationId: (map['conversationId'] ?? map['_id'] ?? '')?.toString() ?? '',
            message: map['data'] as String,
          );
        } else {
          return ZedChatResponse.fromJson(map);
        }
      } else if (decoded is String) {
        return ZedChatResponse(
          conversationId: '',
          message: decoded,
        );
      } else {
        throw ZedApiException('Unexpected response format from AI service');
      }
    } on http.ClientException catch (e) {
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<List<ZedConversation>> getConversations({
    required String schoolId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl${ApiConfig.conversationsEndpoint}?schoolId=$schoolId',
    );

    try {
      final response = await _client
          .get(
            url,
            headers: _getHeaders(),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      debugPrint('=== Conversations Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw body: ${response.body}');
      debugPrint('==============================');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'Failed to get conversations (${response.statusCode})';
        String? errorDetails;
        if (decoded is Map) {
          errorMsg = decoded['message']?.toString() ??
              decoded['error']?.toString() ??
              errorMsg;
          errorDetails = decoded['errorDetails']?.toString();
        }
        throw ZedApiException(
          errorMsg,
          errorDetails: errorDetails,
          statusCode: response.statusCode,
        );
      }

      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final status = map['status'];
        if (status != null &&
            status != 'success' &&
            status != true &&
            status != 200) {
          throw ZedApiException(
            map['message']?.toString() ?? 'Request failed',
            errorDetails: map['errorDetails']?.toString(),
            statusCode: response.statusCode,
          );
        }
        if (map['data'] is List) {
          list = map['data'] as List<dynamic>;
        } else if (map['conversations'] is List) {
          list = map['conversations'] as List<dynamic>;
        } else {
          list = [];
        }
      } else {
        list = [];
      }

      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => ZedConversation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on http.ClientException catch (e) {
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to get conversations: ${e.toString()}');
    }
  }

  @override
  Future<ZedConversationDetails> getConversation({
    required String schoolId,
    required String conversationId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl${ApiConfig.conversationsEndpoint}/$conversationId?schoolId=$schoolId',
    );

    try {
      final response = await _client
          .get(
            url,
            headers: _getHeaders(),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      debugPrint('=== Conversation Details Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw body: ${response.body}');
      debugPrint('====================================');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'Failed to get conversation (${response.statusCode})';
        String? errorDetails;
        if (decoded is Map) {
          errorMsg = decoded['message']?.toString() ??
              decoded['error']?.toString() ??
              errorMsg;
          errorDetails = decoded['errorDetails']?.toString();
        }
        throw ZedApiException(
          errorMsg,
          errorDetails: errorDetails,
          statusCode: response.statusCode,
        );
      }

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final status = map['status'];
        if (status != null &&
            status != 'success' &&
            status != true &&
            status != 200) {
          throw ZedApiException(
            map['message']?.toString() ?? 'Request failed',
            errorDetails: map['errorDetails']?.toString(),
            statusCode: response.statusCode,
          );
        }

        final data = map['data'] is Map
            ? Map<String, dynamic>.from(map['data'] as Map)
            : map;
        return ZedConversationDetails.fromJson(data);
      } else {
        throw ZedApiException('Unexpected response format from conversation API');
      }
    } on http.ClientException catch (e) {
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to get conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation({
    required String schoolId,
    required String conversationId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl${ApiConfig.conversationsEndpoint}/$conversationId?schoolId=$schoolId',
    );

    try {
      final response = await _client
          .delete(
            url,
            headers: _getHeaders(),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      debugPrint('=== Delete Conversation Response ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Raw body: ${response.body}');
      debugPrint('====================================');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMsg = 'Failed to delete conversation (${response.statusCode})';
        String? errorDetails;
        if (decoded is Map) {
          errorMsg = decoded['message']?.toString() ??
              decoded['error']?.toString() ??
              errorMsg;
          errorDetails = decoded['errorDetails']?.toString();
        }
        throw ZedApiException(
          errorMsg,
          errorDetails: errorDetails,
          statusCode: response.statusCode,
        );
      }

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final status = map['status'];
        if (status != null &&
            status != 'success' &&
            status != true &&
            status != 200) {
          throw ZedApiException(
            map['message']?.toString() ?? 'Request failed',
            errorDetails: map['errorDetails']?.toString(),
            statusCode: response.statusCode,
          );
        }
      }
    } on http.ClientException catch (e) {
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to delete conversation: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
