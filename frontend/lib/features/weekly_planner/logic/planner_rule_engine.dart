import '../data/planner_finance_adapter.dart';
import '../domain/planner_models.dart';

class PlannerRuleEngine {
  const PlannerRuleEngine();

  PlannerResult buildPlan({
    required PlannerFinanceSnapshot snapshot,
    required Map<String, double> plannedExpenses,
  }) {
    final savingsReserve = _calculateSavingsReserve(snapshot);
    final spendable = snapshot.currentBalance - savingsReserve;
    final totalPlanned =
        plannedExpenses.values.fold<double>(0, (sum, value) => sum + value);

    final categories = <PlannerCategoryResult>[];
    final warnings = <String>[];

    for (final entry in plannedExpenses.entries) {
      final category = entry.key;
      final planned = entry.value;
      final avg = snapshot.weeklyAverages[category] ?? 0;

      var recommended = planned;
      final higherThanUsual = avg > 0 && planned > avg * 1.3;
      if (higherThanUsual) {
        recommended = avg * 1.15;
      }

      categories.add(
        PlannerCategoryResult(
          category: category,
          planned: planned,
          recommended: recommended,
          weeklyAverage: avg,
          higherThanUsual: higherThanUsual,
        ),
      );
    }

    var totalRecommended =
        categories.fold<double>(0, (sum, c) => sum + c.recommended);

    if (spendable > 0 && totalRecommended > spendable) {
      final scale = spendable / totalRecommended;
      for (var i = 0; i < categories.length; i++) {
        final c = categories[i];
        categories[i] = PlannerCategoryResult(
          category: c.category,
          planned: c.planned,
          recommended: c.recommended * scale,
          weeklyAverage: c.weeklyAverage,
          higherThanUsual: c.higherThanUsual,
        );
      }
      totalRecommended =
          categories.fold<double>(0, (sum, c) => sum + c.recommended);
    }

    final status = _determineStatus(
      spendable: spendable,
      totalPlanned: totalPlanned,
    );

    if (savingsReserve > 0) {
      warnings.add('Savings goals reduce your weekly spendable amount.');
    }
    if (status == PlanBudgetStatus.over) {
      warnings.add('This plan is over your weekly safe limit.');
    } else if (status == PlanBudgetStatus.nearLimit) {
      warnings.add('You are close to your weekly limit.');
    }

    final higherCount = categories.where((c) => c.higherThanUsual).length;
    if (higherCount > 0) {
      warnings.add('$higherCount categor${higherCount == 1 ? 'y is' : 'ies are'} higher than usual.');
    }

    return PlannerResult(
      status: status,
      currentBalance: snapshot.currentBalance,
      savingsReserve: savingsReserve,
      spendableBalance: spendable,
      totalPlanned: totalPlanned,
      totalRecommended: totalRecommended,
      categories: categories,
      warnings: warnings.take(2).toList(),
    );
  }

  double _calculateSavingsReserve(PlannerFinanceSnapshot snapshot) {
    var reserve = 0.0;
    for (final g in snapshot.savingsGoals) {
      final remaining = g.targetAmount - g.currentAmount;
      if (remaining > 0) {
        reserve += remaining / 4.0;
      }
    }
    return reserve;
  }

  PlanBudgetStatus _determineStatus({
    required double spendable,
    required double totalPlanned,
  }) {
    if (spendable <= 0) return PlanBudgetStatus.over;
    if (totalPlanned > spendable) return PlanBudgetStatus.over;
    if (totalPlanned >= spendable * 0.8) return PlanBudgetStatus.nearLimit;
    return PlanBudgetStatus.under;
  }
}

