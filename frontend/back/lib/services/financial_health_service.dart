import '../models/user_profile.dart';
import '../utils/formatters.dart';

/// Service for calculating and reporting financial health scores.
class FinancialHealthService {
  /// Calculate overall financial health score (0-100).
  Map<String, dynamic> calculateHealthScore(UserProfile profile) {
    final breakdown = getHealthBreakdown(profile);
    final metrics = breakdown['metrics'] as List<Map<String, dynamic>>;

    // Weighted average of all metrics
    double totalScore = 0;
    double totalWeight = 0;
    for (final metric in metrics) {
      totalScore += (metric['score'] as double) * (metric['weight'] as double);
      totalWeight += metric['weight'] as double;
    }

    final overallScore = totalWeight > 0 ? (totalScore / totalWeight) : 0.0;

    String grade;
    String gradeEmoji;
    String message;
    if (overallScore >= 90) {
      grade = 'Excellent';
      gradeEmoji = '🌟';
      message = 'Your finances are in outstanding shape! Keep it up!';
    } else if (overallScore >= 75) {
      grade = 'Good';
      gradeEmoji = '💪';
      message =
          'You\'re doing well! A few tweaks could make your finances even stronger.';
    } else if (overallScore >= 60) {
      grade = 'Fair';
      gradeEmoji = '👍';
      message =
          'You\'re on the right track, but there\'s room for improvement.';
    } else if (overallScore >= 40) {
      grade = 'Needs Work';
      gradeEmoji = '⚠️';
      message =
          'Your finances need attention. Focus on the areas with lower scores.';
    } else {
      grade = 'Critical';
      gradeEmoji = '🚨';
      message =
          'Your financial health needs immediate attention. Start with budgeting basics.';
    }

    return {
      'score': overallScore.round(),
      'grade': grade,
      'gradeEmoji': gradeEmoji,
      'message': message,
      'metrics': metrics,
    };
  }

  /// Get detailed breakdown of health score components.
  Map<String, dynamic> getHealthBreakdown(UserProfile profile) {
    final metrics = <Map<String, dynamic>>[];

    // 1. Savings Rate Score (weight: 30%)
    final savingsRate = profile.savingsRate;
    double savingsScore;
    if (savingsRate >= 20) {
      savingsScore = 100;
    } else if (savingsRate >= 10) {
      savingsScore = 60 + (savingsRate - 10) * 4;
    } else if (savingsRate >= 0) {
      savingsScore = savingsRate * 6;
    } else {
      savingsScore = 0;
    }
    metrics.add({
      'name': 'Savings Rate',
      'emoji': '💰',
      'score': savingsScore.clamp(0, 100),
      'weight': 0.30,
      'detail': '${Formatters.percent(savingsRate)} of income saved',
      'tip': savingsRate < 20
          ? 'Aim for at least 20% savings rate.'
          : 'Great! You\'re saving enough.',
    });

    // 2. Budget Adherence Score (weight: 25%)
    double budgetScore = 100;
    if (profile.budgets.isNotEmpty) {
      final onBudget = profile.budgets.where((b) => !b.isOverspent).length;
      budgetScore = (onBudget / profile.budgets.length) * 100;
    }
    metrics.add({
      'name': 'Budget Adherence',
      'emoji': '📊',
      'score': budgetScore.clamp(0, 100),
      'weight': 0.25,
      'detail': '${profile.budgets.where((b) => !b.isOverspent).length}/'
          '${profile.budgets.length} budgets on track',
      'tip': budgetScore < 80
          ? 'Review and adjust your budgets to be more realistic.'
          : 'You\'re managing your budgets well!',
    });

    // 3. Expense Ratio Score (weight: 25%)
    final expenseRatio = profile.totalIncome > 0
        ? (profile.totalExpenses / profile.totalIncome) * 100
        : 100.0;
    double expenseScore;
    if (expenseRatio <= 70) {
      expenseScore = 100;
    } else if (expenseRatio <= 90) {
      expenseScore = 100 - (expenseRatio - 70) * 2.5;
    } else {
      expenseScore = (100 - expenseRatio).clamp(0, 50);
    }
    metrics.add({
      'name': 'Expense Ratio',
      'emoji': '💸',
      'score': expenseScore.clamp(0, 100),
      'weight': 0.25,
      'detail': '${Formatters.percent(expenseRatio)} of income spent',
      'tip': expenseRatio > 80
          ? 'Try to keep expenses below 80% of income.'
          : 'Healthy expense-to-income ratio.',
    });

    // 4. Spending Diversity Score (weight: 20%)
    final categoryCount = <String>{};
    for (final t in profile.expenses) {
      categoryCount.add(t.category.name);
    }
    final diversityScore =
        categoryCount.length >= 5 ? 100.0 : categoryCount.length * 20.0;
    metrics.add({
      'name': 'Spending Diversity',
      'emoji': '🎯',
      'score': diversityScore.clamp(0, 100),
      'weight': 0.20,
      'detail': '${categoryCount.length} spending categories tracked',
      'tip': categoryCount.length < 5
          ? 'Track more categories for better insights.'
          : 'Good spread of expense tracking.',
    });

    return {'metrics': metrics};
  }

  /// Format health score as a chat response.
  String formatHealthResponse(UserProfile profile) {
    final health = calculateHealthScore(profile);
    final metrics = health['metrics'] as List<Map<String, dynamic>>;
    final buffer = StringBuffer();

    buffer.writeln('🏥 **Financial Health Score**\n');
    buffer.writeln('${health['gradeEmoji']} Overall Score: '
        '**${health['score']}/100** (${health['grade']})\n');
    buffer.writeln('${health['message']}\n');

    buffer.writeln('**Score Breakdown:**');
    for (final m in metrics) {
      final scoreBar = _scoreBar(m['score'] as double);
      buffer.writeln(
          '${m['emoji']} ${m['name']}: ${(m['score'] as double).round()}/100 '
          '$scoreBar');
      buffer.writeln('   _${m['detail']}_');
      if ((m['score'] as double) < 80) {
        buffer.writeln('   💡 ${m['tip']}');
      }
    }

    return buffer.toString().trim();
  }

  /// Score visualization bar.
  String _scoreBar(double score) {
    final filled = (score / 10).round().clamp(0, 10);
    return '[${'█' * filled}${'░' * (10 - filled)}]';
  }
}
