import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../data/rule_definitions.dart';
import '../data/sample_data.dart';
import '../utils/constants.dart';
import 'rule_engine.dart';
import 'spending_analysis_service.dart';
import 'budget_service.dart';
import 'savings_service.dart';
import 'weekly_summary_service.dart';
import 'financial_health_service.dart';

/// Main chatbot service that orchestrates intent classification and response generation.
///
/// Flow: User message → RuleEngine (intent) → Appropriate service → Formatted response
class ChatbotService {
  final RuleEngine _ruleEngine = RuleEngine();
  final SpendingAnalysisService _spendingService = SpendingAnalysisService();
  final BudgetService _budgetService = BudgetService();
  final SavingsService _savingsService = SavingsService();
  final WeeklySummaryService _weeklySummaryService = WeeklySummaryService();
  final FinancialHealthService _healthService = FinancialHealthService();

  // In-memory user profiles (in production, use a database)
  final Map<String, UserProfile> _userProfiles = {};

  /// Process a user message and return a bot response.
  ChatMessage processMessage(String userMessage, {String? userId}) {
    final uid = userId ?? 'demo_user_001';
    final profile = _getOrCreateProfile(uid);

    // Step 1: Classify the intent
    final intentResult = _ruleEngine.classify(userMessage);

    // Step 2: Route to the appropriate handler
    String responseText;
    List<String>? quickReplies;

    switch (intentResult.intent) {
      case ChatIntent.analyzeSpending:
        responseText = _handleAnalyzeSpending(profile, intentResult);
        quickReplies = [
          'Budget recommendations',
          'Compare with last month',
          'Savings tips',
          'Financial health score',
        ];
        break;

      case ChatIntent.budgetRecommendation:
        responseText = _handleBudgetRecommendation(profile, intentResult);
        quickReplies = [
          'Analyze my spending',
          'Savings tips',
          'Weekly summary',
          'Financial health score',
        ];
        break;

      case ChatIntent.weeklySummary:
        responseText = _handleWeeklySummary(profile);
        quickReplies = [
          'Analyze my spending',
          'Budget recommendations',
          'Savings tips',
          'Financial health score',
        ];
        break;

      case ChatIntent.savingsTips:
        responseText = _handleSavingsTips(profile, intentResult);
        quickReplies = [
          'Analyze my spending',
          'Budget recommendations',
          'Financial health score',
          'Weekly summary',
        ];
        break;

      case ChatIntent.financialHealth:
        responseText = _handleFinancialHealth(profile);
        quickReplies = [
          'Analyze my spending',
          'Budget recommendations',
          'Savings tips',
          'Weekly summary',
        ];
        break;

      case ChatIntent.checkBalance:
        responseText = _handleCheckBalance(profile);
        quickReplies = [
          'Analyze my spending',
          'Weekly summary',
          'Savings tips',
          'Financial health score',
        ];
        break;

      case ChatIntent.categoryBreakdown:
        responseText = _handleCategoryBreakdown(profile, intentResult);
        quickReplies = [
          'Analyze my spending',
          'Budget recommendations',
          'Savings tips',
          'Compare with last month',
        ];
        break;

      case ChatIntent.compareSpending:
        responseText = _handleCompareSpending(profile);
        quickReplies = [
          'Analyze my spending',
          'Budget recommendations',
          'Savings tips',
          'Weekly summary',
        ];
        break;

      case ChatIntent.greeting:
        responseText = _handleGreeting(profile);
        quickReplies = AppConstants.defaultQuickReplies;
        break;

      case ChatIntent.help:
        responseText = _handleHelp();
        quickReplies = AppConstants.defaultQuickReplies;
        break;

      case ChatIntent.thanks:
        responseText = _handleThanks();
        quickReplies = AppConstants.followUpQuickReplies;
        break;

      case ChatIntent.unknown:
        responseText = _handleUnknown();
        quickReplies = AppConstants.defaultQuickReplies;
        break;
    }

    return ChatMessage.botResponse(
      text: responseText,
      quickReplies: quickReplies,
      metadata: {
        'intent': intentResult.intent.name,
        'confidence': intentResult.confidence,
        'entities': intentResult.entities,
      },
    );
  }

  // ── Intent Handlers ──────────────────────────────────────────────

  String _handleAnalyzeSpending(UserProfile profile, IntentResult intent) {
    return _spendingService.formatAnalysisResponse(profile,
        category: intent.entities['category']);
  }

  String _handleBudgetRecommendation(UserProfile profile, IntentResult intent) {
    return _budgetService.formatBudgetResponse(profile);
  }

  String _handleWeeklySummary(UserProfile profile) {
    return _weeklySummaryService.formatWeeklySummaryResponse(profile);
  }

  String _handleSavingsTips(UserProfile profile, IntentResult intent) {
    return _savingsService.formatSavingsResponse(profile,
        category: intent.entities['category']);
  }

  String _handleFinancialHealth(UserProfile profile) {
    return _healthService.formatHealthResponse(profile);
  }

