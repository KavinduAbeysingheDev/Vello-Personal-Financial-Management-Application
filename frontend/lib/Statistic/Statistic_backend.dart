import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../models/budget.dart';

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
  static final StatisticService instance = StatisticService._internal();
  factory StatisticService() => instance;
  StatisticService._internal();

  final List<Color> _colors = [
    const Color(0xFF0D9488),
    const Color(0xFF10B981),
    const Color(0xFF34D399),
    const Color(0xFF6EE7B7),
    const Color(0xFF99F6E4),
  ];

  List<StatisticSlice> getSlices(List<AppTransaction> transactions, String period) {
    final now = DateTime.now();
    final filtered = transactions.where((t) {
      if (t.type != TransactionType.expense) return false;
      if (period == "Weekly") {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      }
      return t.date.month == now.month && t.date.year == now.year;
    }).toList();

    if (filtered.isEmpty) return [];

    final categoryMap = <String, double>{};
    double total = 0;
    for (final tx in filtered) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
      total += tx.amount;
    }

    final List<StatisticSlice> slices = [];
    int colorIdx = 0;
    categoryMap.forEach((name, amount) {
      slices.add(StatisticSlice(
        name: name,
        amount: amount,
        percentage: (amount / total) * 100,
        color: _colors[colorIdx % _colors.length],
      ));
      colorIdx++;
    });

    return slices;
  }

  List<StatisticBar> getBars(List<AppTransaction> transactions, List<Budget> budgets, String period) {
    if (period == "Weekly") {
      // Last 7 days
      final now = DateTime.now();
      final List<StatisticBar> bars = [];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final daySre = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][day.weekday % 7];
        
        final spent = transactions
            .where((t) => t.type == TransactionType.expense && t.date.day == day.day && t.date.month == day.month)
            .fold(0.0, (sum, t) => sum + t.amount);
            
        // For weekly, we just show a static average budget or leave it at 0 if unknown
        bars.add(StatisticBar(label: daySre, budget: 100, spent: spent));
      }
      return bars;
    } else {
      // Monthly: split into 4 weeks
      final now = DateTime.now();
      final List<StatisticBar> bars = [];
      final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amountLimit);
      final weekBudget = totalBudget / 4;

      for (int w = 1; w <= 4; w++) {
        final spent = transactions
            .where((t) {
              if (t.type != TransactionType.expense || t.date.month != now.month) return false;
              int weekNum = ((t.date.day - 1) / 7).floor() + 1;
              return weekNum == w || (w == 4 && weekNum > 4);
            })
            .fold(0.0, (sum, t) => sum + t.amount);
            
        bars.add(StatisticBar(label: "Week $w", budget: weekBudget > 0 ? weekBudget : 2000, spent: spent));
      }
      return bars;
    }
  }
}
