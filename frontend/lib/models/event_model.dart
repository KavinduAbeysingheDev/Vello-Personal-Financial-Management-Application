import 'package:flutter/material.dart';

class Event {
  final String id;
  final String? userId; // For Supabase RLS
  final String title;
  final DateTime eventDate;
  final double spentAmount;
  final double budgetAmount;
  final IconData icon;
  final Color iconColor;

  Event({
    required this.id,
    this.userId,
    required this.title,
    required this.eventDate,
    required this.spentAmount,
    required this.budgetAmount,
    required this.icon,
    required this.iconColor,
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'event_date': eventDate.toIso8601String(),
      'date': eventDate.toIso8601String(),
      'spent_amount': spentAmount,
      'budget_amount': budgetAmount,
      'icon': icon.codePoint,
      'icon_color': iconColor.toARGB32(),
    };
  }

  factory Event.fromSupabase(Map<String, dynamic> map) {
    final parsedDate = _parseEventDate(map['event_date'] ?? map['date']);

    return Event(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'] as String,
      eventDate: parsedDate,
      spentAmount: (map['spent_amount'] as num).toDouble(),
      budgetAmount: (map['budget_amount'] as num).toDouble(),
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(map['icon_color'] as int),
    );
  }

  // Keep compatibility for any existing map usage if needed
  Map<String, dynamic> toMap() => toSupabase();

  static DateTime _parseEventDate(dynamic raw) {
    if (raw == null) return DateTime.now();

    if (raw is DateTime) return raw;
    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return DateTime.now();

      final parsedIso = DateTime.tryParse(value);
      if (parsedIso != null) return parsedIso;
    }

    return DateTime.now();
  }
}
