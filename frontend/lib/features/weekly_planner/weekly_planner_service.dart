import 'package:intl/intl.dart';
import '../../models/app_models.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/savings_goal_repository.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class WeeklyPlanCategory {
  final String name;
  final double planned;
  final double recommended;
  final double avgLast4Weeks;

  const WeeklyPlanCategory({
    required this.name,
    required this.planned,
    required this.recommended,
    required this.avgLast4Weeks,
  });
}

class WeeklyPlan {
  final DateTime weekStartDate;
  final List<WeeklyPlanCategory> categories;
  final double totalPlanned;
  final double totalRecommended;
  final double availableBalance;
  final double savingsTarget;
  final double spendableBalance;
  final List<String> warnings;
  final List<String> recommendations;

  const WeeklyPlan({
    required this.weekStartDate,
    required this.categories,
    required this.totalPlanned,
    required this.totalRecommended,
    required this.availableBalance,
    required this.savingsTarget,
    required this.spendableBalance,
    required this.warnings,
    required this.recommendations,
  });
}

// ─── Service ──────────────────────────────────────────────────────────────────

class WeeklyPlannerService {
  final TransactionRepository _txRepo = TransactionRepository();
  final SavingsGoalRepository _goalRepo = SavingsGoalRepository();
  final _fmt = NumberFormat.currency(symbol: 'LKR ', decimalDigits: 2);

  // ── Public helpers ──────────────────────────────────────────────────────────

