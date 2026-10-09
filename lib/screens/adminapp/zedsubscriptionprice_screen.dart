import 'package:flutter/material.dart';

class ZedSubscriptionPriceScreen extends StatefulWidget {
  const ZedSubscriptionPriceScreen({super.key});

  @override
  State<ZedSubscriptionPriceScreen> createState() => _ZedSubscriptionPriceScreenState();
}

class _ZedSubscriptionPriceScreenState extends State<ZedSubscriptionPriceScreen> {
  int _billingMonths = 3;
  int _studentCount = 250;
  int _biometricUsers = 25;
  late TextEditingController _studentController;
  late TextEditingController _biometricController;
  
  final Map<String, bool> _selectedFeatures = {
    'Result Processing': false,
    'CBT': false,
    'School Payments': false,
    'QR Code ID Card': false,
    'Biometric Attendance': false,
  };

  @override
  void initState() {
    super.initState();
    _studentController = TextEditingController(text: _studentCount.toString());
    _biometricController = TextEditingController(text: _biometricUsers.toString());
  }

  @override
  void dispose() {
    _studentController.dispose();
    _biometricController.dispose();
    super.dispose();
  }

  // Pricing calculations based on PricingClient.tsx
  int get _subscriptionFee {
    if (!_selectedFeatures['Result Processing']! && 
        !_selectedFeatures['CBT']! && 
        !_selectedFeatures['School Payments']!) {
      return 0;
    }
    if (_studentCount <= 15) return 0;
    if (_studentCount <= 200) return 12500;
    if (_studentCount <= 500) return 25000;
    return 40000;
  }

  int get _biometricMonthly {
    if (!_selectedFeatures['Biometric Attendance']! || _biometricUsers <= 0) return 0;
    return ((_biometricUsers / 25).ceil() * 5000);
  }

  int get _qrCodeMonthly {
    if (!_selectedFeatures['QR Code ID Card']! || 
        _selectedFeatures['Biometric Attendance']! || 
        _studentCount <= 0) {
      return 0;
    }
    return ((_studentCount / 25).ceil() * 3000);
  }

  int get _rawSubscriptionMonthly => _subscriptionFee + _biometricMonthly + _qrCodeMonthly;

  int get _rawSubscriptionTotal => _rawSubscriptionMonthly * _billingMonths;

  bool get _hasSubscriptionDiscount => _billingMonths >= 9;

  int get _subscriptionDiscountAmount {
    return _hasSubscriptionDiscount ? (_rawSubscriptionTotal * 0.2).round() : 0;
  }

  int get _subscriptionTotal => _rawSubscriptionTotal - _subscriptionDiscountAmount;

  int get _terms => (_billingMonths / 4).ceil();

  int get _usageTotal {
    final resultAndPaymentCost = 
        (_selectedFeatures['Result Processing']! || _selectedFeatures['School Payments']!) 
        ? _studentCount * 500 * _terms : 0;
    final cbtCost = _selectedFeatures['CBT']! ? _studentCount * 500 * _terms : 0;
    final biometricCostTotal = _biometricMonthly * _billingMonths;
    final qrCostTotal = _qrCodeMonthly * _billingMonths;
    return resultAndPaymentCost + cbtCost + biometricCostTotal + qrCostTotal;
  }

  bool get _isEnterprise => 
      _studentCount >= 1200 && 
      (_selectedFeatures['Result Processing']! || 
       _selectedFeatures['CBT']! || 
       _selectedFeatures['School Payments']!);

