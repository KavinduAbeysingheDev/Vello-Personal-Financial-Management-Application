import '../../../models/app_models.dart';
import '../weekly_planner_service.dart';

class PlannerFinanceSnapshot {
  final double currentBalance;
  final Map<String, double> weeklyAverages;
  final List<SavingsGoal> savingsGoals;

  const PlannerFinanceSnapshot({
    required this.currentBalance,
    required this.weeklyAverages,
    required this.savingsGoals,
  });
}

class PlannerFinanceAdapter {
  final WeeklyPlannerService? _service;

  PlannerFinanceAdapter({WeeklyPlannerService? service})
      : _service = service;

  Future<PlannerFinanceSnapshot> fetchSnapshot(String userId) async {
    final service = _service ?? WeeklyPlannerService();
    final balance = await service.fetchCurrentBalance(userId);
    final weeklyAverages = await service.fetchWeeklyAverageByCategory(userId);
    final goals = await service.fetchSavingsGoals(userId);

    return PlannerFinanceSnapshot(
      currentBalance: balance,
      weeklyAverages: weeklyAverages,
      savingsGoals: goals,
    );
  }
}
