import 'package:test/test.dart';
import 'package:vello_chatbot_backend/services/chatbot_service.dart';

void main() {
  late ChatbotService chatbot;

  setUp(() {
    chatbot = ChatbotService();
  });

  group('ChatbotService - End-to-End', () {
    test('should respond to spending analysis request', () {
      final response = chatbot.processMessage('Analyze my spending');
      expect(response.text, contains('Spending Analysis'));
      expect(response.isUser, isFalse);
      expect(response.quickReplies, isNotNull);
      expect(response.quickReplies, isNotEmpty);
    });

    test('should respond to budget recommendation request', () {
      final response = chatbot.processMessage('Budget recommendations');
      expect(response.text, contains('Budget'));
      expect(response.isUser, isFalse);
      expect(response.quickReplies, isNotNull);
    });

    test('should respond to weekly summary request', () {
      final response = chatbot.processMessage('Weekly summary');
      expect(response.text, contains('Weekly Summary'));
      expect(response.isUser, isFalse);
    });

    test('should respond to savings tips request', () {
      final response = chatbot.processMessage('Savings tips');
      expect(response.text, contains('Savings'));
      expect(response.isUser, isFalse);
    });

    test('should respond to financial health request', () {
      final response = chatbot.processMessage('Financial health score');
      expect(response.text, contains('Financial Health'));
      expect(response.isUser, isFalse);
    });

    test('should respond to greeting', () {
      final response = chatbot.processMessage('Hello');
      expect(response.text, contains('Vello AI'));
      expect(response.isUser, isFalse);
      expect(response.quickReplies, isNotNull);
    });

    test('should respond to help request', () {
      final response = chatbot.processMessage('What can you do?');
      expect(response.text, contains('What I Can Do'));
      expect(response.isUser, isFalse);
    });

    test('should respond to thanks', () {
      final response = chatbot.processMessage('Thank you!');
      expect(response.text, isNotEmpty);
      expect(response.isUser, isFalse);
    });

    test('should respond to unknown message gracefully', () {
      final response = chatbot.processMessage('xyzzy foo bar');
      expect(response.text, contains('not sure'));
      expect(response.quickReplies, isNotNull);
    });

    test('should respond to balance check', () {
      final response = chatbot.processMessage('Check my balance');
      expect(response.text, contains('Balance'));
      expect(response.isUser, isFalse);
    });

    test('should respond to compare spending', () {
      final response = chatbot.processMessage('Compare my spending');
      expect(response.text, contains('Comparison'));
      expect(response.isUser, isFalse);
    });

    test('should include metadata with intent info', () {
      final response = chatbot.processMessage('Analyze my spending');
      expect(response.metadata, isNotNull);
      expect(response.metadata!['intent'], isNotNull);
      expect(response.metadata!['confidence'], isNotNull);
    });
  });

  group('ChatbotService - Quick Replies', () {
    test('should provide relevant quick replies for each intent', () {
      final spending = chatbot.processMessage('Analyze my spending');
      expect(spending.quickReplies, contains('Budget recommendations'));

      final budget = chatbot.processMessage('Budget recommendations');
      expect(budget.quickReplies, contains('Analyze my spending'));

      final greeting = chatbot.processMessage('Hello');
      expect(greeting.quickReplies, contains('Analyze my spending'));
      expect(greeting.quickReplies, contains('Savings tips'));
    });
  });

  group('ChatbotService - Response Formatting', () {
    test('spending analysis should contain category breakdown', () {
      final response = chatbot.processMessage('Analyze my spending');
      expect(response.text, contains('breakdown'));
    });

    test('budget response should contain 50/30/20 recommendation', () {
      final response = chatbot.processMessage('Budget recommendations');
      expect(response.text, contains('50/30/20'));
    });

    test('health score should contain numeric score', () {
      final response = chatbot.processMessage('Financial health score');
      expect(response.text, contains('/100'));
    });

    test('greeting should contain balance info', () {
      final response = chatbot.processMessage('Hi there');
      expect(response.text, contains('\$'));
    });
  });

  group('ChatbotService - JSON Serialization', () {
    test('response should serialize to valid JSON', () {
      final response = chatbot.processMessage('Hello');
      final json = response.toJson();

      expect(json['text'], isNotNull);
      expect(json['isUser'], isFalse);
      expect(json['timestamp'], isNotNull);
      expect(json['id'], startsWith('bot_'));
    });
  });
}
