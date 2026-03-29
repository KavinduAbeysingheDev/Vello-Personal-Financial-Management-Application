import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class SavingsGoalRepository {
  final _client = Supabase.instance.client;

  Future<List<SavingsGoal>> fetchGoals({String? userId}) async {
    final resolvedUserId = userId ?? _client.auth.currentUser?.id;
    if (resolvedUserId == null) return [];

    final response = await _client
        .from('savings_goals')
        .select()
        .eq('user_id', resolvedUserId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => SavingsGoal.fromSupabase(json)).toList();
  }

  Future<void> upsertGoal(SavingsGoal goal) async {
    await _client.from('savings_goals').upsert(goal.toSupabase());
  }

  Future<void> deleteGoal(String id) async {
    await _client.from('savings_goals').delete().eq('id', id);
  }
}
