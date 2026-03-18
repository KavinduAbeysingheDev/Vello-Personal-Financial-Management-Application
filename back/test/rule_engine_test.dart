import 'package:test/test.dart';
import 'package:vello_chatbot_backend/services/rule_engine.dart';
import 'package:vello_chatbot_backend/data/rule_definitions.dart';

void main() {
  late RuleEngine engine;

  setUp(() {
    engine = RuleEngine();
  });

  group('RuleEngine - Intent Classification', () {
    test('should classify spending analysis intent', () {
      final result = engine.classify('Analyze my spending');
      expect(result.intent, equals(ChatIntent.analyzeSpending));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify "where is my money going" as spending analysis', () {
      final result = engine.classify('Where is my money going?');
      expect(result.intent, equals(ChatIntent.analyzeSpending));
    });

    test('should classify budget recommendation intent', () {
      final result = engine.classify('Budget recommendations');
      expect(result.intent, equals(ChatIntent.budgetRecommendation));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify "how should I budget" as budget intent', () {
      final result = engine.classify('How should I budget my money?');
      expect(result.intent, equals(ChatIntent.budgetRecommendation));
    });

    test('should classify weekly summary intent', () {
      final result = engine.classify('Weekly summary');
      expect(result.intent, equals(ChatIntent.weeklySummary));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify savings tips intent', () {
      final result = engine.classify('Savings tips');
      expect(result.intent, equals(ChatIntent.savingsTips));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify "how can I save more" as savings intent', () {
      final result = engine.classify('How can I save more money?');
      expect(result.intent, equals(ChatIntent.savingsTips));
    });

    test('should classify financial health intent', () {
      final result = engine.classify('Financial health score');
      expect(result.intent, equals(ChatIntent.financialHealth));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify balance check intent', () {
      final result = engine.classify('Check my balance');
      expect(result.intent, equals(ChatIntent.checkBalance));
    });

    test('should classify greeting intent', () {
      final result = engine.classify('Hello');
      expect(result.intent, equals(ChatIntent.greeting));
      expect(result.confidence, greaterThan(0.5));
    });

    test('should classify help intent', () {
      final result = engine.classify('What can you do?');
      expect(result.intent, equals(ChatIntent.help));
    });

    test('should classify thanks intent', () {
      final result = engine.classify('Thank you!');
      expect(result.intent, equals(ChatIntent.thanks));
    });

    test('should classify unknown for gibberish', () {
      final result = engine.classify('asdfghjkl qwerty');
      expect(result.intent, equals(ChatIntent.unknown));
    });

    test('should classify compare spending intent', () {
      final result = engine.classify('Compare my spending with last month');
      expect(result.intent, equals(ChatIntent.compareSpending));
    });
  });

  group('RuleEngine - Entity Extraction', () {
    test('should extract food category entity', () {
      final result = engine.classify('How much did I spend on food?');
      expect(result.entities['category'], equals('food'));
    });

    test('should extract transport category entity', () {
      final result = engine.classify('Show my transport expenses');
      expect(result.entities['category'], equals('transport'));
    });

    test('should extract time period entity', () {
      final result = engine.classify('Show spending this week');
      expect(result.entities['timePeriod'], equals('this_week'));
    });

    test('should extract last month time period', () {
      final result = engine.classify('What did I spend last month?');
      expect(result.entities['timePeriod'], equals('last_month'));
    });

    test('should extract amount entity', () {
      final result = engine.classify('I spent \$45 on groceries');
      expect(result.entities['amount'], isNotNull);
    });
  });

  group('RuleEngine - Edge Cases', () {
    test('should handle empty message', () {
      final result = engine.classify('');
      expect(result.intent, equals(ChatIntent.unknown));
    });

    test('should handle message with only punctuation', () {
      final result = engine.classify('???!!!...');
      expect(result.intent, equals(ChatIntent.unknown));
    });

    test('should be case insensitive', () {
      final result1 = engine.classify('ANALYZE MY SPENDING');
      final result2 = engine.classify('analyze my spending');
      expect(result1.intent, equals(result2.intent));
    });

    test('should handle extra whitespace', () {
      final result = engine.classify('  analyze   my   spending  ');
      expect(result.intent, equals(ChatIntent.analyzeSpending));
    });
  });
}
