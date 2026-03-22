import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget.dart';

class BudgetRepository {
  final _client = Supabase.instance.client;

  Future<List<Budget>> fetchBudgets() async {
    final response = await _client
        .from('budgets')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Budget.fromSupabase(json)).toList();
  }

  Future<void> upsertBudget(Budget budget) async {
    await _client.from('budgets').upsert(budget.toSupabase());
  }

  Future<void> deleteBudget(String id) async {
    await _client.from('budgets').delete().eq('id', id);
  }
  
  Future<void> updateSpentAmount(String category, double amount) async {
    // Note: In a real app, this should probably be a database trigger or a more complex sync.
    // Here we find the budget for the category and increment current_spent.
    final budgets = await fetchBudgets();
    final budget = budgets.where((b) => b.category == category).firstOrNull;
    
    if (budget != null) {
      await _client.from('budgets').update({
        'current_spent': budget.currentSpent + amount
      }).eq('id', budget.id);
    }
  }
}
