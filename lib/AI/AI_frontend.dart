import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// AI Chat Models & Mock Logic (Self-contained)
// -----------------------------------------------------------------------------

enum MessageType { user, ai }

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    required this.timestamp,
  });
}

class AIFinanceScreen extends StatefulWidget {
  const AIFinanceScreen({super.key});

  @override
  State<AIFinanceScreen> createState() => _AIFinanceScreenState();
}

class _AIFinanceScreenState extends State<AIFinanceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial welcome messages
    _messages.addAll([
      ChatMessage(
        text: "Hi there! I'm Vello AI. How can I help you today?",
        type: MessageType.ai,
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        text: "You can ask me about your spending, budget tips, or how to save more!",
        type: MessageType.ai,
        timestamp: DateTime.now(),
      ),
    ]);
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

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        type: MessageType.user,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Mock AI response logic
    await Future.delayed(const Duration(seconds: 1));

    String aiResponseText = "That's interesting! Could you tell me more about it?";
    final input = text.toLowerCase();

    if (input.contains("budget")) {
      aiResponseText = "Creating a budget is a great first step. I recommend the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings.";
    } else if (input.contains("save") || input.contains("savings")) {
      aiResponseText = "To save more, try setting up automatic transfers to your savings account right after you get paid!";
    } else if (input.contains("tips")) {
      aiResponseText = "My top tip: track every single expense for a month. You'll be surprised where the small leaks are!";
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: aiResponseText,
          type: MessageType.ai,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _buildChatMessage(message);
              },
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF10B981)], // Dark teal gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Vello AI",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.white)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    final timeStr = "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(MessageType.ai),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF065F46) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1F2937),
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isUser) _buildAvatar(MessageType.user),
        ],
      ),
    );
  }

  Widget _buildAvatar(MessageType type) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: type == MessageType.user ? const Color(0xFFE5E7EB) : const Color(0xFFD1FAE5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        type == MessageType.user ? Icons.person_outline : Icons.smart_toy_outlined,
        size: 18,
        color: type == MessageType.user ? Colors.grey : const Color(0xFF059669),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _buildAvatar(MessageType.ai),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669)),
                ),
                SizedBox(width: 10),
                Text("Thinking...", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSuggestionChip("Analyze spending"),
                _buildSuggestionChip("Budget tips"),
                _buildSuggestionChip("Weekly summary"),
                _buildSuggestionChip("How to save?"),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onSubmitted: _handleSendMessage,
                  decoration: InputDecoration(
                    hintText: "Ask me anything about your finances...",
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _handleSendMessage(_messageController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _handleSendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1FAE5)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF065F46), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
