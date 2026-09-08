import 'package:flutter/material.dart';

class SchoolpaymentScreen extends StatelessWidget {
  const SchoolpaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Payment')),
      body: const Center(child: Text('School Payment (Admin)')),
    );
  }
}
