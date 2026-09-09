import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../models/school_model.dart';
import '../../services/session_service.dart';
import '../../services/school_service.dart';
import '../../utils/connectivity_helper.dart';

import '../../widgets/advert_slider.dart';

import 'results_screen.dart';
import 'profile_screen.dart';
import 'schoolpayment_screen.dart';
import 'school_screen.dart';

import 'students_class_screen.dart';
import 'school_attendance_screen.dart';
import 'qr_scan_screen.dart';
import '../ai_home/ai_home_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  UserModel? user;
  List<SchoolModel> schools = [];
  SchoolModel? selectedSchool;
  bool loadingSchools = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSchools();
  }

  Future<void> _loadUser() async {
    final currentUser = await SessionService.getUser();
    if (!mounted) return;
    setState(() => user = currentUser);
  }

  Future<void> _loadSchools() async {
    try {
      await ConnectivityHelper.throwIfNoInternet();
      final dynamic response = await SchoolService.getMySchools();
      final List<dynamic> rawList = (response is List) ? response : [];
      final List<SchoolModel> fetchedSchools = rawList.map((item) {
        final Map<String, dynamic> data = (item['schoolId'] is Map)
            ? Map<String, dynamic>.from(item['schoolId'])
            : Map<String, dynamic>.from(item);
        return SchoolModel.fromJson(data);
      }).toList();

      final savedSchoolId = await SessionService.getSelectedSchoolId();
      if (!mounted) return;

      setState(() {
        final Map<String, SchoolModel> schoolMap = {
          for (var s in fetchedSchools) s.id: s
        };
        schools = schoolMap.values.toList();
        if (savedSchoolId != null && schoolMap.containsKey(savedSchoolId)) {
          selectedSchool = schoolMap[savedSchoolId];
        } else if (schools.isNotEmpty) {
          selectedSchool = schools.first;
        } else {
          selectedSchool = null;
        }
        loadingSchools = false;
      });
    } catch (e) {
      debugPrint("Error loading schools: $e");
      if (!mounted) return;
      setState(() => loadingSchools = false);
    }
  }

  Future<void> _onSchoolSelected(SchoolModel school) async {
    await SessionService.saveSchool({
      "id": school.id,
      "schoolName": school.schoolName,
      "logoUrl": school.logoUrl ?? "",
    });
    if (!mounted) return;
    setState(() => selectedSchool = school);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      bottomNavigationBar: _bottomNav(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSchoolDropdown(),
            const SizedBox(height: 24),
            _buildGrid(),
            const SizedBox(height: 30),
            const PromoSlider(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.15),
          backgroundImage:
              (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                  ? NetworkImage(user!.profilePicture!)
                  : null,
          child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
              ? const Icon(Icons.person, color: Color(0xFFFF7A00), size: 22)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  user != null
                      ? "${user!.firstName} ${user!.lastName}"
                      : "Loading...",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const Text("Select School",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 14,
                color: Color(0xFFFF7A00),
              ),
              const SizedBox(width: 4),
              const Text("Admin",
                  style: TextStyle(
                      color: Color(0xFFFF7A00),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QrScanScreen(
                schoolName: selectedSchool?.schoolName,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 55,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SchoolModel>(
          isExpanded: true,
          value: selectedSchool != null &&
                  schools.any((s) => s.id == selectedSchool!.id)
              ? schools.firstWhere((s) => s.id == selectedSchool!.id)
              : null,
          hint: const Text("Select School"),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: schools.map((school) {
            return DropdownMenuItem<SchoolModel>(
              value: school,
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 14,
                      backgroundImage: (school.logoUrl ?? "").isNotEmpty
                          ? NetworkImage(school.logoUrl!)
                          : null),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(school.schoolName,
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
          onChanged: (school) {
            if (school != null) _onSchoolSelected(school);
          },
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _card(
            "Class Result",
            Icons.person_outline,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const StudentsClassScreen()))),
        _card(
            "Result",
            Icons.check_circle_outline,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ResultsScreen()))),
        _card(
            "School\nAttendance",
            Icons.assignment_turned_in_outlined,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SchoolAttendanceScreen(initialSchoolId: selectedSchool?.id),
                ),
            ),
        ),
        _card(
            "Payment",
            Icons.credit_card,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SchoolpaymentScreen()))),
      ],
    );
  }

  Widget _card(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFFFF7A00),
            borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: const Icon(Icons.home),
              color: Colors.orange,
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.school),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SchoolScreen()))),
          IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()))),
          IconButton(
              icon: const Icon(Icons.psychology),
              color: Colors.orange,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AiHomeScreen()))),
        ],
      ),
    );
  }
}
