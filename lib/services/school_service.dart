import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/school.dart';
import '../models/zed/zed_school.dart';
import '../models/zed/zed_api_exception.dart';
import '../config/api_config.dart';

class SchoolService {
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

  void selectSchool(String schoolId) {
    _selectedSchoolId = schoolId;
  }

  String getSelectedSchoolId() {
    return _selectedSchoolId;
  }

  Future<void> fetchSchools() async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    try {
      final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.schoolsEndpoint}');
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (ApiConfig.authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${ApiConfig.authToken}';
      }
      
      print('=== Schools Request ===');
      print('URL: $url');
      print('Headers: $headers');
      print('======================');
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: ApiConfig.requestTimeout),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Log the full response for debugging
      print('=== Schools Response ===');
      print('Status: ${responseData['status']}');
      print('Full Response: ${jsonEncode(responseData)}');
      print('======================');

      if (responseData['status'] != 'success') {
        throw ZedApiException(
          responseData['message'] as String? ?? 'Failed to fetch schools',
          errorDetails: responseData['errorDetails'] as String?,
          statusCode: response.statusCode,
        );
      }

      final data = responseData['data'] as List<dynamic>;
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
    } on http.ClientException catch (e) {
      print('Network error details: ${e.message}');
      throw ZedApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ZedApiException) rethrow;
      throw ZedApiException('Failed to fetch schools: ${e.toString()}');
    } finally {
      _isLoading = false;
    }
  }
}
