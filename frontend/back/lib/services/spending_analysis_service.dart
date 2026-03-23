import '../models/transaction.dart';
import '../models/category.dart';
import '../models/user_profile.dart';
import '../utils/formatters.dart';

/// Service for analyzing spending patterns across categories and time periods.
class SpendingAnalysisService {
  /// Get spending breakdown by category with percentages.
  Map<String, dynamic> analyzeByCategory(UserProfile profile,
      {String? timePeriod}) {
    final expenses = _filterByTimePeriod(profile.expenses, timePeriod);
    final total =
        expenses.fold<double>(0, (sum, t) => sum + t.amount);

    // Group by category
    final categoryTotals = <Category, double>{};
    for (final t in expenses) {
      categoryTotals[t.category] =
          (categoryTotals[t.category] ?? 0) + t.amount;
    }

    // Sort by amount (descending)
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final breakdown = sorted.map((e) {
      final percent = total > 0 ? (e.value / total) * 100 : 0.0;
      return {
        'category': e.key.displayName,
        'emoji': e.key.emoji,
        'amount': e.value,
        'formatted': Formatters.currency(e.value),
        'percent': percent,
        'percentFormatted': Formatters.percent(percent),
      };
    }).toList();

    return {
      'totalExpenses': total,
      'totalFormatted': Formatters.currency(total),
      'categoryCount': breakdown.length,
      'breakdown': breakdown,
      'transactionCount': expenses.length,
    };
  }

  /// Get top N expenses in the period.
  List<Map<String, dynamic>> getTopExpenses(UserProfile profile,
      {int count = 5, String? timePeriod}) {
    final expenses = _filterByTimePeriod(profile.expenses, timePeriod);
    expenses.sort((a, b) => b.amount.compareTo(a.amount));

    return expenses.take(count).map((t) {
      return {
        'description': t.description,
        'amount': t.amount,
        'formatted': Formatters.currency(t.amount),
        'category': t.category.displayName,
        'emoji': t.category.emoji,
        'date': Formatters.date(t.date),
        'relativeDate': Formatters.relativeTime(t.date),
      };
    }).toList();
  }

  /// Compare spending with previous period (month-over-month).
  Map<String, dynamic> compareWithPrevious(UserProfile profile) {
    final now = DateTime.now();
    final thisMonthStart = Formatters.startOfMonth(now);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd =
        DateTime(now.year, now.month, 0, 23, 59, 59);

    final thisMonthExpenses = profile.expenses
        .where((t) => t.date.isAfter(thisMonthStart) || t.date == thisMonthStart)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final lastMonthExpenses = profile.expenses
        .where((t) =>
            (t.date.isAfter(lastMonthStart) ||
                t.date == lastMonthStart) &&
            (t.date.isBefore(lastMonthEnd) || t.date == lastMonthEnd))
        .fold<double>(0, (sum, t) => sum + t.amount);

    final difference = thisMonthExpenses - lastMonthExpenses;
    final percentChange = lastMonthExpenses > 0
        ? (difference / lastMonthExpenses) * 100
        : 0.0;

    return {
      'thisMonth': thisMonthExpenses,
      'thisMonthFormatted': Formatters.currency(thisMonthExpenses),
      'lastMonth': lastMonthExpenses,
      'lastMonthFormatted': Formatters.currency(lastMonthExpenses),
      'difference': difference,
      'differenceFormatted': Formatters.currency(difference.abs()),
      'percentChange': percentChange,
      'percentChangeFormatted': Formatters.percent(percentChange.abs()),
      'trend': difference > 0 ? 'increased' : (difference < 0 ? 'decreased' : 'unchanged'),
      'trendEmoji': difference > 0 ? '📈' : (difference < 0 ? '📉' : '➡️'),
    };
  }

