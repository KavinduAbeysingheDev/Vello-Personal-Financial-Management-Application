import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class DebtRepository {
  final _client = Supabase.instance.client;

  Future<List<Debt>> fetchDebts() async {
    final response = await _client
        .from('debts')
        .select()
        .order('due_date', ascending: true);
    
    return (response as List).map((json) => Debt.fromSupabase(json)).toList();
  }

  Future<void> upsertDebt(Debt debt) async {
    await _client.from('debts').upsert(debt.toSupabase());
  }

  Future<void> deleteDebt(String id) async {
    await _client.from('debts').delete().eq('id', id);
  }
}
