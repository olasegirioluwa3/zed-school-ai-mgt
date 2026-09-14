class StaffAttendanceModel {
  final String id;
  final String staffId;
  final String staffName;
  final String department;
  final String role;
  final String schoolId;
  final String markedBy;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime date;
  final String punctuality;
  final String attendanceType;
  final String status;
  final String? comment;

  StaffAttendanceModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    this.department = 'General Staff',
    this.role = 'Staff Member',
    required this.schoolId,
    required this.markedBy,
    this.checkInTime,
    this.checkOutTime,
    required this.date,
    this.punctuality = 'On Time',
    this.attendanceType = 'QR ID Scan',
    this.status = 'Checked In',
    this.comment,
  });

  bool get isCheckedOut => checkOutTime != null;

  bool get isOnTime => punctuality.toLowerCase() == 'on time';

  String get formattedCheckIn {
    if (checkInTime == null) return '--:--';
    final dt = checkInTime!.toLocal();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  String get formattedCheckOut {
    if (checkOutTime == null) return 'Not Checked Out';
    final dt = checkOutOutDateTime!.toLocal();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  DateTime? get checkOutOutDateTime => checkOutTime;

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  factory StaffAttendanceModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultStaffName,
    String? defaultStaffId,
  }) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final checkIn = parseDate(json['checkInTime'] ?? json['checkIn'] ?? json['time']);
    final checkOut = parseDate(json['checkOutTime'] ?? json['checkOut']);
    final dateParsed = parseDate(json['date'] ?? json['createdAt']) ?? checkIn ?? DateTime.now();

    // Extract staffId & staffName (which can be a String or a nested Map)
    String parsedStaffId = defaultStaffId ?? '';
    String parsedStaffName = defaultStaffName ?? '';

    final rawStaffId = json['staffId'] ?? json['staff_id'];
    if (rawStaffId is Map) {
      final idVal = rawStaffId['_id'] ?? rawStaffId['id'];
      if (idVal != null && idVal.toString().isNotEmpty) {
        parsedStaffId = idVal.toString();
      }
      final firstName = rawStaffId['firstName']?.toString() ?? '';
      final lastName = rawStaffId['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty && parsedStaffName.isEmpty) {
        parsedStaffName = fullName;
      }
    } else if (rawStaffId != null) {
      parsedStaffId = rawStaffId.toString();
    }

    if (parsedStaffName.isEmpty) {
      parsedStaffName = json['staffName']?.toString() ??
          json['name']?.toString() ??
          json['fullName']?.toString() ??
          'Staff Member';
    }

    // Determine punctuality
    String punct = json['punctuality']?.toString() ?? '';
    final commentVal = json['comment']?.toString();
    if (punct.isEmpty && commentVal != null && commentVal.isNotEmpty) {
      punct = commentVal;
    }
    if (punct.isEmpty && checkIn != null) {
      final local = checkIn.toLocal();
      punct = (local.hour < 8 || (local.hour == 8 && local.minute <= 30))
          ? 'On Time'
          : 'Late Arrival';
    } else if (punct.isEmpty) {
      punct = 'On Time';
    }

    // Determine status
    String stat = json['status']?.toString() ?? '';
    if (stat.isEmpty) {
      stat = checkOut != null ? 'Checked Out' : 'Checked In';
    }

    String parsedDepartment = json['department']?.toString() ?? json['dept']?.toString() ?? '';
    if (parsedDepartment.isEmpty && rawStaffId is Map) {
      parsedDepartment = rawStaffId['department']?.toString() ?? rawStaffId['dept']?.toString() ?? '';
    }
    if (parsedDepartment.isEmpty) {
      parsedDepartment = 'General Staff';
    }

    String parsedRole = json['role']?.toString() ?? json['designation']?.toString() ?? '';
    if (parsedRole.isEmpty && rawStaffId is Map) {
      parsedRole = rawStaffId['role']?.toString() ?? rawStaffId['designation']?.toString() ?? '';
    }
    if (parsedRole.isEmpty) {
      parsedRole = 'Staff Member';
    }

    // Parse markedBy (can be a nested Map from API or a String)
    String parsedMarkedBy = '';
    final rawMarkedBy = json['markedBy'];
    if (rawMarkedBy is Map) {
      final fName = rawMarkedBy['firstName']?.toString() ?? '';
      final lName = rawMarkedBy['lastName']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      if (fullName.isNotEmpty) {
        parsedMarkedBy = fullName;
      } else {
        parsedMarkedBy = rawMarkedBy['name']?.toString() ??
            rawMarkedBy['email']?.toString() ??
            rawMarkedBy['_id']?.toString() ??
            '';
      }
    } else if (rawMarkedBy != null) {
      parsedMarkedBy = rawMarkedBy.toString();
    }

    return StaffAttendanceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      staffId: parsedStaffId,
      staffName: parsedStaffName,
      department: parsedDepartment,
      role: parsedRole,
      schoolId: json['schoolId']?.toString() ?? '',
      markedBy: parsedMarkedBy,
      checkInTime: checkIn,
      checkOutTime: checkOut,
      date: dateParsed,
      punctuality: punct,
      attendanceType: json['attendanceType'] ?? json['type'] ?? 'QR ID Scan',
      status: stat,
      comment: commentVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'department': department,
      'role': role,
      'schoolId': schoolId,
      'markedBy': markedBy,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'date': date.toIso8601String(),
      'punctuality': punctuality,
      'attendanceType': attendanceType,
      'status': status,
      if (comment != null) 'comment': comment,
    };
  }

  StaffAttendanceModel copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? department,
    String? role,
    String? schoolId,
    String? markedBy,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? date,
    String? punctuality,
    String? attendanceType,
    String? status,
    String? comment,
  }) {
    return StaffAttendanceModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      department: department ?? this.department,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      markedBy: markedBy ?? this.markedBy,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      date: date ?? this.date,
      punctuality: punctuality ?? this.punctuality,
      attendanceType: attendanceType ?? this.attendanceType,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}

/// Result returned from the Mark Attendance API endpoint:
/// POST /api/v2/user/schoolstaffattendance/
class MarkAttendanceResult {
  final bool isSuccess;
  final String message;
  final String staffName;
  final StaffAttendanceModel? attendance;
  final String? errorMessage;
  final int? statusCode;

  const MarkAttendanceResult({
    required this.isSuccess,
    required this.message,
    this.staffName = '',
    this.attendance,
    this.errorMessage,
    this.statusCode,
  });

  factory MarkAttendanceResult.success({
    required String message,
    required String staffName,
    StaffAttendanceModel? attendance,
    int statusCode = 200,
  }) {
    return MarkAttendanceResult(
      isSuccess: true,
      message: message,
      staffName: staffName,
      attendance: attendance,
      statusCode: statusCode,
    );
  }

  factory MarkAttendanceResult.failure({
    required String message,
    String? errorMessage,
    int? statusCode,
  }) {
    return MarkAttendanceResult(
      isSuccess: false,
      message: message,
      errorMessage: errorMessage ?? message,
      statusCode: statusCode,
    );
  }
}
