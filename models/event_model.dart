import 'package:flutter/material.dart';

class Event {
  int? id;
  final String title;
  final String date;
  final double spentAmount;
  final double budgetAmount;
  final IconData icon;
  final Color iconColor;

  Event({
    this.id,
    required this.title,
    required this.date,
    required this.spentAmount,
    required this.budgetAmount,
    required this.icon,
    required this.iconColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'spentAmount': spentAmount,
      'budgetAmount': budgetAmount,
      'icon': icon.codePoint,
      'iconColor': iconColor.value,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      spentAmount: map['spentAmount'] as double,
      budgetAmount: map['budgetAmount'] as double,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(map['iconColor'] as int),
    );
  }
}