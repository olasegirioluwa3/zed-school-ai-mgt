import 'package:flutter/material.dart';

class CbtFeeScreen extends StatefulWidget {
  const CbtFeeScreen({super.key});

  @override
  State<CbtFeeScreen> createState() => _CbtFeeScreenState();
}

class _CbtFeeScreenState extends State<CbtFeeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Student> _students = _getDefaultStudents();
  List<Student> _filteredStudents = [];
  final List<Student> _selectedStudents = [];
  String _selectedPackage = 'PKGCBT';
  String _paymentMethod = 'PAYSTACK';

  @override
  void initState() {
    super.initState();
    _filteredStudents = _students;
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.identity.toLowerCase().contains(query) ||
            student.contact.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleStudentSelection(Student student) {
    setState(() {
      if (_selectedStudents.contains(student)) {
        _selectedStudents.remove(student);
      } else {
        _selectedStudents.add(student);
      }
    });
  }

  double _calculateTotal() {
    final price = _selectedPackage == 'PKGCBT' ? 400.0 : 0.0;
    return price * _selectedStudents.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CBT Fee',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFFFF7A00), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_students.length}',
                  style: const TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildPaymentSection(),
            _buildStatsSection(),
            SizedBox(
              height: 450,
              child: _buildStudentTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.computer,
                  color: Color(0xFFFF7A00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CBT Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Choose CBT Package',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Text(
                  'Select Package',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedPackage,
                  items: const [
                    DropdownMenuItem(value: 'PKGCBT', child: Text('PKGCBT')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPackage = value!;
                    });
                  },
                  underline: const SizedBox(),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  const Color(0xFFFF9E42).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'CBT Access',
                  style: TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '₦400',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Text(
                  'PAYSTACK',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Radio<String>(
                  value: 'PAYSTACK',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                  activeColor: const Color(0xFFFF7A00),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Students',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedStudents.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₦${_calculateTotal().toInt()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedStudents.isEmpty ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Students', '19', Icons.people),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Status', 'Active', Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard('Records Directory', '0 Selected / 19 Total', Icons.folder),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF7A00),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search students by name, ID, or email...',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
              onPressed: () {
                _searchController.clear();
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use horizontal scroll for small screens
          if (constraints.maxWidth < 600) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 600, // Minimum width for the table
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTableHeader(),
                      // Show all students
                      ..._filteredStudents.map((student) => _buildStudentRow(student)),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Normal layout for larger screens - add vertical scroll
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTableHeader(),
                  // Show all students
                  ..._filteredStudents.map((student) => _buildStudentRow(student)),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const Expanded(
            flex: 2,
            child: Text(
              'Identity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 3,
            child: Text(
              'Contact',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: Text(
              'CBT Access',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: Text(
              'Valid Until',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: Text(
              'State',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Student student) {
    final isSelected = _selectedStudents.contains(student);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              _toggleStudentSelection(student);
            },
            activeColor: const Color(0xFFFF7A00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    student.initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7A00),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.contact,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _buildAccessBadge(student.cbtAccess),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: Text(
              student.validUntil,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _buildStateBadge(student.state),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAccessBadge(String access) {
    Color color;
    if (access == 'Authorized') {
      color = const Color(0xFF10B981);
    } else if (access == 'Restricted') {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        access,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStateBadge(String state) {
    Color color;
    if (state == 'active') {
      color = const Color(0xFF10B981);
    } else if (state == 'pending') {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _processPayment() {
    // Implement payment processing logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Processing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing payment for ${_selectedStudents.length} students'),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  static List<Student> _getDefaultStudents() {
    return [
      Student(
        initials: 'HO',
        name: 'Hannah Olorunshola',
        identity: 'morounkejivictor86',
        contact: 'morounkejivictor86@gmail.com',
        cbtAccess: 'Authorized',
        validUntil: '11 Nov 2026',
        state: 'pending',
      ),
      Student(
        initials: 'AR',
        name: 'Adeoti Ridwan',
        identity: 'adeotiridwan',
        contact: 'ridwanadeoti577@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'OO',
        name: 'Oluwafemi Olasegiri',
        identity: 'olasegirioluwa3',
        contact: 'o.olasegiri@zionai.com.ng',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'rA',
        name: 'rid Ade',
        identity: 'ridade',
        contact: 'N/A',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'TF',
        name: 'Talent Fc',
        identity: 'talent',
        contact: 'N/A',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'fA',
        name: 'favour Adelowo',
        identity: 'NO UID',
        contact: 'favouradelowo8@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'FA',
        name: 'Feranmi Alagbe',
        identity: 'oluwaferanmi alagbe',
        contact: 'N/A',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'fJ',
        name: 'feranmi Johnson',
        identity: 'feranmi',
        contact: 'N/A',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'AE',
        name: 'Adesola Emmanuel',
        identity: 'adesolaemmanuel',
        contact: 'N/A',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'JO',
        name: 'John Okafor',
        identity: 'johnokafor',
        contact: 'john.okafor@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'MB',
        name: 'Mary Benson',
        identity: 'marybenson',
        contact: 'mary.benson@yahoo.com',
        cbtAccess: 'Authorized',
        validUntil: '15 Dec 2026',
        state: 'active',
      ),
      Student(
        initials: 'DK',
        name: 'David Kolawole',
        identity: 'davidkolawole',
        contact: 'david.k@outlook.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'SA',
        name: 'Sarah Adeyemi',
        identity: 'sarahadeyemi',
        contact: 'sarah.adeyemi@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'EO',
        name: 'Emmanuel Okonkwo',
        identity: 'emmanuelokonkwo',
        contact: 'emmanuel.o@ng.com',
        cbtAccess: 'Authorized',
        validUntil: '20 Jan 2027',
        state: 'active',
      ),
      Student(
        initials: 'FA',
        name: 'Fatima Abdullahi',
        identity: 'fatimaabdullahi',
        contact: 'fatima.a@hotmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'CM',
        name: 'Chukwuma Mbakwe',
        identity: 'chukwumambakwe',
        contact: 'chukwu.m@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
      Student(
        initials: 'GK',
        name: 'Grace Kalu',
        identity: 'gracekalu',
        contact: 'grace.kalu@yahoo.com',
        cbtAccess: 'Authorized',
        validUntil: '10 Mar 2027',
        state: 'active',
      ),
      Student(
        initials: 'IO',
        name: 'Ifeoma Okafor',
        identity: 'ifeomaokafor',
        contact: 'ifeoma.o@gmail.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'pending',
      ),
      Student(
        initials: 'BK',
        name: 'Babatunde Kuti',
        identity: 'babatundekuti',
        contact: 'baba.kuti@ng.com',
        cbtAccess: 'Restricted',
        validUntil: 'NOT APPLICABLE',
        state: 'active',
      ),
    ];
  }
}

class Student {
  final String initials;
  final String name;
  final String identity;
  final String contact;
  final String cbtAccess;
  final String validUntil;
  final String state;

  Student({
    required this.initials,
    required this.name,
    required this.identity,
    required this.contact,
    required this.cbtAccess,
    required this.validUntil,
    required this.state,
  });
}