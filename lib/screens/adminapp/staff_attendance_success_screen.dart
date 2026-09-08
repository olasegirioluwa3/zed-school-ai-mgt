import 'dart:async';
import 'package:flutter/material.dart';

class StaffAttendanceSuccessScreen extends StatefulWidget {
  final String staffId;
  final String staffName;
  final String department;
  final String role;
  final String? profilePicture;
  final String schoolName;
  final DateTime timestamp;
  final bool isAlreadyLogged;
  final String attendanceType;

  const StaffAttendanceSuccessScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    this.department = 'Academic Staff',
    this.role = 'Staff Member',
    this.profilePicture,
    this.schoolName = 'ZED Model School',
    required this.timestamp,
    this.isAlreadyLogged = false,
    this.attendanceType = 'Morning QR Check-In',
  });

  @override
  State<StaffAttendanceSuccessScreen> createState() =>
      _StaffAttendanceSuccessScreenState();
}

class _StaffAttendanceSuccessScreenState
    extends State<StaffAttendanceSuccessScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _secondsRemaining = 2;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // 2-second countdown controller for smooth visual progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Auto-return to QR Code Scanning after 2 seconds
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _countdownTimer?.cancel();
          _returnToScanner();
        }
      });
    });
  }

  void _returnToScanner() {
    _countdownTimer?.cancel();
    if (mounted) {
      Navigator.pop(context, true); // signals scanner to immediately resume
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec $period';
  }

  String _formatDate(DateTime dt) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
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
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  bool get _isOnTime {
    return widget.timestamp.hour < 8 ||
        (widget.timestamp.hour == 8 && widget.timestamp.minute <= 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: _returnToScanner,
        ),
        title: const Text(
          "Attendance Verified",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Visual countdown pill in top bar
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 14, color: Color(0xFFFF7A00)),
                const SizedBox(width: 4),
                Text(
                  "${_secondsRemaining}s auto-scan",
                  style: const TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto-Return Timer Progress Indicator Banner
              _buildAutoReturnBanner(),
              const SizedBox(height: 16),

              // Status Header showing STAFF NAME prominently
              _buildStatusHeader(),
              const SizedBox(height: 18),

              // Official Staff ID Card with Large Name
              _buildStaffIdCard(),
              const SizedBox(height: 18),

              // Attendance Breakdown Details
              _buildAttendanceBreakdown(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Auto-return banner showing countdown and visual progress bar
  Widget _buildAutoReturnBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Next scan begins in $_secondsRemaining seconds...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _returnToScanner,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Scan Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
                  minHeight: 3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.isAlreadyLogged
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isAlreadyLogged
              ? const Color(0xFFFDE68A)
              : const Color(0xFFA7F3D0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: widget.isAlreadyLogged
                  ? const Color(0xFFFF7A00)
                  : const Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isAlreadyLogged
                          ? const Color(0xFFFF7A00)
                          : const Color(0xFF10B981))
                      .withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              widget.isAlreadyLogged ? Icons.info_outline : Icons.check,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 12),

          // STAFF NAME DISPLAYED AS THE HERO TITLE
          Text(
            widget.staffName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: widget.isAlreadyLogged
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.isAlreadyLogged
                  ? "Already Recorded Today"
                  : "Verified Present at School Today",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.isAlreadyLogged
                    ? const Color(0xFFB45309)
                    : const Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffIdCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ID Card Header Band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schoolName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "STAFF IDENTIFICATION CARD",
                        style: TextStyle(
                          color: Color(0xFFFFB066),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "PRESENT",
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ID Card Body with Staff Details
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Staff Photo with Verification Badge
                    Stack(
                      children: [
                        Container(
                          width: 78,
                          height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF7A00).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: (widget.profilePicture != null &&
                                  widget.profilePicture!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    widget.profilePicture!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 46,
                                  color: Color(0xFFFF7A00),
                                ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Staff Name & Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large prominent Staff Name
                          Text(
                            widget.staffName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Role / Designation
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.role,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF7A00),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Department
                          Text(
                            "Dept: ${widget.department}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Staff ID Number
                          Row(
                            children: [
                              const Icon(Icons.qr_code,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                "ID: ${widget.staffId}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card Footer Bar with Verification Confirmation
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Verified via Staff ID Card QR Code",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available, color: Color(0xFFFF7A00), size: 18),
              SizedBox(width: 8),
              Text(
                "Today's Attendance Record",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(
              "Staff Name", widget.staffName, Icons.person_outline),
          const Divider(height: 16),
          _detailRow(
              "Date", _formatDate(widget.timestamp), Icons.calendar_today),
          const Divider(height: 16),
          _detailRow(
              "Check-In Time", _formatTime(widget.timestamp), Icons.access_time),
          const Divider(height: 16),
          _detailRow(
            "Punctuality",
            _isOnTime ? "On Time" : "Late Arrival",
            Icons.timer_outlined,
            valueColor: _isOnTime
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
          ),
          const Divider(height: 16),
          _detailRow(
            "Attendance Type",
            widget.attendanceType,
            Icons.badge_outlined,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary: Scan Next Staff Card
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7A00),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.qr_code_scanner, size: 22),
          label: Text(
            "Scan Next Staff ID Card (${_secondsRemaining}s)",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _returnToScanner,
        ),
        const SizedBox(height: 12),

        // Secondary: Done / Back to Home
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.home_outlined,
              size: 20, color: Color(0xFF475569)),
          label: const Text(
            "Done / Back to Admin Home",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          onPressed: () {
            _countdownTimer?.cancel();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
