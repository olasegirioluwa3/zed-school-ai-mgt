import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/chat_message.dart';

class AiMessage extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onCopy;
  final VoidCallback? onRegenerate;

  const AiMessage({
    super.key,
    required this.message,
    this.onCopy,
    this.onRegenerate,
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
            child: MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.5,
                ),
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                h3: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                listBullet: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                code: TextStyle(
                  backgroundColor: Colors.grey[200],
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquote: TextStyle(
                  backgroundColor: Colors.grey[100],
                  color: Colors.grey[700],
                ),
                blockquoteDecoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(left: BorderSide(color: Colors.grey[400]!)),
                ),
                blockquotePadding: const EdgeInsets.all(8),
                tableHead: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                tableBody: const TextStyle(
                  color: Colors.black,
                ),
                tableBorder: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
          ),
          if (onCopy != null || onRegenerate != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 8),
              child: Row(
                children: [
                  if (onCopy != null)
                    TextButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text(
                        'Copy',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  if (onRegenerate != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onRegenerate,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'Regenerate',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
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
