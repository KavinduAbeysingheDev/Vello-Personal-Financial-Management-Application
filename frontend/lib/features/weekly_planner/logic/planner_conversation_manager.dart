import '../data/planner_finance_adapter.dart';
import '../domain/planner_intent.dart';
import '../domain/planner_models.dart';
import '../domain/planner_state.dart';
import 'planner_input_parser.dart';
import 'planner_response_builder.dart';
import 'planner_rule_engine.dart';

class PlannerConversationManager {
  final PlannerInputParser _parser;
  final PlannerFinanceAdapter _financeAdapter;
  final PlannerRuleEngine _ruleEngine;
  final PlannerResponseBuilder _responseBuilder;

  PlannerState state = PlannerState.greeting;
  PlannerResult? _lastResult;
  Map<String, double>? _lastPlannedExpenses;

  PlannerConversationManager({
    PlannerInputParser? parser,
    PlannerFinanceAdapter? financeAdapter,
    PlannerRuleEngine? ruleEngine,
    PlannerResponseBuilder? responseBuilder,
  })  : _parser = parser ?? PlannerInputParser(),
        _financeAdapter = financeAdapter ?? PlannerFinanceAdapter(),
        _ruleEngine = ruleEngine ?? const PlannerRuleEngine(),
        _responseBuilder = responseBuilder ?? PlannerResponseBuilder();

  String greeting({required bool isWeekend}) {
    if (!isWeekend) {
      state = PlannerState.awaitingPlan;
      return 'This planner is available on weekends only. Come back on Saturday or Sunday.';
    }

    state = PlannerState.awaitingPlan;
    return 'Hi! Send your weekly expenses (example: "food 5000, transport 2000").';
  }

  Future<String> handleUserMessage({
    required String userId,
    required String message,
    required bool isWeekend,
  }) async {
    if (!isWeekend) {
      return 'Weekend only. Please return on Saturday or Sunday.';
    }

    final parsed = _parser.parse(message);

    switch (parsed.intent) {
      case PlannerIntent.resetPlan:
        _lastResult = null;
        _lastPlannedExpenses = null;
        state = PlannerState.awaitingPlan;
        return _responseBuilder.resetReply();

      case PlannerIntent.showSummaryAgain:
        return _responseBuilder.summaryAgain(_lastResult);

      case PlannerIntent.askSavings:
        return _responseBuilder.savingsReply(_lastResult);

      case PlannerIntent.adjustCategory:
        if (_lastPlannedExpenses == null ||
            parsed.category == null ||
            parsed.amount == null) {
          return _responseBuilder.invalidInput();
        }
        _lastPlannedExpenses![parsed.category!] = parsed.amount!;
        return _buildPlanFromExpenses(userId, _lastPlannedExpenses!);

      case PlannerIntent.submitPlan:
        _lastPlannedExpenses = {...parsed.expenses};
        return _buildPlanFromExpenses(userId, parsed.expenses);

      case PlannerIntent.unknown:
        return _responseBuilder.invalidInput();
    }
  }

  Future<String> _buildPlanFromExpenses(
    String userId,
    Map<String, double> expenses,
  ) async {
    final snapshot = await _financeAdapter.fetchSnapshot(userId);
    final result = _ruleEngine.buildPlan(
      snapshot: snapshot,
      plannedExpenses: expenses,
    );

    _lastResult = result;
    state = PlannerState.planReady;
    return _responseBuilder.buildPlanReply(result);
  }
}

