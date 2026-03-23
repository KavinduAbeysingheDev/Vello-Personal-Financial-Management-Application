import '../services/intent_classifier_service.dart';

class IntentRule {
  final ChatIntent intent;
  final List<String> keywords;
  final List<String> phrases;
  final double baseConfidence;

  const IntentRule({
    required this.intent,
    required this.keywords,
    this.phrases = const [],
    this.baseConfidence = 0.5,
  });
}

class ChatRuleDefinitions {
  static const List<IntentRule> rules = [
    IntentRule(
      intent: ChatIntent.analyzeSpending,
      keywords: ['spending', 'spent', 'expenses', 'analysis', 'breakdown'],
      phrases: ['analyze my spending', 'where is my money going', 'spending breakdown'],
      baseConfidence: 0.7,
    ),
    IntentRule(
      intent: ChatIntent.budgetRecommendation,
      keywords: ['budget', 'allocate', 'plan', 'recommendation'],
      phrases: ['budget recommendations', 'help me budget', 'am i over budget'],
      baseConfidence: 0.7,
    ),
    IntentRule(
      intent: ChatIntent.weeklyBudgetPlan,
      keywords: ['weekly budget', 'next week', 'plan my week', 'week plan', 'planner', 'plan for next week'],
      phrases: [
        'weekly budget plan',
        'weekly budget',
        'budget for next week',
        'plan my week',
        'plan next week',
        'weekly plan',
        'budget next week',
        'plan for next week',
        'help me plan next week',
      ],
      baseConfidence: 0.85,
    ),
    IntentRule(
      intent: ChatIntent.weeklySummary,
      keywords: ['weekly', 'week', 'summary', 'report'],
      phrases: ['weekly summary', 'how was my week'],
      baseConfidence: 0.7,
    ),
    IntentRule(
      intent: ChatIntent.savingsTips,
      keywords: ['save', 'saving', 'tips', 'reduce'],
      phrases: ['savings tips', 'how to save money'],
      baseConfidence: 0.7,
    ),
    IntentRule(
      intent: ChatIntent.financialHealth,
      keywords: ['health', 'score', 'status'],
      phrases: ['financial health', 'rate my finances'],
      baseConfidence: 0.7,
    ),
    IntentRule(
      intent: ChatIntent.checkBalance,
      keywords: ['balance', 'total', 'have'],
      phrases: ['check my balance', 'how much do i have'],
      baseConfidence: 0.6,
    ),
    IntentRule(
      intent: ChatIntent.categoryBreakdown,
      keywords: ['category', 'categories', 'food', 'transport', 'shopping'],
      phrases: ['spending by category', 'how much on food'],
      baseConfidence: 0.6,
    ),
    IntentRule(
      intent: ChatIntent.compareSpending,
      keywords: ['compare', 'versus', 'last month'],
      phrases: ['compare my spending', 'last month comparison'],
      baseConfidence: 0.6,
    ),
    IntentRule(
      intent: ChatIntent.greeting,
      keywords: ['hello', 'hi', 'hey'],
      phrases: ['hi there', 'good morning'],
      baseConfidence: 0.9,
    ),
    IntentRule(
      intent: ChatIntent.help,
      keywords: ['help', 'what can you do', 'options'],
      phrases: ['what can you do', 'show me help'],
      baseConfidence: 0.8,
    ),
    IntentRule(
      intent: ChatIntent.thanks,
      keywords: ['thanks', 'thank you'],
      phrases: ['much appreciated', 'thats helpful'],
      baseConfidence: 0.9,
    ),
  ];

  static const Map<String, String> categoryKeywords = {
     'food': 'food', 'restaurant': 'food', 'transport': 'transport', 'taxi': 'transport',
     'shopping': 'shopping', 'amazon': 'shopping', 'bills': 'bills', 'electricity': 'bills',
     'entertainment': 'entertainment', 'netflix': 'entertainment', 'groceries': 'groceries',
     'rent': 'rent', 'subscription': 'subscription',
  };

  static const Map<String, String> timePeriodKeywords = {
    'today': 'today', 'yesterday': 'yesterday', 'this week': 'this_week', 
    'last week': 'last_week', 'this month': 'this_month', 'last month': 'last_month',
  };
}
