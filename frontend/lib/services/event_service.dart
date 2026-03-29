import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_constants.dart';
import '../models/event_model.dart';

class EventService {
  static final _client = http.Client();

  static String _detailFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } catch (_) {}
    return body;
  }

  static Future<Map<String, String>> _headers() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please log in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Event>> getEvents({String? userId}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsEndpoint}');
    final response = await _client.get(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load events (${response.statusCode}): ${_detailFromBody(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body);
    final rawEvents = decoded is Map<String, dynamic>
        ? (decoded['events'] as List? ?? const [])
        : (decoded is List ? decoded : const []);

    return rawEvents
        .whereType<Map<String, dynamic>>()
        .map(Event.fromSupabase)
        .toList();
  }

  static Future<void> addEvent(Event event, {String? userId}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsEndpoint}');
    final body = jsonEncode({
      'title': event.title,
      'event_date': event.eventDate.toIso8601String(),
      'spent_amount': event.spentAmount,
      'budget_amount': event.budgetAmount,
      'icon': event.icon.codePoint,
      'icon_color': event.iconColor.toARGB32(),
      'status': 'planned',
    });

    final response = await _client.post(
      url,
      headers: await _headers(),
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create event (${response.statusCode}): ${_detailFromBody(response.body)}',
      );
    }
  }

  static Future<void> updateEvent(Event event, {String? userId}) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsEndpoint}/${event.id}');
    final body = jsonEncode({
      'title': event.title,
      'event_date': event.eventDate.toIso8601String(),
      'spent_amount': event.spentAmount,
      'budget_amount': event.budgetAmount,
      'icon': event.icon.codePoint,
      'icon_color': event.iconColor.toARGB32(),
      'status': 'planned',
    });

    final response = await _client.put(
      url,
      headers: await _headers(),
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update event (${response.statusCode}): ${_detailFromBody(response.body)}',
      );
    }
  }

  static Future<void> deleteEvent(Event event, {String? userId}) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventsEndpoint}/${event.id}');
    final response = await _client.delete(url, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete event (${response.statusCode}): ${_detailFromBody(response.body)}',
      );
    }
  }
}
