import 'package:flutter/material.dart';

class CbtScreen extends StatelessWidget {
  const CbtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT')),
      body: const Center(child: Text('CBT Screen (Admin)')),
    );
  }
}
