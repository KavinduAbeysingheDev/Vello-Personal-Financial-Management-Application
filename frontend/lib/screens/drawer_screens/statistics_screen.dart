import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          final transactions = provider.transactions.where((t) => 
            t.type == TransactionType.expense && 
            t.date.month == now.month && 
            t.date.year == now.year
          ).toList();

          if (transactions.isEmpty) {
            return const Center(child: Text('No expenses found for this month.', style: TextStyle(color: Colors.grey)));
          }

          // Group by category
          final categoryTotals = <String, double>{};
          for (var t in transactions) {
            categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
          }

          final total = categoryTotals.values.fold<double>(0, (sum, val) => sum + val);
          
          // Sort and slice top 5
          final sortedEntries = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final colors = [
            const Color(0xFFFF1744),
            const Color(0xFF0DA66E),
            const Color(0xFF4A84E8),
            const Color(0xFFFF9800),
            const Color(0xFF9C27B0),
            const Color(0xFFE91E63),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Monthly Spending Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(sortedEntries.length, (i) {
                        final entry = sortedEntries[i];
                        final percent = (entry.value / total * 100);
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: entry.value,
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: 70,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(sortedEntries.length, (i) {
                  final entry = sortedEntries[i];
                  return _legendItem(
                    colors[i % colors.length],
                    entry.key,
                    "\$${entry.value.toStringAsFixed(2)}"
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legendItem(Color color, String title, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
