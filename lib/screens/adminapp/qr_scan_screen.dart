import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/staff_attendance_service.dart';
import 'staff_attendance_success_screen.dart';

class StaffAttendanceRecord {
  final String staffId;
  final String name;
  final String department;
  final String role;
  final String? profilePicture;
  final DateTime timestamp;
  final String status;

  StaffAttendanceRecord({
    required this.staffId,
    required this.name,
    this.department = 'Academic / Teaching',
    this.role = 'Staff Member',
    this.profilePicture,
    required this.timestamp,
    this.status = 'Present',
  });
}

class QrScanScreen extends StatefulWidget {
  final String? schoolName;

  const QrScanScreen({super.key, this.schoolName});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _controller;
  late AnimationController _laserAnimationController;

  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isCheckInMode = true; // true = Check-In, false = Check-Out

  // Real-time scan feedback & timer
  Timer? _scanTimer;
  int _secondsElapsed = 0;

  // Track staff members scanned during this active session
  final List<StaffAttendanceRecord> _sessionAttendance = [];

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _startScanTimer();
  }

  void _startScanTimer() {
    _scanTimer?.cancel();
    _secondsElapsed = 0;
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (!_isProcessing) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _resetScanTimer() {
    setState(() {
      _secondsElapsed = 0;
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _laserAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Parse data scanned from Staff ID Card QR Code
  StaffAttendanceRecord _parseStaffQrData(String rawData) {
    String staffId = rawData.trim();
    String staffName = 'Staff Member';
    String department = 'Academic / Teaching';
    String role = 'Staff Member';
    String? profilePicture;

    try {
      if (rawData.startsWith('{') && rawData.endsWith('}')) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(jsonDecode(rawData));
        staffId = json['userId']?.toString() ??
            json['staffId']?.toString() ??
            json['id']?.toString() ??
            json['staff_id']?.toString() ??
            json['code']?.toString() ??
            staffId;
        if (json['name'] != null) {
          staffName = json['name'].toString();
        } else if (json['staffName'] != null) {
          staffName = json['staffName'].toString();
        } else if (json['fullName'] != null) {
          staffName = json['fullName'].toString();
        } else if (json['firstName'] != null) {
          staffName = "${json['firstName']} ${json['lastName'] ?? ''}".trim();
        } else if (json['username'] != null) {
          staffName = json['username'].toString();
        }
        department = json['department'] ??
            json['dept'] ??
            department;
        role = json['role'] ??
            json['designation'] ??
            json['title'] ??
            role;
        profilePicture = json['profilePicture']?.toString() ??
            json['avatar']?.toString() ??
            json['photoUrl']?.toString() ??
            json['photo']?.toString() ??
            json['image']?.toString() ??
            json['picture']?.toString();
      } else if (rawData.contains('staffId=') || rawData.contains('id=') || rawData.contains('name=')) {
        final uri = Uri.tryParse(rawData);
        if (uri != null) {
          staffId = uri.queryParameters['staffId'] ??
              uri.queryParameters['id'] ??
              staffId;
          staffName = uri.queryParameters['name'] ??
              uri.queryParameters['staffName'] ??
              staffName;
          department = uri.queryParameters['dept'] ?? department;
          role = uri.queryParameters['role'] ?? role;
        }
      } else if (rawData.toLowerCase().contains('name:')) {
        // e.g. "Name: Oluwaseun Adeyemi, ID: STF-01"
        final parts = rawData.split(RegExp(r'[,;\n]'));
        for (final p in parts) {
          final trimmed = p.trim();
          if (trimmed.toLowerCase().startsWith('name:')) {
            staffName = trimmed.substring(5).trim();
          } else if (trimmed.toLowerCase().startsWith('id:')) {
            staffId = trimmed.substring(3).trim();
          }
        }
      } else if (!rawData.startsWith('http') && rawData.contains(' ') && !RegExp(r'^[0-9\-]+$').hasMatch(rawData)) {
        // Text with spaces like "Mr. Oluwaseun Adeyemi"
        staffName = rawData.trim();
      } else if (RegExp(r'^[a-zA-Z]{3,25}$').hasMatch(rawData.trim())) {
        // Single word name like "Adeyemi"
        staffName = rawData.trim();
      }
    } catch (_) {
      // Keep fallback
    }

    return StaffAttendanceRecord(
      staffId: staffId,
      name: staffName,
      department: department,
      role: role,
      profilePicture: profilePicture,
      timestamp: DateTime.now(),
      status: 'Present',
    );
  }

  Future<void> _handleAttendanceVerification(StaffAttendanceRecord record) async {
    final bool alreadyScanned =
        _sessionAttendance.any((s) => s.staffId == record.staffId);

    if (!alreadyScanned) {
      setState(() {
        _sessionAttendance.insert(0, record);
      });
    }

    // Call Check-In or Check-Out API based on active mode
    final activeSchoolId = await StaffAttendanceService.getActiveSchoolId();
    String verifiedStaffName = record.name;
    try {
      final action = _isCheckInMode ? 'check-in' : 'check-out';
      final result = await StaffAttendanceService.markAttendance(
        schoolId: activeSchoolId,
        staffId: record.staffId,
        action: action,
        staffName: record.name,
        department: record.department,
        role: record.role,
      );

      if (result.staffName.isNotEmpty && result.staffName != 'Staff Member') {
        verifiedStaffName = result.staffName;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: result.isSuccess
                ? (_isCheckInMode
                    ? const Color(0xFF10B981)
                    : const Color(0xFF3B82F6))
                : const Color(0xFFEF4444),
            content: Text(result.message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Attendance API sync error: $e");
    }

    if (!mounted) return;

    // Navigate to Staff Attendance Verify Successful Screen
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => StaffAttendanceSuccessScreen(
          staffId: record.staffId,
          staffName: verifiedStaffName,
          department: record.department,
          role: record.role,
          profilePicture: record.profilePicture,
          schoolName: widget.schoolName ?? 'ZED Model School',
          timestamp: record.timestamp,
          isAlreadyLogged: alreadyScanned,
          attendanceType: _isCheckInMode ? 'Morning QR Check-In' : 'Evening QR Check-Out',
        ),
      ),
    );

    if (mounted) {
      _resetScanTimer();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawCode = barcodes.first.rawValue;
    if (rawCode == null || rawCode.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    final record = _parseStaffQrData(rawCode);
    _handleAttendanceVerification(record);
  }

  /// Pick an ID Card photo from gallery or camera to decode
  Future<void> _pickImageAndScan() async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isProcessing = true);

      // On mobile/native, analyzeImage decodes barcode from file path
      final BarcodeCapture? capture =
          await _controller.analyzeImage(image.path);

      if (capture != null &&
          capture.barcodes.isNotEmpty &&
          capture.barcodes.first.rawValue != null) {
        final record =
            _parseStaffQrData(capture.barcodes.first.rawValue!);
        await _handleAttendanceVerification(record);
      } else {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFE11D48),
            content: Text(
              "No QR code found in selected photo. Please ensure clear lighting.",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error analyzing image: $e");
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showManualEntryDialog();
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  void _showWhyTakingLongSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF7A00).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFFFF7A00),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Why is the Scan taking time?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _helpTip(
                Icons.light_mode_outlined,
                "Card Glare / Reflection",
                "Laminated ID cards reflect overhead lights. Tilt the card slightly to eliminate white glare.",
              ),
              const SizedBox(height: 12),
              _helpTip(
                Icons.crop_free,
                "Distance & Focus",
                "Hold the card about 15-20 cm (6-8 inches) away so the camera can focus clearly.",
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 12),
                _helpTip(
                  Icons.laptop_chromebook,
                  "Webcam on Chrome",
                  "Laptop webcams often have fixed focus. Hold the card steady and fill 60% of the box.",
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  "Don't wait: Enter Staff ID Manually",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showManualEntryDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _helpTip(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF7A00)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSessionHistorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Session Scans (${_sessionAttendance.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_sessionAttendance.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      "No staff scanned yet in this session.\nScan a Staff ID Card to verify attendance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _sessionAttendance.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _sessionAttendance[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFFFF7A00).withValues(alpha: 0.12),
                          child: const Icon(Icons.badge,
                              color: Color(0xFFFF7A00), size: 20),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          "${item.staffId} • ${_formatTime(item.timestamp)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Verified",
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showManualEntryDialog() {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.badge_outlined, color: Color(0xFFFF7A00)),
              SizedBox(width: 8),
              Text("Staff Attendance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Staff Full Name:",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "e.g. Mr. Oluwaseun Adeyemi",
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Staff ID (Optional):",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  hintText: "e.g. STF-2024-001",
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final enteredName = nameController.text.trim();
                final enteredId = idController.text.trim();
                Navigator.pop(dialogCtx);
                if (enteredName.isNotEmpty || enteredId.isNotEmpty) {
                  final displayName = enteredName.isNotEmpty
                      ? enteredName
                      : enteredId;
                  final displayId = enteredId.isNotEmpty
                      ? enteredId
                      : "STF-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

                  final record = StaffAttendanceRecord(
                    staffId: displayId,
                    name: displayName,
                    timestamp: DateTime.now(),
                  );
                  _handleAttendanceVerification(record);
                }
              },
              child: const Text("Verify Attendance"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanBoxWidth = screenSize.width > 500 ? 340.0 : screenSize.width * 0.78;
    final scanBoxHeight = scanBoxWidth * 0.78;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        "Camera Access Required",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Please allow camera access in your browser or device to scan Staff ID Cards.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.keyboard),
                        label: const Text("Enter Staff ID Manually"),
                        onPressed: _showManualEntryDialog,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Translucent Vignette with Viewfinder Cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanBoxWidth,
                    height: scanBoxHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Viewfinder Frame, Laser & Corner Accents
          Center(
            child: SizedBox(
              width: scanBoxWidth,
              height: scanBoxHeight,
              child: Stack(
                children: [
                  // Corner Borders
                  CustomPaint(
                    size: Size(scanBoxWidth, scanBoxHeight),
                    painter: _ScannerBorderPainter(
                      color: _secondsElapsed > 6
                          ? const Color(0xFFF59E0B) // Amber warning if taking long
                          : const Color(0xFFFF7A00),
                      cornerLength: 32,
                      strokeWidth: 4,
                      borderRadius: 22,
                    ),
                  ),

                  // Subtle ID Card Watermark in Center
                  Center(
                    child: Icon(
                      Icons.badge_outlined,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),

                  // Animated Scanning Laser Bar
                  AnimatedBuilder(
                    animation: _laserAnimationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimationController.value *
                                (scanBoxHeight - 24) +
                            12,
                        left: 14,
                        right: 14,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF7A00).withValues(alpha:0.0),
                                const Color(0xFFFF7A00),
                                const Color(0xFFFFB066),
                                const Color(0xFFFF7A00),
                                const Color(0xFFFF7A00).withValues(alpha: 0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF7A00).withValues(alpha:0.8),
                                blurRadius: 8,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Top App Bar Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:0.45),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Staff Attendance Scanner",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Point at QR Code on Staff ID Card",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "Why is it taking time?" Info button
                  IconButton(
                    tooltip: "Scanning Help",
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline,
                          size: 18, color: Colors.white),
                    ),
                    onPressed: _showWhyTakingLongSheet,
                  ),

                  // Session Attendance Counter
                  GestureDetector(
                    onTap: _showSessionHistorySheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00).withValues(alpha:0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "${_sessionAttendance.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Torch button
                  if (!kIsWeb)
                    IconButton(
                      icon: Icon(
                        _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        color: _isTorchOn
                            ? const Color(0xFFFF7A00)
                            : Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          await _controller.toggleTorch();
                          setState(() => _isTorchOn = !_isTorchOn);
                        } catch (e) {
                          debugPrint("Torch not supported: $e");
                        }
                      },
                    ),

                  // Switch camera button
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () async {
                      try {
                        await _controller.switchCamera();
                      } catch (e) {
                        debugPrint("Switch camera not supported: $e");
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Real-Time Scanning Process Indicator Bar (Directly Above Viewfinder)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeToggle(),
                    const SizedBox(height: 8),
                    _buildScanningProcessBadge(),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls & Quick Options
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic Taking Long Alert Banner
                    if (_secondsElapsed >= 5) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFF7A00).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFF7A00),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Scanning taking longer than expected?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Hold card 15cm away or tap below to type ID",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: _showWhyTakingLongSheet,
                              child: const Text(
                                "Tips",
                                style: TextStyle(
                                  color: Color(0xFFFF7A00),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Action buttons row (Upload Photo + Manual Input)
                    Row(
                      children: [
                        // Upload / Pick Card Photo
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.16),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.image, size: 18),
                            label: const Text(
                              "Upload Photo",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            onPressed: _pickImageAndScan,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Enter Staff ID Manually (Guaranteed instant fallback)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF7A00),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.keyboard, size: 18),
                            label: const Text(
                              "Enter ID Manually",
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _showManualEntryDialog,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Live Scanning Process Status Badge
  Widget _buildScanningProcessBadge() {
    String statusTitle;
    String statusSubtitle;
    Color badgeColor;
    IconData statusIcon;

    if (_secondsElapsed < 3) {
      statusTitle = "Searching for Staff QR Code...";
      statusSubtitle = "Align card in the frame";
      badgeColor = const Color(0xFF10B981); // Green
      statusIcon = Icons.radar;
    } else if (_secondsElapsed < 7) {
      statusTitle = "Scanning & Analyzing Frame...";
      statusSubtitle = "Hold card steady (${_secondsElapsed}s)";
      badgeColor = const Color(0xFFFF7A00); // Orange
      statusIcon = Icons.filter_center_focus;
    } else {
      statusTitle = "Reading QR Code (${_secondsElapsed}s)...";
      statusSubtitle = "Check lighting or enter ID manually";
      badgeColor = const Color(0xFFF59E0B); // Amber
      statusIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: badgeColor.withValues(alpha:0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha:0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(statusIcon, color: badgeColor, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                statusTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statusSubtitle,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mode toggle widget between Check-In and Check-Out
  Widget _buildModeToggle() {
    return ToggleButtons(
      isSelected: [_isCheckInMode, !_isCheckInMode],
      onPressed: (int index) {
        setState(() {
          _isCheckInMode = index == 0;
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedBorderColor: const Color(0xFFFF7A00),
      selectedColor: Colors.white,
      fillColor: const Color(0xFFFF7A00),
      color: Colors.white70,
      constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
      children: const [
        Text('Check-In', style: TextStyle(fontSize: 12)),
        Text('Check-Out', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}


/// Custom painter for the viewfinder corner borders
class _ScannerBorderPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;

  _ScannerBorderPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final r = borderRadius;
    final l = cornerLength;

    // Top-left corner
    final topLeft = Path()
      ..moveTo(0, l)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(l, 0);
    canvas.drawPath(topLeft, paint);

    // Top-right corner
    final topRight = Path()
      ..moveTo(w - l, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, l);
    canvas.drawPath(topRight, paint);

    // Bottom-right corner
    final bottomRight = Path()
      ..moveTo(w, h - l)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(w - l, h);
    canvas.drawPath(bottomRight, paint);

    // Bottom-left corner
    final bottomLeft = Path()
      ..moveTo(l, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..lineTo(0, h - l);
    canvas.drawPath(bottomLeft, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
