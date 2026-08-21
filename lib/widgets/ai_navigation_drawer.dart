import 'package:flutter/material.dart';
import '../models/chat_conversation.dart';

class AiNavigationDrawer extends StatelessWidget {
  final List<ChatConversation> conversations;
  final String currentSchoolId;
  final String currentSchoolName;
  final String userName;
  final String userRole;
  final VoidCallback onNewChat;
  final Function(ChatConversation) onChatSelected;
  final Function(ChatConversation) onChatRenamed;
  final Function(ChatConversation) onChatDeleted;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  const AiNavigationDrawer({
    super.key,
    required this.conversations,
    required this.currentSchoolId,
    required this.currentSchoolName,
    required this.userName,
    required this.userRole,
    required this.onNewChat,
    required this.onChatSelected,
    required this.onChatRenamed,
    required this.onChatDeleted,
    required this.onSettings,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.8;

    return Container(
      width: drawerWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          _buildHeader(context),
          // New chat button
          _buildNewChatButton(),
          const SizedBox(height: 16),
          // Search chats
          _buildSearchChats(),
          const SizedBox(height: 16),
          // Chat history
          Expanded(
            child: _buildChatHistory(),
          ),
          // Divider
          const Divider(height: 1),
          // Settings and Help
          _buildBottomOptions(),
          // User profile
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currentSchoolName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onNewChat,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C42),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'New chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchChats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: Implement search functionality
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Search chats',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHistory() {
    // Group conversations by date
    final groupedConversations = _groupConversationsByDate();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Chats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...groupedConversations.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...entry.value.map((conversation) {
                return _buildConversationItem(conversation);
              }),
            ],
          );
        }),
      ],
    );
  }

  Map<String, List<ChatConversation>> _groupConversationsByDate() {
    final Map<String, List<ChatConversation>> grouped = {};

    // Filter conversations by current school
    final schoolConversations = conversations
        .where((conversation) => conversation.schoolId == currentSchoolId)
        .toList();

    for (final conversation in schoolConversations) {
      final dateLabel = conversation.dateLabel;
      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(conversation);
    }

    return grouped;
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    return GestureDetector(
      onTap: () => onChatSelected(conversation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildConversationActions(conversation),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationActions(ChatConversation conversation) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_horiz,
        color: Colors.grey,
        size: 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'rename':
            onChatRenamed(conversation);
            break;
          case 'delete':
            onChatDeleted(conversation);
            break;
          case 'archive':
            // TODO: Implement archive functionality
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Text('Rename'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem(
          value: 'archive',
          child: Text('Archive'),
        ),
      ],
    );
  }

  Widget _buildBottomOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildBottomOption(
            icon: Icons.settings,
            label: 'Settings',
            onTap: onSettings,
          ),
          _buildBottomOption(
            icon: Icons.help_outline,
            label: 'Help',
            onTap: onHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C42),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  userRole,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
