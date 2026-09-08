import 'package:flutter/material.dart';
import '../../models/staff_attendance_model.dart';
import '../../models/school_model.dart';
import '../../services/school_service.dart';
import '../../services/session_service.dart';
import '../../services/staff_attendance_service.dart';
import 'qr_scan_screen.dart';

class SchoolAttendanceScreen extends StatefulWidget {
  final String? initialSchoolId;

  const SchoolAttendanceScreen({super.key, this.initialSchoolId});

  @override
  State<SchoolAttendanceScreen> createState() => _SchoolAttendanceScreenState();
}

class _SchoolAttendanceScreenState extends State<SchoolAttendanceScreen> {
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  List<StaffAttendanceModel> _attendanceRecords = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // 'All', 'Checked In', 'Checked Out', 'On Time', 'Late'
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadSchools();
    if (_selectedSchool != null) {
      await _loadAttendance(_selectedSchool!.id);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchools() async {
    try {
      final rawList = await SchoolService.getMySchools();
      final List<SchoolModel> fetched = rawList.map((item) {
        final Map<String, dynamic> data = (item['schoolId'] is Map)
            ? Map<String, dynamic>.from(item['schoolId'])
            : Map<String, dynamic>.from(item);
        return SchoolModel.fromJson(data);
      }).toList();

      final savedId = await SessionService.getSelectedSchoolId();
      if (!mounted) return;

      setState(() {
        _schools = fetched;
        if (widget.initialSchoolId != null &&
            _schools.any((s) => s.id == widget.initialSchoolId)) {
          _selectedSchool = _schools.firstWhere((s) => s.id == widget.initialSchoolId);
        } else if (savedId != null && _schools.any((s) => s.id == savedId)) {
          _selectedSchool = _schools.firstWhere((s) => s.id == savedId);
        } else if (_schools.isNotEmpty) {
          _selectedSchool = _schools.first;
        }
      });
    } catch (e) {
      debugPrint("Error loading schools in Attendance: $e");
    }
  }

  Future<void> _loadAttendance(String schoolId) async {
    setState(() => _isLoading = true);
    try {
      final records = await StaffAttendanceService.fetchTodayAttendance(schoolId: schoolId);
      if (!mounted) return;
      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading attendance records: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<StaffAttendanceModel> get _filteredRecords {
    return _attendanceRecords.where((record) {
      // Filter by status/punctuality
      if (_selectedFilter == 'Checked In') {
        return record.status == 'Checked In';
      } else if (_selectedFilter == 'Checked Out') {
        return record.isCheckedOut;
      } else if (_selectedFilter == 'On Time') {
        return record.isOnTime;
      } else if (_selectedFilter == 'Late') {
        return !record.isOnTime;
      }
      return true;
    }).toList();
  }

  // Quick Manual Check-Out
  Future<void> _handleQuickCheckOut(StaffAttendanceModel record) async {
    if (_selectedSchool == null) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checking out ${record.staffName}..."),
          duration: const Duration(seconds: 1),
        ),
      );

      await StaffAttendanceService.syncCheckOut(
        schoolId: _selectedSchool!.id,
        staffId: record.staffId,
        staffName: record.staffName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text("Check-out successful"),
        ),
      );

      _loadAttendance(_selectedSchool!.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE11D48),
          content: Text("Check-out failed"),
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = _attendanceRecords.length;
    final int checkedInCount = _attendanceRecords.where((r) => r.status == 'Checked In').length;
    final int checkedOutCount = _attendanceRecords.where((r) => r.isCheckedOut).length;
    final int lateCount = _attendanceRecords.where((r) => !r.isOnTime).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Staff Attendance",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Refresh Button
          IconButton(
            tooltip: "Refresh Attendance",
            icon: const Icon(Icons.refresh, color: Color(0xFFFF7A00)),
            onPressed: () {
              if (_selectedSchool != null) {
                _loadAttendance(_selectedSchool!.id);
              }
            },
          ),
          // QR Code Scanner Action
          IconButton(
            tooltip: "Open QR Scanner",
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScanScreen(
                    schoolName: _selectedSchool?.schoolName,
                  ),
                ),
              );
              if (_selectedSchool != null) {
                _loadAttendance(_selectedSchool!.id);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text(
          "Scan Staff Card",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QrScanScreen(
                schoolName: _selectedSchool?.schoolName,
              ),
            ),
          );
          if (_selectedSchool != null) {
            _loadAttendance(_selectedSchool!.id);
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedSchool != null) {
            await _loadAttendance(_selectedSchool!.id);
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // School Selector & Date Bar
            _buildSchoolAndDateBar(),
            const SizedBox(height: 16),

            // Attendance KPI Counters
            _buildKpiSummary(
              total: totalCount,
              checkedIn: checkedInCount,
              checkedOut: checkedOutCount,
              lateCount: lateCount,
            ),
            const SizedBox(height: 18),

            // Filter Tabs (All, Checked In, Checked Out, On Time, Late)
            _buildFilterChips(),
            const SizedBox(height: 16),

            // Records List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attendance Records (${_filteredRecords.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Records List or Empty State
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: Color(0xFFFF7A00)),
                ),
              )
            else if (_filteredRecords.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return _buildAttendanceCard(record);
                },
              ),

            const SizedBox(height: 80), // Fab padding
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolAndDateBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Color(0xFFFF7A00), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: _schools.isEmpty
                ? Text(
                    _selectedSchool?.schoolName ?? "Active School",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<SchoolModel>(
                      isExpanded: true,
                      value: _selectedSchool != null &&
                              _schools.any((s) => s.id == _selectedSchool!.id)
                          ? _schools.firstWhere((s) => s.id == _selectedSchool!.id)
                          : null,
                      hint: const Text("Select School"),
                      items: _schools.map((s) {
                        return DropdownMenuItem<SchoolModel>(
                          value: s,
                          child: Text(
                            s.schoolName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSchool = val);
                          _loadAttendance(val.id);
                        }
                      },
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSummary({
    required int total,
    required int checkedIn,
    required int checkedOut,
    required int lateCount,
  }) {
    return Row(
      children: [
        _kpiBox("Total Staff", "$total", const Color(0xFF1E293B), Icons.groups),
        const SizedBox(width: 8),
        _kpiBox("Checked In", "$checkedIn", const Color(0xFF10B981), Icons.login),
        const SizedBox(width: 8),
        _kpiBox("Checked Out", "$checkedOut", const Color(0xFF3B82F6), Icons.logout),
        const SizedBox(width: 8),
        _kpiBox("Late Arrivals", "$lateCount", const Color(0xFFF59E0B), Icons.timer_outlined),
      ],
    );
  }

  Widget _kpiBox(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Checked In', 'Checked Out', 'On Time', 'Late'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f),
              selected: isSelected,
              selectedColor: const Color(0xFFFF7A00),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                setState(() => _selectedFilter = f);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceCard(StaffAttendanceModel record) {
    final bool isCheckedOut = record.isCheckedOut;
    final bool isOnTime = record.isOnTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Staff Name & Punctuality Tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFF7A00).withOpacity(0.12),
                child: const Icon(Icons.person, color: Color(0xFFFF7A00), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.staffName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${record.role} • ${record.department}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Punctuality Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnTime
                      ? const Color(0xFF10B981).withOpacity(0.12)
                      : const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnTime ? Icons.check_circle : Icons.timer_outlined,
                      size: 12,
                      color: isOnTime ? const Color(0xFF10B981) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.punctuality,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOnTime ? const Color(0xFF10B981) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          // Metadata Grid: Date, Check-In Time, Check-Out Time, Attendance Type
          Row(
            children: [
              // Check In
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.login, size: 13, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          "Check-In Time",
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.formattedCheckIn,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),

              // Check Out
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.logout, size: 13, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 4),
                        Text(
                          "Check-Out Time",
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.formattedCheckOut,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCheckedOut ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              // Attendance Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 13, color: Color(0xFFFF7A00)),
                        const SizedBox(width: 4),
                        Text(
                          "Attendance Type",
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.attendanceType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action if not checked out yet
          if (!isCheckedOut) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6).withOpacity(0.08),
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout, size: 14),
                label: const Text(
                  "Check Out Staff",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _handleQuickCheckOut(record),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_outlined, size: 40, color: Color(0xFFFF7A00)),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Attendance Records Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No staff attendance recorded for ${_formatDate(_selectedDate)} with filter '$_selectedFilter'.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text("Scan Staff ID Card"),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScanScreen(
                    schoolName: _selectedSchool?.schoolName,
                  ),
                ),
              );
              if (_selectedSchool != null) {
                _loadAttendance(_selectedSchool!.id);
              }
            },
          ),
        ],
      ),
    );
  }
}
