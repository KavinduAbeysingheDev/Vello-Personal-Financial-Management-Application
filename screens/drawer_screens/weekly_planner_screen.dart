import 'package:flutter/material.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Planner'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF9F3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0DBE82).withOpacity(0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Color(0xFF0DBE82)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "AI Suggestion: You have \$120 left for entertainment this week. Consider a movie night instead of dining out.",
                      style: TextStyle(color: Color(0xFF004D40)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("This Week's Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _planCard("Monday", "Groceries", "\$80.00"),
                  _planCard("Wednesday", "Gas", "\$40.00"),
                  _planCard("Friday", "Dinner out", "\$60.00"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard(String day, String title, String amount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFF004D40).withOpacity(0.1), child: const Icon(Icons.calendar_today, color: Color(0xFF004D40), size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(day),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
