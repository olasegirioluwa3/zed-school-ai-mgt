import 'package:flutter/material.dart';
import '../../models/class_model.dart';

class AddResultPage extends StatefulWidget {
  final StudentModel student;

  const AddResultPage({super.key, required this.student});

  @override
  State<AddResultPage> createState() => _AddResultPageState();
}

class _AddResultPageState extends State<AddResultPage> {
  final _formKey = GlobalKey<FormState>();
  final _sessionController = TextEditingController();
  final _termController = TextEditingController();
  final _daysPresentController = TextEditingController();
  final _daysAbsentController = TextEditingController();
  final _teacherRemarkController = TextEditingController();
  final _principalRemarkController = TextEditingController();
  
  String? _selectedSession;
  String? _selectedTerm;
  String? _selectedSubject;
  
  final _firstCAController = TextEditingController();
  final _secondCAController = TextEditingController();
  final _assignmentController = TextEditingController();
  final _practicalController = TextEditingController();
  final _examController = TextEditingController();

  final List<SubjectResult> _subjects = [];

  final List<String> _sessions = [
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  final List<String> _terms = [
    'First Term',
    'Second Term',
    'Third Term',
  ];

  final List<String> _subjectsList = [
    'Mathematics',
    'English',
    'Science',
    'Social Studies',
    'Computer Studies',
    'Physical Education',
    'Art',
    'Music',
    'French',
    'Yoruba',
  ];

  @override
  void dispose() {
    _sessionController.dispose();
    _termController.dispose();
    _daysPresentController.dispose();
    _daysAbsentController.dispose();
    _teacherRemarkController.dispose();
    _principalRemarkController.dispose();
    _firstCAController.dispose();
    _secondCAController.dispose();
    _assignmentController.dispose();
    _practicalController.dispose();
    _examController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Result',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassInfoCard(),
              const SizedBox(height: 16),
              _buildSubjectCard(),
              const SizedBox(height: 16),
              _buildAttendanceCard(),
              const SizedBox(height: 16),
              _buildRemarksCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Class', 'Primary 6'),
          const SizedBox(height: 16),
          _buildDropdownField('Session', 'Select a session', _sessions, (value) {
            setState(() {
              _selectedSession = value;
            });
          }),
          const SizedBox(height: 16),
          _buildDropdownField('Term', 'Select a term', _terms, (value) {
            setState(() {
              _selectedTerm = value;
            });
          }),
          const SizedBox(height: 16),
          _buildStudentField(),
        ],
      ),
    );
  }

  Widget _buildStudentField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
            child: Text(
              widget.student.initials,
              style: const TextStyle(
                color: Color(0xFFFF7A00),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.student.admissionNo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subject & Scores',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Score: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      '${_calculateTotalScore()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF7A00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdownField('Subject', 'Select a subject', _subjectsList, (value) {
            setState(() {
              _selectedSubject = value;
            });
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildNumberField('1st CA', _firstCAController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField('2nd CA', _secondCAController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNumberField('Assignment', _assignmentController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField('Practical', _practicalController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberField('Exam', _examController),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_subjects.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Added Subjects',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ..._subjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              return _buildSubjectItem(subject, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectItem(SubjectResult subject, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () {
                  setState(() {
                    _subjects.removeAt(index);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScoreBadge('1st CA', subject.firstCA),
              const SizedBox(width: 8),
              _buildScoreBadge('2nd CA', subject.secondCA),
              const SizedBox(width: 8),
              _buildScoreBadge('Assign', subject.assignment),
              const SizedBox(width: 8),
              _buildScoreBadge('Prac', subject.practical),
              const SizedBox(width: 8),
              _buildScoreBadge('Exam', subject.exam),
              const SizedBox(width: 8),
              _buildScoreBadge('Total', subject.total, isTotal: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String label, int value, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTotal
            ? const Color(0xFFFF7A00).withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTotal
              ? const Color(0xFFFF7A00)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isTotal
                  ? const Color(0xFFFF7A00)
                  : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isTotal
                  ? const Color(0xFFFF7A00)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubject() {
    if (_selectedSubject != null && _selectedSubject!.isNotEmpty) {
      final subject = SubjectResult(
        name: _selectedSubject!,
        firstCA: int.tryParse(_firstCAController.text) ?? 0,
        secondCA: int.tryParse(_secondCAController.text) ?? 0,
        assignment: int.tryParse(_assignmentController.text) ?? 0,
        practical: int.tryParse(_practicalController.text) ?? 0,
        exam: int.tryParse(_examController.text) ?? 0,
      );
      subject.calculateTotal();
      setState(() {
        _subjects.add(subject);
        _selectedSubject = null;
        _firstCAController.clear();
        _secondCAController.clear();
        _assignmentController.clear();
        _practicalController.clear();
        _examController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateTotalScore() {
    return _subjects.fold(0, (sum, subject) => sum + subject.total);
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Days Present', 'e.g. 45', _daysPresentController),
          const SizedBox(height: 16),
          _buildTextField('Days Absent', 'e.g. 5', _daysAbsentController),
        ],
      ),
    );
  }

  Widget _buildRemarksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remarks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          _buildRemarkSection('Teacher', 'Teacher\'s Remark', 'Enter teacher\'s remark...', _teacherRemarkController),
          const SizedBox(height: 20),
          _buildRemarkSection('Principal', 'Principal\'s Remark', 'Enter principal\'s remark...', _principalRemarkController),
        ],
      ),
    );
  }

  Widget _buildRemarkSection(String title, String hint, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String>? items, void Function(String?)? onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items != null ? (label == 'Session' ? _selectedSession : _selectedTerm) : hint,
              hint: Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              items: items?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Result saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: const Text('Save Result'),
      ),
    );
  }
}

class SubjectResult {
  String name;
  int firstCA;
  int secondCA;
  int assignment;
  int practical;
  int exam;
  int total;

  SubjectResult({
    required this.name,
    this.firstCA = 0,
    this.secondCA = 0,
    this.assignment = 0,
    this.practical = 0,
    this.exam = 0,
    this.total = 0,
  });

  void calculateTotal() {
    total = firstCA + secondCA + assignment + practical + exam;
  }
}
