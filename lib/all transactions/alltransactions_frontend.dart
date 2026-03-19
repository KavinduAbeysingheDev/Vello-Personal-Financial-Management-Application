import 'package:flutter/material.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  static const Color _teal = Color(0xFF00875A);
  static const Color _incomeGreen = Color(0xFF2ECC71);
  static const Color _expenseRed = Color(0xFFE74C3C);
  static const Color _purple = Color(0xFF4F46E5);

  final List<Map<String, dynamic>> _transactions = [
    {'title': 'Salary', 'category': 'Income', 'date': 'Nov 20, 2025', 'amount': 5000.00, 'isExpense': false},
    {'title': 'Grocery Shopping', 'category': 'Food', 'date': 'Nov 19, 2025', 'amount': 150.00, 'isExpense': true},
    {'title': 'Netflix Subscription', 'category': 'Entertainment', 'date': 'Nov 18, 2025', 'amount': 15.99, 'isExpense': true},
    {'title': 'Gas', 'category': 'Transportation', 'date': 'Nov 17, 2025', 'amount': 60.00, 'isExpense': true},
    {'title': 'Freelance Project', 'category': 'Income', 'date': 'Nov 15, 2025', 'amount': 800.00, 'isExpense': false},
    {'title': 'Restaurant', 'category': 'Food', 'date': 'Nov 14, 2025', 'amount': 85.00, 'isExpense': true},
  ];

  int _selectedNavIndex = 0;

  void _deleteTransaction(int index) {
    setState(() => _transactions.removeAt(index));
  }

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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.menu, color: Colors.white, size: 24), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24), onPressed: () {}),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sub-header ─────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFFEFEFEF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'All Transactions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444444)),
            ),
          ),

          // ── Transaction List ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final bool isExpense = tx['isExpense'] as bool;
                final double amount = tx['amount'] as double;
                final String amountStr =
                    (isExpense ? '-' : '+') + r'$' + amount.toStringAsFixed(2);

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
                      // ── Arrow circle icon ──────────────────────────────────
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isExpense
                              ? _expenseRed.withOpacity(0.12)
                              : _incomeGreen.withOpacity(0.12),
                          border: Border.all(
                            color: isExpense
                                ? _expenseRed.withOpacity(0.5)
                                : _incomeGreen.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isExpense ? _expenseRed : _incomeGreen,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ── Title / Category / Date ────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['title'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tx['category'] as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              tx['date'] as String,
                              style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
                            ),
                          ],
                        ),
                      ),

                      // ── Amount ─────────────────────────────────────────────
                      Text(
                        amountStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isExpense ? _expenseRed : _incomeGreen,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ── Delete icon ────────────────────────────────────────
                      GestureDetector(
                        onTap: () => _deleteTransaction(index),
                        child: const Icon(Icons.delete_outline, color: _expenseRed, size: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Bottom Navigation Bar (Figma exact) ───────────────────────────────
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Home',
              selected: _selectedNavIndex == 0,
              selectedColor: _teal,
              onTap: () => setState(() => _selectedNavIndex = 0),
            ),
            _NavItem(
              icon: Icons.qr_code_scanner,
              label: 'Scan',
              selected: _selectedNavIndex == 1,
              selectedColor: _teal,
              onTap: () => setState(() => _selectedNavIndex = 1),
            ),

            // ── Centre Add button (purple circle) ──────────────────────────
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
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x554F46E5),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Add',
                    style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            _NavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Events',
              selected: _selectedNavIndex == 3,
              selectedColor: _teal,
              onTap: () => setState(() => _selectedNavIndex = 3),
            ),
            _NavItem(
              icon: Icons.smart_toy_outlined,
              label: 'AI',
              selected: _selectedNavIndex == 4,
              selectedColor: _teal,
              onTap: () => setState(() => _selectedNavIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav icon+label helper ──────────────────────────────────────────────
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
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
