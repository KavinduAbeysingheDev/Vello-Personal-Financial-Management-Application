import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/connected_account.dart';

class ConnectedAccountRepository {
  final _client = Supabase.instance.client;

  Future<List<ConnectedAccount>> fetchMyAccounts() async {
    final response = await _client
        .from('connected_accounts')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => ConnectedAccount.fromJson(json)).toList();
  }

  Future<ConnectedAccount> upsertAccount(ConnectedAccount account) async {
    final response = await _client
        .from('connected_accounts')
        .upsert(account.toJson())
        .select()
        .single();
    
    return ConnectedAccount.fromJson(response);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('connected_accounts').delete().eq('id', id);
  }
}
