import 'package:flutter/material.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Home'),
        backgroundColor: const Color(0xFFFF8C42),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Staff Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Staff functionality coming soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
