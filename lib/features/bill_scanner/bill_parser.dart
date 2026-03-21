import 'dart:convert';
import 'package:flutter/foundation.dart';

class BillItem {
  final String name;
  final double price;
  const BillItem({required this.name, required this.price});
}

class BillScanResult {
  final List<BillItem> items;
  final double total;
  const BillScanResult({required this.items, required this.total});
}

/// Pure parsing logic, free of platform dependencies — fully unit-testable.
class BillParser {
  static final _amountRegExp =
      RegExp(r'\d{1,3}(?:,\s*\d{3})*(?:\.\s*\d{1,2})?');

  static const _keywords = [
    'net amount', 'net total', 'grand total', 'total', 'payable',
    'card -', 'card-', 'cash -', 'cash-',
    'මුළු', 'මුලු', 'එකතුව', 'ගෙවිය යුතු', 'සේවිය යුතු',
  ];

  /// Parses a Groq JSON response string into a [BillScanResult].
  /// Falls back to [ocrFallback] on malformed JSON or empty items.
  BillScanResult? parseGroqResponse(String content, String ocrText) {
    try {
      final cleaned = content
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final rawItems = json['items'] as List<dynamic>? ?? [];

      final items = rawItems
          .whereType<Map<String, dynamic>>()
          .where((e) => e['name'] != null && e['price'] != null)
          .map((e) => BillItem(
                name: e['name'].toString().trim(),
                price: (e['price'] as num).toDouble(),
              ))
          .where((item) => item.name.isNotEmpty && item.price > 0)
          .toList();

      if (items.isEmpty) return ocrFallback(ocrText);

      final rawTotal = (json['total'] as num?)?.toDouble();
      final total = (rawTotal != null && rawTotal > 0)
          ? rawTotal
          : items.fold(0.0, (sum, item) => sum + item.price);

      return BillScanResult(items: items, total: total);
    } catch (e) {
      debugPrint('Parse Error: $e');
      return ocrFallback(ocrText);
    }
  }

  /// Regex-based fallback parser for when the AI call fails or returns nothing.
  BillScanResult? ocrFallback(String text) {
    final lines = text.split('\n');

    // Pass 1: look for a keyword-labelled total on the same line or nearby.
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (_keywords.any((kw) => lower.contains(kw))) {
        for (final m in _amountRegExp.allMatches(lines[i])) {
          final val = _parseAmount(m.group(0)!);
          if (val != null && val > 10) return singleItemResult(val);
        }
        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          for (final m in _amountRegExp.allMatches(lines[j])) {
            final val = _parseAmount(m.group(0)!);
            if (val != null && val > 10) return singleItemResult(val);
          }
        }
      }
    }

    // Pass 2: collect all amounts, then use the cash/change pattern.
    final List<double> allAmounts = [];
    for (final line in lines) {
      for (final m in _amountRegExp.allMatches(line)) {
        final val = _parseAmount(m.group(0)!);
        if (val != null && val > 10) allAmounts.add(val);
      }
    }

    final roundNumbers =
        allAmounts.where((v) => v % 100 == 0 && v >= 100).toList();
    if (roundNumbers.isNotEmpty && allAmounts.length >= 2) {
      final cashGiven = roundNumbers.reduce((a, b) => a > b ? a : b);
      final idx = allAmounts.lastIndexOf(cashGiven);
      if (idx > 0) return singleItemResult(allAmounts[idx - 1]);
    }

    // Pass 3: last resort — return the largest amount found.
    final largest = allAmounts.isNotEmpty
        ? allAmounts.reduce((a, b) => a > b ? a : b)
        : 0.0;
    return largest > 0 ? singleItemResult(largest) : null;
  }

  BillScanResult singleItemResult(double amount) => BillScanResult(
        items: [BillItem(name: 'Bill Total', price: amount)],
        total: amount,
      );

  double? _parseAmount(String raw) =>
      double.tryParse(raw.replaceAll(' ', '').replaceAll(',', ''));
}