  String get _recommended {
    if (_isEnterprise) return "Enterprise Partnership";
    return _subscriptionTotal < _usageTotal ? "Subscription" : "Usage-Based";
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
          'ZED Subscription',
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
            const Text(
              'ZED Pricing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare subscription vs usage-based pricing based on your needs.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildRecommendedPlan(),
            const SizedBox(height: 24),
            
            _buildSelectFeatures(),
            const SizedBox(height: 24),
            
            _buildStudentCount(),
            const SizedBox(height: 24),
            
            _buildBillingPeriod(),
            const SizedBox(height: 24),
            
            _buildSubscriptionModel(),
            const SizedBox(height: 24),
            
            _buildUsageBasedModel(),
            const SizedBox(height: 24),
            
            if (_selectedFeatures['Biometric Attendance']!) _buildBiometricHardware(),
            if (_selectedFeatures['Biometric Attendance']!) const SizedBox(height: 24),
            
            _buildUpgradeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7A00)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended Plan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  _recommended,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFeatures() {
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
            'Select Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ..._selectedFeatures.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _selectedFeatures[entry.key] = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFFF7A00),
                  ),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentCount() {
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
            'School Configuration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Number of Students',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_studentCount > 0) {
                              setState(() {
                                _studentCount--;
                                _studentController.text = _studentCount.toString();
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFFFF7A00),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _studentController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFFF7A00)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              final newValue = int.tryParse(value);
                              if (newValue != null && newValue >= 0) {
                                setState(() {
                                  _studentCount = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _studentCount++;
                              _studentController.text = _studentCount.toString();
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFFFF7A00),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (_selectedFeatures['Biometric Attendance']!)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biometric Users',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_biometricUsers > 0) {
                                setState(() {
                                  _biometricUsers--;
                                  _biometricController.text = _biometricUsers.toString();
                                });
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: const Color(0xFFFF7A00),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _biometricController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFFF7A00)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onChanged: (value) {
                                final newValue = int.tryParse(value);
                                if (newValue != null && newValue >= 0) {
                                  setState(() {
                                    _biometricUsers = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _biometricUsers++;
                                _biometricController.text = _biometricUsers.toString();
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: const Color(0xFFFF7A00),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingPeriod() {
    final bool hasDiscount = _billingMonths >= 9;
    
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
              const Text(
                'Billing Period (Months)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '20% OFF',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select 9–12 months for 20% OFF',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$_billingMonths months selected',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFF7A00),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Slide to 9+ months to unlock 20% discount',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _billingMonths.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            label: '$_billingMonths months',
            activeColor: const Color(0xFFFF7A00),
            onChanged: (value) {
              setState(() {
                _billingMonths = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionModel() {
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
              const Text(
                'Subscription Model',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (_hasSubscriptionDiscount) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '20% OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isEnterprise 
                ? "Custom high-volume partnership for 1,200+ students."
                : "Predictable monthly billing based on school size.",
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          if (_isEnterprise) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF7A00)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENTERPRISE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7A00),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact us to enjoy good discount offer and partner with us.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Custom volume pricing for ${_studentCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildSubscriptionBreakdown(),
            const SizedBox(height: 16),
            if (_hasSubscriptionDiscount) ...[
              Row(
                children: [
                  Text(
                    '₦${_subscriptionTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₦${_rawSubscriptionTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF9CA3AF),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '20% discount applied for $_billingMonths months (Saved ₦${_subscriptionDiscountAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                '₦${_subscriptionTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total for selected period ($_billingMonths months)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedFeatures['Result Processing']! || _selectedFeatures['CBT']! || _selectedFeatures['School Payments']!) ...[
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedFeatures['Result Processing']!)
                      const Text('Result Processing', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    if (_selectedFeatures['CBT']!)
                      const Text('CBT', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    if (_selectedFeatures['School Payments']!)
                      const Text('School Payments', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₦${_subscriptionFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              const Text('same plan', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00))),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedFeatures['QR Code ID Card']!) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QR Code ID Card', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    if (_selectedFeatures['Biometric Attendance']!)
                      const Text('Covered by Biometric plan', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00)))
                    else
                      const Text('₦3,000/mo per 25 students', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _selectedFeatures['Biometric Attendance']! 
                        ? '₦0/mo' 
                        : '₦${_qrCodeMonthly.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (_selectedFeatures['Biometric Attendance']!)
                    const Text('FREE', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedFeatures['Biometric Attendance']!) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biometric Platform', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              Text(
                '₦${_biometricMonthly.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (!_selectedFeatures['Result Processing']! && 
            !_selectedFeatures['CBT']! && 
            !_selectedFeatures['School Payments']! && 
            !_selectedFeatures['QR Code ID Card']! && 
            !_selectedFeatures['Biometric Attendance']!)
          const Text('No features selected.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildUsageBasedModel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF7A00)),
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
            'Usage-Based Model (Estimated price)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pay only when you use academic services.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          _buildUsageBreakdown(),
          const SizedBox(height: 16),
          Text(
            '₦${_usageTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usage totals for $_billingMonths month${_billingMonths > 1 ? 's' : ''} ($_terms term${_terms > 1 ? 's' : ''})',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedFeatures['Result Processing']! || _selectedFeatures['School Payments']!) ...[
          Row(
            children: [
              Container(
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedFeatures['Result Processing']!)
                      const Text('Result Processing', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    if (_selectedFeatures['School Payments']!)
                      const Text('School Payments', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${((_studentCount * 500 * _terms).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '₦500 × $_studentCount × $_terms term${_terms > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFFF7A00)),
                  ),
                  const Text('same rate', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedFeatures['CBT']!) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CBT Access', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${((_studentCount * 500 * _terms).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '₦500 × $_studentCount × $_terms term${_terms > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedFeatures['QR Code ID Card']!) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QR Code ID Card', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
                    if (_selectedFeatures['Biometric Attendance']!)
                      const Text('Covered by Biometric plan', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00)))
                    else
                      const Text('₦3,000/mo per 25 students', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _selectedFeatures['Biometric Attendance']! 
                        ? '₦0' 
                        : '₦${((_qrCodeMonthly * _billingMonths).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (_selectedFeatures['Biometric Attendance']!)
                    const Text('FREE', style: TextStyle(fontSize: 10, color: Color(0xFFFF7A00)))
                  else
                    Text(
                      '₦${_qrCodeMonthly.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo × $_billingMonths mo',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedFeatures['Biometric Attendance']!) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biometric Platform', style: TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${((_biometricMonthly * _billingMonths).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'))}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '₦${_biometricMonthly.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo × $_billingMonths mo',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (!_selectedFeatures['Result Processing']! && 
            !_selectedFeatures['CBT']! && 
            !_selectedFeatures['School Payments']! && 
            !_selectedFeatures['QR Code ID Card']! && 
            !_selectedFeatures['Biometric Attendance']!)
          const Text('No features selected.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildBiometricHardware() {
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
            'Biometric Hardware',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Device Price',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '₦150,000 (One-time)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Platform Subscription',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '₦5,000/month per 25 users',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_recommended plan upgrade initiated!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Upgrade to $_recommended Plan',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
