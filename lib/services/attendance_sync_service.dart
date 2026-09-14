import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'staff_attendance_service.dart';

/// Represents a single pending (failed) attendance sync record.
class _PendingRecord {
  final String type; // 'checkIn' | 'checkOut'
  final String schoolId;
  final String staffId;
  final String markedBy;
  final String timestamp; // ISO 8601
  final int attempts;
  final String? action;
  final String? timeZone;
  final String? comment;

  _PendingRecord({
    required this.type,
    required this.schoolId,
    required this.staffId,
    required this.markedBy,
    required this.timestamp,
    this.attempts = 0,
    this.action,
    this.timeZone,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'schoolId': schoolId,
        'staffId': staffId,
        'markedBy': markedBy,
        'timestamp': timestamp,
        'attempts': attempts,
        if (action != null) 'action': action,
        if (timeZone != null) 'timeZone': timeZone,
        if (comment != null) 'comment': comment,
      };

  factory _PendingRecord.fromJson(Map<String, dynamic> json) => _PendingRecord(
        type: json['type'] as String? ?? 'checkIn',
        schoolId: json['schoolId'] as String? ?? '',
        staffId: json['staffId'] as String? ?? '',
        markedBy: json['markedBy'] as String? ?? 'admin',
        timestamp: json['timestamp'] as String? ?? '',
        attempts: (json['attempts'] as int?) ?? 0,
        action: json['action'] as String?,
        timeZone: json['timeZone'] as String?,
        comment: json['comment'] as String?,
      );

  _PendingRecord withAttempt() => _PendingRecord(
        type: type,
        schoolId: schoolId,
        staffId: staffId,
        markedBy: markedBy,
        timestamp: timestamp,
        attempts: attempts + 1,
        action: action,
        timeZone: timeZone,
        comment: comment,
      );
}

/// Background service that retries failed attendance check-in/out records.
///
/// Records are enqueued by [StaffAttendanceService] when an API call fails.
/// This service:
///  - Retries every 60 seconds via a periodic timer.
///  - Also retries immediately whenever the device regains internet connectivity.
///  - Removes a record from the queue only on a confirmed 2xx server response.
///  - Drops a record after [maxAttempts] failures to avoid an infinite loop.
class AttendanceSyncService {
  AttendanceSyncService._();
  static final AttendanceSyncService instance = AttendanceSyncService._();

  static const String _pendingKey = 'attendance_pending_sync';
  static const int _intervalSeconds = 60;
  static const int maxAttempts = 10; // give up after 10 tries (~10 minutes)

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncing = false;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  Future<void> start() async {
    debugPrint('[AttendanceSyncService] Starting...');

    // Periodic retry every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: _intervalSeconds), (_) {
      _attemptSync();
    });

