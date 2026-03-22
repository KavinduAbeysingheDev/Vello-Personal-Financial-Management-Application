import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../app_theme.dart';
import '../services/finance_service.dart';
import '../models/budget_model.dart';

const _kTeal = Color(0xFF26a69a);

// ─── Category config ──────────────────────────────────────────────────────────
class _CatConfig {
  final String name;
  final IconData icon;
  final Color color;
  const _CatConfig(this.name, this.icon, this.color);
}

const _categories = [
  _CatConfig('Food',           Icons.restaurant_rounded,     Color(0xFF35C7A1)),
  _CatConfig('Transportation', Icons.directions_car_rounded,  Color(0xFF4A84E8)),
  _CatConfig('Entertainment',  Icons.movie_filter_rounded,    Color(0xFF8A63F0)),
  _CatConfig('Shopping',       Icons.shopping_bag_rounded,    Color(0xFFFF1744)),
  _CatConfig('Bills',          Icons.receipt_long_rounded,    Color(0xFFFF9800)),
  _CatConfig('Healthcare',     Icons.local_hospital_rounded,  Color(0xFFE91E63)),
  _CatConfig('Education',      Icons.school_rounded,          Color(0xFF009688)),
  _CatConfig('Other',          Icons.category_rounded,        Color(0xFF78909C)),
];

_CatConfig _configFor(String category) =>
    _categories.firstWhere((c) => c.name == category,
        orElse: () => _CatConfig(
            category, Icons.category_rounded, const Color(0xFF78909C)));

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _financeService = FinanceService();
  final _userId = FirebaseAuth.instance.currentUser!.uid;

  bool  get _dark => appTheme.isDark;
  Color get _scaffoldBg => _dark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
  Color get _cardBg     => _dark ? const Color(0xFF1F2937) : Colors.white;
  Color get _borderClr  => _dark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  Color get _textPrimary   => _dark ? Colors.white : const Color(0xFF111111);
  Color get _textSecondary => _dark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;
  Color get _inputFill  => _dark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appTheme,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: _scaffoldBg,

          // ── AppBar ────────────────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: _kTeal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/vello_logo.png',
                      fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Vello',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                      fontSize: 22)),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: Colors.white),
                tooltip: 'Add Budget',
                onPressed: () => _showAddOrEditDialog(context),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────────────
          body: StreamBuilder<List<Budget>>(
            stream: _financeService.getBudgets(_userId),
            builder: (context, snap) {
              // Loading
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: _kTeal));
              }

              // Error
              if (snap.hasError) {
                return Center(
                  child: Text('Error: ${snap.error}',
                      style: const TextStyle(color: Colors.red)),
                );
              }

              final budgets = snap.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budget Overview',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary)),
                            const SizedBox(height: 2),
                            Text('Manage your monthly spending limits',
                                style: TextStyle(
                                    fontSize: 12, color: _textSecondary)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddOrEditDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Budget',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Summary card ─────────────────────────────────────
                    if (budgets.isNotEmpty) ...[
                      _summaryCard(budgets),
                      const SizedBox(height: 18),
                    ],

                    // ── Budget list ──────────────────────────────────────
                    budgets.isEmpty
                        ? _emptyState()
                        : Column(
                      children: budgets
                          .map((b) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 14),
                        child: _budgetCard(context, b),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
