import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class DetectedBill {
  final String sender;
  final String body;
  final double amount;
  final DateTime? date;

  const DetectedBill({
    required this.sender,
    required this.body,
    required this.amount,
    required this.date,
  });
}

class SmsDetectorService {
  // Gate 1 – promotional / marketing block-list.
  // If any of these patterns match, the message is not a real transaction.
  static final _promoPatterns = [
    RegExp(r'promo', caseSensitive: false),
    RegExp(r'offer', caseSensitive: false),
    RegExp(r'discount', caseSensitive: false),
    RegExp(r'cashback', caseSensitive: false),
    RegExp(r'reward', caseSensitive: false),
    RegExp(r'voucher', caseSensitive: false),
    RegExp(r'coupon', caseSensitive: false),
    RegExp(r'win\b', caseSensitive: false),
    RegExp(r'free\b', caseSensitive: false),
    RegExp(r'lucky', caseSensitive: false),
    RegExp(r'click here', caseSensitive: false),
    RegExp(r'visit\s+(?:our|www)', caseSensitive: false),
    RegExp(r'subscribe', caseSensitive: false),
    RegExp(r'unsubscribe', caseSensitive: false),
    RegExp(r'opt.?out', caseSensitive: false),
    RegExp(r'reply\s+(?:stop|no)', caseSensitive: false),
    RegExp(r'marketing', caseSensitive: false),
    RegExp(r'advertisement', caseSensitive: false),
    RegExp(r'congratulat', caseSensitive: false),
    RegExp(r'selected\s+(?:for|as)', caseSensitive: false),
    RegExp(r'data\s+package', caseSensitive: false),
    RegExp(r'gb\s+for', caseSensitive: false), // "5GB for Rs.99" bundle ads
    RegExp(r'mb\s+for', caseSensitive: false),
    RegExp(r'recharge', caseSensitive: false),
    RegExp(r'top.?up', caseSensitive: false),
    RegExp(r'activate', caseSensitive: false),
    RegExp(r'enjoy\b', caseSensitive: false),
    RegExp(r'valid\s+(?:till|until|for)', caseSensitive: false),
    RegExp(r'expires?\s+(?:on|in)', caseSensitive: false),
  ];

  // Gate 2 – must have at least one strong transaction signal phrase.
  // These are phrases that only appear in genuine payment confirmations.
  static final _transactionPatterns = [
    RegExp(r'\bpayment\s+(?:of|for|received|successful|confirmed)\b', caseSensitive: false),
    RegExp(r'\b(?:debited|credited)\b', caseSensitive: false),
    RegExp(r'\bdebit(?:ed)?\s+(?:of|from|rs\.?|lkr)\b', caseSensitive: false),
    RegExp(r'\bcredit(?:ed)?\s+(?:to|of|rs\.?|lkr)\b', caseSensitive: false),
    RegExp(r'\btransaction\s+(?:of|id|ref|no|successful)\b', caseSensitive: false),
    RegExp(r'\bpurchase\s+(?:of|at|for|confirmed)\b', caseSensitive: false),
    RegExp(r'\bpaid\s+(?:rs\.?|lkr|to)\b', caseSensitive: false),
    RegExp(r'\b(?:rs\.?|lkr)\s*[0-9,]+(?:\.[0-9]{1,2})?\s+(?:debited|credited|paid|charged|deducted)\b', caseSensitive: false),
    RegExp(r'\b(?:debited|credited|charged|deducted)\s+(?:rs\.?|lkr)\b', caseSensitive: false),
    RegExp(r'\bavailable\s+balance\b', caseSensitive: false),
    RegExp(r'\baccount\s+balance\b', caseSensitive: false),
    RegExp(r'\bbal(?:ance)?\s*(?:rs\.?|lkr|:)\b', caseSensitive: false),
    RegExp(r'\binvoice\s+(?:#|no|number|amount)\b', caseSensitive: false),
    RegExp(r'\breceipt\s+(?:#|no|number)\b', caseSensitive: false),
    RegExp(r'\bref(?:erence)?\s*(?:no|#|:)\s*[a-z0-9]+\b', caseSensitive: false),
    RegExp(r'\byour\s+(?:card|account).{0,30}(?:debited|credited|charged)\b', caseSensitive: false),
    RegExp(r'\butil(?:ity)?\s+bill\b', caseSensitive: false),
    RegExp(r'\belectricity\s+bill\b', caseSensitive: false),
    RegExp(r'\bwater\s+bill\b', caseSensitive: false),
    RegExp(r'\binternet\s+bill\b', caseSensitive: false),
  ];

  static const _promoSenderWords = ['PROMO', 'OFFER', 'DEAL', 'ADS', 'ADVERT', 'MARKET'];

  Future<List<DetectedBill>> scanAndStore() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) return [];

    try {
      final SmsQuery query = SmsQuery();
      final List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50,
      );

      final List<DetectedBill> results = [];

      for (final msg in messages) {
        final body = msg.body ?? '';

        // Reject promotional messages immediately.
        if (_promoPatterns.any((p) => p.hasMatch(body))) continue;

        // Require at least one strong transactional signal.
        if (!_transactionPatterns.any((p) => p.hasMatch(body))) continue;

        // Also reject if the sender looks like a promotional alpha-tag
        // (e.g. "DialogPROMO", "MobitelOFFER"). Genuine bank/utility senders
        // are short codes (5-6 digits) or clean alpha-tags without promo words.
        final sender = (msg.sender ?? '').toUpperCase();
        if (_promoSenderWords.any((w) => sender.contains(w))) continue;

        final amount = _extractAmount(body);
        if (amount == null) continue;

        results.add(DetectedBill(
          sender: msg.sender ?? 'Unknown',
          body: body,
          amount: amount,
          date: msg.date,
        ));
      }

      return results;
    } catch (e) {
      debugPrint('SMS Scan Error: $e');
      return [];
    }
  }

  static final _amountPatterns = [
    RegExp(r'(?:LKR|Rs\.?|රු\.?)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false),
    RegExp(r'(?:amount|paid|charged|debit|credit)[^\d]*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false),
    RegExp(r'\b([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2}))\b'),
  ];

  double? _extractAmount(String text) {
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(raw);
        if (value != null && value > 10) return value;
      }
    }
    return null;
  }
}
