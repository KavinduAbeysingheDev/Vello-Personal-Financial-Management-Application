import 'package:uuid/uuid.dart';

enum ChatMessageType { user, ai }

class ChatMessage {
  final String id;
  final String? userId;
  final String text;
  final ChatMessageType type;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    this.userId,
    required this.text,
    required this.type,
    this.metadata = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'type': type == ChatMessageType.user ? 'user' : 'ai',
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromSupabase(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      userId: map['user_id'],
      text: map['text'],
      type: map['type'] == 'user' ? ChatMessageType.user : ChatMessageType.ai,
      metadata: map['metadata'] ?? {},
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? text,
    ChatMessageType? type,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
