import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final List<PaymentRecord> _payments = [
    PaymentRecord(
      studentName: 'Talent Fc',
      feeName: 'Tuesday Testing',
      reference: '6gt9q5stx9',
      date: '4 Nov 2025',
      amount: 100,
      total: 403,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'Hannah Olorunshola',
      feeName: 'association fee for term 1',
      reference: '17 Oct 2025',
      date: '17 Oct 2025',
      amount: 100,
      total: 809,
      paymentMethod: 'Paystack',
      status: 'pending',
    ),
    PaymentRecord(
      studentName: 'Talent Fc',
      feeName: 'Drug testing fee',
      reference: 'hgay8iwaey',
      date: '17 Oct 2025',
      amount: 10000,
      total: 10454,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'Hannah Olorunshola',
      feeName: 'Drug testing fee',
      reference: 'f3gnuwejo2',
      date: '17 Oct 2025',
      amount: 20000,
      total: 20606,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'feranmi Johnson',
      feeName: 'Drug testing fee',
      reference: 'leh3un2k1q',
      date: '17 Oct 2025',
      amount: 7000,
      total: 7408,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'rid Johnson',
      feeName: 'Drug testing fee',
      reference: 'x1he4nou5o',
      date: '17 Oct 2025',
      amount: 15000,
      total: 15530,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'rid Johnson',
      feeName: 'Final fee testing for term 1',
      reference: 'trnpx0y5qr',
      date: '16 Oct 2025',
      amount: 15000,
      total: 15530,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'feranmi Johnson',
      feeName: 'Final fee testing for term 1',
      reference: 'asunssghkp',
      date: '16 Oct 2025',
      amount: 30000,
      total: 4362,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'rid Johnson',
      feeName: 'association fee for term 1',
      reference: 'ql94z012bn',
      date: '16 Oct 2025',
      amount: 15000,
      total: 10454,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
    PaymentRecord(
      studentName: 'rid Ade',
      feeName: 'association fee for term 1',
      reference: 'isyuda1why',
      date: '16 Oct 2025',
      amount: 15000,
      total: 15530,
      paymentMethod: 'Paystack',
      status: 'completed',
    ),
  ];

  int get _totalPaid => _payments.fold(0, (sum, payment) => sum + payment.amount);
  int get _completedCount => _payments.where((p) => p.status == 'completed').length;
  int get _pendingCount => _payments.where((p) => p.status == 'pending').length;
  int get _failedCount => _payments.where((p) => p.status == 'failed').length;

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
          'Payment History',
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
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildPaymentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFFF9E42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Paid',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Total payments received',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '₦${_totalPaid.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Completed', _completedCount, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Pending', _pendingCount, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem('Failed', _failedCount, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Payment records',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 0,
              horizontalMargin: 0,
              headingRowHeight: 56,
              dataRowMinHeight: 100,
              dataRowMaxHeight: 100,
              columns: const [
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Reference',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Payment Method',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
              ],
              rows: _payments.map((payment) {
                return DataRow(
                  cells: [
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              payment.studentName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              payment.feeName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              payment.reference,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              payment.date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₦${payment.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total: ₦${payment.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          payment.paymentMethod,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: payment.status == 'completed'
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : payment.status == 'pending'
                                    ? const Color(0xFFFF7A00).withValues(alpha: 0.1)
                                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            payment.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: payment.status == 'completed'
                                  ? const Color(0xFF10B981)
                                  : payment.status == 'pending'
                                      ? const Color(0xFFFF7A00)
                                      : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('View details coming soon')),
                            );
                          },
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF7A00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentRecord {
  final String studentName;
  final String feeName;
  final String reference;
  final String date;
  final int amount;
  final int total;
  final String paymentMethod;
  final String status;

  PaymentRecord({
    required this.studentName,
    required this.feeName,
    required this.reference,
    required this.date,
    required this.amount,
    required this.total,
    required this.paymentMethod,
    required this.status,
  });
}
