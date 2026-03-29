import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final _client = Supabase.instance.client;

  Future<List<Event>> fetchEvents({String? userId}) async {
    final resolvedUserId = userId ?? _client.auth.currentUser?.id;
    if (resolvedUserId == null) return [];

    final response = await _client
        .from('events')
        .select()
        .eq('user_id', resolvedUserId);

    final events = (response as List).map((json) => Event.fromSupabase(json)).toList();
    events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return events;
  }

  Future<void> insertEvent(Event event, {String? userId}) async {
    final resolvedUserId = userId ?? _client.auth.currentUser?.id;
    if (resolvedUserId == null) {
      throw StateError('No authenticated user for event insert.');
    }

    final payload = {
      ...event.toSupabase(),
      'user_id': resolvedUserId,
    };

    await _client.from('events').insert(payload);
  }

  Future<void> upsertEvent(Event event, {String? userId}) async {
    final resolvedUserId = userId ?? _client.auth.currentUser?.id;
    if (resolvedUserId == null) {
      throw StateError('No authenticated user for event update.');
    }

    final payload = {
      ...event.toSupabase(),
      'user_id': resolvedUserId,
    };

    await _client.from('events').upsert(payload);
  }

  Future<void> deleteEvent(String id, {String? userId}) async {
    final resolvedUserId = userId ?? _client.auth.currentUser?.id;
    if (resolvedUserId == null) {
      throw StateError('No authenticated user for event delete.');
    }

    await _client
        .from('events')
        .delete()
        .eq('id', id)
        .eq('user_id', resolvedUserId);
  }
}
