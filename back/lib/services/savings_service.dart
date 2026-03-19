import '../models/user_profile.dart';
import '../models/category.dart';
import '../data/tips_data.dart';
import '../utils/formatters.dart';
import '../utils/constants.dart';

/// Service for generating personalized savings tips and projections.
class SavingsService {
  /// Calculate savings rate and analysis.
  Map<String, dynamic> getSavingsAnalysis(UserProfile profile) {
    final savingsRate = profile.savingsRate;
    final monthlySavings = profile.totalIncome - profile.totalExpenses;

    String rating;
    String ratingEmoji;
    if (savingsRate >= AppConstants.excellentSavingsRate) {
      rating = 'Excellent';
      ratingEmoji = '🌟';
    } else if (savingsRate >= AppConstants.goodSavingsRate) {
      rating = 'Good';
      ratingEmoji = '👍';
    } else if (savingsRate >= AppConstants.poorSavingsRate) {
      rating = 'Fair';
      ratingEmoji = '⚠️';
    } else {
      rating = 'Needs Improvement';
      ratingEmoji = '🔴';
    }

    return {
      'savingsRate': savingsRate,
      'savingsRateFormatted': Formatters.percent(savingsRate),
      'monthlySavings': monthlySavings,
      'monthlySavingsFormatted': Formatters.currency(monthlySavings),
      'rating': rating,
      'ratingEmoji': ratingEmoji,
      'annualProjection': monthlySavings * 12,
      'annualProjectionFormatted':
          Formatters.currency(monthlySavings * 12),
    };
  }

  /// Get personalized savings tips based on spending patterns.
  List<String> getPersonalizedTips(UserProfile profile) {
    final tips = <String>[];

    // Find the highest spending category
    final categorySpending = <Category, double>{};
    for (final t in profile.expenses) {
      categorySpending[t.category] =
          (categorySpending[t.category] ?? 0) + t.amount;
    }

    if (categorySpending.isNotEmpty) {
      final sorted = categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Add category-specific tips for top spending categories
      for (final entry in sorted.take(2)) {
        final categoryTips =
            TipsData.getTipsForCategory(entry.key.name);
        if (categoryTips.isNotEmpty) {
          tips.addAll(categoryTips.take(2));
        }
      }
    }

    // Add general savings tips
    tips.addAll(TipsData.getRandomTips(3));

    // Deduplicate and limit
    return tips.toSet().take(5).toList();
  }

  /// Project future savings based on current rate.
  Map<String, dynamic> projectSavings(UserProfile profile,
      {int months = 12}) {
    final monthlySavings = profile.totalIncome - profile.totalExpenses;
    final projections = <Map<String, dynamic>>[];

    for (var i = 1; i <= months; i += 3) {
      projections.add({
        'month': i,
        'projected': Formatters.currency(monthlySavings * i),
      });
    }

    // Time to reach savings goal
    int? monthsToGoal;
    if (monthlySavings > 0 && profile.savingsGoal > 0) {
      monthsToGoal = (profile.savingsGoal / monthlySavings).ceil();
    }

    return {
      'monthlySavings': Formatters.currency(monthlySavings),
      'projections': projections,
      'monthsToGoal': monthsToGoal,
      'savingsGoal': Formatters.currency(profile.savingsGoal),
    };
  }

  /// Format savings tips as a chat response.
  String formatSavingsResponse(UserProfile profile,
      {String? category}) {
    final analysis = getSavingsAnalysis(profile);
    final tips = getPersonalizedTips(profile);
    final buffer = StringBuffer();

    buffer.writeln('💡 **Savings Tips & Analysis**\n');
    buffer.writeln(
        '${analysis['ratingEmoji']} Your savings rate: '
        '**${analysis['savingsRateFormatted']}** (${analysis['rating']})\n');
    buffer.writeln(
        '💵 Monthly savings: **${analysis['monthlySavingsFormatted']}**');
    buffer.writeln(
        '📈 Annual projection: **${analysis['annualProjectionFormatted']}**\n');

    buffer.writeln('Here are some personalized tips for you:\n');
    for (var i = 0; i < tips.length; i++) {
      buffer.writeln('${i + 1}. ${tips[i]}');
    }

    // Goal progress
    if (profile.savingsGoal > 0) {
      final projection = projectSavings(profile);
      if (projection['monthsToGoal'] != null) {
        buffer.writeln(
            '\n🎯 At this rate, you\'ll reach your savings goal of '
            '**${projection['savingsGoal']}** in '
            '**${projection['monthsToGoal']} months**!');
      }
    }

    return buffer.toString().trim();
  }
}
