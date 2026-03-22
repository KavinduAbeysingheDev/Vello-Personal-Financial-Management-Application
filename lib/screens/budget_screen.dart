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
