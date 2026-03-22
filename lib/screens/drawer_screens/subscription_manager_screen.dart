import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';

class SubscriptionManagerScreen extends StatelessWidget {
  const SubscriptionManagerScreen({super.key});

  void _showAddSubscriptionDialog(BuildContext context) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    String cycle = 'Monthly';
    DateTime nextDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Subscription', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cost (\$)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: cycle,
                  decoration: InputDecoration(
                    labelText: 'Billing Cycle',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'Annual', child: Text('Annual')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  ],
                  onChanged: (val) => setDialogState(() => cycle = val ?? 'Monthly'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Next Billing Date', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  subtitle: Text('${nextDate.month}/${nextDate.day}/${nextDate.year}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogCtx,
                      initialDate: nextDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setDialogState(() => nextDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final cost = double.tryParse(costController.text) ?? 0;
                if (cost <= 0) return;
                Provider.of<AppProvider>(context, listen: false).addSubscription(
                  Subscription(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    cost: cost,
                    billingCycle: cycle,
                    nextBillingDate: nextDate,
                    logoUrl: nameController.text[0].toUpperCase(),
                  ),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = Provider.of<AppProvider>(context).subscriptions;
    final totalMonthly = subscriptions.where((s) => s.billingCycle == 'Monthly').fold(0.0, (sum, s) => sum + s.cost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
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
                gradient: const LinearGradient(colors: [Color(0xFF8A63F0), Color(0xFF6750A4)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Monthly Cost', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '${subscriptions.length} Active Sub${subscriptions.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '\$${totalMonthly.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: subscriptions.isEmpty
                  ? const Center(child: Text('No subscriptions. Tap + to add one.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        return Dismissible(
                          key: ValueKey(sub.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            Provider.of<AppProvider>(context, listen: false).deleteSubscription(sub.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${sub.name} removed')),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF8A63F0).withOpacity(0.1),
                                child: Text(sub.logoUrl, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6750A4))),
                              ),
                              title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${sub.billingCycle} • Next: ${sub.nextBillingDate.month}/${sub.nextBillingDate.day}/${sub.nextBillingDate.year}'),
                              trailing: Text('\$${sub.cost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
        onPressed: () => _showAddSubscriptionDialog(context),
      ),
    );
  }
}
