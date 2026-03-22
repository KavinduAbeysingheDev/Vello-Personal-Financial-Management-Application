import 'dart:developer';

class SmsParserService {
  // Common Sri Lankan bank SMS keywords
  static const List<String> transactionKeywords = [
    'rs', 'lkr', 'debited', 'credited', 'spent', 'payment', 
    'purchase', 'txn', 'card', 'account', 'transferred', 'paid',
    'combank', 'hnb', 'sampath', 'boc', 'ndb', 'dfcc', 'seylan'
  ];

  bool isTransactionMessage(String text) {
    if (text.isEmpty) return false;
    final lowerText = text.toLowerCase();
    
    // Check for explicit keywords first
    final hasKeyword = transactionKeywords.any((kw) => lowerText.contains(kw));
    if (!hasKeyword) return false;

    // Additionally check if there's any numeric value (to avoid just info msgs)
    return RegExp(r'\d+').hasMatch(text);
  }

  double? extractAmount(String text) {
    // Advanced regex for LKR formats: 
    // Rs 1,000.00 | RS.1000 | LKR 500 | 5,250.75 LKR
    final patterns = [
      RegExp(r'(?:rs|lkr)\.?\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'([\d,]+\.?\d*)\s*(?:rs|lkr)', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final valueStr = match.group(1)?.replaceAll(',', '') ?? '0';
        final value = double.tryParse(valueStr);
        if (value != null && value > 1) return value; // Ignore very small amounts/noise
      }
    }
    
    // Fallback: look for any number followed by/preceded by "debited" or "spent"
    final fallbackRegex = RegExp(r'(?:debited|spent|paid)\s+(?:of\s+)?([\d,]+\.?\d*)', caseSensitive: false);
    final fallbackMatch = fallbackRegex.firstMatch(text);
    if (fallbackMatch != null) {
      final valueStr = fallbackMatch.group(1)?.replaceAll(',', '') ?? '0';
      return double.tryParse(valueStr);
    }

    return null;
  }

  String extractMerchant(String text) {
    // Look for patterns like "at [Merchant]", "to [Merchant]", "towards [Merchant]"
    final merchantPatterns = [
      RegExp(r'(?:at|to|towards|payment\s+for)\s+([A-Z0-9\s&]{3,25})', caseSensitive: false),
      RegExp(r'paid\s+to\s+([A-Z0-9\s&]{3,25})', caseSensitive: false),
    ];

    for (var pattern in merchantPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final name = match.group(1)?.trim() ?? '';
        if (name.isNotEmpty && !_isGenericTerm(name)) return name;
      }
    }
    
    return 'Unknown Merchant';
  }

  bool _isGenericTerm(String term) {
    final lower = term.toLowerCase();
    const generic = ['your', 'account', 'the', 'rs', 'lkr', 'payment', 'of'];
    return generic.contains(lower);
  }

  String extractCurrency(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('\$')) return 'USD';
    return 'LKR'; // Default for Sri Lanka
  }
}
