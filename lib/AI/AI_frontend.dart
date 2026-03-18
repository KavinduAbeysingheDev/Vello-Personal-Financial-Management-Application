import 'package:flutter/material.dart';

class AIFinanceScreen extends StatefulWidget {
  const AIFinanceScreen({super.key});

  @override
  State<AIFinanceScreen> createState() => _AIFinanceScreenState();
}

class _AIFinanceScreenState extends State<AIFinanceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          "Hello! I'm your Vello AI assistant. I can help you with budgeting, spending analysis, and financial advice. How can I assist you today?",
      'time': '09:41 AM',
    },
    {
      'isUser': true,
      'text': 'Can you analyze my spending for this month?',
      'time': '09:42 AM',
    },
    {
      'isUser': false,
      'text':
          "I've analyzed your transactions. You've spent \$1,240 so far, which is 15% more than last month at this time. Most of it went to 'Dining Out'.",
      'time': '09:42 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Clean off-white bg
      body: Column(
        children: [
          // Premium Header with Gradient
          _buildHeader(context),

          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildChatMessage(
                      isUser: msg['isUser'],
                      text: msg['text'],
                      time: msg['time'],
                    );
                  },
                ),

                // Floating Bottom Input Section
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Custom Vello Logo Style
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vello AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Finance Assistant • Online',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage({
    required bool isUser,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFF059669),
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF059669) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      if (!isUser)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : const Color(0xFF1F2937),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (isUser)
            const SizedBox(width: 32), // Space for user avatar if needed
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB).withOpacity(0.95),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.3],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSuggestionChip('Analyze spending'),
                _buildSuggestionChip('Budget tips'),
                _buildSuggestionChip('Savings summary'),
                _buildSuggestionChip('Investment help'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF065F46),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFECFDF5),
        side: const BorderSide(color: Color(0xFFD1FAE5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {},
      ),
    );
  }
}
