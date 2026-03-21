import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:vello_app/features/bill_scanner/bill_parser.dart';
import 'package:vello_app/features/bill_scanner/bill_scanner_service.dart';

void main() {
  // Initialise dotenv so BillScannerService._groqApiKey doesn't throw.
  setUpAll(() => dotenv.loadFromString(envString: 'GROQ_API_KEY=test_key'));
  // ─── BillItem ────────────────────────────────────────────────────────────

  group('BillItem', () {
    test('stores name and price correctly', () {
      const item = BillItem(name: 'Rice', price: 50.0);
      expect(item.name, 'Rice');
      expect(item.price, 50.0);
    });
  });

  // ─── BillScanResult ──────────────────────────────────────────────────────

  group('BillScanResult', () {
    test('stores items and total correctly', () {
      const items = [BillItem(name: 'Rice', price: 50.0)];
      const result = BillScanResult(items: items, total: 50.0);
      expect(result.items, items);
      expect(result.total, 50.0);
    });

    test('items list can contain multiple entries', () {
      const items = [
        BillItem(name: 'Rice', price: 50.0),
        BillItem(name: 'Sugar', price: 75.0),
      ];
      const result = BillScanResult(items: items, total: 125.0);
      expect(result.items.length, 2);
      expect(result.total, 125.0);
    });
  });

  // ─── BillParser ──────────────────────────────────────────────────────────

  group('BillParser', () {
    late BillParser parser;

    setUp(() => parser = BillParser());

    // ── parseGroqResponse ─────────────────────────────────────────────────

    group('parseGroqResponse', () {
      test('parses valid JSON with items and total', () {
        const json =
            '{"items":[{"name":"Rice","price":50.0},{"name":"Sugar","price":75.0}],"total":125.0}';
        final result = parser.parseGroqResponse(json, '');

        expect(result, isNotNull);
        expect(result!.items.length, 2);
        expect(result.items[0].name, 'Rice');
        expect(result.items[0].price, 50.0);
        expect(result.items[1].name, 'Sugar');
        expect(result.items[1].price, 75.0);
        expect(result.total, 125.0);
      });

      test('falls back to sum of items when total is absent', () {
        const json =
            '{"items":[{"name":"Rice","price":50.0},{"name":"Sugar","price":75.0}]}';
        final result = parser.parseGroqResponse(json, '');

        expect(result, isNotNull);
        expect(result!.total, closeTo(125.0, 0.001));
      });

      test('falls back to sum of items when total is zero', () {
        const json =
            '{"items":[{"name":"Rice","price":50.0}],"total":0}';
        final result = parser.parseGroqResponse(json, '');

        expect(result!.total, 50.0);
      });

      test('strips markdown ```json code fences before parsing', () {
        const json =
            '```json\n{"items":[{"name":"Rice","price":50.0}],"total":50.0}\n```';
        final result = parser.parseGroqResponse(json, '');

        expect(result, isNotNull);
        expect(result!.items.length, 1);
        expect(result.total, 50.0);
      });

      test('strips plain ``` code fences before parsing', () {
        const json =
            '```\n{"items":[{"name":"Rice","price":50.0}],"total":50.0}\n```';
        final result = parser.parseGroqResponse(json, '');

        expect(result, isNotNull);
        expect(result!.total, 50.0);
      });

      test('falls back to ocrFallback on malformed JSON', () {
        final result =
            parser.parseGroqResponse('not valid json {{', 'Total 500.00');

        expect(result, isNotNull);
        expect(result!.total, 500.0);
      });

      test('falls back to ocrFallback when items list is empty', () {
        const json = '{"items":[],"total":100.0}';
        final result = parser.parseGroqResponse(json, 'Total 100.00');

        expect(result, isNotNull);
        expect(result!.total, 100.0);
      });

      test('filters out items with zero price', () {
        const json =
            '{"items":[{"name":"Valid","price":50.0},{"name":"Zero","price":0}],"total":50.0}';
        final result = parser.parseGroqResponse(json, '');

        expect(result!.items.length, 1);
        expect(result.items[0].name, 'Valid');
      });

      test('filters out items with negative price', () {
        const json =
            '{"items":[{"name":"Valid","price":50.0},{"name":"Neg","price":-5.0}],"total":50.0}';
        final result = parser.parseGroqResponse(json, '');

        expect(result!.items.length, 1);
        expect(result.items[0].name, 'Valid');
      });

      test('trims whitespace from item names', () {
        const json =
            '{"items":[{"name":"  Rice  ","price":50.0}],"total":50.0}';
        final result = parser.parseGroqResponse(json, '');

        expect(result!.items[0].name, 'Rice');
      });

      test('returns null when items are empty and ocrFallback also finds nothing', () {
        const json = '{"items":[],"total":100.0}';
        final result =
            parser.parseGroqResponse(json, 'no prices here at all');

        expect(result, isNull);
      });
    });

    // ── ocrFallback ───────────────────────────────────────────────────────

    group('ocrFallback', () {
      test('extracts amount from line containing "total" keyword', () {
        const text =
            'Item A 50.00\nItem B 75.00\nTotal 125.00\nCash Given 200.00\nBalance 75.00';
        final result = parser.ocrFallback(text);

        expect(result, isNotNull);
        expect(result!.total, 125.0);
      });

      test('extracts amount from line containing "grand total" keyword', () {
        const text = 'Grand Total 250.00\nCash 300.00\nChange 50.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 250.0);
      });

      test('extracts amount from line containing "net amount" keyword', () {
        const text = 'Net Amount 180.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 180.0);
      });

      test('extracts amount from line containing "payable" keyword', () {
        const text = 'Amount Payable 90.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 90.0);
      });

      test('extracts amount from next line when keyword line has no amount', () {
        const text = 'Total\n330.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 330.0);
      });

      test('uses cash/balance pattern to identify total (no keyword)', () {
        // 593.36 is total, 1000.00 is cash given (round), 406.64 is change.
        // The regex matches '100' from '1000.00' (no-comma form), which is
        // >=100 and divisible by 100, so it acts as the cash-given marker.
        const text = '593.36\n1000.00\n406.64';
        final result = parser.ocrFallback(text);

        expect(result, isNotNull);
        expect(result!.total, 593.36);
      });

      test('cash/balance pattern picks amount before largest round number', () {
        const text = '845.50\n1000.00\n154.50';
        final result = parser.ocrFallback(text);

        expect(result!.total, 845.50);
      });

      test('returns largest amount as last resort when no pattern matches', () {
        // No keyword, no round-hundred cash marker → largest wins.
        const text = '45.50\n67.25\n32.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 67.25);
      });

      test('handles comma-formatted amounts', () {
        const text = 'Total 1,250.00';
        final result = parser.ocrFallback(text);

        expect(result!.total, 1250.0);
      });

      test('returns null when text has no amounts', () {
        final result = parser.ocrFallback('No prices here at all');

        expect(result, isNull);
      });

      test('returns null when all amounts are <= 10', () {
        final result = parser.ocrFallback('Price: 5.00\nQty: 3.00');

        expect(result, isNull);
      });

      test('result is a single-item BillScanResult with name "Bill Total"', () {
        final result = parser.ocrFallback('Total 99.00');

        expect(result!.items.length, 1);
        expect(result.items[0].name, 'Bill Total');
        expect(result.items[0].price, 99.0);
      });
    });

    // ── singleItemResult ──────────────────────────────────────────────────

    group('singleItemResult', () {
      test('creates result with one item named "Bill Total" and matching total', () {
        final result = parser.singleItemResult(500.0);

        expect(result.items.length, 1);
        expect(result.items[0].name, 'Bill Total');
        expect(result.items[0].price, 500.0);
        expect(result.total, 500.0);
      });
    });
  });

  // ─── BillScannerService — HTTP layer ─────────────────────────────────────

  group('BillScannerService - HTTP', () {
    /// Wraps a Groq-style JSON content string in the full API response envelope.
    String groqEnvelope(String content) => jsonEncode({
          'choices': [
            {
              'message': {'content': content}
            }
          ],
        });

    test('returns BillScanResult on a successful 200 response', () async {
      final client = MockClient((_) async => http.Response(
            groqEnvelope(
                '{"items":[{"name":"Tea","price":120.0}],"total":120.0}'),
            200,
          ));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Tea 120.00');

      expect(result, isNotNull);
      expect(result!.items.length, 1);
      expect(result.items[0].name, 'Tea');
      expect(result.total, 120.0);
      service.dispose();
    });

    test('falls back to ocrFallback on HTTP 401 error', () async {
      final client = MockClient(
          (_) async => http.Response('{"error":"Unauthorized"}', 401));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Total 250.00');

      expect(result, isNotNull);
      expect(result!.total, 250.0);
      service.dispose();
    });

    test('falls back to ocrFallback on HTTP 500 error', () async {
      final client = MockClient(
          (_) async => http.Response('{"error":"Internal Server Error"}', 500));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Total 350.00');

      expect(result, isNotNull);
      expect(result!.total, 350.0);
      service.dispose();
    });

    test('falls back to ocrFallback on network exception', () async {
      final client =
          MockClient((_) async => throw Exception('Network error'));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Total 400.00');

      expect(result, isNotNull);
      expect(result!.total, 400.0);
      service.dispose();
    });

    test('falls back to ocrFallback when Groq returns malformed JSON in content', () async {
      final client = MockClient((_) async => http.Response(
            groqEnvelope('not valid json {{'),
            200,
          ));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Total 175.00');

      expect(result, isNotNull);
      expect(result!.total, 175.0);
      service.dispose();
    });

    test('returns null when HTTP fails and ocrFallback also finds nothing', () async {
      final client = MockClient(
          (_) async => http.Response('{"error":"fail"}', 503));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('no prices here');

      expect(result, isNull);
      service.dispose();
    });

    test('parses multi-item response correctly', () async {
      final client = MockClient((_) async => http.Response(
            groqEnvelope(
                '{"items":[{"name":"Milk","price":80.0},{"name":"Bread","price":45.0},{"name":"Eggs","price":60.0}],"total":185.0}'),
            200,
          ));

      final service = BillScannerService(httpClient: client);
      final result =
          await service.extractItemsFromText('Milk 80\nBread 45\nEggs 60');

      expect(result!.items.length, 3);
      expect(result.total, 185.0);
      service.dispose();
    });

    test('strips markdown fences from Groq response before parsing', () async {
      final client = MockClient((_) async => http.Response(
            groqEnvelope(
                '```json\n{"items":[{"name":"Coffee","price":55.0}],"total":55.0}\n```'),
            200,
          ));

      final service = BillScannerService(httpClient: client);
      final result = await service.extractItemsFromText('Coffee 55.00');

      expect(result!.items[0].name, 'Coffee');
      expect(result.total, 55.0);
      service.dispose();
    });
  });
}
