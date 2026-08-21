import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Log the full response for debugging
      print('=== AI Response ===');
      print('Status: ${responseData['status']}');
      print('Full Response: ${jsonEncode(responseData)}');
      print('==================');

      // Store the response structure to shared preferences
      await _storeResponseStructure(responseData);

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Request failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return ZedChatResponse.fromJson(data);
    } on http.ClientException catch (e) {
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> _storeResponseStructure(Map<String, dynamic> response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_ai_response', jsonEncode(response));
      print('Response structure saved to shared preferences');
    } catch (e) {
      print('Failed to save response structure: ${e.toString()}');
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Request failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final data = responseData['data'] as List<dynamic>;
      return data
          .map((item) => ZedConversation.fromJson(item as Map<String, dynamic>))
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Request failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      return ZedConversationDetails.fromJson(data);
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Request failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
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
