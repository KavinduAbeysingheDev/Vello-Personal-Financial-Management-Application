import 'package:flutter/material.dart';
import '../widgets/vello_top_bar.dart';
import '../widgets/vello_drawer.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [
    {"isBot": true, "text": "Hi there! 👋 I'm your Vello AI assistant. How can I help you manage your finances today?"},
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"isBot": false, "text": text});
    });
    _controller.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "isBot": true,
            "text": "I analyzed your recent spending. You spent 15% more on food this week. Need some tips to cut down?"
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg["text"], msg["isBot"]);
              },
            ),
          ),
          
          if (_messages.length == 1) // Show suggestions only initially
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _suggestionChip("Analyze spending"),
                    const SizedBox(width: 8),
                    _suggestionChip("Budget recommendations"),
                    const SizedBox(width: 8),
                    _suggestionChip("Weekly summary"),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Message Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask anything about your money...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF006D5B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF006D5B)),
      backgroundColor: const Color(0xFFEAF9F3),
      side: const BorderSide(color: Color(0xFF006D5B), width: 0.5),
      onPressed: () => _sendMessage(label),
    );
  }

  Widget _buildChatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : const Color(0xFF006D5B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isBot ? Radius.zero : const Radius.circular(20),
            bottomRight: isBot ? const Radius.circular(20) : Radius.zero,
          ),
          boxShadow: [
            if (isBot) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? const Color(0xFF1F2937) : Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
