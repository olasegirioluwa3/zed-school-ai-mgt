import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../../models/school.dart';
import '../../models/zed/zed_chat_message.dart';
import '../../models/zed/zed_api_exception.dart';
import '../../services/school_service.dart';
import '../../services/zed_ai_service.dart';
import '../../config/api_config.dart';
import '../../widgets/ai_navigation_drawer.dart';
import '../../widgets/school_selector.dart';
import '../../widgets/chat/user_message.dart';
import '../../widgets/chat/ai_message.dart';
import '../../widgets/chat/ai_typing_indicator.dart';
import '../../widgets/chat/chat_input.dart';
import '../../widgets/chat/suggestion_chip.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../services/ad_service.dart';

class AiHomeScreen extends StatefulWidget {
  const AiHomeScreen({super.key});

  @override
  State<AiHomeScreen> createState() => _AiHomeScreenState();
}

class _AiHomeScreenState extends State<AiHomeScreen> {
  // Visual constants for easy adjustment
  static const Color whiteColor = Colors.white;
  static const double menuButtonSize = 46.0;
  static const double horizontalPadding = 16.0;

  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ZedAiService _zedAiService = ZedAiServiceImpl();
  final SchoolService _schoolService = SchoolService();

  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  School? _currentSchool;
  String _currentConversationId = '';
  String get _userName {
    if (ApiConfig.currentUser != null) {
      final name = ApiConfig.currentUser.fullName as String?;
      if (name != null && name.trim().isNotEmpty) return name;
      final username = ApiConfig.currentUser.username as String?;
      if (username != null && username.trim().isNotEmpty) return username;
    }
    return 'School Admin';
  }
  String get _userRole => ApiConfig.currentUser?.role ?? 'Administrator';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    debugPrint('=== Initializing Data ===');
    debugPrint('Auth Token: ${ApiConfig.authToken.isNotEmpty ? "Present" : "Empty"}');

    // 1. Load from local cache immediately (works offline & provides instant UI)
    await _schoolService.loadLocalSchools();
    if (mounted) {
      setState(() {
        _currentSchool = _schoolService.getSelectedSchool();
      });
    }