  /// Detect unusual spending patterns.
  List<Map<String, dynamic>> detectAnomalies(UserProfile profile) {
    final anomalies = <Map<String, dynamic>>[];

    // Group expenses by category
    final categoryExpenses = <Category, List<Transaction>>{};
    for (final t in profile.expenses) {
      categoryExpenses.putIfAbsent(t.category, () => []).add(t);
    }

    for (final entry in categoryExpenses.entries) {
      final amounts = entry.value.map((t) => t.amount).toList();
      if (amounts.length < 2) continue;

      final avg = amounts.fold<double>(0, (s, a) => s + a) / amounts.length;

      // Flag individual transactions that are > 2x the average
      for (final t in entry.value) {
        if (t.amount > avg * 2 && t.amount > 20) {
          anomalies.add({
            'transaction': t.description,
            'amount': Formatters.currency(t.amount),
            'category': entry.key.displayName,
            'emoji': entry.key.emoji,
            'reason':
                'This is ${(t.amount / avg).toStringAsFixed(1)}x your average '
                    '${entry.key.displayName.toLowerCase()} expense of '
                    '${Formatters.currency(avg)}',
          });
        }
      }
    }

    return anomalies;
  }

  /// Format spending analysis as a human-readable chat response.
  String formatAnalysisResponse(UserProfile profile, {String? category}) {
    final analysis = analyzeByCategory(profile);
    final breakdown = analysis['breakdown'] as List;
    final buffer = StringBuffer();

    buffer.writeln('📊 **Spending Analysis**\n');
    buffer.writeln(
        'Total expenses this month: **${analysis['totalFormatted']}**\n');
    buffer.writeln('Here\'s your spending breakdown:\n');

    for (final cat in breakdown) {
      final bar = _progressBar(cat['percent'] as double);
      buffer.writeln(
          '${cat['emoji']} ${cat['category']}: ${cat['formatted']} '
          '(${cat['percentFormatted']}) $bar');
    }

    // Add top expenses
    final topExpenses = getTopExpenses(profile, count: 3);
    if (topExpenses.isNotEmpty) {
      buffer.writeln('\n💡 **Top expenses:**');
      for (var i = 0; i < topExpenses.length; i++) {
        final exp = topExpenses[i];
        buffer.writeln(
            '${i + 1}. ${exp['description']} — ${exp['formatted']} '
            '(${exp['relativeDate']})');
      }
    }

    // Add anomalies
    final anomalies = detectAnomalies(profile);
    if (anomalies.isNotEmpty) {
      buffer.writeln('\n⚠️ **Unusual spending detected:**');
      for (final a in anomalies.take(2)) {
        buffer.writeln('• ${a['transaction']}: ${a['amount']} — ${a['reason']}');
      }
    }

    return buffer.toString().trim();
  }

  /// Simple text-based progress bar.
  String _progressBar(double percent) {
    final filled = (percent / 10).round().clamp(0, 10);
    return '[${'█' * filled}${'░' * (10 - filled)}]';
  }

  /// Filter transactions by time period.
  List<Transaction> _filterByTimePeriod(
      List<Transaction> transactions, String? timePeriod) {
    if (timePeriod == null) return transactions;

    final now = DateTime.now();
    late final DateTime start;

    switch (timePeriod) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'yesterday':
        start = DateTime(now.year, now.month, now.day - 1);
        return transactions
            .where((t) =>
                t.date.year == start.year &&
                t.date.month == start.month &&
                t.date.day == start.day)
            .toList();
      case 'this_week':
        start = Formatters.startOfWeek(now);
        break;
      case 'last_week':
        final thisWeekStart = Formatters.startOfWeek(now);
        start = thisWeekStart.subtract(const Duration(days: 7));
        return transactions
            .where((t) =>
                t.date.isAfter(start) && t.date.isBefore(thisWeekStart))
            .toList();
      case 'this_month':
        start = Formatters.startOfMonth(now);
        break;
      case 'last_month':
        start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        return transactions
            .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
            .toList();
      default:
        return transactions;
    }

    return transactions
        .where((t) => t.date.isAfter(start) || t.date == start)
        .toList();
  }
}
