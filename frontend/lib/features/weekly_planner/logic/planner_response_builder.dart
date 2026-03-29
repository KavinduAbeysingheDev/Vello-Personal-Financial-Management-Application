import 'package:intl/intl.dart';

import '../domain/planner_models.dart';

class PlannerResponseBuilder {
  final _money = NumberFormat.currency(symbol: 'LKR ', decimalDigits: 0);

  String invalidInput() {
    return 'Please enter planned expenses like: "food 5000, transport 2000".';
  }

  String summaryAgain(PlannerResult? result) {
    if (result == null) {
      return 'No plan yet. Send your weekly expenses first.';
    }
    return buildPlanReply(result);
  }

  String savingsReply(PlannerResult? result) {
    if (result == null) {
      return 'No plan yet. Send your weekly expenses first.';
    }
    final remaining = (result.spendableBalance - result.totalRecommended)
        .clamp(0, double.infinity);
    return 'You can still save about ${_money.format(remaining)} this week.';
  }

  String resetReply() {
    return 'Plan reset. Send new weekly expenses to build a fresh plan.';
  }

  String buildPlanReply(PlannerResult result) {
    final summary = _summaryLine(result);
    final guidance = _topCategoryGuidance(result);
    final warning = result.warnings.isNotEmpty ? 'Warning: ${result.warnings.first}' : null;

    final parts = <String>[
      summary,
      if (guidance.isNotEmpty) guidance,
      if (warning != null) warning,
      'Next: send "change food to 4500" to adjust.',
    ];

    return parts.join('\n');
  }

  String _summaryLine(PlannerResult result) {
    switch (result.status) {
      case PlanBudgetStatus.under:
        return 'Good plan. You are under budget (${_money.format(result.totalRecommended)} recommended).';
      case PlanBudgetStatus.nearLimit:
        return 'Careful plan. You are near the weekly limit (${_money.format(result.totalRecommended)} recommended).';
      case PlanBudgetStatus.over:
        return 'Plan is over budget. Reduce spending to about ${_money.format(result.totalRecommended)}.';
    }
  }

  String _topCategoryGuidance(PlannerResult result) {
    final top = [...result.categories]
      ..sort((a, b) => (b.planned - b.recommended).compareTo(a.planned - a.recommended));

    final lines = <String>[];
    for (final c in top.take(2)) {
      final diff = c.planned - c.recommended;
      if (diff > 0) {
        lines.add('${c.category}: keep near ${_money.format(c.recommended)} (cut ${_money.format(diff)}).');
      } else {
        lines.add('${c.category}: ${_money.format(c.recommended)} is fine.');
      }
    }
    return lines.join(' ');
  }
}