  Future<double> fetchCurrentBalance(String userId) async {
    final transactions = await _txRepo.fetchTransactions(userId: userId);
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  Future<Map<String, double>> fetchWeeklyAverageByCategory(String userId) async {
    final transactions = await _txRepo.fetchTransactions(userId: userId);
    final fourWeeksAgo = DateTime.now().subtract(const Duration(days: 28));

    final recent = transactions.where(
      (t) => t.type == TransactionType.expense && t.date.isAfter(fourWeeksAgo),
    );

    final totals = <String, double>{};
    for (final t in recent) {
      final cat = _normalizeCategory(t.category);
      totals[cat] = (totals[cat] ?? 0) + t.amount.abs();
    }

    // Divide by 4 to get the per-week average
    return totals.map((k, v) => MapEntry(k, v / 4.0));
  }

  Future<List<SavingsGoal>> fetchSavingsGoals(String userId) async {
    return _goalRepo.fetchGoals(userId: userId);
  }

  // ── Core plan generation ────────────────────────────────────────────────────

  /// Returns null when the message contains no parseable expenses.
  Future<WeeklyPlan?> generateWeeklyPlan(
    String userId,
    String userMessage,
  ) async {
    final planned = _parseExpenses(userMessage);
    if (planned.isEmpty) return null;

    final balance = await fetchCurrentBalance(userId);
    final avgByCategory = await fetchWeeklyAverageByCategory(userId);
    final goals = await _goalRepo.fetchGoals(userId: userId);

    // Weekly savings target = sum of remaining amounts across active goals / 4
    double savingsTarget = 0;
    for (final g in goals) {
      final remaining = g.targetAmount - g.currentAmount;
      if (remaining > 0) savingsTarget += remaining / 4.0;
    }

    final spendableBalance = balance - savingsTarget;
    final totalPlanned = planned.values.fold<double>(0, (s, v) => s + v);

    final warnings = <String>[];
    final recommendations = <String>[];
    final categories = <WeeklyPlanCategory>[];

    // Rule: reserve savings first
    if (savingsTarget > 0 && goals.isNotEmpty) {
      recommendations.add(
        'Reserve ${_fmt.format(savingsTarget)} for your savings goals before you spend anything.',
      );
    }

    // Rule: total planned > 80 % of spendable balance
    if (spendableBalance <= 0) {
      warnings.add(
        'Your savings goals already consume your entire balance. '
        'Consider adjusting your goals or increasing income.',
      );
    } else if (totalPlanned > spendableBalance * 0.8) {
      warnings.add(
        'Your total planned spending (${_fmt.format(totalPlanned)}) exceeds '
        '80 % of your spendable balance (${_fmt.format(spendableBalance)}). '
        'Consider trimming non-essential categories.',
      );
    }

    // Per-category rules: apply 1.15x average cap first
    for (final entry in planned.entries) {
      final cat = entry.key;
      final plannedAmt = entry.value;
      final avg = avgByCategory[cat] ?? 0.0;
      double recommended = plannedAmt;

      // Rule: planned > 130% above 4-week average -> warn and suggest 1.15x
      if (avg > 0 && plannedAmt > avg * 1.3) {
        final pct = ((plannedAmt / avg - 1) * 100).toStringAsFixed(0);
        warnings.add(
          '$cat: ${_fmt.format(plannedAmt)} is $pct% above your '
          '4-week average of ${_fmt.format(avg)}.',
        );
        recommended = avg * 1.15; // suggest 15% above avg as compromise
      }

      categories.add(WeeklyPlanCategory(
        name: cat,
        planned: plannedAmt,
        recommended: recommended, // Temporary before scaling
        avgLast4Weeks: avg,
      ));
    }

    // Calculate total after initial category caps
    double tempTotalRecommended =
        categories.fold<double>(0, (s, c) => s + c.recommended);

    // Rule: proportionally scale down if total STILL exceeds spendable
    if (tempTotalRecommended > spendableBalance && spendableBalance > 0) {
      final scalingFactor = spendableBalance / tempTotalRecommended;
      for (var i = 0; i < categories.length; i++) {
        final cat = categories[i];
        categories[i] = WeeklyPlanCategory(
          name: cat.name,
          planned: cat.planned,
          recommended: cat.recommended * scalingFactor,
          avgLast4Weeks: cat.avgLast4Weeks,
        );
      }
    } else if (spendableBalance <= 0) {
      // Zero spendable -> everything to zero
      for (var i = 0; i < categories.length; i++) {
        final cat = categories[i];
        categories[i] = WeeklyPlanCategory(
          name: cat.name,
          planned: cat.planned,
          recommended: 0,
          avgLast4Weeks: cat.avgLast4Weeks,
        );
      }
    }

    final totalRecommended =
        categories.fold<double>(0, (s, c) => s + c.recommended);

    if (spendableBalance > 0 && spendableBalance > totalRecommended) {
      recommendations.add(
        'You have ${_fmt.format(spendableBalance - totalRecommended)} left '
        'after your plan. Consider putting it toward savings!',
      );
    }

    // Next Monday as week start
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final weekStart = daysUntilMonday == 0
        ? now.add(const Duration(days: 7))
        : now.add(Duration(days: daysUntilMonday));

    return WeeklyPlan(
      weekStartDate: weekStart,
      categories: categories,
      totalPlanned: totalPlanned,
      totalRecommended: totalRecommended,
      availableBalance: balance,
      savingsTarget: savingsTarget,
      spendableBalance: spendableBalance,
      warnings: warnings,
      recommendations: recommendations,
    );
  }

  // ── Response formatter ──────────────────────────────────────────────────────

  String formatPlanResponse(WeeklyPlan plan) {
    final buf = StringBuffer();
    buf.writeln(
      'Weekly Budget Plan  (w/c ${_fmtDate(plan.weekStartDate)})\n',
    );
    buf.writeln('Current Balance:  ${_fmt.format(plan.availableBalance)}');

    if (plan.savingsTarget > 0) {
      buf.writeln('Savings Reserve:  ${_fmt.format(plan.savingsTarget)}');
    }

    buf.writeln('Spendable:        ${_fmt.format(plan.spendableBalance)}\n');
    buf.writeln('Budget Breakdown:');

    for (final cat in plan.categories) {
      final surplus = cat.planned - cat.recommended;
      final status = surplus > 1
          ? '  Reduce by ${_fmt.format(surplus)}'
          : '  Looks good';
      buf.writeln('  ${cat.name}: ${_fmt.format(cat.recommended)}$status');
      if (cat.avgLast4Weeks > 0) {
        buf.writeln(
          '    (4-week avg: ${_fmt.format(cat.avgLast4Weeks)})',
        );
      }
    }

    buf.writeln(
      '\nTotal recommended: ${_fmt.format(plan.totalRecommended)}',
    );

    if (plan.warnings.isNotEmpty) {
      buf.writeln('\nWarnings:');
      for (final w in plan.warnings) {
        buf.writeln('  $w');
      }
    }

    if (plan.recommendations.isNotEmpty) {
      buf.writeln('\nTips:');
      for (final r in plan.recommendations) {
        buf.writeln('  $r');
      }
    }

    return buf.toString().trim();
  }

  String formatFollowUpResponse(WeeklyPlan? lastPlan, String message) {
    final lower = message.toLowerCase();

    if (lower.contains('sav')) {
      if (lastPlan != null && lastPlan.savingsTarget > 0) {
        return 'Your weekly savings target is ${_fmt.format(lastPlan.savingsTarget)}. '
            'After all planned spending you should have '
            '${_fmt.format((lastPlan.spendableBalance - lastPlan.totalRecommended).clamp(0, double.infinity))} '
            'left over to put toward your goals.';
      }
      return 'I don\'t see any active savings goals yet. '
          'Head to Savings Goals in the menu to set one up!';
    }

    if (lower.contains('balanc')) {
      if (lastPlan != null) {
        return 'Your current balance is ${_fmt.format(lastPlan.availableBalance)}. '
            'After your savings reserve that leaves ${_fmt.format(lastPlan.spendableBalance)} to spend this week.';
      }
    }

    if (lower.contains('reduc') || lower.contains('cut') || lower.contains('trim')) {
      if (lastPlan != null) {
        final overBudget = lastPlan.categories
            .where((c) => c.planned > c.recommended + 1)
            .toList();
        if (overBudget.isEmpty) {
          return 'Your plan looks balanced already! No major cuts needed.';
        }
        final buf = StringBuffer('Here\'s where you can trim:\n');
        for (final c in overBudget) {
          buf.writeln(
            '  ${c.name}: planned ${_fmt.format(c.planned)} '
            '→ recommended ${_fmt.format(c.recommended)}',
          );
        }
        return buf.toString().trim();
      }
    }

    return 'Tell me your planned expenses for next week and I\'ll build you a personalised budget plan. '
        'For example: "food 5000, transport 2000, entertainment 1500"';
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Parses "food 3000, transport 1500" or "3000 on food, 1500 on transport"
  Map<String, double> _parseExpenses(String message) {
    final result = <String, double>{};

    // Pattern A: category then separator then number  →  "food 3000" or "food: 3000"
    final patA = RegExp(
      r'([a-zA-Z][a-zA-Z\s]{1,20}?)[:\s-]{1,3}(\d[\d,]*(?:\.\d+)?)',
      caseSensitive: false,
    );
    for (final m in patA.allMatches(message)) {
      final catRaw = m.group(1)!.trim();
      final cat = _normalizeCategory(catRaw);
      final amt = double.tryParse(m.group(2)!.replaceAll(',', '')) ?? 0;
      if (amt > 0 && cat.isNotEmpty) result[cat] = amt;
    }

    // Pattern B: number then "on/for" then category  →  "3000 on food"
    final patB = RegExp(
      r'(\d[\d,]*(?:\.\d+)?)\s+(?:on|for)\s+([a-zA-Z][a-zA-Z\s]{1,20})',
      caseSensitive: false,
    );
    for (final m in patB.allMatches(message)) {
      final amt = double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
      final catRaw = m.group(2)!.trim();
      final cat = _normalizeCategory(catRaw);
      if (amt > 0 && cat.isNotEmpty) result[cat] = amt;
    }

    return result;
  }

  String _normalizeCategory(String raw) {
    final lower = raw.trim().toLowerCase();

    const map = {
      'food': 'Food',
      'eat': 'Food',
      'dining': 'Food',
      'restaurant': 'Food',
      'groceries': 'Food',
      'grocery': 'Food',
      'transport': 'Transport',
      'travel': 'Transport',
      'fuel': 'Transport',
      'bus': 'Transport',
      'uber': 'Transport',
      'commute': 'Transport',
      'entertainment': 'Entertainment',
      'fun': 'Entertainment',
      'movie': 'Entertainment',
      'game': 'Entertainment',
      'health': 'Health',
      'medical': 'Health',
      'pharmacy': 'Health',
      'doctor': 'Health',
      'education': 'Education',
      'school': 'Education',
      'tuition': 'Education',
      'book': 'Education',
      'shopping': 'Shopping',
      'clothes': 'Shopping',
      'clothing': 'Shopping',
      'utilities': 'Utilities',
      'bill': 'Utilities',
      'electricity': 'Utilities',
      'water': 'Utilities',
      'internet': 'Utilities',
      'rent': 'Rent',
      'savings': 'Savings',
      'other': 'Other',
      'misc': 'Other',
    };

    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    if (lower.isEmpty) return 'Other';
    return lower[0].toUpperCase() + lower.substring(1);
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
