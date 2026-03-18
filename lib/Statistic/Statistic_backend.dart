// lib/Statistic/Statistic_backend.dart

import 'package:flutter/material.dart';

class StatisticSlice {
  final String name;
  final double percentage;
  final Color color;

  StatisticSlice({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

class StatisticBar {
  final String label;
  final double budget;
  final double spent;

  StatisticBar({
    required this.label,
    required this.budget,
    required this.spent,
  });
}

class StatisticService {
  // Pie chart slice colours
  static const Color colorFood = Color(0xFF10B981);
  static const Color colorBills = Color(0xFF065F46);
  static const Color colorTransport = Color(0xFF34D399);
  static const Color colorEntertainment = Color(0xFFD1FAE5);

  // Bar chart bar colours
  static const Color colorBudget = Color(0xFFBBF7D0);
  static const Color colorSpent = Color(0xFF065F46);

  List<StatisticSlice> getSlices() {
    return [
      StatisticSlice(name: 'Food', percentage: 59, color: colorFood),
      StatisticSlice(name: 'Bills', percentage: 22, color: colorBills),
      StatisticSlice(name: 'Transportation', percentage: 15, color: colorTransport),
      StatisticSlice(name: 'Entertainment', percentage: 4, color: colorEntertainment),
    ];
  }

  List<StatisticBar> getBars() {
    return [
      StatisticBar(label: 'Food', budget: 480, spent: 235),
      StatisticBar(label: 'Transportation', budget: 175, spent: 60),
      StatisticBar(label: 'Entertainment', budget: 100, spent: 15),
      StatisticBar(label: 'Shopping', budget: 300, spent: 0),
    ];
  }
}
