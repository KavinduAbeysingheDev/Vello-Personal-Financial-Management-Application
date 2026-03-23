import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_provider.dart';
import '../../models/budget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  void _showAddBudgetDialog(BuildContext context) {
    final limitController = TextEditingController();
    String? selectedCategory;
    final categories = ['Food', 'Transport', 'Shopping', 'Housing', 'Entertainment', 'Health', 'Bills', 'Groceries', 'Education', 'Other'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Spending Budget', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setDialogState(() => selectedCategory = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Limit (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
              onPressed: () {
                if (selectedCategory == null) return;
                final limit = double.tryParse(limitController.text) ?? 0;
                if (limit <= 0) return;

                Provider.of<AppProvider>(context, listen: false).addBudget(
                  Budget(
                    id: const Uuid().v4(),
                    category: selectedCategory!,
                    amountLimit: limit,
                  ),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final budgets = provider.budgets;

          if (budgets.isEmpty) {
            return const Center(
              child: Text(
                'No budgets set.\nTap + to create a spending limit.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final progress = budget.usagePercent.clamp(0.0, 1.0);
              final isOver = budget.isOverspent;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(budget.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${budget.currentSpent.toStringAsFixed(0)} / \$${budget.amountLimit.toStringAsFixed(0)}',
                          style: TextStyle(color: isOver ? Colors.red : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red : const Color(0xFF0DA66E)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOver ? 'Over budget by \$${(budget.currentSpent - budget.amountLimit).toStringAsFixed(0)}' : '${(progress * 100).toStringAsFixed(0)}% used',
                          style: TextStyle(fontSize: 12, color: isOver ? Colors.red : Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          onPressed: () => provider.deleteBudget(budget.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004D40),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddBudgetDialog(context),
      ),
    );
  }
}
