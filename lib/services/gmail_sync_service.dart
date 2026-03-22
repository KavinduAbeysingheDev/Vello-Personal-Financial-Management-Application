import 'package:uuid/uuid.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../repositories/sync_log_repository.dart';
import '../repositories/raw_import_repository.dart';
import '../repositories/transaction_repository.dart';
import '../models/app_models.dart';
import '../models/raw_import.dart';
import 'sms_parser_service.dart'; // Re-use the smart parser logic

class GmailSyncService {
  final SyncLogRepository _syncRepo = SyncLogRepository();
  final RawImportRepository _rawRepo = RawImportRepository();
  final TransactionRepository _txRepo = TransactionRepository();
  final SmsParserService _parser = SmsParserService(); // Re-using amount/merchant regex
  final _uuid = const Uuid();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '396040336267-nnrfode235hjk7hknrod2nq7bppjpv7b.apps.googleusercontent.com',
    scopes: ['https://www.googleapis.com/auth/gmail.readonly'],
  );

  Future<void> triggerGmailSync(String userId) async {
    // 1. Start Sync Log
    final syncId = await _syncRepo.startSync(userId, 'gmail');
    
    int scanned = 0;
    int imported = 0;

    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) throw Exception('Gmail not connected. Please connect first.');

      final authHeaders = await account.authHeaders;
      final httpClient = GoogleAuthClient(authHeaders);
      final gmailApi = GmailApi(httpClient);

      // 2. Search for recent financial emails
      // Query for receipts, orders, payments in the last 7 days, including purchase category
      final query = 'label:inbox (category:purchases OR purchase OR receipt OR payment OR order OR billing) after:${DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000}';
      final listResponse = await gmailApi.users.messages.list('me', q: query);
      
      if (listResponse.messages != null) {
        for (var msgRef in listResponse.messages!) {
          scanned++;
          final msg = await gmailApi.users.messages.get('me', msgRef.id!);
          final body = msg.snippet ?? ''; // For MVP we use snippet, full body parsing would be better but complex
          final externalId = msg.id!;

          // 3. Deduplicate
          final exists = await _rawRepo.exists('gmail', externalId);
          if (exists) continue;

          // 4. Parse (using snippet for now)
          final amount = _parser.extractAmount(body);
          final merchant = _parser.extractMerchant(body);
          final date = DateTime.fromMillisecondsSinceEpoch(int.parse(msg.internalDate!));

          if (amount != null && amount > 0) {
            final rawId = await _rawRepo.insertRawImport(RawImport(
              userId: userId,
              sourceType: 'gmail',
              externalId: externalId,
              subject: body.length > 50 ? body.substring(0, 50) : body,
              rawText: body,
              transactionDate: date,
            ));

            await _txRepo.insertTransaction(AppTransaction(
              id: _uuid.v4(),
              userId: userId,
              rawImportId: rawId,
              sourceType: 'gmail',
              title: merchant == 'Unknown Merchant' ? 'Gmail Transaction' : merchant,
              category: 'Shopping',
              amount: -amount, // Most gmail receipts are expenses
              date: date,
              type: TransactionType.expense,
              icon: Icons.email_outlined,
            ));
            imported++;
          }
        }
      }

      // 5. Update Sync Log
      await _syncRepo.updateSync(syncId, 
        status: 'success', 
        message: 'Imported $imported transactions from $scanned Gmail messages.',
        scanned: scanned, 
        imported: imported,
      );
    } catch (e) {
      await _syncRepo.updateSync(syncId, 
        status: 'error', 
        message: e.toString(),
      );
    }
  }

  // Initial sync logic placeholder
  Future<void> performInitialSync(String userId) async {
    await triggerGmailSync(userId);
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  
  GoogleAuthClient(this._headers);
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
