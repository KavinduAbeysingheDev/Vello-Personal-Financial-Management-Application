import 'package:flutter/material.dart';

class StatisticSlice {
  final String name;
  final double percentage;
  final Color color;
  final double amount;

  StatisticSlice({
    required this.name,
    required this.percentage,
    required this.color,
    required this.amount,
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

class StatisticService extends ChangeNotifier {
  // Singleton pattern for shared access
  static final StatisticService instance = StatisticService._internal();
  factory StatisticService() => instance;
  StatisticService._internal();

  // Shared Data State (Can be updated from Home or anywhere)
  // These categories match the Vello Figma design
  Map<String, List<StatisticSlice>> _categorySlices = {
    "Weekly": [
      StatisticSlice(name: "Food", percentage: 40, color: const Color(0xFF0D9488), amount: 450),
      StatisticSlice(name: "Bills", percentage: 25, color: const Color(0xFF10B981), amount: 300),
      StatisticSlice(name: "Transportation", percentage: 20, color: const Color(0xFF34D399), amount: 200),
      StatisticSlice(name: "Others", percentage: 15, color: const Color(0xFF6EE7B7), amount: 150),
    ],
    "Monthly": [
      StatisticSlice(name: "Food", percentage: 35, color: const Color(0xFF0D9488), amount: 1200),
      StatisticSlice(name: "Bills", percentage: 30, color: const Color(0xFF10B981), amount: 1000),
      StatisticSlice(name: "Transportation", percentage: 20, color: const Color(0xFF34D399), amount: 700),
      StatisticSlice(name: "Others", percentage: 15, color: const Color(0xFF6EE7B7), amount: 500),
    ]
  };

  Map<String, List<StatisticBar>> _barData = {
    "Weekly": [
      StatisticBar(label: "Mon", budget: 400, spent: 300),
      StatisticBar(label: "Tue", budget: 400, spent: 450),
      StatisticBar(label: "Wed", budget: 400, spent: 200),
      StatisticBar(label: "Thu", budget: 400, spent: 350),
    ],
    "Monthly": [
      StatisticBar(label: "Week 1", budget: 2000, spent: 1800),
      StatisticBar(label: "Week 2", budget: 2000, spent: 2200),
      StatisticBar(label: "Week 3", budget: 2000, spent: 1500),
      StatisticBar(label: "Week 4", budget: 2000, spent: 1900),
    ]
  };

  List<StatisticSlice> getSlices(String period) => _categorySlices[period] ?? [];
  List<StatisticBar> getBars(String period) => _barData[period] ?? [];

  // This method allows the Home Page (or any other part) to update the budget/spent values
  void updateCategoryData(String period, String categoryName, double newSpent) {
    if (_categorySlices.containsKey(period)) {
      final list = _categorySlices[period]!;
      int idx = list.indexWhere((s) => s.name == categoryName);
      if (idx != -1) {
        // In a real app, logic to recalculate percentage based on total would go here
        final old = list[idx];
        list[idx] = StatisticSlice(
          name: old.name,
          percentage: old.percentage, // Keeping percentage fixed for mock simplification
          color: old.color,
          amount: newSpent,
        );
        notifyListeners(); // NOTIFY THE UI TO REBUILD IMMEDIATELY
      }
    }
  }

  // Update whole period data
  void setPeriodData(String period, List<StatisticSlice> slices, List<StatisticBar> bars) {
    _categorySlices[period] = slices;
    _barData[period] = bars;
    notifyListeners();
  }
}
