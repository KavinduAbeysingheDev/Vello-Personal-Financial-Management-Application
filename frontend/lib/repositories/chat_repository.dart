import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final _client = Supabase.instance.client;

  Future<List<ChatMessage>> getMessages(String userId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    
    return (response as List).map((m) => ChatMessage.fromSupabase(m)).toList();
  }

  Future<void> insertMessage(ChatMessage message) async {
    await _client.from('chat_messages').insert(message.toSupabase());
  }

  Future<void> clearHistory(String userId) async {
    await _client.from('chat_messages').delete().eq('user_id', userId);
  }
}
