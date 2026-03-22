/// Application-wide constants for the Vello chatbot backend.
class AppConstants {
  AppConstants._();

  // ── Server ──────────────────────────────────────────────────────────
  static const int defaultPort = 8080;
  static const String apiPrefix = '/api';

  // ── Currency ────────────────────────────────────────────────────────
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  // ── Budget Rules (50/30/20) ─────────────────────────────────────────
  static const double needsPercent = 50.0;
  static const double wantsPercent = 30.0;
  static const double savingsPercent = 20.0;

  // ── Financial Health Thresholds ─────────────────────────────────────
  static const double excellentSavingsRate = 20.0;
  static const double goodSavingsRate = 10.0;
  static const double poorSavingsRate = 5.0;

  // ── Chatbot ─────────────────────────────────────────────────────────
  static const String botName = 'Vello AI';
  static const int maxQuickReplies = 4;

  // ── Default Quick Replies ───────────────────────────────────────────
  static const List<String> defaultQuickReplies = [
    'Analyze my spending',
    'Budget recommendations',
    'Weekly summary',
    'Savings tips',
  ];

  static const List<String> followUpQuickReplies = [
    'Tell me more',
    'Financial health score',
    'How can I save more?',
    'Show my budgets',
  ];
}
