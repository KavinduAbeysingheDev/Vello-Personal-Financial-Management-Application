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

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64,
              color:
              _dark ? const Color(0xFF374151) : Colors.grey[300]),
          const SizedBox(height: 14),
          Text('No budgets set up yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          Text('Tap "Add Budget" to set spending limits\nfor your categories.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddOrEditDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Budget'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _kTeal, foregroundColor: Colors.white),
          ),
        ],
      ),
    ),
  );

  // ── Summary card ────────────────────────────────────────────────────────────
  Widget _summaryCard(List<Budget> budgets) {
    final totalLimit = budgets.fold(0.0, (s, b) => s + b.limit);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final overCount  = budgets.where((b) => b.spent > b.limit).length;
    final progress   = totalLimit > 0
        ? (totalSpent / totalLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26a69a), Color(0xFF0DBE82)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _kTeal.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Monthly Budget',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Spacer(),
            if (overCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$overCount over limit',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ \$${totalLimit.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                  totalSpent > totalLimit ? Colors.red.shade300 : Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text('${(progress * 100).toStringAsFixed(1)}% used',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Text(
                '\$${(totalLimit - totalSpent).abs().toStringAsFixed(2)} '
                    '${totalSpent > totalLimit ? 'over' : 'remaining'}',
                style: TextStyle(
                    color: totalSpent > totalLimit
                        ? Colors.red.shade200
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  // ── Individual budget card ──────────────────────────────────────────────────
  Widget _budgetCard(BuildContext context, Budget budget) {
    final cfg         = _configFor(budget.category);
    final rawProgress = budget.limit > 0 ? budget.spent / budget.limit : 0.0;
    final progress    = rawProgress.clamp(0.0, 1.0);
    final overBudget  = rawProgress >= 1.0;
    // Three-state: red = over, orange = nearing (>=80%), category = healthy
    final Color barColor;
    if (rawProgress >= 1.0) {
      barColor = const Color(0xFFE53935);
    } else if (rawProgress >= 0.8) {
      barColor = const Color(0xFFF57C00);
    } else {
      barColor = cfg.color;
    }
    final remaining = budget.limit - budget.spent;

    return Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: overBudget ? Colors.red.withOpacity(0.4) : _borderClr),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
        // ── Top row ────────────────────────────────────────────────────────
        Row(children: [
        Container(
        width: 42, height: 42,
          decoration: BoxDecoration(
            color: cfg.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(cfg.icon, color: cfg.color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(budget.category,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary)),
              const SizedBox(height: 2),
              Text(
                rawProgress >= 1.0
                    ? '⚠️ Over by \$${(budget.spent - budget.limit).toStringAsFixed(2)}'
                    : rawProgress >= 0.8
                    ? '⚠️ \$${remaining.toStringAsFixed(2)} remaining'
                    : '\$${remaining.toStringAsFixed(2)} remaining',
                style: TextStyle(
                    fontSize: 12,
                    color: rawProgress >= 1.0
                        ? const Color(0xFFE53935)
                        : rawProgress >= 0.8
                        ? const Color(0xFFF57C00)
                        : const Color(0xFF16A34A),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        // Edit button
        IconButton(
          icon: Icon(Icons.edit_outlined, color: _kTeal, size: 20),
          tooltip: 'Edit limit',
          onPressed: () => _showAddOrEditDialog(context, existing: budget),
        ),
        // Delete button
        IconButton(
          icon: Icon(Icons.delete_outline_rounded,
              color: _textSecondary.withOpacity(0.6), size: 20),
          tooltip: 'Delete budget',
          onPressed: () => _confirmDelete(context, budget),
        ),
        ]),
        const SizedBox(height: 14),

          // ── Spent / limit row ───────────────────────────────────────────────
          Row(children: [
            Text('Spent',
                style: TextStyle(fontSize: 12, color: _textSecondary)),
            const Spacer(),
            Text('\$${budget.spent.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
          ]),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: _borderClr,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 8),

          // ── Limit row ───────────────────────────────────────────────────────
          Row(children: [
            Text('Limit',
                style: TextStyle(fontSize: 12, color: _textSecondary)),
            const Spacer(),
            Text('\$${budget.limit.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
          ]),

          // ── Usage percentage ────────────────────────────────────────────────
          const SizedBox(height: 8),
          Row(children: [
            // Usage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: barColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${(progress * 100).toStringAsFixed(0)}% used',
                  style: TextStyle(
                      color: barColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            // Quick edit limit button
            GestureDetector(
              onTap: () => _showAddOrEditDialog(context, existing: budget),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: _kTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('Change limit',
                    style: TextStyle(
                        color: _kTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ]),
    );
  }

  // ── Add / Edit dialog ───────────────────────────────────────────────────────
  void _showAddOrEditDialog(BuildContext context, {Budget? existing}) {
    final isEdit = existing != null;

    // For new budgets, track which category is selected
    String selectedCategory = existing?.category ?? _categories.first.name;
    final limitCtrl = TextEditingController(
        text: existing != null
            ? existing.limit.toStringAsFixed(2)
            : '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final dlgBg     = _dark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
          final dlgCard   = _dark ? const Color(0xFF374151) : Colors.white;
          final dlgBorder = _dark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB);
          final dlgText   = _dark ? Colors.white : const Color(0xFF111827);
          final dlgSub    = _dark ? const Color(0xFF9CA3AF) : Colors.black54;
          final cfg       = _configFor(selectedCategory);

          return Dialog(
            backgroundColor: dlgBg,
            insetPadding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Dialog title ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Edit Budget' : 'Add Budget',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: dlgText)),
                        IconButton(
                          icon: Icon(Icons.close, size: 20, color: dlgSub),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Category picker (only for new budgets) ────────────
                    if (!isEdit) ...[
                      Text('Category',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: dlgSub)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: _categories.map((cat) {
                          final isSel = selectedCategory == cat.name;
                          return GestureDetector(
                            onTap: () =>
                                setDlg(() => selectedCategory = cat.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? cat.color.withOpacity(0.15)
                                    : dlgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: isSel ? cat.color : dlgBorder,
                                    width: isSel ? 2 : 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(cat.icon,
                                      color: isSel ? cat.color : dlgSub,
                                      size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name.length > 6
                                        ? '${cat.name.substring(0, 5)}..'
                                        : cat.name,
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: isSel ? cat.color : dlgSub,
                                        fontWeight: isSel
                                            ? FontWeight.w700
                                            : FontWeight.w400),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ── Selected category preview (for edit) ──────────────
                    if (isEdit) ...[
                      Text('Category',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: dlgSub)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: cfg.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: cfg.color.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Icon(cfg.icon, color: cfg.color, size: 20),
                          const SizedBox(width: 10),
                          Text(selectedCategory,
                              style: TextStyle(
                                  color: cfg.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Monthly limit field ───────────────────────────────
                    Text('Monthly Limit',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dlgSub)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: limitCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: dlgText),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                            color: dlgText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        hintStyle: TextStyle(color: dlgSub),
                        filled: true,
                        fillColor: _inputFill,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: dlgBorder)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: dlgBorder)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: _kTeal, width: 1.5)),
                      ),
                    ),

                    // ── Current spent info (edit only) ────────────────────
                    if (isEdit) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _kTeal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Icon(Icons.info_outline_rounded,
                              color: _kTeal, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Current spending: \$${existing!.spent.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: _kTeal,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Save button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final limit =
                          double.tryParse(limitCtrl.text.trim());
                          if (limit == null || limit <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Please enter a valid amount'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }

                          await _financeService.setBudget(
                            userId:   _userId,
                            category: selectedCategory,
                            limit:    limit,
                          );

                          if (ctx.mounted) Navigator.pop(ctx);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit
                                    ? '$selectedCategory limit updated to \$${limit.toStringAsFixed(2)}'
                                    : '$selectedCategory budget added'),
                                backgroundColor: _kTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEdit ? 'Update Limit' : 'Add Budget',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Delete confirmation ─────────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Budget',
            style: TextStyle(color: _textPrimary)),
        content: Text(
            'Remove the ${budget.category} budget of \$${budget.limit.toStringAsFixed(2)}?',
            style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _financeService.deleteBudget(budget.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${budget.category} budget removed'),
            backgroundColor: _kTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
      } catch (e) {
        debugPrint('Delete error: $e');
      }
    }
  }
}