    // Retry immediately when connectivity is restored
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasNetwork = results
          .any((r) => r != ConnectivityResult.none);
      if (hasNetwork) {
        debugPrint('[AttendanceSyncService] Connectivity restored — syncing...');
        _attemptSync();
      }
    });

    // Run once on startup in case there are leftover pending records
    await _attemptSync();
  }

  /// Call stop() if you ever need to tear the service down (e.g. logout).
  void stop() {
    _timer?.cancel();
    _timer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    debugPrint('[AttendanceSyncService] Stopped.');
  }

  /// Enqueue a failed check-in for later retry.
  static Future<void> enqueueCheckIn({
    required String schoolId,
    required String staffId,
    required String markedBy,
    required DateTime timestamp,
    String? timeZone,
    String? comment,
  }) async {
    await _enqueue(_PendingRecord(
      type: 'checkIn',
      action: 'check-in',
      schoolId: schoolId,
      staffId: staffId,
      markedBy: markedBy,
      timestamp: timestamp.toUtc().toIso8601String(),
      timeZone: timeZone ?? StaffAttendanceService.getLocalIanaTimeZone(),
      comment: comment,
    ));
  }

  /// Enqueue a failed check-out for later retry.
  static Future<void> enqueueCheckOut({
    required String schoolId,
    required String staffId,
    required String markedBy,
    required DateTime timestamp,
    String? timeZone,
    String? comment,
  }) async {
    await _enqueue(_PendingRecord(
      type: 'checkOut',
      action: 'check-out',
      schoolId: schoolId,
      staffId: staffId,
      markedBy: markedBy,
      timestamp: timestamp.toUtc().toIso8601String(),
      timeZone: timeZone ?? StaffAttendanceService.getLocalIanaTimeZone(),
      comment: comment,
    ));
  }

  /// Returns the number of records currently waiting to be synced.
  static Future<int> pendingCount() async {
    final list = await _loadQueue();
    return list.length;
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Future<void> _attemptSync() async {
    if (_isSyncing) return; // prevent overlapping runs
    _isSyncing = true;

    try {
      final queue = await _loadQueue();
      if (queue.isEmpty) return;

      debugPrint(
          '[AttendanceSyncService] Syncing ${queue.length} pending record(s)...');

      final token = await StaffAttendanceService.getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final List<_PendingRecord> stillPending = [];

      for (final record in queue) {
        final success = await _pushRecord(record, headers);
        if (!success) {
          final updated = record.withAttempt();
          if (updated.attempts < maxAttempts) {
            stillPending.add(updated);
          } else {
            debugPrint(
                '[AttendanceSyncService] Dropping record after $maxAttempts attempts: '
                '${record.type} staffId=${record.staffId}');
          }
        }
        // On success we simply don't add it back — it's removed from the queue.
      }

      await _saveQueue(stillPending);

      debugPrint(
          '[AttendanceSyncService] Sync complete. ${stillPending.length} record(s) still pending.');
    } catch (e) {
      debugPrint('[AttendanceSyncService] Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _pushRecord(
      _PendingRecord record, Map<String, String> headers) async {
    try {
      final action = record.action ??
          (record.type.toLowerCase() == 'checkout' || record.type == 'checkOut'
              ? 'check-out'
              : 'check-in');

      final payload = <String, dynamic>{
        'schoolId': record.schoolId,
        'staffId': record.staffId,
        'action': action,
        'timeZone': record.timeZone ?? StaffAttendanceService.getLocalIanaTimeZone(),
        if (record.comment != null && record.comment!.isNotEmpty)
          'comment': record.comment,
      };

      final url =
          Uri.parse('${ApiConfig.zedAiBaseUrl}${ApiConfig.staffAttendanceEndpoint}');

      final response = await http
          .post(url, headers: headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      final ok = response.statusCode >= 200 && response.statusCode < 300;
      debugPrint(
          '[AttendanceSyncService] ${record.type} staffId=${record.staffId} → ${response.statusCode}');
      return ok;
    } catch (e) {
      debugPrint(
          '[AttendanceSyncService] Failed to push ${record.type} for ${record.staffId}: $e');
      return false;
    }
  }

  // ─── Queue persistence ─────────────────────────────────────────────────────

  static Future<void> _enqueue(_PendingRecord record) async {
    final queue = await _loadQueue();
    // Avoid duplicate entries for the same staffId + type + timestamp
    final exists = queue.any((r) =>
        r.staffId == record.staffId &&
        r.type == record.type &&
        r.timestamp == record.timestamp);
    if (!exists) {
      queue.add(record);
      await _saveQueue(queue);
      debugPrint(
          '[AttendanceSyncService] Enqueued ${record.type} for staffId=${record.staffId}');
    }
  }

  static Future<List<_PendingRecord>> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => _PendingRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[AttendanceSyncService] Error loading queue: $e');
      return [];
    }
  }

  static Future<void> _saveQueue(List<_PendingRecord> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _pendingKey, jsonEncode(queue.map((r) => r.toJson()).toList()));
    } catch (e) {
      debugPrint('[AttendanceSyncService] Error saving queue: $e');
    }
  }
}