    // 2. Fetch fresh schools from API if online
    try {
      if (ApiConfig.authToken.isNotEmpty) {
        debugPrint('Fetching schools with auth token...');
        await _schoolService.fetchSchools();
        if (mounted) {
          setState(() {
            _currentSchool = _schoolService.getSelectedSchool();
          });
        }
        debugPrint('Schools loaded successfully');
      } else {
        debugPrint('Skipping schools fetch - no auth token');
      }
      if (mounted && _currentSchool != null) {
        await _loadConversations();
      }
    } catch (e) {
      debugPrint('Failed to fetch latest schools from API: ${e.toString()}');
      // Continue with cached local data if API call fails
    }
  }

  /// Returns the currently selected school ID.
  /// Shows an error snackbar and throws if no school has been selected.
  String _getSchoolId() {
    final id = _currentSchool?.id;
    if (id == null || id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a school first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw StateError('No school selected');
    }
    return id;
  }

  Future<void> _loadConversations() async {
    // Only load conversations if we have an auth token and school
    if (ApiConfig.authToken.isEmpty || _currentSchool == null) {
      return;
    }
    
    final schoolId = _currentSchool!.id;
    if (schoolId.isEmpty) {
      return;
    }

    try {
      final zedConversations = await _zedAiService.getConversations(
        schoolId: schoolId,
      );

      if (mounted) {
        setState(() {
          _conversations = zedConversations.map((zedConv) {
            return ChatConversation(
              id: zedConv.conversationId,
              schoolId: schoolId,
              title: zedConv.title ?? 'New conversation',
              messages: [], // Messages will be loaded when conversation is selected
              createdAt: zedConv.createdAt,
              updatedAt: zedConv.updatedAt,
            );
          }).toList();
        });
      }
    } on ZedApiException catch (e) {
      // Silently fail on initial load, user can retry later
      debugPrint('Failed to load conversations: ${e.message}');
    } catch (e) {
      debugPrint('Failed to load conversations: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AiNavigationDrawer(
        conversations: _conversations,
        currentSchoolId: _currentSchool?.id ?? '',
        currentSchoolName: _currentSchool?.name ?? 'Select School',
        userName: _userName,
        userRole: _userRole,
        onNewChat: _handleNewChat,
        onChatSelected: _handleChatSelected,
        onChatRenamed: _handleChatRenamed,
        onChatDeleted: _handleChatDeleted,
        onSettings: _handleSettings,
        onHelp: _handleHelp,
      ),
      body: Column(
        children: [
          // Fixed header - DO NOT MODIFY
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => _buildMenuButton(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SchoolSelector(
                      currentSchool: _currentSchool,
                      availableSchools: _schoolService.getAvailableSchools(),
                      onSchoolSelected: _handleSchoolSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Banner Ad above chat response
          const AdBannerWidget(
            margin: EdgeInsets.symmetric(vertical: 4),
          ),
          // Chat content area
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildChatMessages(),
          ),
          // Banner Ad fixed above input field
          const AdBannerWidget(
            margin: EdgeInsets.symmetric(vertical: 4),
          ),
          // Chat input
          ChatInput(
            controller: _questionController,
            onSend: _handleSendMessage,
            onAttachment: _handleAttachment,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Image.asset(
                'assets/zedai.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'How can I help with your\nschool today?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SuggestionChip(
            text: 'How many students have paid their school fees in SSS 3?',
            onTap: () => _handleSuggestionTap('How many students have paid their school fees in SSS 3?'),
          ),
          const SizedBox(height: 12),
          SuggestionChip(
            text: 'Get me the name of new students in JSS 3',
            onTap: () => _handleSuggestionTap('Get me the name of new students in JSS 3'),
          ),
          const SizedBox(height: 12),
          SuggestionChip(
            text: 'Enroll Adebayo Ayomide into SSS 1',
            onTap: () => _handleSuggestionTap('Enroll Adebayo Ayomide into SSS 1'),
          ),
          const SizedBox(height: 12),
          SuggestionChip(
            text: 'Show me students with outstanding school fees',
            onTap: () => _handleSuggestionTap('Show me students with outstanding school fees'),
          ),
          const SizedBox(height: 12),
          SuggestionChip(
            text: 'How many students are currently in SSS 3?',
            onTap: () => _handleSuggestionTap('How many students are currently in SSS 3?'),
          ),
          const SizedBox(height: 12),
          SuggestionChip(
            text: 'Who are the new students this term?',
            onTap: () => _handleSuggestionTap('Who are the new students this term?'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: AiTypingIndicator(),
          );
        }
        final message = _messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: message.role == MessageRole.user
              ? UserMessage(message: message)
              : AiMessage(
                  message: message,
                  onCopy: () => _copyToClipboard(message.content),
                  onRegenerate: () => _regenerateResponse(message),
                ),
        );
      },
    );
  }




  Widget _buildMenuButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: menuButtonSize,
        height: menuButtonSize,
        decoration: BoxDecoration(
          color: whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(),
            SizedBox(width: 3),
            _Dot(),
            SizedBox(width: 3),
            _Dot(),
          ],
        ),
      ),
    );
  }

  void _handleSchoolSelected(School school) {
    if (_currentSchool?.id != school.id) {
      AdService.instance.showRewardedAd();
    }
    setState(() {
      _currentSchool = school;
      _schoolService.selectSchool(school.id);
      _messages.clear();
      _currentConversationId = '';
    });
    _loadConversations();
  }

  void _handleAttachment(dynamic attachmentData) {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: _formatAttachmentMessage(attachmentData),
        timestamp: DateTime.now(),
        imagePath: attachmentData['type'] == 'image' ? attachmentData['path'] : null,
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    // Send attachment to ZED AI API
    _handleSendMessageWithAttachment(attachmentData);
  }

  Future<void> _handleSendMessageWithAttachment(dynamic attachmentData) async {
    try {
      final schoolId = _getSchoolId();
      final conversationId = _currentConversationId.isEmpty ? null : _currentConversationId;
      final message = _formatAttachmentMessage(attachmentData);
      
      final response = await _zedAiService.sendMessage(
        schoolId: schoolId,
        message: message,
        conversationId: conversationId,
      );

      final isNewConversation = _currentConversationId.isEmpty;

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: response.message,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;

        // Save the conversation ID from the response
        if (_currentConversationId.isEmpty) {
          _currentConversationId = response.conversationId;
        }
      });

      _scrollToBottom();

      // Refresh sidebar when a brand-new conversation is started
      if (isNewConversation) {
        _loadConversations();
      }
    } on ZedApiException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to process attachment. Please try again.');
    }
  }

  String _formatAttachmentMessage(dynamic attachmentData) {
    if (attachmentData['type'] == 'image') {
      return '[Image attached]';
    } else if (attachmentData['type'] == 'file') {
      return '[File: ${attachmentData['name']}]';
    }
    return '[Attachment]';
  }

  void _handleSuggestionTap(String suggestion) {
    _questionController.text = suggestion;
    _handleSendMessage();
  }

  Future<void> _handleSendMessage() async {
    final message = _questionController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: message,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _questionController.clear();
    });

    _scrollToBottom();

    try {
      final schoolId = _getSchoolId();
      final conversationId = _currentConversationId.isEmpty ? null : _currentConversationId;
      
      final response = await _zedAiService.sendMessage(
        schoolId: schoolId,
        message: message,
        conversationId: conversationId,
      );

      final isNewConversation = _currentConversationId.isEmpty;

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: MessageRole.assistant,
          content: response.message,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;

        // Save the conversation ID from the response
        if (_currentConversationId.isEmpty) {
          _currentConversationId = response.conversationId;
        }
      });

      _scrollToBottom();

      // Refresh sidebar when a brand-new conversation is started
      if (isNewConversation) {
        _loadConversations();
      }
    } on ZedApiException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to send message. Please try again.');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    // TODO: Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _regenerateResponse(ChatMessage message) {
    // TODO: Implement regenerate functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Regenerate coming soon')),
    );
  }

  void _handleNewChat() {
    Navigator.of(context).pop();
    setState(() {
      _messages.clear();
      _currentConversationId = '';
    });
  }

  void _handleChatSelected(ChatConversation conversation) async {
    // Only allow selecting conversations from the current school
    if (conversation.schoolId != _currentSchool?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot load conversation from a different school')),
      );
      return;
    }

    if (_currentConversationId != conversation.id) {
      AdService.instance.showRewardedAd();
    }

    Navigator.of(context).pop();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final schoolId = _getSchoolId();
      final conversationDetails = await _zedAiService.getConversation(
        schoolId: schoolId,
        conversationId: conversation.id,
      );

      setState(() {
        _messages = conversationDetails.messages.map((zedMsg) {
          return ChatMessage(
            id: zedMsg.id,
            role: zedMsg.role == ZedMessageRole.user ? MessageRole.user : MessageRole.assistant,
            content: zedMsg.content,
            timestamp: zedMsg.timestamp,
          );
        }).toList();
        _currentConversationId = conversationDetails.conversationId;
        _isLoading = false;
      });

      _scrollToBottom();
    } on ZedApiException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.message);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load conversation. Please try again.');
    }
  }

  void _handleChatRenamed(ChatConversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
          controller: TextEditingController(text: conversation.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement rename functionality
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleChatDeleted(ChatConversation conversation) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation'),
        content: const Text('Delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                final schoolId = _getSchoolId();
                await _zedAiService.deleteConversation(
                  schoolId: schoolId,
                  conversationId: conversation.id,
                );

                setState(() {
                  _conversations.removeWhere((c) => c.id == conversation.id);
                  if (_currentConversationId == conversation.id) {
                    _messages.clear();
                    _currentConversationId = '';
                  }
                });
              } on ZedApiException catch (e) {
                _showErrorDialog(e.message);
              } catch (e) {
                _showErrorDialog('Failed to delete conversation. Please try again.');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleSettings() {
    Navigator.of(context).pop();
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon')),
    );
  }

  void _handleHelp() {
    Navigator.of(context).pop();
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help coming soon')),
    );
  }

}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
}
