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

  factory StaffAttendanceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final checkIn = parseDate(json['checkInTime'] ?? json['checkIn'] ?? json['time']);
    final checkOut = parseDate(json['checkOutTime'] ?? json['checkOut']);
    final dateParsed = parseDate(json['date'] ?? json['createdAt']) ?? checkIn ?? DateTime.now();

    // Determine punctuality
    String punct = json['punctuality'] ?? '';
    if (punct.isEmpty && checkIn != null) {
      final local = checkIn.toLocal();
      punct = (local.hour < 8 || (local.hour == 8 && local.minute <= 30))
          ? 'On Time'
          : 'Late Arrival';
    } else if (punct.isEmpty) {
      punct = 'On Time';
    }

    // Determine status
    String stat = json['status'] ?? '';
    if (stat.isEmpty) {
      stat = checkOut != null ? 'Checked Out' : 'Checked In';
    }

    return StaffAttendanceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? json['staff_id']?.toString() ?? '',
      staffName: json['staffName']?.toString() ??
          json['name']?.toString() ??
          json['fullName']?.toString() ??
          'Staff Member',
      department: json['department']?.toString() ?? json['dept']?.toString() ?? 'General Staff',
      role: json['role']?.toString() ?? json['designation']?.toString() ?? 'Staff Member',
      schoolId: json['schoolId']?.toString() ?? '',
      markedBy: json['markedBy']?.toString() ?? '',
      checkInTime: checkIn,
      checkOutTime: checkOut,
      date: dateParsed,
      punctuality: punct,
      attendanceType: json['attendanceType'] ?? json['type'] ?? 'QR ID Scan',
      status: stat,
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
    );
  }
}
