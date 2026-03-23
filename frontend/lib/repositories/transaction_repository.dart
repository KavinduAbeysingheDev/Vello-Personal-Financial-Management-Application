import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class TransactionRepository {
  final _client = Supabase.instance.client;

  Future<List<AppTransaction>> fetchTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .order('transaction_date', ascending: false);
    
    return (response as List).map((json) => AppTransaction.fromSupabase(json)).toList();
  }

  Future<void> insertTransaction(AppTransaction transaction) async {
    await _client.from('transactions').insert(transaction.toSupabase());
  }

  Future<void> insertTransactions(List<AppTransaction> transactions) async {
    final data = transactions.map((t) => t.toSupabase()).toList();
    await _client.from('transactions').insert(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}
