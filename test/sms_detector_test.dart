import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vello_app/features/sms_detector/sms_detector_service.dart';
import 'package:vello_app/services/finance_service.dart';

// ── Mock FinanceService ───────────────────────────────────────────────────────

class _MockFinanceService extends FinanceService {
  final List<Map<String, dynamic>> calls = [];

  @override
  Future<void> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required String category,
    required String type,
    required DateTime date,
  }) async {
    calls.add({
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date,
    });
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

SmsMessage _msg({
  int id = 1,
  String? sender = 'TESTBANK',
  String body = '',
  DateTime? date,
}) {
  final d = date ?? DateTime(2024, 6, 1);
  return SmsMessage.fromJson({
    '_id': id,
    'address': sender,
    'body': body,
    'date': d.millisecondsSinceEpoch,
  });
}

Future<SharedPreferences> _freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── detectCategory ──────────────────────────────────────────────────────────
  group('detectCategory', () {
    late SmsDetectorService svc;
    setUp(() => svc = SmsDetectorService());

    test('returns Food for uber eats', () {
      expect(svc.detectCategory('Your Uber Eats order total is LKR 850.00'), 'Food');
    });

    test('returns Food for food keyword', () {
      expect(svc.detectCategory('Payment for food delivery confirmed'), 'Food');
    });

    test('returns Food for restaurant', () {
      expect(svc.detectCategory('restaurant payment debited'), 'Food');
    });

    test('returns Food for grocery', () {
      expect(svc.detectCategory('grocery purchase debited LKR 2,300.00'), 'Food');
    });

    test('returns Food for supermarket', () {
      expect(svc.detectCategory('supermarket payment successful'), 'Food');
    });

    test('returns Transportation for uber (not uber eats)', () {
      expect(svc.detectCategory('Your Uber ride has been debited'), 'Transportation');
    });

    test('returns Transportation for pickme', () {
      expect(svc.detectCategory('PickMe trip payment debited LKR 450.00'), 'Transportation');
    });

    test('returns Transportation for transport', () {
      expect(svc.detectCategory('transport payment charged'), 'Transportation');
    });

    test('returns Transportation for fuel', () {
      expect(svc.detectCategory('fuel purchase debited Rs.5,600'), 'Transportation');
    });

    test('returns Transportation for petrol', () {
      expect(svc.detectCategory('petrol payment of Rs.3,200 debited'), 'Transportation');
    });

    test('returns Bills for electricity', () {
      expect(svc.detectCategory('electricity bill payment debited LKR 4,200'), 'Bills');
    });

    test('returns Bills for water bill', () {
      expect(svc.detectCategory('water bill payment of LKR 1,100 debited'), 'Bills');
    });

    test('returns Bills for internet bill', () {
      expect(svc.detectCategory('internet bill debited Rs.2,999'), 'Bills');
    });

    test('returns Bills for utility', () {
      expect(svc.detectCategory('utility payment debited LKR 3,500'), 'Bills');
    });

    test('returns Bills for dialog', () {
      expect(svc.detectCategory('dialog payment debited LKR 1,499'), 'Bills');
    });

    test('returns Bills for hutch', () {
      expect(svc.detectCategory('hutch bill debited LKR 999'), 'Bills');
    });

    test('returns Bills for slt', () {
      expect(svc.detectCategory('slt broadband bill debited'), 'Bills');
    });

    test('returns Shopping for generic purchase', () {
      expect(svc.detectCategory('payment of LKR 3,500 debited'), 'Shopping');
    });

    test('uber eats takes priority over uber-only check', () {
      // "uber eats" contains "uber" but should be Food, not Transportation
      expect(svc.detectCategory('uber eats delivery debited'), 'Food');
    });
  });

  // ── extractAmount ───────────────────────────────────────────────────────────
  group('extractAmount', () {
    late SmsDetectorService svc;
    setUp(() => svc = SmsDetectorService());

    test('extracts LKR amount', () {
      expect(svc.extractAmount('LKR 1500.00 debited from your account'), 1500.00);
    });

    test('extracts Rs. amount', () {
      expect(svc.extractAmount('Rs.850 charged to your card'), 850.0);
    });

    test('extracts Rs amount without dot', () {
      expect(svc.extractAmount('Rs 2500 debited'), 2500.0);
    });

    test('extracts Sinhala rupee symbol', () {
      expect(svc.extractAmount('රු. 3,200.00 debited'), 3200.0);
    });

    test('extracts amount via "amount" keyword', () {
      expect(svc.extractAmount('amount 4500.00 has been charged'), 4500.0);
    });

    test('extracts amount via "paid" keyword', () {
      expect(svc.extractAmount('paid 750.00 to merchant'), 750.0);
    });

    test('extracts amount via "charged" keyword', () {
      expect(svc.extractAmount('charged 1,200.00 to your account'), 1200.0);
    });

    test('extracts amount via "debit" keyword', () {
      expect(svc.extractAmount('debit 999.00 from account'), 999.0);
    });

    test('extracts comma-formatted amount', () {
      expect(svc.extractAmount('LKR 12,500.00 debited'), 12500.0);
    });

    test('extracts large comma-formatted amount', () {
      expect(svc.extractAmount('LKR 1,250,000.00 debited'), 1250000.0);
    });

    test('returns null for text with no amount', () {
      expect(svc.extractAmount('Your account update notification'), isNull);
    });

    test('returns null for amount <= 10', () {
      expect(svc.extractAmount('LKR 5.00 charged'), isNull);
    });

    test('returns null for empty string', () {
      expect(svc.extractAmount(''), isNull);
    });

    test('extracts decimal amount without leading digits pattern', () {
      expect(svc.extractAmount('Total amount: 350.00'), 350.0);
    });
  });

  // ── isEnabled / setEnabled (SharedPreferences only) ─────────────────────────
  group('isEnabled', () {
    test('returns false when never set', () async {
      SharedPreferences.setMockInitialValues({});
      final svc = SmsDetectorService();
      expect(await svc.isEnabled(), isFalse);
    });

    test('returns true after setMockInitialValues with true', () async {
      SharedPreferences.setMockInitialValues({'sms_detector_enabled': true});
      final svc = SmsDetectorService();
      expect(await svc.isEnabled(), isTrue);
    });

    test('returns false after setMockInitialValues with false', () async {
      SharedPreferences.setMockInitialValues({'sms_detector_enabled': false});
      final svc = SmsDetectorService();
      expect(await svc.isEnabled(), isFalse);
    });
  });

  // ── processMessages ─────────────────────────────────────────────────────────
  group('processMessages', () {
    late _MockFinanceService mockFs;
    late SmsDetectorService svc;

    setUp(() {
      mockFs = _MockFinanceService();
      svc = SmsDetectorService(financeService: mockFs);
    });

    // ── empty input ──────────────────────────────────────────────────────────
    test('returns 0 for empty message list', () async {
      final prefs = await _freshPrefs();
      expect(await svc.processMessages([], prefs, 'u1'), 0);
      expect(mockFs.calls, isEmpty);
    });

    // ── promo filtering ──────────────────────────────────────────────────────
    test('rejects message containing "promo"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Special promo! Get 50% off your next purchase. LKR 500 debited'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
      expect(mockFs.calls, isEmpty);
    });

    test('rejects message containing "offer"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Exclusive offer! LKR 1000 debited for your subscription'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message containing "discount"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'discount applied LKR 500 debited'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message containing "cashback"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'cashback of LKR 200 credited to your account'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message containing "recharge"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'recharge Rs.199 for data package debited'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message containing "free"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Get 1GB free with LKR 500 debited package'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message containing "subscribe"', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'subscribe to our plan LKR 999 debited'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    // ── promo sender filtering ────────────────────────────────────────────────
    test('rejects message from sender containing PROMO', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'DialogPROMO',
          body: 'Your account has been debited LKR 1,500.00. Available balance: LKR 45,000.',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message from sender containing OFFER', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'MobitelOFFER',
          body: 'LKR 500 debited from your account',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    test('rejects message from sender containing DEAL', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'SomeDEAL',
          body: 'LKR 750 debited from your account',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
    });

    // ── transaction signal required ──────────────────────────────────────────
    test('rejects message with amount but no transaction signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Your package LKR 1,500 is on the way!'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
      expect(mockFs.calls, isEmpty);
    });

    test('accepts message with "debited" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Your account has been debited LKR 1,500.00. Available balance: LKR 45,000.'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
      expect(mockFs.calls, hasLength(1));
    });

    test('accepts message with "credited" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'LKR 5,000.00 credited to your account. Balance: LKR 50,000.'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
    });

    test('accepts message with "payment of" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'payment of LKR 3,200.00 was successful. Ref: 123456'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
    });

    test('accepts message with "available balance" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Rs.2,500 charged. Available balance Rs.15,000'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
    });

    test('accepts message with "electricity bill" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'electricity bill payment of LKR 4,200 processed'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
    });

    test('accepts message with "water bill" signal', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'water bill Rs.1,100 debited from your account'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
    });

    // ── amount extraction required ────────────────────────────────────────────
    test('rejects message with transaction signal but no extractable amount', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'Your account has been debited. Please check your balance.'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
      expect(mockFs.calls, isEmpty);
    });

    // ── saved transaction data ────────────────────────────────────────────────
    test('saves correct amount to FinanceService', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'BOC-BANK',
          body: 'LKR 3,750.00 debited from your account',
          date: DateTime(2024, 6, 15),
        ),
      ];
      await svc.processMessages(msgs, prefs, 'user123');
      expect(mockFs.calls.first['amount'], 3750.0);
    });

    test('saves sender as title', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'BOC-BANK',
          body: 'LKR 1,000.00 debited from your account',
        ),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['title'], 'BOC-BANK');
    });

    test('saves userId correctly', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'LKR 500.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'my_user_id');
      expect(mockFs.calls.first['userId'], 'my_user_id');
    });

    test('saves type as expense', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'LKR 500.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['type'], 'expense');
    });

    test('saves message date', () async {
      final date = DateTime(2024, 3, 20);
      final prefs = await _freshPrefs();
      final msgs = [_msg(body: 'LKR 500.00 debited from your account', date: date)];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['date'], date);
    });

    test('uses "SMS Bill" as title when sender is null', () async {
      final prefs = await _freshPrefs();
      // No 'address' key → sender getter returns null
      final msg = SmsMessage.fromJson({
        '_id': 99,
        'body': 'LKR 500.00 debited from your account',
        'date': DateTime(2024, 6, 1).millisecondsSinceEpoch,
      });
      expect(await svc.processMessages([msg], prefs, 'u1'), 1);
      expect(mockFs.calls.first['title'], 'SMS Bill');
    });

    // ── category assignment ───────────────────────────────────────────────────
    test('assigns Food category for food body', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'food delivery LKR 850.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['category'], 'Food');
    });

    test('assigns Transportation category for fuel body', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'fuel purchase LKR 5,600.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['category'], 'Transportation');
    });

    test('assigns Bills category for electricity body', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'electricity bill LKR 4,200.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['category'], 'Bills');
    });

    test('assigns Shopping category for generic body', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'LKR 3,500.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(mockFs.calls.first['category'], 'Shopping');
    });

    // ── duplicate detection ──────────────────────────────────────────────────
    test('skips message with already-seen ID', () async {
      SharedPreferences.setMockInitialValues({
        'sms_detector_seen_ids': ['42'],
      });
      final prefs = await SharedPreferences.getInstance();
      final msgs = [
        _msg(id: 42, body: 'LKR 1,000.00 debited from your account'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 0);
      expect(mockFs.calls, isEmpty);
    });

    test('processes message with new ID and skips one with seen ID', () async {
      SharedPreferences.setMockInitialValues({
        'sms_detector_seen_ids': ['10'],
      });
      final prefs = await SharedPreferences.getInstance();
      final msgs = [
        _msg(id: 10, body: 'LKR 1,000.00 debited from your account'),
        _msg(id: 11, body: 'LKR 2,000.00 debited from your account'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
      expect(mockFs.calls, hasLength(1));
      expect(mockFs.calls.first['amount'], 2000.0);
    });

    test('saves new seen IDs to SharedPreferences after processing', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(id: 5, body: 'LKR 1,000.00 debited from your account'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      final seenIds = prefs.getStringList('sms_detector_seen_ids');
      expect(seenIds, contains('5'));
    });

    test('does not update seen IDs when no messages were saved', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(body: 'promo offer LKR 500 debited'),
      ];
      await svc.processMessages(msgs, prefs, 'u1');
      expect(prefs.getStringList('sms_detector_seen_ids'), isNull);
    });

    // ── multiple messages ─────────────────────────────────────────────────────
    test('processes multiple valid messages', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(id: 1, body: 'LKR 1,000.00 debited from your account'),
        _msg(id: 2, body: 'LKR 2,000.00 debited from your account'),
        _msg(id: 3, body: 'LKR 3,000.00 debited from your account'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 3);
      expect(mockFs.calls, hasLength(3));
    });

    test('filters some and saves others in a mixed batch', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(id: 1, body: 'LKR 1,000.00 debited from your account'),
        _msg(id: 2, body: 'promo offer get LKR 500 debited'),
        _msg(id: 3, body: 'Your package LKR 500 is on the way'),
        _msg(id: 4, body: 'electricity bill LKR 4,200.00 debited'),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 2);
      expect(mockFs.calls, hasLength(2));
    });

    // ── genuine bank SMS samples ──────────────────────────────────────────────
    test('processes genuine BOC debit SMS', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'BOC-BANK',
          body: 'Your A/C No. **1234 has been debited with LKR 12,500.00 on 15/06/2024. '
              'Available balance: LKR 87,450.00. Ref: TXN20240615001',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
      expect(mockFs.calls.first['amount'], 12500.0);
      expect(mockFs.calls.first['category'], 'Shopping');
    });

    test('processes genuine ComBank payment SMS', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'COMBANK',
          body: 'Payment of LKR 3,200.00 debited from your account for dialog bill. '
              'Ref no: PAY123456.',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
      expect(mockFs.calls.first['amount'], 3200.0);
      expect(mockFs.calls.first['category'], 'Bills');
    });

    test('processes genuine utility bill SMS', () async {
      final prefs = await _freshPrefs();
      final msgs = [
        _msg(
          sender: 'LECO',
          body: 'electricity bill of LKR 4,850.00 has been successfully paid. '
              'Account: 123456789.',
        ),
      ];
      expect(await svc.processMessages(msgs, prefs, 'u1'), 1);
      expect(mockFs.calls.first['category'], 'Bills');
    });
  });
}
