import 'package:flutter/material.dart';

class AiActionCard extends StatelessWidget {
  final String message;
  final String? actionText;
  final List<String>? buttons;
  final Function(String)? onButtonPressed;

  const AiActionCard({
    super.key,
    required this.message,
    this.actionText,
    this.buttons,
    this.onButtonPressed,
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                if (buttons != null && buttons!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: buttons!.map((buttonText) {
        final isPrimary = buttonText.toLowerCase().contains('confirm');
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () => onButtonPressed?.call(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? const Color(0xFFFF8C42) : Colors.grey[200],
              foregroundColor: isPrimary ? Colors.white : Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
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
