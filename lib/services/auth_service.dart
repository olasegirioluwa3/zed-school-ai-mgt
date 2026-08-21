import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/zed/zed_login_request.dart';
import '../models/zed/zed_login_response.dart';
import '../models/zed/zed_api_exception.dart';

abstract class AuthService {
  Future<ZedLoginResponse> login({
    required String email,
    required String password,
  });
  
  void dispose();
}

class AuthServiceImpl implements AuthService {
  final http.Client _client;
  final String _baseUrl;

  AuthServiceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.zedAiBaseUrl;

  @override
  Future<ZedLoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.loginEndpoint}');
    
    final request = ZedLoginRequest(
      email: email,
      password: password,
    );

    print('=== Login Request ===');
    print('URL: $url');
    print('Email: $email');
    print('====================');

    try {
      print('Sending POST request to: $url');
      print('Request body: ${jsonEncode(request.toJson())}');
      
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Log the full response for debugging
      print('=== Login Response ===');
      print('Status: ${responseData['status']}');
      print('Full Response: ${jsonEncode(responseData)}');
      print('====================');

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Login failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final loginResponse = ZedLoginResponse.fromJson(data);

      // Store the auth token globally
      ApiConfig.setAuthToken(loginResponse.token);

      return loginResponse;
    } on http.ClientException catch (e) {
      print('Network error details: ${e.message}');
      print('Error type: ${e.runtimeType}');
      if (e.message.contains('Failed host lookup')) {
        print('DNS resolution failed - check internet connection');
      } else if (e.message.contains('Connection refused')) {
        print('Server refused connection - server may be down');
      } else if (e.message.contains('Failed to fetch')) {
        print('Fetch failed - possible CORS issue (on web) or network issue');
        print('Try accessing the URL directly in a browser: $url');
      }
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to login: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
