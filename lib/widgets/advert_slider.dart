import 'package:flutter/material.dart';

class PromoSlider extends StatelessWidget {
  const PromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Promotional Slider',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
