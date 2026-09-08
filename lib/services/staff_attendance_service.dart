import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/staff_attendance_model.dart';
import 'session_service.dart';

class StaffAttendanceService {
  static const String _localAttendanceCachePrefix = 'staff_attendance_cache_';

  /// Helper to get the active authentication token
  static Future<String> getAuthToken() async {
    if (ApiConfig.authToken.isNotEmpty) {
      return ApiConfig.authToken;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  /// Helper to get the active admin user ID
  static Future<String> getAdminUserId() async {
    if (ApiConfig.currentUser != null) {
      final id = ApiConfig.currentUser.id?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map && decoded['_id'] != null) {
          return decoded['_id'].toString();
        }
        if (decoded is Map && decoded['id'] != null) {
          return decoded['id'].toString();
        }
      } catch (_) {}
    }
    return 'admin';
  }

  /// Helper to get active school ID
  static Future<String> getActiveSchoolId() async {
    final savedId = await SessionService.getSelectedSchoolId();
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }
    return '';
  }

  /// Check In a staff member
  static Future<StaffAttendanceModel> syncCheckIn({
    required String schoolId,
    required String staffId,
    String? staffName,
    String? department,
    String? role,
    String? markedBy,
    DateTime? checkInTime,
  }) async {
    final token = await getAuthToken();
    final adminId = markedBy ?? await getAdminUserId();
    final timestamp = checkInTime ?? DateTime.now();
    final isoTime = timestamp.toUtc().toIso8601String();

    final payload = {
      'schoolId': schoolId,
      'staffId': staffId,
      'markedBy': adminId,
      'checkInTime': isoTime,
    };

    final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.staffCheckInEndpoint}');
    final headers = {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    debugPrint('=== Sync Check-In Request ===');
    debugPrint('URL: $url');
    debugPrint('Payload: ${jsonEncode(payload)}');
    debugPrint('=============================');

    Map<String, dynamic>? responseData;
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      debugPrint('Check-In Response [${response.statusCode}]: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          responseData = decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
        }
      }
    } catch (e) {
      debugPrint('Sync Check-In Network Warning: $e (Falling back to local cache)');
    }

    // Determine punctuality: before 08:30 AM is On Time
    final localTime = timestamp.toLocal();
    final bool isOnTime = localTime.hour < 8 || (localTime.hour == 8 && localTime.minute <= 30);

    final record = StaffAttendanceModel(
      id: responseData?['_id']?.toString() ??
          responseData?['id']?.toString() ??
          'loc_${DateTime.now().millisecondsSinceEpoch}',
      staffId: staffId,
      staffName: staffName ?? responseData?['staffName'] ?? responseData?['name'] ?? 'Staff Member',
      department: department ?? responseData?['department'] ?? 'Academic Staff',
      role: role ?? responseData?['role'] ?? 'Staff Member',
      schoolId: schoolId,
      markedBy: adminId,
      checkInTime: timestamp,
      date: DateTime(timestamp.year, timestamp.month, timestamp.day),
      punctuality: isOnTime ? 'On Time' : 'Late Arrival',
      attendanceType: 'Morning QR Check-In',
      status: 'Checked In',
    );

    // Save record to local persistent storage
    await _saveRecordLocally(schoolId, record);
    return record;
  }

  /// Check Out a staff member
  static Future<StaffAttendanceModel> syncCheckOut({
    required String schoolId,
    required String staffId,
    String? staffName,
    String? markedBy,
    DateTime? checkOutTime,
  }) async {
    final token = await getAuthToken();
    final adminId = markedBy ?? await getAdminUserId();
    final timestamp = checkOutTime ?? DateTime.now();
    final isoTime = timestamp.toUtc().toIso8601String();

    final payload = {
      'schoolId': schoolId,
      'staffId': staffId,
      'markedBy': adminId,
      'checkOutTime': isoTime,
    };

    final url = Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.staffCheckOutEndpoint}');
    final headers = {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    debugPrint('=== Sync Check-Out Request ===');
    debugPrint('URL: $url');
    debugPrint('Payload: ${jsonEncode(payload)}');
    debugPrint('==============================');

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      debugPrint('Check-Out Response [${response.statusCode}]: ${response.body}');
    } catch (e) {
      debugPrint('Sync Check-Out Network Warning: $e (Falling back to local cache)');
    }

    // Update local cache record
    final records = await getLocalAttendance(schoolId);
    final index = records.indexWhere((r) => r.staffId == staffId);

    StaffAttendanceModel record;
    if (index != -1) {
      record = records[index].copyWith(
        checkOutTime: timestamp,
        status: 'Checked Out',
        attendanceType: 'Full Day / Evening Check-Out',
      );
      records[index] = record;
      await _persistListLocally(schoolId, records);
    } else {
      record = StaffAttendanceModel(
        id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        staffName: staffName ?? 'Staff ($staffId)',
        schoolId: schoolId,
        markedBy: adminId,
        checkOutTime: timestamp,
        date: DateTime(timestamp.year, timestamp.month, timestamp.day),
        punctuality: 'On Time',
        attendanceType: 'Evening Check-Out',
        status: 'Checked Out',
      );
      await _saveRecordLocally(schoolId, record);
    }

    return record;
  }

  /// Fetch today's attendance records for a school
  static Future<List<StaffAttendanceModel>> fetchTodayAttendance({
    required String schoolId,
    String? token,
  }) async {
    final authToken = token ?? await getAuthToken();
    final localList = await getLocalAttendance(schoolId);

    if (schoolId.isEmpty) return localList;

    try {
      final url = Uri.parse(
          '${ApiConfig.zedAiBaseUrl}${ApiConfig.staffTodayAttendanceEndpoint}?schoolId=$schoolId');

      final headers = {
        'Content-Type': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      };

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            rawList = decoded['data'] as List<dynamic>;
          } else if (decoded['attendance'] is List) {
            rawList = decoded['attendance'] as List<dynamic>;
          }
        }

        if (rawList.isNotEmpty) {
          final serverList = rawList
              .map((item) => StaffAttendanceModel.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList();

          // Merge server list with any offline records not yet in server
          final Map<String, StaffAttendanceModel> mergedMap = {};
          for (final s in serverList) {
            mergedMap[s.staffId] = s;
          }
          for (final l in localList) {
            if (!mergedMap.containsKey(l.staffId)) {
              mergedMap[l.staffId] = l;
            }
          }

          final mergedList = mergedMap.values.toList();
          await _persistListLocally(schoolId, mergedList);
          return mergedList;
        }
      }
    } catch (e) {
      debugPrint('Error fetching today attendance from server: $e');
    }

    return localList;
  }

  /// Get locally cached attendance list for a school
  static Future<List<StaffAttendanceModel>> getLocalAttendance(String schoolId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_localAttendanceCachePrefix$schoolId';
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => StaffAttendanceModel.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error loading local attendance: $e');
      return [];
    }
  }

  static Future<void> _saveRecordLocally(String schoolId, StaffAttendanceModel record) async {
    final list = await getLocalAttendance(schoolId);
    final existingIndex = list.indexWhere((r) => r.staffId == record.staffId);
    if (existingIndex != -1) {
      list[existingIndex] = record;
    } else {
      list.insert(0, record);
    }
    await _persistListLocally(schoolId, list);
  }

  static Future<void> _persistListLocally(
      String schoolId, List<StaffAttendanceModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_localAttendanceCachePrefix$schoolId';
      final jsonList = list.map((r) => r.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error persisting attendance locally: $e');
    }
  }
}
