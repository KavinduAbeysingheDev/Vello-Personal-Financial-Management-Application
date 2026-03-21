import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:vello_app/features/gmail_detector/gmail_detector_service.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Encodes [text] to standard base64 (with padding).
/// decodeBase64() normalises URL-safe chars then calls base64Decode, which
/// requires proper padding — so we must keep the '=' chars in test data.
String _gmailBase64(String text) => base64.encode(utf8.encode(text));

/// Builds a [gmail.Message] using a direct-body payload (not multipart).
/// Multipart behaviour is tested separately in the getBody() group.
gmail.Message _makeMessage({
  String? subject,
  String? plainBody,
  String? id,
}) {
  final subjectHeader = subject != null
      ? (gmail.MessagePartHeader()
        ..name = 'Subject'
        ..value = subject)
      : null;

  final payload = gmail.MessagePart()
    ..headers = [?subjectHeader]
    ..body = plainBody != null
        ? (gmail.MessagePartBody()..data = _gmailBase64(plainBody))
        : null;

  return gmail.Message()
    ..id = id
    ..payload = payload;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late GmailDetectorService service;

  setUp(() {
    service = GmailDetectorService();
  });

  // ── isSignedIn ─────────────────────────────────────────────────────────────

  group('isSignedIn', () {
    test('is false initially', () {
      expect(service.isSignedIn, isFalse);
    });
  });

  // ── scanAndStore ───────────────────────────────────────────────────────────

  group('scanAndStore()', () {
    test('returns 0 when not signed in', () async {
      expect(service.isSignedIn, isFalse);
      final count = await service.scanAndStore();
      expect(count, equals(0));
    });
  });

  // ── detectCategory ────────────────────────────────────────────────────────

  group('detectCategory()', () {
    test('returns Food for "uber eats" in subject', () {
      expect(service.detectCategory('Uber Eats Order Confirmed'), 'Food');
    });

    test('returns Food for "food" keyword', () {
      expect(service.detectCategory('Your food order is ready'), 'Food');
    });

    test('returns Food for "restaurant" keyword', () {
      expect(service.detectCategory('Receipt from Restaurant ABC'), 'Food');
    });

    test('returns Food for "eats" keyword', () {
      expect(service.detectCategory('KFC Eats Delivery'), 'Food');
    });

    test('returns Transportation for "uber" (not uber eats)', () {
      expect(service.detectCategory('Your Uber ride receipt'), 'Transportation');
    });

    test('returns Transportation for "pickme"', () {
      expect(service.detectCategory('PickMe ride completed'), 'Transportation');
    });

    test('returns Transportation for "transport"', () {
      expect(service.detectCategory('Transport Bill - April'), 'Transportation');
    });

    test('returns Shopping for "order"', () {
      expect(service.detectCategory('Your order has shipped'), 'Shopping');
    });

    test('returns Shopping for "receipt"', () {
      expect(service.detectCategory('Payment receipt enclosed'), 'Shopping');
    });

    test('returns Shopping for "purchase"', () {
      expect(service.detectCategory('Purchase confirmation'), 'Shopping');
    });

    test('returns Shopping for "google play"', () {
      expect(service.detectCategory('Google Play purchase'), 'Shopping');
    });

    test('returns Shopping for "invoice"', () {
      expect(service.detectCategory('Invoice #12345'), 'Shopping');
    });

    test('returns Bills for "electric"', () {
      expect(service.detectCategory('Electric bill for March'), 'Bills');
    });

    test('returns Bills for "water"', () {
      expect(service.detectCategory('Water bill payment'), 'Bills');
    });

    test('returns Bills for "internet"', () {
      expect(service.detectCategory('Internet bill - Dialog'), 'Bills');
    });

    test('returns Bills for "dialog"', () {
      expect(service.detectCategory('Dialog Axiata bill'), 'Bills');
    });

    test('returns Bills for "hutch"', () {
      expect(service.detectCategory('Hutch monthly bill'), 'Bills');
    });

    test('returns Bills for "slt"', () {
      expect(service.detectCategory('SLT broadband bill'), 'Bills');
    });

    test('returns Shopping as default for unrecognised subject', () {
      expect(service.detectCategory('Hello there'), 'Shopping');
    });

    test('is case-insensitive', () {
      expect(service.detectCategory('UBER EATS ORDER'), 'Food');
      expect(service.detectCategory('PICKME RIDE'), 'Transportation');
    });
  });

  // ── extractAmount ─────────────────────────────────────────────────────────

  group('extractAmount()', () {
    test('returns null for empty text', () {
      expect(service.extractAmount(''), isNull);
    });

    test('returns null when no amount present', () {
      expect(service.extractAmount('Hello, your package is on the way.'), isNull);
    });

    test('returns null for amounts <= 10', () {
      expect(service.extractAmount('LKR 5.00'), isNull);
      expect(service.extractAmount('Rs. 10'), isNull);
    });

    test('parses LKR prefix', () {
      expect(service.extractAmount('Total: LKR 1500.00'), equals(1500.0));
    });

    test('parses Rs. prefix', () {
      expect(service.extractAmount('Amount: Rs. 250.50'), equals(250.50));
    });

    test('parses Rs prefix without dot', () {
      expect(service.extractAmount('Rs 750'), equals(750.0));
    });

    test('parses comma-formatted LKR amount', () {
      expect(service.extractAmount('LKR 1,250.00'), equals(1250.0));
    });

    test('parses "Total" keyword pattern', () {
      expect(service.extractAmount('Total: 850.00'), equals(850.0));
    });

    test('parses "Amount Due" keyword pattern', () {
      expect(service.extractAmount('Amount Due: 320.75'), equals(320.75));
    });

    test('parses "Net Amount" keyword pattern', () {
      expect(service.extractAmount('Net Amount 4,500.00'), equals(4500.0));
    });

    test('parses "Grand Total" keyword pattern', () {
      expect(service.extractAmount('Grand Total 2,000.00'), equals(2000.0));
    });

    test('parses "Payable" keyword pattern', () {
      expect(service.extractAmount('Payable 999.00'), equals(999.0));
    });

    test('parses standalone decimal amount (pattern 3)', () {
      expect(service.extractAmount('593.36'), equals(593.36));
    });

    test('parses comma-grouped standalone amount', () {
      expect(service.extractAmount('1,250.00'), equals(1250.0));
    });

    test('returns first match when multiple amounts present', () {
      // LKR prefix pattern fires first
      final result = service.extractAmount('LKR 500.00 Total 800.00');
      expect(result, equals(500.0));
    });
  });

  // ── decodeBase64 ──────────────────────────────────────────────────────────

  group('decodeBase64()', () {
    test('decodes standard base64 string', () {
      final encoded = base64.encode(utf8.encode('Hello World'));
      expect(service.decodeBase64(encoded), equals('Hello World'));
    });

    test('decodes URL-safe base64 (- and _ substituted)', () {
      // Gmail uses URL-safe base64 (- instead of +, _ instead of /)
      final urlSafe = base64Url.encode(utf8.encode('LKR 1,500.00 receipt'));
      expect(service.decodeBase64(urlSafe), equals('LKR 1,500.00 receipt'));
    });

    test('returns empty string for malformed base64', () {
      expect(service.decodeBase64('!!!not_valid_base64!!!'), equals(''));
    });

    test('returns empty string for empty input', () {
      expect(service.decodeBase64(''), equals(''));
    });

    test('handles UTF-8 content', () {
      final encoded = base64Url.encode(utf8.encode('මුළු මුදල 500'));
      expect(service.decodeBase64(encoded), equals('මුළු මුදල 500'));
    });
  });

  // ── getBody ───────────────────────────────────────────────────────────────

  group('getBody()', () {
    test('returns empty string for null payload', () {
      expect(service.getBody(null), equals(''));
    });

    test('returns empty string when no body data and no parts', () {
      final payload = gmail.MessagePart()..headers = [];
      expect(service.getBody(payload), equals(''));
    });

    test('decodes direct body data', () {
      final payload = gmail.MessagePart()
        ..body = (gmail.MessagePartBody()..data = _gmailBase64('Direct body text'));
      expect(service.getBody(payload), equals('Direct body text'));
    });

    test('prefers text/plain part over text/html', () {
      final payload = gmail.MessagePart()
        ..parts = [
          gmail.MessagePart()
            ..mimeType = 'text/html'
            ..body = (gmail.MessagePartBody()..data = _gmailBase64('<b>HTML</b>')),
          gmail.MessagePart()
            ..mimeType = 'text/plain'
            ..body = (gmail.MessagePartBody()..data = _gmailBase64('Plain text')),
        ];
      expect(service.getBody(payload), equals('Plain text'));
    });

    test('falls back to text/html when no text/plain part', () {
      final payload = gmail.MessagePart()
        ..parts = [
          gmail.MessagePart()
            ..mimeType = 'text/html'
            ..body = (gmail.MessagePartBody()..data = _gmailBase64('<b>HTML body</b>')),
        ];
      expect(service.getBody(payload), equals('<b>HTML body</b>'));
    });

    test('returns empty string when parts exist but none match known mime types', () {
      final payload = gmail.MessagePart()
        ..parts = [
          gmail.MessagePart()
            ..mimeType = 'image/png'
            ..body = (gmail.MessagePartBody()..data = _gmailBase64('binary')),
        ];
      expect(service.getBody(payload), equals(''));
    });
  });

  // ── extractBillData ───────────────────────────────────────────────────────

  group('extractBillData()', () {
    test('returns null when no amount found anywhere', () {
      final message = _makeMessage(subject: 'Hello from support team');
      expect(service.extractBillData(message), isNull);
    });

    test('extracts subject from headers', () {
      final message = _makeMessage(
        subject: 'Order receipt #99',
        plainBody: 'Total: LKR 450.00',
      );
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['subject'], equals('Order receipt #99'));
    });

    test('falls back to "Bill from Gmail" when subject is absent', () {
      final message = _makeMessage(plainBody: 'LKR 300.00');
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['subject'], equals('Bill from Gmail'));
    });

    test('extracts amount from body', () {
      final message = _makeMessage(
        subject: 'Your receipt',
        plainBody: 'Grand Total 1,250.00',
      );
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['amount'], equals(1250.0));
    });

    test('extracts amount from subject when body is empty', () {
      final message = _makeMessage(subject: 'Rs. 750 paid');
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['amount'], equals(750.0));
    });

    test('detects category from subject', () {
      final message = _makeMessage(
        subject: 'Uber Eats order confirmed',
        plainBody: 'Total: LKR 650.00',
      );
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['category'], equals('Food'));
    });

    test('returns null when message has no payload', () {
      final message = gmail.Message()..id = 'x';
      expect(service.extractBillData(message), isNull);
    });

    test('handles message with null id gracefully', () {
      final message = _makeMessage(
        subject: 'Invoice #1',
        plainBody: 'Amount Due: 500.00',
      );
      final result = service.extractBillData(message);
      expect(result, isNotNull);
      expect(result!['amount'], equals(500.0));
    });
  });
}