  String _handleCheckBalance(UserProfile profile) {
    final buffer = StringBuffer();
    buffer.writeln('💳 **Account Overview**\n');
    buffer.writeln(
        '🏦 Total Balance: **\$${profile.balance.toStringAsFixed(2)}**');
    buffer.writeln(
        '📈 Total Income: **\$${profile.totalIncome.toStringAsFixed(2)}**');
    buffer.writeln(
        '📉 Total Expenses: **\$${profile.totalExpenses.toStringAsFixed(2)}**');
    buffer.writeln(
        '💰 Savings Rate: **${profile.savingsRate.toStringAsFixed(1)}%**');

    if (profile.savingsGoal > 0) {
      final progress =
          (profile.balance / profile.savingsGoal * 100).clamp(0, 100);
      buffer.writeln('\n🎯 Savings Goal Progress: '
          '**${progress.toStringAsFixed(0)}%** of '
          '\$${profile.savingsGoal.toStringAsFixed(2)}');
    }

    return buffer.toString().trim();
  }

  String _handleCategoryBreakdown(UserProfile profile, IntentResult intent) {
    final category = intent.entities['category'];
    if (category != null) {
      // Specific category detail
      final catExpenses = profile.expenses
          .where((t) => t.category.name.toLowerCase() == category.toLowerCase())
          .toList();

      if (catExpenses.isEmpty) {
        return '📦 No expenses found for the **$category** category this period.\n\n'
            'Would you like to see your overall spending analysis instead?';
      }

      final total = catExpenses.fold<double>(0, (sum, t) => sum + t.amount);
      final buffer = StringBuffer();
      buffer
          .writeln('📂 **${category[0].toUpperCase()}${category.substring(1)} '
              'Expenses**\n');
      buffer.writeln('Total: **\$${total.toStringAsFixed(2)}**');
      buffer.writeln('Transactions: **${catExpenses.length}**\n');

      for (final t in catExpenses) {
        buffer.writeln('• ${t.description}: \$${t.amount.toStringAsFixed(2)} '
            '(${t.date.day}/${t.date.month})');
      }

      return buffer.toString().trim();
    }

    // General category breakdown — delegate to spending analysis
    return _spendingService.formatAnalysisResponse(profile);
  }

  String _handleCompareSpending(UserProfile profile) {
    final comparison = _spendingService.compareWithPrevious(profile);
    final buffer = StringBuffer();

    buffer.writeln('📊 **Spending Comparison**\n');
    buffer.writeln('${comparison['trendEmoji']} Your spending has '
        '**${comparison['trend']}** compared to last month.\n');
    buffer.writeln('📅 This month: **${comparison['thisMonthFormatted']}**');
    buffer.writeln('📅 Last month: **${comparison['lastMonthFormatted']}**');
    buffer.writeln('📐 Difference: **${comparison['differenceFormatted']}** '
        '(${comparison['percentChangeFormatted']} '
        '${comparison['trend']})');

    if (comparison['trend'] == 'increased') {
      buffer.writeln('\n💡 **Tip:** Review your recent purchases to identify '
          'areas where you can cut back.');
    } else if (comparison['trend'] == 'decreased') {
      buffer.writeln('\n🎉 You\'re spending less than last month. '
          'Keep up the great work!');
    }

    return buffer.toString().trim();
  }

  String _handleGreeting(UserProfile profile) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return '👋 $greeting! I\'m **${AppConstants.botName}**, your personal '
        'finance assistant.\n\n'
        '💰 Your current balance is '
        '**\$${profile.balance.toStringAsFixed(2)}** with a savings rate '
        'of **${profile.savingsRate.toStringAsFixed(1)}%**.\n\n'
        'How can I help you today? You can ask me to:\n'
        '• 📊 Analyze your spending\n'
        '• 💰 Get budget recommendations\n'
        '• 📅 View your weekly summary\n'
        '• 💡 Get personalized savings tips\n'
        '• 🏥 Check your financial health score';
  }

  String _handleHelp() {
    return '🤖 **${AppConstants.botName} — What I Can Do**\n\n'
        'I can help you with:\n\n'
        '📊 **Spending Analysis** — "Analyze my spending" or "Where is my money going?"\n'
        '💰 **Budget Help** — "Budget recommendations" or "Am I over budget?"\n'
        '📅 **Weekly Summary** — "Weekly summary" or "How was my week?"\n'
        '💡 **Savings Tips** — "Savings tips" or "How can I save more?"\n'
        '🏥 **Financial Health** — "Financial health score" or "Rate my finances"\n'
        '💳 **Balance Check** — "Check my balance" or "How much do I have?"\n'
        '📂 **Category Details** — "How much on food?" or "Show transport expenses"\n'
        '📊 **Compare Months** — "Compare my spending" or "Am I spending more?"\n\n'
        'Just type your question or tap one of the quick-reply buttons below! 👇';
  }

  String _handleThanks() {
    final responses = [
      '😊 You\'re welcome! Is there anything else I can help with?',
      '🙌 Happy to help! Let me know if you need anything else.',
      '✨ Glad I could help! Feel free to ask me anything about your finances.',
      '👍 Anytime! Your financial wellbeing is my priority.',
    ];
    responses.shuffle();
    return responses.first;
  }

  String _handleUnknown() {
    return '🤔 I\'m not sure I understand that. I\'m best at helping with:\n\n'
        '• Spending analysis\n'
        '• Budget recommendations\n'
        '• Weekly summaries\n'
        '• Savings tips\n'
        '• Financial health scores\n\n'
        'Try asking something like **"Analyze my spending"** or '
        '**"How can I save more?"**\n\n'
        'Or tap one of the quick-reply buttons below! 👇';
  }

  // ── Helper Methods ───────────────────────────────────────────────

  /// Get or create a user profile (uses sample data for demo).
  UserProfile _getOrCreateProfile(String userId) {
    return _userProfiles.putIfAbsent(userId, () => SampleData.getSampleUser());
  }
}
