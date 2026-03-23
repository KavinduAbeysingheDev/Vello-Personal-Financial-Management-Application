import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/app_models.dart';
import '../models/budget.dart';

class BackendService {
  static final _client = http.Client();

  Future<Map<String, dynamic>> generateWeeklyBudgetPlan({
    required double weeklyIncome,
    required List<AppTransaction> fixedExpenses,
    required List<AppTransaction> variableExpenses,
    required double savingsGoal,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ruleAiEndpoint}');
    
    final bodyMap = {
      'weekly_income': weeklyIncome,
      'fixed_expenses': fixedExpenses.map((e) => e.toBackendJson()).toList(),
      'variable_expenses': variableExpenses.map((e) => e.toBackendJson()).toList(),
      'savings_goal': savingsGoal,
    };
    final body = jsonEncode(bodyMap);

    print('🚀 [API Request] POST $url');
    print('📦 [API Body] $body');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 [API Response] Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [API Success] Data: $data');
        return data;
      } else {
        print('❌ [API Error] Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      print('☢️ [API Connection Failed] Error: $e');
      throw Exception('Could not connect to FastAPI backend: $e');
    }
  }
}
