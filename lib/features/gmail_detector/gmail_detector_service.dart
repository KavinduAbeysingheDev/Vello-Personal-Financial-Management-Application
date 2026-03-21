import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/finance_service.dart';

class GmailDetectorService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  GoogleSignInAccount? _currentUser;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      debugPrint('Gmail Sign In Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  bool get isSignedIn => _currentUser != null;

  Future<void> setEnabled(bool enabled) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
    await _firestore.collection('user_settings').doc(userId).set({
      'gmail_detector_enabled': enabled,
    }, SetOptions(merge: true));

    if (enabled) {
      // Always force sign in dialog — don't use silent sign in
      await _googleSignIn.signOut(); // clear cached account first
      final signedIn = await signIn();
      if (signedIn) {
        await scanAndStore();
      }
    } else {
      await signOut();
    }
  }

  Future<bool> isEnabled() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
    final doc = await _firestore.collection('user_settings').doc(userId).get();
    return doc.data()?['gmail_detector_enabled'] as bool? ?? false;
  }

  Future<int> scanAndStore() async {
    _currentUser ??= await _googleSignIn.signInSilently();
    if (_currentUser == null) return 0;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';

    final client = _AuthenticatedClient(await _currentUser!.authHeaders);
    try {
      final gmailApi = gmail.GmailApi(client);

      const query = 'category:purchases newer_than:30d';

      final messages = await gmailApi.users.messages.list(
        'me',
        q: query,
        maxResults: 50,
      );

      if (messages.messages == null) return 0;

      int savedCount = 0;

      for (final msg in messages.messages!.take(20)) {
        if (msg.id == null) continue;
        final detail = await gmailApi.users.messages.get('me', msg.id!);
        final extracted = extractBillData(detail);

        if (extracted != null) {
          final existing = await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: userId)
              .where('source', isEqualTo: 'gmail')
              .where('sourceId', isEqualTo: msg.id)
              .get();

          if (existing.docs.isEmpty) {
            await FinanceService().addTransaction(
              userId: userId,
              title: extracted['subject'] as String,
              amount: extracted['amount'] as double,
              category: extracted['category'] as String,
              type: 'expense',
              date: DateTime.now(),
            );
            savedCount++;
          }
        }
      }

      return savedCount;
    } catch (e) {
      debugPrint('Gmail Scan Error: $e');
      return 0;
    } finally {
      client.close();
    }
  }

  @visibleForTesting
  Map<String, dynamic>? extractBillData(gmail.Message message) {
    String subject = '';

    final headers = message.payload?.headers ?? [];
    for (final header in headers) {
      if (header.name == 'Subject') {
        subject = header.value ?? '';
      }
    }

    final body = getBody(message.payload);

    final amount = extractAmount(body.isNotEmpty ? body : subject);
    if (amount == null) return null;

    return {
      'subject': subject.isNotEmpty ? subject : 'Bill from Gmail',
      'amount': amount,
      'category': detectCategory(subject),
    };
  }

  @visibleForTesting
  String detectCategory(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('uber eats') ||
        s.contains('food') ||
        s.contains('restaurant') ||
        s.contains('eats')) {
      return 'Food';
    }
    if (s.contains('uber') ||
        s.contains('pickme') ||
        s.contains('transport')) {
      return 'Transportation';
    }
    if (s.contains('order') ||
        s.contains('receipt') ||
        s.contains('purchase') ||
        s.contains('google play') ||
        s.contains('invoice')) {
      return 'Shopping';
    }
    if (s.contains('electric') ||
        s.contains('water') ||
        s.contains('internet') ||
        s.contains('dialog') ||
        s.contains('hutch') ||
        s.contains('slt')) {
      return 'Bills';
    }
    return 'Shopping';
  }

  @visibleForTesting
  String getBody(gmail.MessagePart? payload) {
    if (payload == null) return '';
    if (payload.body?.data != null) {
      return decodeBase64(payload.body!.data!);
    }
    if (payload.parts != null) {
      for (final part in payload.parts!) {
        if (part.mimeType == 'text/plain' && part.body?.data != null) {
          return decodeBase64(part.body!.data!);
        }
      }
      for (final part in payload.parts!) {
        if (part.mimeType == 'text/html' && part.body?.data != null) {
          return decodeBase64(part.body!.data!);
        }
      }
    }
    return '';
  }

  @visibleForTesting
  String decodeBase64(String data) {
    try {
      // base64Url.normalize adds missing '=' padding; decode handles URL-safe chars
      final bytes = base64Url.decode(base64Url.normalize(data));
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      return '';
    }
  }

  @visibleForTesting
  double? extractAmount(String text) {
    if (text.isEmpty) return null;
    final patterns = [
      RegExp(
        r'(?:LKR|Rs\.?|රු\.?)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:total|amount\s*due|net\s*amount|grand\s*total|payable)[^\d]*([0-9,]+(?:\.[0-9]{1,2})?)',
        caseSensitive: false,
      ),
      RegExp(r'\b([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2}))\b'),
    ];
    for (final pattern in patterns) {
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

class _AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}