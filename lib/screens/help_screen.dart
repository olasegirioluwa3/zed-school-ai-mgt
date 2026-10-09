import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _selectedStatus = 'All';

  final List<SupportTicket> _tickets = [
    SupportTicket(
      id: 'TKT-003',
      title: 'Payment processing delay',
      school: 'Excellence College',
      reporter: 'Mike Johnson',
      description: 'Payment made 3 hours ago but not reflecting in system.',
      category: 'Billing & Payments',
      priority: 'high',
      status: 'resolved',
      createdAt: '2026-04-26',
      updatedAt: '2026-04-28',
    ),
  ];

  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I reset a student\'s password?',
      category: 'Account Management',
      answer: 'Go to the student management section, select the student, and click on "Reset Password". The new password will be sent to their registered email.',
    ),
    FAQItem(
      question: 'What should I do if a parent can\'t log in?',
      category: 'Login Issues',
      answer: 'First verify the parent\'s credentials are correct. If they are, check if their account is active. You may need to reset their password or contact support for further assistance.',
    ),
    FAQItem(
      question: 'How do I add a new subject to the curriculum?',
      category: 'Academics',
      answer: 'Navigate to the Curriculum section, click "Add Subject", fill in the subject details including name, code, and assigned teachers, then save.',
    ),
    FAQItem(
      question: 'Why are payments not showing in the system?',
      category: 'Payments',
      answer: 'Check if the payment gateway has processed the transaction successfully. If confirmed, wait for 10-15 minutes for system synchronization. If still not showing, contact support.',
    ),
    FAQItem(
      question: 'How do I generate student reports?',
      category: 'Reports',
      answer: 'Go to the Reports section, select the report type (academic, attendance, or financial), choose the class and time period, then click "Generate Report".',
    ),
    FAQItem(
      question: 'What\'s the process for promoting students to the next class?',
      category: 'Class Management',
      answer: 'Navigate to Class Management, select the current class, click "Promote Students", choose the destination class, review the list, and confirm the promotion.',
    ),
  ];

  List<SupportTicket> get _filteredTickets {
    if (_selectedStatus == 'All') return _tickets;
    return _tickets.where((ticket) => ticket.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();
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
          'Help & Support',
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
            _buildSupportTickets(),
            const SizedBox(height: 24),
            _buildFAQ(),
            const SizedBox(height: 24),
            _buildContactSupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTickets() {
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
                'Support Tickets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showNewTicketDialog();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage and track support requests',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Open', 'In Progress', 'Resolved'].map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    selectedColor: const Color(0xFFFF7A00).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFFF7A00),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF6B7280),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFFF3F4F6),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredTickets.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 12),
                    Text(
                      'No tickets found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredTickets.map((ticket) => _buildTicketCard(ticket)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ),
              Text(
                ticket.id,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${ticket.school} • ${ticket.reporter}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ticket.priority == 'high' 
                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                      : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${ticket.priority} Priority',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ticket.priority == 'high' 
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ticket.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                'Created ${ticket.createdAt}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF3B82F6);
      case 'in progress':
        return const Color(0xFFFF7A00);
      case 'resolved':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildFAQ() {
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
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick answers to common admin questions',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ..._faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            faq.category,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFFF7A00),
            ),
          ),
        ],
      ),
      iconColor: const Color(0xFFFF7A00),
      collapsedIconColor: const Color(0xFF9CA3AF),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
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
            'Contact Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get direct help from our support team',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.chat,
            title: 'WhatsApp',
            description: 'Chat with us instantly',
            action: 'WhatsApp',
            url: 'https://wa.me/2347073248888',
            color: const Color(0xFF25D366),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.email,
            title: 'Email Support',
            description: 'Send detailed queries via email',
            action: 'Send Email',
            url: 'mailto:zionrebornlimited@gmail.com',
            color: const Color(0xFFEA4335),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.phone,
            title: 'Phone Support',
            description: 'Call us for immediate assistance',
            action: 'Call Now',
            url: 'tel:+2347073248888',
            color: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String action,
    required String url,
    required Color color,
  }) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _launchUrl(url),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  void _showNewTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Ticket'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticket creation coming soon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class SupportTicket {
  final String id;
  final String title;
  final String school;
  final String reporter;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String createdAt;
  final String updatedAt;

  SupportTicket({
    required this.id,
    required this.title,
    required this.school,
    required this.reporter,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

class FAQItem {
  final String question;
  final String category;
  final String answer;

  FAQItem({
    required this.question,
    required this.category,
    required this.answer,
  });
}
