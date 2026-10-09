import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ai_home/ai_home_screen.dart';

class ResultPaymentPublishScreen extends StatefulWidget {
  const ResultPaymentPublishScreen({super.key});

  @override
  State<ResultPaymentPublishScreen> createState() => _ResultPaymentPublishScreenState();
}

class _ResultPaymentPublishScreenState extends State<ResultPaymentPublishScreen> {
  final Set<int> _selectedRecords = {};
  bool _selectAll = false;

  late List<ResultRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = _getRecords();
  }

  List<ResultRecord> _getRecords() {
    return [
      ResultRecord(
      id: 1,
      name: 'Hannah Olorunshola',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2026/2027 Academic Session',
      paymentStatus: 'Not Paid',
      resultStatus: 'draft',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/b12dc1ab-338d-4572-884b-61d1647b4184',
    ),
    ResultRecord(
      id: 2,
      name: 'Hannah Olorunshola',
      term: 'Term 3',
      classInfo: 'Primary 6',
      session: '2026/2027 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/6baee455-c045-42ce-94d4-421a4b79dfa7',
    ),
    ResultRecord(
      id: 3,
      name: 'Hannah Olorunshola',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2026/2027 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/8627b743-6596-4b00-a312-0feae076d57d',
    ),
    ResultRecord(
      id: 4,
      name: 'Oluwafemi Olasegiri',
      initials: 'OO',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'draft',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/a800f031-881b-4a84-8820-4e975059a8e5',
    ),
    ResultRecord(
      id: 5,
      name: 'favour Adelowo',
      initials: 'fA',
      term: 'Term 4',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/a184c317-f189-4fb9-ac7a-1baf617e9e61',
    ),
    ResultRecord(
      id: 6,
      name: 'Feranmi Alagbe',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/0fdd658a-65ea-4ccd-94f9-fd4b37ddf0b3',
    ),
    ResultRecord(
      id: 7,
      name: 'Hannah Olorunshola',
      term: 'Term 2',
      classInfo: 'Primary 3',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'draft',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/af969b4d-a168-44c4-98b3-0f2d347134c1',
    ),
    ResultRecord(
      id: 8,
      name: 'Hannah Olorunshola',
      term: 'Term 1',
      classInfo: 'Primary 3',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'draft',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/f5baf970-d18c-4e8f-bac1-710a4e139560',
    ),
    ResultRecord(
      id: 9,
      name: 'Adesola Emmanuel',
      initials: 'AE',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/51bef152-40d4-449c-a97f-e51e5c390e69',
    ),
    ResultRecord(
      id: 10,
      name: 'feranmi Johnson',
      initials: 'fJ',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/aa475430-58a7-4bc5-9cce-8f041e00d5de',
    ),
    ResultRecord(
      id: 11,
      name: 'feranmi Johnson',
      initials: 'fJ',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/8ac3cdb3-a48d-40bb-a869-0412ffff89a6',
    ),
    ResultRecord(
      id: 12,
      name: 'Oluwafemi Olasegiri',
      initials: 'OO',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/96fe6e04-22fd-4e8e-94f0-cdbfdcdb7bda',
    ),
    ResultRecord(
      id: 13,
      name: 'favour Adelowo',
      initials: 'fA',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/1f3cb72d-758f-4140-9390-087dd34b2287',
    ),
    ResultRecord(
      id: 14,
      name: 'favour Adelowo',
      initials: 'fA',
      term: 'Term 3',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/66f38b81-2b3e-4e1e-9292-a70f286fd441',
    ),
    ResultRecord(
      id: 15,
      name: 'Adeoti Ridwan',
      term: 'Term 3',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/7517a4ff-3e3b-429e-a640-35212208ff35',
    ),
    ResultRecord(
      id: 16,
      name: 'Oluwafemi Olasegiri',
      initials: 'OO',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/6cfb41ca-32c5-45d4-8273-80053bb149d0',
    ),
    ResultRecord(
      id: 17,
      name: 'Adeoti Ridwan',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/5b6419c9-28ce-41e5-9fef-ce006a4567e4',
    ),
    ResultRecord(
      id: 18,
      name: 'Hannah Olorunshola',
      term: 'Term 2',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/2e0191d6-de6b-4ffe-8b12-bed2fb67b286',
    ),
    ResultRecord(
      id: 19,
      name: 'Hannah Olorunshola',
      term: 'Term 3',
      classInfo: 'Primary 6',
      session: '2025/2026 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/d4b25acb-d2d5-4ba3-852a-41fab9752478',
    ),
    ResultRecord(
      id: 20,
      name: 'favour Adelowo',
      initials: 'fA',
      term: 'Term 1',
      classInfo: 'Primary 6',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'draft',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/3da5c763-df59-4380-9998-d83c6a8b303b',
    ),
    ResultRecord(
      id: 21,
      name: 'NO CLASS',
      term: 'Term 2',
      classInfo: 'NO CLASS',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/5e1d7b6e-9970-4210-a81b-0dae20e3f962',
    ),
    ResultRecord(
      id: 22,
      name: 'NO CLASS',
      term: 'Term 3',
      classInfo: 'NO CLASS',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/0fe0c168-49c0-4fb3-8bf2-c028d89f8c9f',
    ),
    ResultRecord(
      id: 23,
      name: 'NO CLASS',
      term: 'Term 1',
      classInfo: 'NO CLASS',
      session: '2024/2025 Academic Session',
      paymentStatus: 'Paid',
      resultStatus: 'publish',
      viewUrl: 'https://school.zionai.com.ng/portal/admin/dashboard/results/0ab70483-9dcb-4598-b11c-3b119a13a9c2',
    ),
    ];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
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
          'Student Results',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPublishPayCard(),
            const SizedBox(height: 16),
            _buildFilterSection(),
            const SizedBox(height: 16),
            _buildRecordsDirectory(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishPayCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.publish,
                  color: Color(0xFFFF7A00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publish & Pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select packages and publish results',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF7A00),
                  const Color(0xFFFF7A00).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₦500',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKGRES',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Result Package',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Publish & Pay coming soon')),
                    );
                  },
                  icon: const Icon(Icons.publish, size: 18),
                  label: const Text('Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AiHomeScreen(
                          initialPrompt: 'I need to pay ₦500 for result publishing package. Please help me with payment methods like Google Pay, credit card, or bank transfer. Guide me through the payment process step by step.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology, size: 18),
                  label: const Text('Pay with AI'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7A00),
                    side: const BorderSide(color: Color(0xFFFF7A00)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pay Now coming soon')),
                    );
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          const SizedBox(height: 16),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRecordsDirectory() {
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
                'Records Directory',
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
                child: Text(
                  '${_selectedRecords.length} Selected / ${_records.length} Total Results',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF7A00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    if (_selectAll) {
                      _selectedRecords.addAll(_records.map((r) => r.id).toSet());
                    } else {
                      _selectedRecords.clear();
                    }
                  });
                },
                activeColor: const Color(0xFFFF7A00),
              ),
              const Text(
                'Select All Records',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecordsTable(),
        ],
      ),
    );
  }

  Widget _buildRecordsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
        dataRowMinHeight: 70,
        dataRowMaxHeight: 70,
        columns: const [
          DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('S/N', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Identity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Class / Session', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Payment Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Result Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ],
        rows: _records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          return DataRow(
            cells: [
              DataCell(
                Checkbox(
                  value: _selectedRecords.contains(record.id),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedRecords.add(record.id);
                      } else {
                        _selectedRecords.remove(record.id);
                      }
                    });
                  },
                  activeColor: const Color(0xFFFF7A00),
                ),
              ),
              DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12))),
              DataCell(
                Container(
                  constraints: const BoxConstraints(maxHeight: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        record.initials ?? record.name,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.name,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Container(
                  constraints: const BoxConstraints(maxHeight: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        record.term,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.classInfo,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.session,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.paymentStatus == 'Paid'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record.paymentStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: record.paymentStatus == 'Paid' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.resultStatus == 'publish'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record.resultStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: record.resultStatus == 'publish' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _launchUrl(record.viewUrl),
                      child: const Text('View', style: TextStyle(fontSize: 12, color: Color(0xFFFF7A00))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () {
                        setState(() {
                          _records.remove(record);
                          _selectedRecords.remove(record.id);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class ResultRecord {
  final int id;
  final String name;
  final String? initials;
  final String term;
  final String classInfo;
  final String session;
  final String paymentStatus;
  final String resultStatus;
  final String viewUrl;

  ResultRecord({
    required this.id,
    required this.name,
    this.initials,
    required this.term,
    required this.classInfo,
    required this.session,
    required this.paymentStatus,
    required this.resultStatus,
    required this.viewUrl,
  });
}
