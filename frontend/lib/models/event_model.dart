import 'package:flutter/material.dart';

class Event {
  final String id;
  final String? userId; // For Supabase RLS
  final String title;
  final String date;
  final double spentAmount;
  final double budgetAmount;
  final IconData icon;
  final Color iconColor;

  Event({
    required this.id,
    this.userId,
    required this.title,
    required this.date,
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
      'date': date,
      'spent_amount': spentAmount,
      'budget_amount': budgetAmount,
      'icon': icon.codePoint,
      'icon_color': iconColor.value,
    };
  }

  factory Event.fromSupabase(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'] as String,
      date: map['date'] as String,
      spentAmount: (map['spent_amount'] as num).toDouble(),
      budgetAmount: (map['budget_amount'] as num).toDouble(),
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(map['icon_color'] as int),
    );
  }

  // Keep compatibility for any existing map usage if needed
  Map<String, dynamic> toMap() => toSupabase();
}