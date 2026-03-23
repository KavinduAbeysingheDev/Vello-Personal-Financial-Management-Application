import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

class SubscriptionRepository {
  final _client = Supabase.instance.client;

  Future<List<Subscription>> fetchSubscriptions() async {
    final response = await _client
        .from('subscriptions')
        .select()
        .order('next_billing_date', ascending: true);
    
    return (response as List).map((json) => Subscription.fromSupabase(json)).toList();
  }

  Future<void> upsertSubscription(Subscription subscription) async {
    await _client.from('subscriptions').upsert(subscription.toSupabase());
  }

  Future<void> deleteSubscription(String id) async {
    await _client.from('subscriptions').delete().eq('id', id);
  }
}
