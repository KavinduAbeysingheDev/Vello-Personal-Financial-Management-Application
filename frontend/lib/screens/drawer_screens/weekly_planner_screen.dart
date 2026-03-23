import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/weekly_planner/weekly_planner_service.dart';

// ─── Conversation state ────────────────────────────────────────────────────────

enum _PlannerState { greeting, awaitingExpenses, planGenerated }

class _PlannerMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _PlannerMessage({required this.text, required this.isUser})
      : time = DateTime.now();
}

// ─── Screen ────────────────────────────────────────────────────────────────────

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  static const _green = Color(0xFF00674F);
  static const _lightGreen = Color(0xFFEAF9F3);
  static const _darkGreen = Color(0xFF004D40);

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = WeeklyPlannerService();

  final List<_PlannerMessage> _messages = [];
  _PlannerState _state = _PlannerState.greeting;
  WeeklyPlan? _lastPlan;
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

  // ── Greeting ────────────────────────────────────────────────────────────────

  void _sendGreeting() {
    if (!_isWeekend) {
      _addAiMessage(
        "This weekly planner is available on weekends only.\n\n"
        "Come back on Saturday or Sunday to plan your spending for the week ahead!",
      );
      return;
    }

    _addAiMessage(
      "Hi! I'm your Weekly Budget Planner.\n\n"
      "Every weekend I help you build a personalised budget for the coming week "
      "using your actual balance, spending history, and savings goals.\n\n"
      "Tell me your planned expenses for next week. For example:\n"
      '"food 5000, transport 2000, entertainment 1500, health 1000"',
    );
    setState(() => _state = _PlannerState.awaitingExpenses);
  }

  // ── Message handling ────────────────────────────────────────────────────────

  Future<void> _handleSend(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !_isWeekend) return;

    _addUserMessage(trimmed);
    _controller.clear();

    setState(() => _isTyping = true);
    _scrollToBottom();

    // Small artificial delay for UX
    await Future.delayed(const Duration(milliseconds: 600));

    if (_state == _PlannerState.awaitingExpenses ||
        _state == _PlannerState.planGenerated) {
      await _handlePlanInput(trimmed);
    }
  }

  Future<void> _handlePlanInput(String text) async {
    try {
      final plan = await _service.generateWeeklyPlan(_userId, text);

      if (plan == null) {
        // Could not parse expenses — treat as follow-up
        final reply = _service.formatFollowUpResponse(_lastPlan, text);
        _addAiMessage(reply);
        setState(() => _isTyping = false);
        return;
      }

      _lastPlan = plan;
      final response = _service.formatPlanResponse(plan);
      _addAiMessage(response);
      _addAiMessage(
        'You can adjust any category — just tell me the new amounts and I\'ll update the plan.',
      );
      setState(() {
        _isTyping = false;
        _state = _PlannerState.planGenerated;
      });
    } catch (e) {
      _addAiMessage(
        'Sorry, I ran into a problem fetching your financial data. '
        'Please check your connection and try again.',
      );
      setState(() => _isTyping = false);
    }
  }

  // ── Message helpers ─────────────────────────────────────────────────────────

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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _darkGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Budget Planner',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'Rule-based AI Agent',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _green.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _green, size: 16),
          const SizedBox(width: 8),
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
    final isUser = msg.isUser;
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF065F46) : Colors.white,
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
                      color: isUser ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 10),
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
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser
            ? const Color(0xFFE5E7EB)
            : _lightGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser
            ? Icons.person_outline
            : Icons.calendar_month_outlined,
        size: 16,
        color: isUser ? Colors.grey : _green,
      ),
    );
  }

  Widget _buildTypingRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Row(
        children: [
          _buildAvatar(isUser: false),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _green,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Analysing your finances...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick-fill chips
          if (_isWeekend && _state == _PlannerState.awaitingExpenses)
            _buildChipRow(),
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
                        ? 'e.g. food 5000, transport 2000...'
                        : 'Available on weekends only',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
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
                onTap: _isWeekend
                    ? () => _handleSend(_controller.text)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isWeekend ? _green : Colors.grey.shade300,
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
    final chips = [
      'food 5000, transport 2000',
      'entertainment 1500',
      'health 1000',
      'How much can I save?',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _green.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(
                      color: _darkGreen,
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
