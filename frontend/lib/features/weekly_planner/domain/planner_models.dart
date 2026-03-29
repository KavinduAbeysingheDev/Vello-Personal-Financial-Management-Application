import 'planner_intent.dart';

enum PlanBudgetStatus { under, nearLimit, over }

class PlannerInput {
  final PlannerIntent intent;
  final Map<String, double> expenses;
  final String? category;
  final double? amount;

  const PlannerInput({
    required this.intent,
    this.expenses = const {},
    this.category,
    this.amount,
  });
}

class PlannerCategoryResult {
  final String category;
  final double planned;
  final double recommended;
  final double weeklyAverage;
  final bool higherThanUsual;

  const PlannerCategoryResult({
    required this.category,
    required this.planned,
    required this.recommended,
    required this.weeklyAverage,
    required this.higherThanUsual,
  });
}

class PlannerResult {
  final PlanBudgetStatus status;
  final double currentBalance;
  final double savingsReserve;
  final double spendableBalance;
  final double totalPlanned;
  final double totalRecommended;
  final List<PlannerCategoryResult> categories;
  final List<String> warnings;

  const PlannerResult({
    required this.status,
    required this.currentBalance,
    required this.savingsReserve,
    required this.spendableBalance,
    required this.totalPlanned,
    required this.totalRecommended,
    required this.categories,
    required this.warnings,
  });
}

