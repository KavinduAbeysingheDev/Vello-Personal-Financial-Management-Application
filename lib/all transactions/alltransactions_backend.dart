import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/transaction_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Filter enum ────────────────────────────────────────────────────────────────
enum TransactionFilter { all, income, expense }

// ── TransactionProvider ────────────────────────────────────────────────────────
class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<AppTransaction> _transactions = [];
  TransactionFilter _activeFilter = TransactionFilter.all;
  bool _isLoading = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  TransactionFilter get activeFilter => _activeFilter;

  /// All transactions sorted newest first
  List<AppTransaction> get allTransactions {
    return _transactions;
  }

  /// Filtered list based on [_activeFilter]
  List<AppTransaction> get filteredTransactions {
    switch (_activeFilter) {
      case TransactionFilter.income:
        return _transactions.where((t) => t.type == TransactionType.income).toList();
      case TransactionFilter.expense:
        return _transactions.where((t) => t.type == TransactionType.expense).toList();
      case TransactionFilter.all:
        return _transactions;
    }
  }

  /// Total income
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Total expenses
  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Net balance
  double get balance => totalIncome - totalExpenses;

  // ── Constructor ──────────────────────────────────────────────────────────────
  TransactionProvider() {
    refresh();
  }

  // ── Fetch from Supabase ─────────────────────────────────────────────────────
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _repository.fetchTransactions();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── CRUD operations ───────────────────────────────────────────────────────────

  /// Add a new transaction
  Future<void> addTransaction({
    required String title,
    required String category,
    required DateTime date,
    required double amount,
    required bool isExpense,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final tx = AppTransaction(
      id: '', // Supabase will ignore/generate if configured
      userId: userId,
      title: title,
      category: category,
      date: date,
      amount: amount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      icon: isExpense ? Icons.shopping_bag : Icons.attach_money,
    );
    
    await _repository.insertTransaction(tx);
    await refresh();
  }

  /// Delete a transaction by id
  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await refresh();
  }

  // ── Filter ────────────────────────────────────────────────────────────────────
  void setFilter(TransactionFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }
}

