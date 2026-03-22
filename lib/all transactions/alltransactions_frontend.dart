import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../all transactions/alltransactions_backend.dart';
import '../models/app_models.dart';
import '../screens/connect_data_sources_screen.dart';
import 'package:intl/intl.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  static const Color _teal = Color(0xFF00875A);
  static const Color _incomeGreen = Color(0xFF2ECC71);
  static const Color _expenseRed = Color(0xFFE74C3C);
  static const Color _purple = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      // ── App Bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Vello',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white, size: 24), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectDataSourcesScreen()),
              );
            }
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24), onPressed: () {}),
        ],
      ),

      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }

          final transactions = provider.filteredTransactions;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sub-header ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: const Color(0xFFEFEFEF),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Text(
                  'All Transactions',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444444)),
                ),
              ),

              // ── Transaction List ──────────────────────────────────────────
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions found.',
                          style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final bool isExpense = tx.type == TransactionType.expense;
                          final String amountStr =
                              (isExpense ? '-' : '+') + r'$' + tx.amount.toStringAsFixed(2);
                          final String dateStr = DateFormat('MMM dd, yyyy').format(tx.date);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                // Arrow circle
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isExpense
                                        ? _expenseRed.withOpacity(0.12)
                                        : _incomeGreen.withOpacity(0.12),
                                    border: Border.all(
                                      color: isExpense
                                          ? _expenseRed.withOpacity(0.5)
                                          : _incomeGreen.withOpacity(0.5),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                    color: isExpense ? _expenseRed : _incomeGreen,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Title / category / date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.title,
                                          style: const TextStyle(
                                              fontSize: 13, fontWeight: FontWeight.normal, color: Color(0xFF1A1A1A))),
                                      const SizedBox(height: 2),
                                      Text(tx.category,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
                                      const SizedBox(height: 1),
                                      Text(dateStr,
                                          style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                                    ],
                                  ),
                                ),

                                // Amount
                                Text(
                                  amountStr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: isExpense ? _expenseRed : _incomeGreen),
                                ),
                                const SizedBox(width: 8),

                                // Delete
                                GestureDetector(
                                  onTap: () => provider.deleteTransaction(tx.id),
                                  child: const Icon(Icons.delete_outline, color: _expenseRed, size: 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00875A) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _selected = -1;
  static const Color _teal = Color(0xFF00875A);
  static const Color _purple = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Home',
              selected: _selected == 0, selectedColor: _teal,
              onTap: () => setState(() => _selected = 0)),
          _NavItem(icon: Icons.camera_alt_outlined, label: 'Scan',
              selected: _selected == 1, selectedColor: _teal,
              onTap: () => setState(() => _selected = 1)),
          // Add button (purple circle)
          GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x554F46E5), blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 2),
                const Text('Add', style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          _NavItem(icon: Icons.calendar_today_outlined, label: 'Events',
              selected: _selected == 3, selectedColor: _teal,
              onTap: () => setState(() => _selected = 3)),
          _NavItem(icon: Icons.work_outline, label: 'AI',
              selected: _selected == 4, selectedColor: _teal,
              onTap: () => setState(() => _selected = 4)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : const Color(0xFF999999);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
