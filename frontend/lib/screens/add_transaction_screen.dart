import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import '../services/app_provider.dart';
import '../widgets/vello_drawer.dart';
import '../screens/setting_screen_backend.dart';

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

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    provider.addTransaction(newTx);
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(settings.t('Transaction added!'))));

    // If using as a tab page, use the callback instead of popping the whole nav stack
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    return Scaffold(
      backgroundColor: Colors.transparent,
      endDrawer: const VelloDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(settings.t("Add Transaction"), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.expense ? (isDark ? const Color(0xFF422123) : const Color(0xFFFFE0E2)) : Colors.transparent,
                        border: Border.all(color: _type == TransactionType.expense ? const Color(0xFFFF1744) : (isDark ? const Color(0xFF374151) : Colors.grey[300]!)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(settings.t("Expense"), style: TextStyle(color: _type == TransactionType.expense ? const Color(0xFFFF1744) : (isDark ? Colors.white70 : Colors.grey[600]), fontWeight: FontWeight.bold))),
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
                        color: _type == TransactionType.income ? (isDark ? const Color(0xFF1E3A32) : const Color(0xFFEAF9F3)) : Colors.transparent,
                        border: Border.all(color: _type == TransactionType.income ? const Color(0xFF0DA66E) : (isDark ? const Color(0xFF374151) : Colors.grey[300]!)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(settings.t("Income"), style: TextStyle(color: _type == TransactionType.income ? const Color(0xFF0DA66E) : (isDark ? Colors.white70 : Colors.grey[600]), fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF14B8A6) : const Color(0xFF006D5B)),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF14B8A6) : const Color(0xFF006D5B)),
                labelText: settings.t("Amount"),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey[400]!)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: settings.t("Title (e.g., Target run)"),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey[400]!)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: settings.t("Category"),
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey[400]!)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(settings.t(c)))).toList(),
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
                  backgroundColor: isDark ? const Color(0xFF0D9488) : const Color(0xFF006D5B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(settings.t("Save Transaction"), style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
