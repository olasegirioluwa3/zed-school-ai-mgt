import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/staff_attendance_model.dart';
import 'attendance_sync_service.dart';
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

  /// Returns a valid IANA time zone string (e.g. 'Africa/Lagos', 'America/New_York', 'UTC').
  /// The server uses the supplied IANA time zone to determine the local attendance date.
  static String getLocalIanaTimeZone() {
    try {
      final now = DateTime.now();
      final zoneName = now.timeZoneName;

      // If zoneName is already in IANA format (contains '/' e.g. 'Africa/Lagos') or is 'UTC'
      if (zoneName.contains('/') || zoneName.toUpperCase() == 'UTC') {
        return zoneName;
      }

      // Map UTC offset to canonical IANA time zone
      final offset = now.timeZoneOffset;
      final totalMinutes = offset.inMinutes;

      switch (totalMinutes) {
        case 60: // UTC+1 (West Africa Time / Nigeria)
          return 'Africa/Lagos';
        case 0: // UTC+0 (GMT / London / Accra)
          return 'UTC';
        case 120: // UTC+2 (Central Africa / Johannesburg / Cairo)
          return 'Africa/Johannesburg';
        case 180: // UTC+3 (East Africa / Nairobi)
          return 'Africa/Nairobi';
        case -300: // UTC-5 (US Eastern)
          return 'America/New_York';
        case -360: // UTC-6 (US Central)
          return 'America/Chicago';
        case -420: // UTC-7 (US Mountain)
          return 'America/Denver';
        case -480: // UTC-8 (US Pacific)
          return 'America/Los_Angeles';
        case 330: // UTC+5:30 (India)
          return 'Asia/Kolkata';
        case 480: // UTC+8 (Singapore / China)
          return 'Asia/Singapore';
        case 540: // UTC+9 (Japan)
          return 'Asia/Tokyo';
        case 600: // UTC+10 (Sydney)
          return 'Australia/Sydney';
        default:
          if (offset.inHours == 1) return 'Africa/Lagos';
          if (offset.inHours == 0) return 'UTC';
          if (offset.inHours == 2) return 'Africa/Johannesburg';
          if (offset.inHours == 3) return 'Africa/Nairobi';
          return 'Africa/Lagos';
      }
    } catch (_) {
      return 'Africa/Lagos';
    }
  }

  /// Mark staff check-in or check-out using POST /api/v2/user/schoolstaffattendance/
  ///
  /// Marks attendance using the server's current time. The supplied IANA time zone
  /// is used only to determine the local attendance date, so clients cannot provide
  /// or override the attendance timestamp.
  ///
  /// Body:
  /// {
  ///   "schoolId": "string",
  ///   "staffId": "string",
  ///   "action": "check-in" | "check-out",
  ///   "timeZone": "string",
  ///   "comment": "string"
  /// }
  static Future<MarkAttendanceResult> markAttendance({
    required String schoolId,
    required String staffId,
    required String action, // 'check-in' or 'check-out'
    String? timeZone,
    String? comment,
    String? staffName,
    String? department,
    String? role,
    String? markedBy,
  }) async {
    final token = await getAuthToken();
    final adminId = markedBy ?? await getAdminUserId();
    final resolvedTimeZone = (timeZone != null && timeZone.trim().isNotEmpty)
        ? timeZone.trim()
        : getLocalIanaTimeZone();

    final normalizedAction =
        action.toLowerCase() == 'check-out' ? 'check-out' : 'check-in';

    final payload = <String, dynamic>{
      'schoolId': schoolId,
      'staffId': staffId,
      'action': normalizedAction,
      'timeZone': resolvedTimeZone,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    };

    final url = Uri.parse(
        '${ApiConfig.zedAiBaseUrl}${ApiConfig.staffAttendanceEndpoint}');
    final headers = {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    debugPrint('=== Mark Attendance Request ===');
    debugPrint('URL: $url');
    debugPrint('Payload: ${jsonEncode(payload)}');
    debugPrint('===============================');

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      debugPrint(
          'Mark Attendance Response [${response.statusCode}]: ${response.body}');

      Map<String, dynamic>? decoded;
      try {
        final rawDecoded = jsonDecode(response.body);
        if (rawDecoded is Map<String, dynamic>) {
          decoded = rawDecoded;
        }
      } catch (_) {}

      final message = decoded?['message']?.toString() ??
          (response.statusCode == 200
              ? 'Attendance marked successfully'
              : 'Failed to mark attendance (Status ${response.statusCode})');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final serverStaffName =
            decoded?['staffName']?.toString() ?? staffName ?? 'Staff Member';

        Map<String, dynamic>? attData;
        if (decoded?['attendance'] is Map<String, dynamic>) {
          attData = decoded!['attendance'] as Map<String, dynamic>;
        } else if (decoded?['data'] is Map<String, dynamic>) {
          attData = decoded!['data'] as Map<String, dynamic>;
        }

        StaffAttendanceModel record;
        final now = DateTime.now();

        if (attData != null) {
          record = StaffAttendanceModel.fromJson(
            attData,
            defaultStaffName: serverStaffName,
            defaultStaffId: staffId,
          ).copyWith(
            department: department,
            role: role,
            schoolId: schoolId,
            markedBy: adminId,
            status: normalizedAction == 'check-out'
                ? 'Checked Out'
                : 'Checked In',
            attendanceType: normalizedAction == 'check-out'
                ? 'Evening QR Check-Out'
                : 'Morning QR Check-In',
          );
        } else {
          final bool isOnTime =
              now.hour < 8 || (now.hour == 8 && now.minute <= 30);
          record = StaffAttendanceModel(
            id: decoded?['_id']?.toString() ??
                'att_${now.millisecondsSinceEpoch}',
            staffId: staffId,
            staffName: serverStaffName,
            department: department ?? 'General Staff',
            role: role ?? 'Staff Member',
            schoolId: schoolId,
            markedBy: adminId,
            checkInTime: normalizedAction == 'check-in' ? now : null,
            checkOutTime: normalizedAction == 'check-out' ? now : null,
            date: DateTime(now.year, now.month, now.day),
            punctuality: isOnTime ? 'On Time' : 'Late Arrival',
            attendanceType: normalizedAction == 'check-out'
                ? 'Evening QR Check-Out'
                : 'Morning QR Check-In',
            status: normalizedAction == 'check-out'
                ? 'Checked Out'
                : 'Checked In',
            comment: comment,
          );
        }

        // Save record locally for instant UI update & cache
        await _saveRecordLocally(schoolId, record);

        return MarkAttendanceResult.success(
          message: message,
          staffName: serverStaffName,
          attendance: record,
          statusCode: response.statusCode,
        );
      }

      // Specific HTTP error cases (400, 401, 403, etc.)
      return MarkAttendanceResult.failure(
        message: message,
        errorMessage: message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint(
          'Mark Attendance Network Warning: $e (Falling back to local cache & offline queue)');

      final now = DateTime.now();

      // Enqueue for background retry
      if (normalizedAction == 'check-out') {
        await AttendanceSyncService.enqueueCheckOut(
          schoolId: schoolId,
          staffId: staffId,
          markedBy: adminId,
          timestamp: now,
          timeZone: resolvedTimeZone,
          comment: comment,
        );
      } else {
        await AttendanceSyncService.enqueueCheckIn(
          schoolId: schoolId,
          staffId: staffId,
          markedBy: adminId,
          timestamp: now,
          timeZone: resolvedTimeZone,
          comment: comment,
        );
      }

      // Offline-first record
      final bool isOnTime =
          now.hour < 8 || (now.hour == 8 && now.minute <= 30);
      final offlineRecord = StaffAttendanceModel(
        id: 'loc_${now.millisecondsSinceEpoch}',
        staffId: staffId,
        staffName: staffName ?? 'Staff ($staffId)',
        department: department ?? 'General Staff',
        role: role ?? 'Staff Member',
        schoolId: schoolId,
        markedBy: adminId,
        checkInTime: normalizedAction == 'check-in' ? now : null,
        checkOutTime: normalizedAction == 'check-out' ? now : null,
        date: DateTime(now.year, now.month, now.day),
        punctuality: isOnTime ? 'On Time' : 'Late Arrival',
        attendanceType: normalizedAction == 'check-out'
            ? 'Evening QR Check-Out'
            : 'Morning QR Check-In',
        status:
            normalizedAction == 'check-out' ? 'Checked Out' : 'Checked In',
        comment: comment,
      );

      await _saveRecordLocally(schoolId, offlineRecord);

      return MarkAttendanceResult.success(
        message: 'Attendance saved locally (queued for sync)',
        staffName: staffName ?? 'Staff ($staffId)',
        attendance: offlineRecord,
        statusCode: 0,
      );
    }
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
    String? timeZone,
    String? comment,
  }) async {
    final result = await markAttendance(
      schoolId: schoolId,
      staffId: staffId,
      action: 'check-in',
      timeZone: timeZone,
      comment: comment,
      staffName: staffName,
      department: department,
      role: role,
      markedBy: markedBy,
    );

    if (result.attendance != null) {
      return result.attendance!;
    }

    final now = checkInTime ?? DateTime.now();
    final bool isOnTime = now.hour < 8 || (now.hour == 8 && now.minute <= 30);
    final fallback = StaffAttendanceModel(
      id: 'loc_${now.millisecondsSinceEpoch}',
      staffId: staffId,
      staffName: staffName ?? result.staffName,
      department: department ?? 'General Staff',
      role: role ?? 'Staff Member',
      schoolId: schoolId,
      markedBy: markedBy ?? 'admin',
      checkInTime: now,
      date: DateTime(now.year, now.month, now.day),
      punctuality: isOnTime ? 'On Time' : 'Late Arrival',
      attendanceType: 'Morning QR Check-In',
      status: 'Checked In',
      comment: comment,
    );
    await _saveRecordLocally(schoolId, fallback);
    return fallback;
  }

  /// Check Out a staff member
  static Future<StaffAttendanceModel> syncCheckOut({
    required String schoolId,
    required String staffId,
    String? staffName,
    String? markedBy,
    DateTime? checkOutTime,
    String? timeZone,
    String? comment,
  }) async {
    final result = await markAttendance(
      schoolId: schoolId,
      staffId: staffId,
      action: 'check-out',
      timeZone: timeZone,
      comment: comment,
      staffName: staffName,
      markedBy: markedBy,
    );

    if (result.attendance != null) {
      return result.attendance!;
    }

    final records = await getLocalAttendance(schoolId);
    final index = records.indexWhere((r) => r.staffId == staffId);
    final now = checkOutTime ?? DateTime.now();

    StaffAttendanceModel record;
    if (index != -1) {
      record = records[index].copyWith(
        checkOutTime: now,
        status: 'Checked Out',
        attendanceType: 'Full Day / Evening Check-Out',
        comment: comment,
      );
      records[index] = record;
      await _persistListLocally(schoolId, records);
    } else {
      record = StaffAttendanceModel(
        id: 'loc_${now.millisecondsSinceEpoch}',
        staffId: staffId,
        staffName: staffName ?? 'Staff ($staffId)',
        schoolId: schoolId,
        markedBy: markedBy ?? 'admin',
        checkOutTime: now,
        date: DateTime(now.year, now.month, now.day),
        punctuality: 'On Time',
        attendanceType: 'Evening Check-Out',
        status: 'Checked Out',
        comment: comment,
      );
      await _saveRecordLocally(schoolId, record);
    }

    return record;
  }

  /// Format a DateTime to 'YYYY-MM-DD' as expected by the API
  static String formatDateForApi(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _cacheKey(String schoolId, [String? dateStr]) {
    if (dateStr != null && dateStr.isNotEmpty) {
      return '$_localAttendanceCachePrefix${schoolId}_$dateStr';
    }
    return '$_localAttendanceCachePrefix$schoolId';
  }

  /// Fetch staff attendance for a specific date using:
  /// POST /api/v2/user/schoolstaffattendance/by-date
  ///
  /// Body:
  /// {
  ///   "schoolId": "string",
  ///   "date": "YYYY-MM-DD"
  /// }
  ///
  /// Saves the fetched list locally on the device for fast offline display.
  static Future<List<StaffAttendanceModel>> fetchAttendanceByDate({
    required String schoolId,
    required DateTime date,
    bool forceRefresh = false,
    String? token,
  }) async {
    final dateStr = formatDateForApi(date);
    final localList = await getLocalAttendance(schoolId, dateStr: dateStr);

    if (schoolId.isEmpty) return localList;

    final authToken = token ?? await getAuthToken();

    try {
      final url = Uri.parse(
          '${ApiConfig.zedAiBaseUrl}${ApiConfig.staffAttendanceByDateEndpoint}');

      final headers = {
        'Content-Type': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      };

      final bodyPayload = jsonEncode({
        'schoolId': schoolId,
        'date': dateStr,
      });

      debugPrint('=== Fetch Attendance By Date Request ===');
      debugPrint('URL: $url');
      debugPrint('Payload: $bodyPayload');
      debugPrint('=======================================');

      final response = await http
          .post(url, headers: headers, body: bodyPayload)
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      debugPrint(
          'Fetch Attendance By Date Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];

        if (decoded is Map<String, dynamic>) {
          if (decoded['attendance'] is List) {
            rawList = decoded['attendance'] as List<dynamic>;
          } else if (decoded['data'] is List) {
            rawList = decoded['data'] as List<dynamic>;
          }
        } else if (decoded is List) {
          rawList = decoded;
        }

        final serverList = rawList
            .map((item) => StaffAttendanceModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();

        // Merge server list with any local un-synced records
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
        // Save to device cache
        await _persistListLocally(schoolId, mergedList, dateStr: dateStr);
        return mergedList;
      }
    } catch (e) {
      debugPrint('Error fetching attendance by date from server: $e');
    }

    return localList;
  }

  /// Fetch today's attendance records for a school
  static Future<List<StaffAttendanceModel>> fetchTodayAttendance({
    required String schoolId,
    String? token,
  }) async {
    return fetchAttendanceByDate(
      schoolId: schoolId,
      date: DateTime.now(),
      token: token,
    );
  }

  /// Get locally cached attendance list for a school and optional date
  static Future<List<StaffAttendanceModel>> getLocalAttendance(
    String schoolId, {
    String? dateStr,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString;
      if (dateStr != null && dateStr.isNotEmpty) {
        jsonString = prefs.getString(_cacheKey(schoolId, dateStr));
      }
      if (jsonString == null || jsonString.isEmpty) {
        jsonString = prefs.getString(_cacheKey(schoolId));
      }
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

  static Future<void> _saveRecordLocally(
    String schoolId,
    StaffAttendanceModel record,
  ) async {
    final dateStr = formatDateForApi(record.date);
    final list = await getLocalAttendance(schoolId, dateStr: dateStr);
    final existingIndex = list.indexWhere((r) => r.staffId == record.staffId);
    if (existingIndex != -1) {
      list[existingIndex] = record;
    } else {
      list.insert(0, record);
    }
    await _persistListLocally(schoolId, list, dateStr: dateStr);
  }

  static Future<void> _persistListLocally(
    String schoolId,
    List<StaffAttendanceModel> list, {
    String? dateStr,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((r) => r.toJson()).toList();
      final encoded = jsonEncode(jsonList);
      if (dateStr != null && dateStr.isNotEmpty) {
        await prefs.setString(_cacheKey(schoolId, dateStr), encoded);
      }
      await prefs.setString(_cacheKey(schoolId), encoded);
    } catch (e) {
      debugPrint('Error persisting attendance locally: $e');
    }
  }
}
