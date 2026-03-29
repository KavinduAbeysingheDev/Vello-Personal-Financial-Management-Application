import '../domain/planner_intent.dart';
import '../domain/planner_models.dart';

class PlannerInputParser {
  static const Map<String, String> _categoryAliases = {
    'food': 'Food',
    'groceries': 'Food',
    'grocery': 'Food',
    'restaurant': 'Food',
    'dining': 'Food',
    'transport': 'Transport',
    'bus': 'Transport',
    'travel': 'Transport',
    'fuel': 'Transport',
    'taxi': 'Transport',
    'uber': 'Transport',
    'entertainment': 'Entertainment',
    'movie': 'Entertainment',
    'fun': 'Entertainment',
    'health': 'Health',
    'medical': 'Health',
    'pharmacy': 'Health',
    'shopping': 'Shopping',
    'bills': 'Utilities',
    'bill': 'Utilities',
    'electricity': 'Utilities',
    'water': 'Utilities',
    'internet': 'Utilities',
    'rent': 'Rent',
    'education': 'Education',
  };

  PlannerInput parse(String message) {
    final text = message.trim();
    final lower = text.toLowerCase();

    if (lower == 'reset plan' || lower == 'reset') {
      return const PlannerInput(intent: PlannerIntent.resetPlan);
    }

    if (lower == 'show summary again' || lower == 'summary') {
      return const PlannerInput(intent: PlannerIntent.showSummaryAgain);
    }

    if (lower.contains('how much can i save') || lower == 'savings') {
      return const PlannerInput(intent: PlannerIntent.askSavings);
    }

    final adjust = _parseAdjustment(text);
    if (adjust != null) {
      return adjust;
    }

    final parsedExpenses = _parseExpenses(text);
    if (parsedExpenses.isNotEmpty) {
      return PlannerInput(
        intent: PlannerIntent.submitPlan,
        expenses: parsedExpenses,
      );
    }

    return const PlannerInput(intent: PlannerIntent.unknown);
  }

  PlannerInput? _parseAdjustment(String text) {
    final exp = RegExp(
      r'change\s+([a-zA-Z][a-zA-Z\s]{1,20})\s+to\s+(\d[\d,]*(?:\.\d+)?)',
      caseSensitive: false,
    );
    final match = exp.firstMatch(text);
    if (match == null) return null;

    final normalized = _normalizeCategory(match.group(1)!);
    final amount = double.tryParse(match.group(2)!.replaceAll(',', ''));
    if (normalized == null || amount == null || amount <= 0) {
      return null;
    }

    return PlannerInput(
      intent: PlannerIntent.adjustCategory,
      category: normalized,
      amount: amount,
    );
  }

  Map<String, double> _parseExpenses(String text) {
    final result = <String, double>{};

    // Pattern A: "food 5000, transport 2000"
    final a = RegExp(
      r'([a-zA-Z][a-zA-Z\s]{1,20}?)[:\s-]{1,3}(\d[\d,]*(?:\.\d+)?)',
      caseSensitive: false,
    );
    for (final m in a.allMatches(text)) {
      final category = _normalizeCategory(m.group(1)!);
      final amount = double.tryParse(m.group(2)!.replaceAll(',', '')) ?? 0;
      if (category != null && amount > 0) {
        result[category] = amount;
      }
    }

    // Pattern B: "5000 for food"
    final b = RegExp(
      r'(\d[\d,]*(?:\.\d+)?)\s+(?:for|on)\s+([a-zA-Z][a-zA-Z\s]{1,20})',
      caseSensitive: false,
    );
    for (final m in b.allMatches(text)) {
      final amount = double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
      final category = _normalizeCategory(m.group(2)!);
      if (category != null && amount > 0) {
        result[category] = amount;
      }
    }

    return result;
  }

  String? _normalizeCategory(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.isEmpty) return null;

    for (final entry in _categoryAliases.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    final cleaned = lower.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}

