import 'package:flutter/material.dart';

class FinancialHealthScreen extends StatelessWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Column(
                children: [
                  Text("Overall Score", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("94/100", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Excellent", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _healthMetric("Emergency Fund", "9.5/10", Icons.shield, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _healthMetric("Savings Rate", "9.2/10", Icons.trending_up, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _healthMetric("Debt-to-Income", "9.8/10", Icons.balance, Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _healthMetric("Credit Score", "9.4/10", Icons.credit_score, Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 30),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "You're in the top 5% of users with your financial habits! Keep up the great work.",
                      style: TextStyle(color: Colors.black87, height: 1.4),
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
