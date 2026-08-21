import 'package:flutter/material.dart';

class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAiAvatar(),
              const SizedBox(width: 8),
              const Text(
                'AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  children: [
                    _buildDot(_animation.value, 0.0),
                    const SizedBox(width: 8),
                    _buildDot(_animation.value, 0.3),
                    const SizedBox(width: 8),
                    _buildDot(_animation.value, 0.6),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double animationValue, double delay) {
    final dotAnimation = (animationValue - delay) % 1.0;
    final opacity = dotAnimation < 0.5 ? dotAnimation * 2 : (1 - dotAnimation) * 2;
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(opacity.clamp(0.2, 1.0)),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C42),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}
