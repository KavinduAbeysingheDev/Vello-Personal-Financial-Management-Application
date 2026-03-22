import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';

class DebtTrackerScreen extends StatelessWidget {
  const DebtTrackerScreen({super.key});

  void _showAddDebtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final totalController = TextEditingController();
    final paidController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New Debt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Debt Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Amount (\$)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Already Paid (\$)',
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  subtitle: Text(
                    '${dueDate.month}/${dueDate.day}/${dueDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1744), foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final total = double.tryParse(totalController.text) ?? 0;
                if (total <= 0) return;
                final paid = double.tryParse(paidController.text) ?? 0;
                Provider.of<AppProvider>(context, listen: false).addDebt(
                  Debt(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    totalAmount: total,
                    paidAmount: paid,
                    dueDate: dueDate,
                  ),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Add Debt'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Debt debt) {
    final amountController = TextEditingController();
    final remaining = debt.totalAmount - debt.paidAmount;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pay "${debt.name}"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFE0E2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF1744), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Remaining: \$${remaining.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Payment Amount (\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0DA66E), foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || amount > remaining) return;
              Provider.of<AppProvider>(context, listen: false).payDebt(debt.id, amount);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment of \$${amount.toStringAsFixed(2)} recorded!')),
              );
            },
            child: const Text('Make Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debts = Provider.of<AppProvider>(context).debts;
    final totalDebt = debts.fold(0.0, (sum, d) => sum + d.totalAmount - d.paidAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Tracker'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1744).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.money_off, color: Color(0xFFFF1744)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Outstanding Debt', style: TextStyle(color: Color(0xFFFF1744), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${totalDebt.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFFF1744), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: debts.isEmpty
                  ? const Center(child: Text('No debts recorded. Tap + to add one.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        final progress = (debt.paidAmount / debt.totalAmount).clamp(0.0, 1.0);
                        final isPaid = debt.paidAmount >= debt.totalAmount;
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(debt.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    isPaid
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEAF9F3),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text('Paid Off ✓', style: TextStyle(color: Color(0xFF0DA66E), fontSize: 12, fontWeight: FontWeight.w600)),
                                          )
                                        : TextButton.icon(
                                            onPressed: () => _showPaymentDialog(context, debt),
                                            icon: const Icon(Icons.payment, size: 16, color: Color(0xFF0DA66E)),
                                            label: const Text('Pay', style: TextStyle(color: Color(0xFF0DA66E), fontSize: 13)),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              backgroundColor: const Color(0xFFEAF9F3),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            ),
                                          ),
                                  ],
                                ),
                                if (!isPaid)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Due: ${debt.dueDate.month}/${debt.dueDate.day}/${debt.dueDate.year}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(isPaid ? const Color(0xFF0DA66E) : const Color(0xFF4A84E8)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Paid: \$${debt.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF0DA66E))),
                                    Text('Total: \$${debt.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004D40),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDebtDialog(context),
      ),
    );
  }
}
