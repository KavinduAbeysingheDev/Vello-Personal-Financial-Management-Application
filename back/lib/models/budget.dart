import 'category.dart';

/// Represents a budget allocation for a specific category.
class Budget {
  final Category category;
  final double limit;
  final double spent;
  final String period; // 'weekly', 'monthly', 'yearly'

  const Budget({
    required this.category,
    required this.limit,
    this.spent = 0.0,
    this.period = 'monthly',
  });

  /// Remaining budget amount.
  double get remaining => limit - spent;

  /// Usage percentage (0.0 to 1.0+).
  double get usagePercent => limit > 0 ? spent / limit : 0.0;

  /// Whether the budget has been exceeded.
  bool get isOverspent => spent > limit;

  /// Create a Budget from JSON map.
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: Category.fromString(json['category'] as String),
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String? ?? 'monthly',
    );
  }

  /// Convert Budget to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'limit': limit,
      'spent': spent,
      'period': period,
      'remaining': remaining,
      'usagePercent': usagePercent,
      'isOverspent': isOverspent,
    };
  }

  @override
  String toString() =>
      'Budget(${category.displayName}: \$${spent.toStringAsFixed(2)}'
      '/\$${limit.toStringAsFixed(2)} $period)';
}
