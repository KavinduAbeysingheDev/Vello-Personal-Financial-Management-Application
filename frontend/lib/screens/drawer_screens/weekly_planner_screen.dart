import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/weekly_planner/domain/planner_state.dart';
import '../../features/weekly_planner/logic/planner_conversation_manager.dart';
import '../setting_screen_backend.dart';

class _PlannerMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _PlannerMessage({required this.text, required this.isUser})
      : time = DateTime.now();
}

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  static const _green = Color(0xFF00674F);
  static const _lightGreen = Color(0xFFEAF9F3);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _manager = PlannerConversationManager();
  final List<_PlannerMessage> _messages = [];

  bool _isTyping = false;
  late final String _userId;
  late final bool _isWeekend;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final weekday = DateTime.now().weekday;
    _isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendGreeting());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendGreeting() {
    final greeting = _manager.greeting(isWeekend: _isWeekend);
    _addAiMessage(greeting);
  }

  Future<void> _handleSend(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _addUserMessage(trimmed);
    _controller.clear();

    setState(() => _isTyping = true);
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 350));

    try {
      final reply = await _manager.handleUserMessage(
        userId: _userId,
        message: trimmed,
        isWeekend: _isWeekend,
      );
      _addAiMessage(reply);
    } catch (_) {
      _addAiMessage('Could not build a plan right now. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(_PlannerMessage(text: text, isUser: true)));
    _scrollToBottom();
  }

  void _addAiMessage(String text) {
    setState(() => _messages.add(_PlannerMessage(text: text, isUser: false)));
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Column(
        children: [
          if (_isWeekend) _buildWeekendBanner(),
          Expanded(child: _buildMessageList()),
          if (_isTyping) _buildTypingRow(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWeekendBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _green.withOpacity(0.1),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: _green, size: 16),
          SizedBox(width: 8),
          Text(
            'Weekend planning is active',
            style: TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(_PlannerMessage msg) {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;
    final isUser = msg.isUser;
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser: false),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF065F46)
                        : (isDark ? const Color(0xFF1F2937) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1F2937)),
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser
            ? (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))
            : _lightGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_outline : Icons.calendar_month_outlined,
        size: 16,
        color: isUser ? Colors.grey : _green,
      ),
    );
  }

  Widget _buildTypingRow() {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Building your weekly plan...',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;
    final showQuickChips = _isWeekend && _manager.state == PlannerState.awaitingPlan;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showQuickChips) _buildChipRow(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: _isWeekend,
                  onSubmitted: _handleSend,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: _isWeekend
                        ? 'e.g. food 5000, transport 2000'
                        : 'Available on weekends only',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isWeekend ? () => _handleSend(_controller.text) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isWeekend
                        ? _green
                        : (isDark ? const Color(0xFF374151) : Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow() {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;

    const chips = [
      'food 5000, transport 2000',
      '5000 for food',
      'change food to 4500',
      'how much can I save',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (c) => GestureDetector(
                onTap: () => _handleSend(c),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : _lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withOpacity(0.3)),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF004D40),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

