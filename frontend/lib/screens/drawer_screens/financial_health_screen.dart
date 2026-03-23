import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';

class FinancialHealthScreen extends StatelessWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    
    // 1. Savings Rate Metric (0-10)
    double savingsRateScore = (provider.savingsRate / 10).clamp(0.0, 10.0);
    
    // 2. Emergency Fund Metric (0-10)
    double emergencyFundScore = 0;
    if (provider.savingsGoals.isNotEmpty) {
      double totalProgress = provider.savingsGoals.fold(0.0, (sum, g) => sum + (g.currentAmount / g.targetAmount));
      emergencyFundScore = (totalProgress / provider.savingsGoals.length * 10).clamp(0.0, 10.0);
    }

    // 3. Debt-to-Income Metric (0-10)
    double totalDebt = provider.debts.fold(0.0, (sum, d) => sum + (d.totalAmount - d.paidAmount));
    double dtiScore = 10.0;
    if (provider.totalIncome > 0) {
      dtiScore = (10 - (totalDebt / provider.totalIncome * 10)).clamp(0.0, 10.0);
    } else if (totalDebt > 0) {
      dtiScore = 0;
    }

    // 4. Budget Discipline (0-10)
    double budgetScore = 10.0;
    if (provider.budgets.isNotEmpty) {
      int overspentCount = provider.budgets.where((b) => b.isOverspent).length;
      budgetScore = (10 - (overspentCount / provider.budgets.length * 10)).clamp(0.0, 10.0);
    }

    double overallScore = ((savingsRateScore + emergencyFundScore + dtiScore + budgetScore) / 4) * 10;
    String rating = _getRating(overallScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF0AA36C),
                 borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text("Overall Score", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("${overallScore.toInt()}/100", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(rating, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _healthMetric("Emergency Fund", "${emergencyFundScore.toStringAsFixed(1)}/10", Icons.shield, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _healthMetric("Savings Rate", "${savingsRateScore.toStringAsFixed(1)}/10", Icons.trending_up, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _healthMetric("Debt Health", "${dtiScore.toStringAsFixed(1)}/10", Icons.balance, Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _healthMetric("Budget Control", "${budgetScore.toStringAsFixed(1)}/10", Icons.assignment_turned_in, Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getTip(overallScore),
                      style: const TextStyle(color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRating(double score) {
    if (score >= 90) return "Excellent";
    if (score >= 75) return "Good";
    if (score >= 50) return "Fair";
    return "Needs Attention";
  }

  String _getTip(double score) {
    if (score >= 90) return "You're in the top 5% of users with your financial habits! Keep up the great work.";
    if (score >= 75) return "You're doing well! Try to boost your emergency fund even further.";
    if (score >= 50) return "You're on the right track. Consider setting more specific budget limits.";
    return "Focus on reducing expenses and tracking every transaction to improve your score.";
  }

  Widget _healthMetric(String title, String score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
