import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/vello_top_bar.dart';
import '../widgets/vello_drawer.dart';
import '../services/app_provider.dart';
import '../models/app_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final children = [
      _balanceCard(provider.totalBalance, provider.savingsRate),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _smallInfoCard(
              title: 'Income',
              amount: '\$${provider.totalIncome.toStringAsFixed(2)}',
              color: const Color(0xFF0DA66E),
              icon: Icons.arrow_downward,
              bg: const Color(0xFFEAF9F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _smallInfoCard(
              title: 'Expenses',
              amount: '\$${provider.totalExpense.toStringAsFixed(2)}',
              color: const Color(0xFFFF1744),
              icon: Icons.arrow_upward,
              bg: const Color(0xFFFFF0F3),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _savingRateCard(provider.savingsRate),
      const SizedBox(height: 14),
      _budgetOverviewCard(provider),
      const SizedBox(height: 14),
      _recentTransactionsCard(provider.transactions),
    ];

    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        child: Column(
          children: List.generate(children.length, (index) {
            final start = (index / children.length) * 0.5;
            final end = start + 0.5;
            final animation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeOutCubic),
              ),
            );
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeIn),
              ),
            );
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(position: animation, child: child),
                );
              },
              child: children[index],
            );
          }),
        ),
      ),
    );
  }

  Widget _balanceCard(double totalBalance, double savingsRate) {
    String emoji;
    String label;
    if (totalBalance < 0) {
      emoji = '🔴';
      label = 'Negative Balance';
    } else if (savingsRate >= 70) {
      emoji = '💚';
      label = 'Excellent Balance';
    } else if (savingsRate >= 40) {
      emoji = '💛';
      label = 'Healthy Balance';
    } else {
      emoji = '🟠';
      label = 'Watch Your Spending';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0DBE82), Color(0xFF13C8B1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 15)),
              const Spacer(),
              Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.9), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$emoji $label',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfoCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _savingRateCard(double savingsRate) {
    final isPositive = savingsRate >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC4D).withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Savings Rate', style: TextStyle(color: Color(0xFFCA6F00))),
              const SizedBox(height: 2),
              Text(
                '${savingsRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Color(0xFFCA6F00),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(isPositive ? '💰' : '⚠️', style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  Widget _budgetOverviewCard(AppProvider provider) {
    final budgets = provider.budgets;

    if (budgets.isEmpty) {
      return _sectionCard(
        title: 'Budget Overview 📊',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No budgets set. Set limits in the side menu!', 
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFF35C7A1),
      const Color(0xFF4A84E8),
      const Color(0xFF8A63F0),
      const Color(0xFFFF9800),
      const Color(0xFFFF1744),
    ];

    return _sectionCard(
      title: 'Monthly Budget Status 📊',
      child: Column(
        children: budgets.asMap().entries.map((entry) {
          final b = entry.value;
          final idx = entry.key;
          final progress = b.usagePercent.clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: BudgetBar(
              label: b.category,
              valueText: '\$${b.currentSpent.toStringAsFixed(0)} / \$${b.amountLimit.toStringAsFixed(0)}',
              progress: progress,
              color: b.isOverspent ? Colors.red : colors[idx % colors.length],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _recentTransactionsCard(List<AppTransaction> transactions) {
    return _sectionCard(
      title: 'Recent Transactions ⚡',
      child: transactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('No transactions yet. Tap + to add one!',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          : Column(
              children: transactions.take(5).map((t) {
                final isIncome = t.type == TransactionType.income;
                return TxTile(
                  title: t.title,
                  subtitle: t.category,
                  amount: '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                  amountColor: isIncome ? const Color(0xFF0DA66E) : const Color(0xFFFF1744),
                  icon: t.icon,
                );
              }).toList(),
            ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BudgetCategory {
  final String name;
  final Color color;
  final double budget;
  const _BudgetCategory(this.name, this.color, this.budget);
}

class BudgetBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress;
  final Color color;

  const BudgetBar({
    super.key,
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(valueText, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class TxTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final IconData? icon;

  const TxTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: amountColor.withOpacity(0.1),
            child: Icon(icon ?? Icons.receipt_long, size: 18, color: amountColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
