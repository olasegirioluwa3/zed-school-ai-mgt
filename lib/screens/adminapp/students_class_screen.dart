import 'package:flutter/material.dart';

class StudentsClassScreen extends StatelessWidget {
  const StudentsClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Results')),
      body: const Center(child: Text('Class Results Screen (Admin)')),
    );
  }
}
