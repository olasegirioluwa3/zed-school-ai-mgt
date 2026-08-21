import 'package:flutter/material.dart';
import '../models/school.dart';

class SchoolSelector extends StatefulWidget {
  final School currentSchool;
  final List<School> availableSchools;
  final Function(School) onSchoolSelected;

  const SchoolSelector({
    super.key,
    required this.currentSchool,
    required this.availableSchools,
    required this.onSchoolSelected,
  });

  @override
  State<SchoolSelector> createState() => _SchoolSelectorState();
}

class _SchoolSelectorState extends State<SchoolSelector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSchoolDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.currentSchool.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '👩‍🏫',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _showSchoolDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select school',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableSchools.length,
                itemBuilder: (context, index) {
                  final school = widget.availableSchools[index];
                  final isSelected = school.id == widget.currentSchool.id;
                  return _buildSchoolItem(school, isSelected);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolItem(School school, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          widget.onSchoolSelected(school);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.transparent,
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFFFF8C42),
                size: 20,
              )
            else
              const SizedBox(width: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                school.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
