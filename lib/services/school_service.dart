import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'session_service.dart';
import '../models/school.dart';
import '../models/zed/zed_school.dart';
import '../models/zed/zed_api_exception.dart';
import '../config/api_config.dart';

class SchoolService {
  static const String _cachedSchoolsKey = 'cached_schools_list';
  static const String _selectedSchoolKey = 'selected_school_id';

  String _selectedSchoolId = '';
  List<School> _cachedSchools = [];
  bool _isLoading = false;

  List<School> getAvailableSchools() {
    return _cachedSchools;
  }

  School? getSelectedSchool() {
    if (_cachedSchools.isEmpty) return null;
    try {
      return _cachedSchools.firstWhere((school) => school.id == _selectedSchoolId);
    } catch (e) {
      if (_cachedSchools.isNotEmpty) {
        return _cachedSchools.first;
      }
      return null;
    }
  }

  Future<void> selectSchool(String schoolId) async {
    _selectedSchoolId = schoolId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedSchoolKey, schoolId);
      // Also persist to session service for quick access across app
      await SessionService.saveSelectedSchoolId(schoolId);
    } catch (e) {
      debugPrint('Failed to persist selected school: $e');
    }
  }

  String getSelectedSchoolId() {
    return _selectedSchoolId;
  }

  /// Load cached schools and selected school from local storage (for offline use)
  Future<void> loadLocalSchools() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_cachedSchoolsKey);
      final savedSelectedId = prefs.getString(_selectedSchoolKey);

      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedJson) as List<dynamic>;
        _cachedSchools = decoded
            .map((item) => School.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (savedSelectedId != null && savedSelectedId.isNotEmpty) {
        _selectedSchoolId = savedSelectedId;
      } else if (_selectedSchoolId.isEmpty && _cachedSchools.isNotEmpty) {
        _selectedSchoolId = _cachedSchools.first.id;
      }
    } catch (e) {
      debugPrint('Failed to load locally saved schools: $e');
    }
  }

  Future<void> _persistSchoolsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedSchools.map((s) => s.toJson()).toList();
      await prefs.setString(_cachedSchoolsKey, jsonEncode(jsonList));
      if (_selectedSchoolId.isNotEmpty) {
        await prefs.setString(_selectedSchoolKey, _selectedSchoolId);
      }
    } catch (e) {
      debugPrint('Failed to persist schools locally: $e');
    }
  }

  Future<void> fetchSchools() async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    // First load from local storage if in-memory cache is empty
    if (_cachedSchools.isEmpty) {
      await loadLocalSchools();
    }

    try {
      final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.schoolsEndpoint}');
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (ApiConfig.authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
      }

      final body = jsonEncode({'role': 'admin'});
      
      debugPrint('=== Schools Request ===');
      debugPrint('URL: $url');
      debugPrint('Method: POST');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');
      debugPrint('======================');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
      );

      final decoded = jsonDecode(response.body);

      // Log the full response for debugging
      debugPrint('=== Schools Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body type: ${decoded.runtimeType}');
      debugPrint('======================');

      List<dynamic> data;

      if (decoded is List) {
        // API returned a raw JSON array directly
        data = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['status'] != 'success') {
          throw ZedApiException(
            decoded['message'] as String? ?? 'Failed to fetch schools',
            errorDetails: decoded['errorDetails'] as String?,
            statusCode: response.statusCode,
          );
        }
        data = decoded['data'] as List<dynamic>;
      } else {
        throw ZedApiException('Unexpected response format from schools API');
      }

      final zedSchools = data
          .map((item) => ZedSchool.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedSchools = zedSchools.map((zedSchool) {
        return School(
          id: zedSchool.id,
          name: zedSchool.name,
          logoUrl: zedSchool.logoUrl,
        );
      }).toList();

      // Auto-select first school if none selected
      if (_selectedSchoolId.isEmpty && _cachedSchools.isNotEmpty) {
        _selectedSchoolId = _cachedSchools.first.id;
      }

      // Save to local storage for offline use
      await _persistSchoolsLocally();
    } on http.ClientException catch (e) {
      debugPrint('Network error details: ${e.message}');
      // If we already have cached schools from local storage, keep them
      if (_cachedSchools.isNotEmpty) {
        return;
      }
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (_cachedSchools.isNotEmpty) {
        // We have local fallback data, so don't crash
        return;
      }
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to fetch schools: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }

  /// Static method for AdminHome to get schools
  /// Returns raw JSON data for compatibility with AdminHome's SchoolModel
  static Future<List<Map<String, dynamic>>> getMySchools() async {
    try {
      final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.schoolsEndpoint}');
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (ApiConfig.authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
      }

      final body = jsonEncode({'role': 'admin'});
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
      );

      final decoded = jsonDecode(response.body);

      List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['status'] != 'success') {
          throw Exception(decoded['message'] ?? 'Failed to fetch schools');
        }
        data = decoded['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }

      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error in getMySchools: $e');
      // Return empty list on error for stub implementation
      return [];
    }
  }

  /// Create a new school
  static Future<Map<String, dynamic>> createSchool({
    required String name,
    required String address,
    required String phoneNumber,
    required String email,
    required String website,
    required String foundedDate,
    required String schoolTypeId,
    required List<Map<String, dynamic>> bankDetails,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.createSchoolEndpoint}');
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (ApiConfig.authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
      }

      final body = jsonEncode({
        'name': name,
        'address': {
          'address_line1': address,
        },
        'phoneNumber': phoneNumber,
        'email': email,
        'website': website,
        'foundedDate': foundedDate,
        'schoolTypeId': schoolTypeId,
        'role': 'admin',
        'bankDetails': bankDetails,
      });
      
      debugPrint('=== Create School Request ===');
      debugPrint('URL: $url');
      debugPrint('Method: POST');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');
      debugPrint('======================');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
      );

      final decoded = jsonDecode(response.body);

      debugPrint('=== Create School Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Body: $decoded');
      debugPrint('======================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded as Map<String, dynamic>;
      } else {
        throw ZedApiException(
          decoded['message'] as String? ?? 'Failed to create school',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('Network error creating school: ${e.message}');
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error creating school: $e');
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to create school: ${e.toString()}');
    }
  }
}
