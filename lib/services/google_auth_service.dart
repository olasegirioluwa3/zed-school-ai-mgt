import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/zed/zed_login_response.dart';
import '../models/zed/zed_api_exception.dart';

class GoogleAuthService {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final GoogleSignIn _googleSignIn;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final String _baseUrl;

  GoogleAuthService({
    http.Client? client,
    String? baseUrl,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.zedAiBaseUrl,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              clientId: '852974895524-mog1f8v0uc01mfe1ovscnmbs076fgh3e.apps.googleusercontent.com',
              serverClientId:
                  '852974895524-mog1f8v0uc01mfe1ovscnmbs076fgh3e.apps.googleusercontent.com',
            );

  Future<ZedLoginResponse> signInWithGoogle() async {
    try {
      debugPrint('=== Starting Google Sign-In ===');
      
      // Google Sign-In doesn't work on web - show message
      if (kIsWeb) {
        debugPrint('Google Sign-In is not supported on web platform');
        throw ZedApiException('Google Sign-In is not supported on web. Please use a mobile device.');
      }
      
      // Trigger Google Sign-In dialog
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        debugPrint('User cancelled Google Sign-In');
        throw ZedApiException('Google Sign-In was cancelled');
      }

      debugPrint('Google Sign-In successful for: ${account.email}');

      // Retrieve authentication details
      final GoogleSignInAuthentication auth = await account.authentication;
      
      debugPrint('Got Google authentication tokens');
      debugPrint('ID Token present: ${auth.idToken?.isNotEmpty == true}');
      debugPrint('Access Token present: ${auth.accessToken?.isNotEmpty == true}');

      // Send tokens to backend
      final url = Uri.parse('$_baseUrl/api/v2/auth/google');
      
      final requestBody = {
        'idToken': auth.idToken,
        'accessToken': auth.accessToken,
      };

      debugPrint('Sending Google tokens to backend: $url');
      debugPrint('Request body: ${jsonEncode(requestBody)}');

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: ApiConfig.requestTimeout),
          );

      debugPrint('Backend response status: ${response.statusCode}');
      debugPrint('Backend response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Check HTTP status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ZedApiException(
          responseData['message'] as String? ??
              responseData['error'] as String? ??
              'Google authentication failed with status ${response.statusCode}',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      // Check if status is explicitly failure
      if (responseData.containsKey('status') &&
          responseData['status'] != 'success' &&
          responseData['status'] != 200 &&
          responseData['status'] != true) {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Google authentication failed',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final loginResponse = ZedLoginResponse.fromJson(responseData);

      if (loginResponse.token.isEmpty) {
        throw ZedApiException(
          responseData['message'] as String? ?? 'No authentication token received in response',
          statusCode: response.statusCode,
        );
      }

      // Store the auth token and user securely
      await _secureStorage.write(key: _authTokenKey, value: loginResponse.token);
      if (loginResponse.user != null) {
        await _secureStorage.write(key: _userKey, value: jsonEncode(loginResponse.user!.toJson()));
      }

      // Store globally for immediate use
      ApiConfig.setAuthToken(loginResponse.token);
      ApiConfig.setCurrentUser(loginResponse.user);

      debugPrint('=== Google Sign-In completed successfully ===');
      return loginResponse;
    } on http.ClientException catch (e) {
      debugPrint('Network error during Google Sign-In: ${e.message}');
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      debugPrint('Error during Google Sign-In: ${e.toString()}');
      throw ZedApiException('Google Sign-In failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _secureStorage.delete(key: _authTokenKey);
      await _secureStorage.delete(key: _userKey);
      ApiConfig.clearAuthToken();
      ApiConfig.clearCurrentUser();
      debugPrint('Google Sign-Out completed');
    } catch (e) {
      debugPrint('Error during Google Sign-Out: ${e.toString()}');
    }
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> dispose() async {
    _client.close();
  }
}
