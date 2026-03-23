import '../data/rule_definitions.dart';

/// Result of intent classification with confidence score and extracted entities.
class IntentResult {
  final ChatIntent intent;
  final double confidence;
  final Map<String, String> entities;

  const IntentResult({
    required this.intent,
    required this.confidence,
    this.entities = const {},
  });

  @override
  String toString() =>
      'IntentResult($intent, confidence: ${confidence.toStringAsFixed(2)}, '
      'entities: $entities)';
}

/// Rule-based engine that classifies user messages into intents
/// using keyword matching and phrase detection.
class RuleEngine {
  /// Classify a user message into an intent with confidence score.
  IntentResult classify(String userMessage) {
    final normalized = _normalize(userMessage);
    final words = normalized.split(RegExp(r'\s+'));

    double bestScore = 0;
    ChatIntent bestIntent = ChatIntent.unknown;
    Map<String, String> entities = {};

    for (final rule in RuleDefinitions.rules) {
      double score = 0;
      int matches = 0;

      // ── Check full phrase matches (highest weight) ──────────────
      for (final phrase in rule.phrases) {
        if (normalized.contains(phrase.toLowerCase())) {
          score += rule.baseConfidence + 0.3;
          matches++;
          break; // one phrase match is enough
        }
      }

      // ── Check keyword matches ──────────────────────────────────
      for (final keyword in rule.keywords) {
        final kwLower = keyword.toLowerCase();
        if (kwLower.contains(' ')) {
          // Multi-word keyword
          if (normalized.contains(kwLower)) {
            score += 0.15;
            matches++;
          }
        } else {
          // Single-word keyword
          if (words.contains(kwLower)) {
            score += 0.1;
            matches++;
          }
        }
      }

      // ── Apply match density bonus ───────────────────────────────
      if (matches > 2) {
        score += 0.1 * (matches - 2);
      }

      // ── Clamp score to [0, 1] ───────────────────────────────────
      score = score.clamp(0.0, 1.0);

      if (score > bestScore) {
        bestScore = score;
        bestIntent = rule.intent;
      }
    }

    // ── Extract entities ──────────────────────────────────────────
    entities = _extractEntities(normalized);

    // ── Minimum confidence threshold ──────────────────────────────
    if (bestScore < 0.15) {
      bestIntent = ChatIntent.unknown;
    }

    return IntentResult(
      intent: bestIntent,
      confidence: bestScore,
      entities: entities,
    );
  }

  /// Extract entities (categories, time periods, amounts) from the message.
  Map<String, String> _extractEntities(String normalizedMessage) {
    final entities = <String, String>{};

    // ── Extract category entities ─────────────────────────────────
    for (final entry in RuleDefinitions.categoryKeywords.entries) {
      if (normalizedMessage.contains(entry.key)) {
        entities['category'] = entry.value;
        break;
      }
    }

    // ── Extract time period entities ──────────────────────────────
    for (final entry in RuleDefinitions.timePeriodKeywords.entries) {
      if (normalizedMessage.contains(entry.key)) {
        entities['timePeriod'] = entry.value;
        break;
      }
    }

    // ── Extract monetary amounts ──────────────────────────────────
    final amountPattern = RegExp(r'\$?([\d,]+\.?\d*)');
    final match = amountPattern.firstMatch(normalizedMessage);
    if (match != null) {
      entities['amount'] = match.group(1)!.replaceAll(',', '');
    }

    return entities;
  }

  /// Normalize user message: lowercase, remove extra punctuation.
  String _normalize(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\$\.]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
