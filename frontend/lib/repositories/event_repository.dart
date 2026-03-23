import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final _client = Supabase.instance.client;

  Future<List<Event>> fetchEvents() async {
    final response = await _client
        .from('events')
        .select()
        .order('date', ascending: false);
    
    return (response as List).map((json) => Event.fromSupabase(json)).toList();
  }

  Future<void> insertEvent(Event event) async {
    await _client.from('events').insert(event.toSupabase());
  }

  Future<void> upsertEvent(Event event) async {
    await _client.from('events').upsert(event.toSupabase());
  }

  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }
}
