import 'dart:io';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../models/raw_import.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/raw_import_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/sync_log_repository.dart';
import 'sms_parser_service.dart';

class SmsImportService {
  final SmsQuery _query = SmsQuery();
  final SmsParserService _parser = SmsParserService();
  final RawImportRepository _rawRepo = RawImportRepository();
  final TransactionRepository _txRepo = TransactionRepository();
  final SyncLogRepository _syncRepo = SyncLogRepository();
  final _uuid = const Uuid();

  Future<void> importSmsTransactions(String userId) async {
    // 1. Android-only platform guard
    if (!Platform.isAndroid) return;

    // 2. Request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) return;
    }

    // 3. Start Sync Log
    final syncId = await _syncRepo.startSync(userId, 'sms');
    int scanned = 0;
    int imported = 0;

    try {
      // 4. Read inbox SMS
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 100, // Sync last 100 messages for MVP
      );

      for (var msg in messages) {
        scanned++;
        final body = msg.body ?? '';
        final externalId = msg.id?.toString() ?? _uuid.v4();

        // 5. Filter likely finance messages
        if (!_parser.isTransactionMessage(body)) continue;

        // 6. Deduplicate
        final exists = await _rawRepo.exists('sms', externalId);
        if (exists) continue;

        // 7. Parse and Insert
        final amount = _parser.extractAmount(body);
        final merchant = _parser.extractMerchant(body);
        final currency = _parser.extractCurrency(body);
        final date = msg.date ?? DateTime.now();

        // Check if message implies an OUTGOING (debit) or INCOMING (credit) transaction
        // Traditional bank alerts: "Rs. X debited" = expense. "Rs. X credited" = income.
        final isCredit = body.toLowerCase().contains('credited') || body.toLowerCase().contains('received');
        final finalAmount = isCredit ? (amount ?? 0) : -(amount ?? 0);

        final rawId = await _rawRepo.insertRawImport(RawImport(
          userId: userId,
          sourceType: 'sms',
          externalId: externalId,
          sender: msg.address,
          rawText: body,
          transactionDate: date,
        ));

        await _txRepo.insertTransaction(AppTransaction(
          id: _uuid.v4(),
          userId: userId,
          rawImportId: rawId,
          sourceType: 'sms',
          title: merchant,
          category: 'SMS Import',
          amount: finalAmount.toDouble(),
          date: date,
          type: isCredit ? TransactionType.income : TransactionType.expense,
          icon: Icons.sms,
        ));

        imported++;
      }

      // 8. Finalize Sync Log
      await _syncRepo.updateSync(syncId, 
        status: 'success', 
        message: 'Imported $imported transactions from $scanned SMS messages.',
        scanned: scanned,
        imported: imported,
      );
    } catch (e) {
      await _syncRepo.updateSync(syncId, 
        status: 'error', 
        message: e.toString(),
        scanned: scanned,
        imported: imported,
      );
    }
  }
}
