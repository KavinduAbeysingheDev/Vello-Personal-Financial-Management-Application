import '../models/user_profile.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Service for budget tracking, status reporting, and recommendations.
class BudgetService {
  /// Get current budget status for all categories.
  Map<String, dynamic> getBudgetStatus(UserProfile profile) {
    final budgets = profile.budgets;
    final overBudget = budgets.where((b) => b.isOverspent).toList();
    final nearBudget =
        budgets.where((b) => b.usagePercent >= 0.8 && !b.isOverspent).toList();
    final onTrack =
        budgets.where((b) => b.usagePercent < 0.8).toList();

    return {
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'overBudget': overBudget.length,
      'nearBudget': nearBudget.length,
      'onTrack': onTrack.length,
      'totalBudgeted':
          budgets.fold<double>(0, (sum, b) => sum + b.limit),
      'totalSpent':
          budgets.fold<double>(0, (sum, b) => sum + b.spent),
    };
  }

  /// Get categories where spending exceeds budget.
  List<Budget> getOverspentCategories(UserProfile profile) {
    return profile.budgets.where((b) => b.isOverspent).toList();
  }

  /// Get 50/30/20 budget recommendations based on income.
  Map<String, dynamic> getRecommendations(UserProfile profile) {
    final income = profile.totalIncome;
    final needsAmount = income * (AppConstants.needsPercent / 100);
    final wantsAmount = income * (AppConstants.wantsPercent / 100);
    final savingsAmount = income * (AppConstants.savingsPercent / 100);

    // Categorize current spending
    final needsCategories = [
      Category.rent,
      Category.bills,
      Category.utilities,
      Category.groceries,
      Category.health,
      Category.transport,
    ];
    final wantsCategories = [
      Category.food,
      Category.entertainment,
      Category.shopping,
      Category.subscription,
    ];

    double actualNeeds = 0;
    double actualWants = 0;

    for (final t in profile.expenses) {
      if (needsCategories.contains(t.category)) {
        actualNeeds += t.amount;
      } else if (wantsCategories.contains(t.category)) {
        actualWants += t.amount;
      }
    }

    final actualSavings = income - profile.totalExpenses;

    return {
      'income': Formatters.currency(income),
      'recommendations': {
        'needs': {
          'label': 'Needs (${AppConstants.needsPercent.toInt()}%)',
          'recommended': Formatters.currency(needsAmount),
          'actual': Formatters.currency(actualNeeds),
          'status': actualNeeds <= needsAmount ? '✅' : '⚠️',
          'overUnder': Formatters.currency((actualNeeds - needsAmount).abs()),
          'isOver': actualNeeds > needsAmount,
        },
        'wants': {
          'label': 'Wants (${AppConstants.wantsPercent.toInt()}%)',
          'recommended': Formatters.currency(wantsAmount),
          'actual': Formatters.currency(actualWants),
          'status': actualWants <= wantsAmount ? '✅' : '⚠️',
          'overUnder': Formatters.currency((actualWants - wantsAmount).abs()),
          'isOver': actualWants > wantsAmount,
        },
        'savings': {
          'label': 'Savings (${AppConstants.savingsPercent.toInt()}%)',
          'recommended': Formatters.currency(savingsAmount),
          'actual': Formatters.currency(actualSavings),
          'status': actualSavings >= savingsAmount ? '✅' : '⚠️',
          'overUnder':
              Formatters.currency((actualSavings - savingsAmount).abs()),
          'isOver': actualSavings < savingsAmount,
        },
      },
    };
  }

  /// Format budget status as a chat response.
  String formatBudgetResponse(UserProfile profile) {
    final status = getBudgetStatus(profile);
    final recommendations = getRecommendations(profile);
    final buffer = StringBuffer();

    buffer.writeln('💰 **Budget Overview**\n');

    // Show each budget status
    for (final b in profile.budgets) {
      final percent = (b.usagePercent * 100).toInt();
      final icon = b.isOverspent
          ? '🔴'
          : (b.usagePercent >= 0.8 ? '🟡' : '🟢');
      final bar = _budgetBar(b.usagePercent);
      buffer.writeln(
          '$icon ${b.category.displayName}: '
          '${Formatters.currency(b.spent)} / ${Formatters.currency(b.limit)} '
          '($percent%) $bar');
    }

    // Summary
    final over = status['overBudget'] as int;
    final near = status['nearBudget'] as int;
    if (over > 0) {
      buffer.writeln(
          '\n⚠️ You\'ve exceeded your budget in **$over** '
          '${over == 1 ? 'category' : 'categories'}.');
    }
    if (near > 0) {
      buffer.writeln(
          '🟡 **$near** ${near == 1 ? 'category is' : 'categories are'} '
          'approaching the limit (>80%).');
    }

    // 50/30/20 recommendation
    buffer.writeln('\n📐 **50/30/20 Rule Recommendation:**');
    final recs = recommendations['recommendations'] as Map<String, dynamic>;
    for (final entry in recs.entries) {
      final rec = entry.value as Map<String, dynamic>;
      buffer.writeln(
          '${rec['status']} ${rec['label']}: '
          '${rec['actual']} / ${rec['recommended']} recommended');
    }

    return buffer.toString().trim();
  }

  /// Simple budget bar visualization.
  String _budgetBar(double usagePercent) {
    final percent = (usagePercent * 100).clamp(0, 150).toInt();
    final filled = (percent / 10).clamp(0, 10).toInt();
    final overFilled = percent > 100 ? ((percent - 100) / 10).clamp(0, 5).toInt() : 0;
    if (overFilled > 0) {
      return '[${'█' * 10}${'▓' * overFilled}]';
    }
    return '[${'█' * filled}${'░' * (10 - filled)}]';
  }
}
