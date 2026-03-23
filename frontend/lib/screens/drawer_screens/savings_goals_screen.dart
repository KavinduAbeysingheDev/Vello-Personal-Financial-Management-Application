import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String selectedEmoji = '🎯';
    final emojis = ['🎯', '💻', '✈️', '🏠', '🚗', '💍', '📱', '🛡️', '🎓', '💰'];
    final colors = [
      const Color(0xFF4A84E8),
      const Color(0xFF00C853),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
    ];
    Color selectedColor = colors[0];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Savings Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (\$)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Pick an emoji', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setDialogState(() => selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: selectedEmoji == e ? const Color(0xFFEAF9F3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedEmoji == e ? Border.all(color: const Color(0xFF0AA36C)) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Pick a color', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: colors.map((c) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selectedColor == c ? Border.all(color: Colors.black, width: 2) : null,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
              onPressed: () {
                if (titleController.text.isEmpty) return;
                final target = double.tryParse(targetController.text) ?? 0;
                if (target <= 0) return;
                Provider.of<AppProvider>(context, listen: false).addSavingsGoal(
                  SavingsGoal(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    targetAmount: target,
                    iconStr: selectedEmoji,
                    color: selectedColor,
                  ),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add to "${goal.title}"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Amount to add (\$)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;
              Provider.of<AppProvider>(context, listen: false).updateSavingsGoalProgress(goal.id, amount);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = Provider.of<AppProvider>(context).savingsGoals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: goals.isEmpty
          ? const Center(child: Text('No goals yet. Tap + to add one!', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
                return GestureDetector(
                  onTap: () => _showAddProgressDialog(context, goal),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: goal.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text(goal.iconStr, style: const TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(goal.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% complete',
                              style: TextStyle(fontSize: 12, color: goal.color, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Tap to add funds',
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004D40),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddGoalDialog(context),
      ),
    );
  }
}
