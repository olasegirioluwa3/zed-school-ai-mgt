import 'package:flutter/material.dart';

class ResultSettingsScreen extends StatefulWidget {
  const ResultSettingsScreen({super.key});

  @override
  State<ResultSettingsScreen> createState() => _ResultSettingsScreenState();
}

class _ResultSettingsScreenState extends State<ResultSettingsScreen> {
  final _searchController = TextEditingController();

  final List<ResultSetting> _settings = [
    ResultSetting(
      id: 1,
      date: '15 Aug',
      details: 'term 2',
      info: '₦13,000',
      resume: 'Resume: 15 Aug',
      status: 'Active',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/resultoptions/d72e4dde-a52f-405e-8a55-d2a46f0d8ae9',
    ),
    ResultSetting(
      id: 2,
      date: '16 Jul',
      details: 'term 3',
      info: '₦2,300',
      resume: 'Resume: 16 Jul',
      status: 'Active',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/resultoptions/771fdeef-143e-4fcd-accc-65ec4f867593',
    ),
    ResultSetting(
      id: 3,
      date: '1 Jul',
      details: 'term 1',
      info: '₦2,000',
      resume: 'Resume: 1 Jul',
      status: 'Active',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/resultoptions/52ad7a76-7ccf-4f28-9237-bd98c05056c3',
    ),
  ];



  final _totalFeeController = TextEditingController();
  final _resumptionDateController = TextEditingController();

  void _showDeleteDialog(ResultSetting setting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Setting',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${setting.details}?',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _settings.remove(setting);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Setting deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _totalFeeController.dispose();
    _resumptionDateController.dispose();
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
          'Result Settings',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
            onPressed: () => _showAddSettingDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterSection(),
            const SizedBox(height: 16),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          hintText: 'Search...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
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
            'Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter applied')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply Filter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddSettingDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Setting'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7A00),
                    side: const BorderSide(color: Color(0xFFFF7A00)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
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
            'Settings List',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTable(),
        ],
      ),
    );
  }

  Widget _buildSettingsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
        dataRowMinHeight: 80,
        dataRowMaxHeight: 80,
        columns: const [
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Info', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ],
        rows: _settings.map((setting) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  setting.date,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      setting.details,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setting.resume,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  setting.info,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF7A00)),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: setting.status == 'Active'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    setting.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: setting.status == 'Active' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteDialog(setting),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddSettingDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSettingDialog(
        onSettingAdded: (newSetting) {
          setState(() {
            _settings.add(newSetting);
          });
        },
      ),
    );
  }
}

class AddSettingDialog extends StatefulWidget {
  final Function(ResultSetting) onSettingAdded;

  const AddSettingDialog({super.key, required this.onSettingAdded});

  @override
  State<AddSettingDialog> createState() => _AddSettingDialogState();
}

class _AddSettingDialogState extends State<AddSettingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _selectedClassController = TextEditingController();
  final _selectedSessionController = TextEditingController();
  final _selectedTermController = TextEditingController();
  final _resumptionDateController = TextEditingController();
  final _totalFeeController = TextEditingController();
  
  @override
  void dispose() {
    _selectedClassController.dispose();
    _selectedSessionController.dispose();
    _selectedTermController.dispose();
    _resumptionDateController.dispose();
    _totalFeeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newSetting = ResultSetting(
        id: DateTime.now().millisecondsSinceEpoch,
        date: _resumptionDateController.text.isEmpty ? 'Pending' : _resumptionDateController.text,
        details: _selectedTermController.text.isEmpty ? 'Pending' : _selectedTermController.text,
        info: '₦${_totalFeeController.text}',
        resume: 'Resume: ${_resumptionDateController.text}',
        status: 'Active',
        viewUrl: '',
      );
      
      Navigator.of(context).pop();
      widget.onSettingAdded(newSetting);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Result Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add New Setting',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSectionHeader('Basic Info'),
                const SizedBox(height: 16),
                _buildCheckboxGroup('Select Classes', ['Primary 6', 'Primary 3', 'Primary 2']),
                const SizedBox(height: 16),
                _buildDropdownField('Academic Session', 'Select Session', ['2026/2027', '2025/2026', '2024/2025']),
                const SizedBox(height: 16),
                _buildDropdownField('Term', 'Select Term', ['Term 01', 'Term 02', 'Term 03']),
                const SizedBox(height: 16),
                _buildTextField('Resumption Date', 'dd/mm/yyyy', _resumptionDateController),
                const SizedBox(height: 8),
                const Text(
                  'This date will appear on report sheets.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                
                _buildSectionHeader('Fee Info'),
                const SizedBox(height: 16),
                _buildTextField('Total Fee', '₦', _totalFeeController),
                const SizedBox(height: 16),
                _buildFeeBreakdown(),
                const SizedBox(height: 32),
                
                _buildSectionHeader('Show/Hide Options'),
                const SizedBox(height: 16),
                _buildShowHideOptions(),
                const SizedBox(height: 32),
                
                _buildSectionHeader('Custom Grading Scale'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Custom Grading Set',
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Default school grading will be used',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Custom grading coming soon
                          },
                          icon: const Icon(Icons.expand_more, size: 18),
                          label: const Text('Create Custom Grading'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF7A00),
                            side: const BorderSide(color: Color(0xFFFF7A00)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E293B),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Discard Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Save Setting'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildCheckboxGroup(String label, List<String> options) {
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
        const SizedBox(height: 12),
        ...options.map((option) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {},
                activeColor: const Color(0xFFFF7A00),
              ),
              const SizedBox(width: 12),
              Text(
                option,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> options) {
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
              hint: Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              items: options.map((String item) {
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
              onChanged: (value) {},
            ),
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

  Widget _buildFeeBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fee Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Fee items functionality coming soon
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7A00),
                  side: const BorderSide(color: Color(0xFFFF7A00)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Fee breakdown items will be added in future update',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowHideOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Show/Hide options will be available in future update',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class ResultSetting {
  final int id;
  final String date;
  final String details;
  final String info;
  final String resume;
  final String status;
  final String viewUrl;

  ResultSetting({
    required this.id,
    required this.date,
    required this.details,
    required this.info,
    required this.resume,
    required this.status,
    required this.viewUrl,
  });
}
