import '../models/user_profile.dart';
import '../models/category.dart';
import '../utils/formatters.dart';

/// Service for generating weekly financial summaries.
class WeeklySummaryService {
  /// Generate a comprehensive weekly summary.
  Map<String, dynamic> generateWeeklySummary(UserProfile profile) {
    final now = DateTime.now();
    final weekStart = Formatters.startOfWeek(now);
    final weekEnd = now;

    // Filter transactions for this week
    final weekExpenses = profile.expenses
        .where(
          (t) =>
              (t.date.isAfter(weekStart) || _isSameDay(t.date, weekStart)) &&
              (t.date.isBefore(weekEnd) || _isSameDay(t.date, weekEnd)),
        )
        .toList();
    final weekIncome = profile.incomes
        .where(
          (t) =>
              (t.date.isAfter(weekStart) || _isSameDay(t.date, weekStart)) &&
              (t.date.isBefore(weekEnd) || _isSameDay(t.date, weekEnd)),
        )
        .toList();

    final totalExpenses = weekExpenses.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final totalIncome = weekIncome.fold<double>(0, (sum, t) => sum + t.amount);

    // Category breakdown for the week
    final categoryTotals = <Category, double>{};
    for (final t in weekExpenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }
    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Daily average
    final daysElapsed = now.difference(weekStart).inDays + 1;
    final dailyAverage = daysElapsed > 0 ? totalExpenses / daysElapsed : 0.0;

    // Budget adherence
    final budgetStatus = <String, dynamic>{};
    for (final b in profile.budgets) {
      final weeklyLimit = b.limit / 4; // Approximate weekly budget
      final weeklySpent = categoryTotals[b.category] ?? 0;
      budgetStatus[b.category.displayName] = {
        'spent': weeklySpent,
        'weeklyLimit': weeklyLimit,
        'onTrack': weeklySpent <= weeklyLimit,
      };
    }

    return {
      'period': Formatters.dateRange(weekStart, weekEnd),
      'totalExpenses': totalExpenses,
      'totalExpensesFormatted': Formatters.currency(totalExpenses),
      'totalIncome': totalIncome,
      'totalIncomeFormatted': Formatters.currency(totalIncome),
      'transactionCount': weekExpenses.length + weekIncome.length,
      'dailyAverage': dailyAverage,
      'dailyAverageFormatted': Formatters.currency(dailyAverage),
      'topCategories': topCategories
          .take(3)
          .map(
            (e) => {
              'category': e.key.displayName,
              'emoji': e.key.emoji,
              'amount': Formatters.currency(e.value),
            },
          )
          .toList(),
      'budgetStatus': budgetStatus,
    };
  }

  /// Format weekly summary as a chat response.
  String formatWeeklySummaryResponse(UserProfile profile) {
    final summary = generateWeeklySummary(profile);
    final buffer = StringBuffer();

    buffer.writeln('📅 **Weekly Summary**');
    buffer.writeln('_${summary['period']}_\n');

    buffer.writeln('💵 Income: **${summary['totalIncomeFormatted']}**');
    buffer.writeln('💸 Expenses: **${summary['totalExpensesFormatted']}**');
    buffer.writeln('📊 Daily average: **${summary['dailyAverageFormatted']}**');
    buffer.writeln('🧾 Transactions: **${summary['transactionCount']}**\n');

    // Top categories
    final topCats = summary['topCategories'] as List<Map<String, dynamic>>;
    if (topCats.isNotEmpty) {
      buffer.writeln('**Top spending categories this week:**');
      for (var i = 0; i < topCats.length; i++) {
        buffer.writeln(
          '${i + 1}. ${topCats[i]['emoji']} ${topCats[i]['category']}: '
          '${topCats[i]['amount']}',
        );
      }
    }

    // Budget alerts
    final budgetStatus = summary['budgetStatus'] as Map<String, dynamic>;
    final overBudget = budgetStatus.entries
        .where((e) => !(e.value as Map)['onTrack'])
        .toList();
    if (overBudget.isNotEmpty) {
      buffer.writeln('\n⚠️ **Budget alerts:**');
      for (final entry in overBudget) {
        final data = entry.value as Map;
        buffer.writeln(
          '• ${entry.key}: ${Formatters.currency(data['spent'] as double)} '
          'spent (weekly limit: '
          '${Formatters.currency(data['weeklyLimit'] as double)})',
        );
      }
    } else {
      buffer.writeln('\n✅ All budgets are on track this week!');
    }

    return buffer.toString().trim();
  }

  /// Check if two dates are the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
