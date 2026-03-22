import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sync_log.dart';

class SyncLogRepository {
  final _client = Supabase.instance.client;

  Future<String> startSync(String userId, String sourceType) async {
    final response = await _client
        .from('sync_logs')
        .insert({
          'user_id': userId,
          'source_type': sourceType,
          'status': 'in_progress',
          'started_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();
    
    return response['id'];
  }

  Future<void> updateSync(String id, {String? status, String? message, int? scanned, int? imported}) async {
    await _client.from('sync_logs').update({
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (scanned != null) 'items_scanned': scanned,
      if (imported != null) 'items_imported': imported,
      if (status == 'success' || status == 'error') 'finished_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
