import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import '../services/app_provider.dart';
import '../widgets/vello_top_bar.dart';
import '../widgets/vello_drawer.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Called after a transaction is saved. When null, falls back to Navigator.pop().
  final VoidCallback? onSaved;

  const AddTransactionScreen({super.key, this.onSaved});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedCategory = 'Food';
  TransactionType _type = TransactionType.expense;

  final List<String> _categories = ['Food', 'Bills', 'Transport', 'Entertainment', 'Shopping', 'Income', 'Other'];

  void _saveTransaction() {
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Choose icon roughly based on category
    IconData icon = Icons.money_off;
    if (_type == TransactionType.income) icon = Icons.account_balance_wallet;
    else if (_selectedCategory == 'Food') icon = Icons.restaurant;
    else if (_selectedCategory == 'Bills') icon = Icons.receipt;
    else if (_selectedCategory == 'Transport') icon = Icons.directions_car;

    final newTx = AppTransaction(
      id: const Uuid().v4(),
      title: _titleController.text,
      category: _selectedCategory,
      amount: amount,
      date: DateTime.now(),
      type: _type,
      icon: icon,
    );

    provider.addTransaction(newTx);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction added!')));

    // If using as a tab page, use the callback instead of popping the whole nav stack
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Transaction", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.expense ? const Color(0xFFFFE0E2) : Colors.transparent,
                        border: Border.all(color: _type == TransactionType.expense ? const Color(0xFFFF1744) : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text("Expense", style: TextStyle(color: _type == TransactionType.expense ? const Color(0xFFFF1744) : Colors.grey[600], fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.income ? const Color(0xFFEAF9F3) : Colors.transparent,
                        border: Border.all(color: _type == TransactionType.income ? const Color(0xFF0DA66E) : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text("Income", style: TextStyle(color: _type == TransactionType.income ? const Color(0xFF0DA66E) : Colors.grey[600], fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006D5B)),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF006D5B)),
                labelText: "Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title (e.g., Target run)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Save Transaction", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
