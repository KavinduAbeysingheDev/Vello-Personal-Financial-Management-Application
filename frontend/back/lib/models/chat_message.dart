/// Represents a single chat message in the conversation.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
    this.metadata,
  });

  /// Create a bot response message with optional quick-reply chips.
  factory ChatMessage.botResponse({
    required String text,
    List<String>? quickReplies,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
      metadata: metadata,
    );
  }

  /// Create a user message.
  factory ChatMessage.userMessage({required String text}) {
    return ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Convert ChatMessage to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      if (quickReplies != null && quickReplies!.isNotEmpty)
        'quickReplies': quickReplies,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() => 'ChatMessage(${isUser ? "User" : "Bot"}: $text)';
}
