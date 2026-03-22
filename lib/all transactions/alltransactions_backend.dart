import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Transaction model ──────────────────────────────────────────────────────────
class Transaction {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final bool isExpense;

  Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isExpense,
  });

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'date': date.toIso8601String(),
        'amount': amount,
        'isExpense': isExpense,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        isExpense: json['isExpense'] as bool,
      );

  // For easy editing — return a copy with overridden fields
  Transaction copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? date,
    double? amount,
    bool? isExpense,
  }) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        isExpense: isExpense ?? this.isExpense,
      );
}

// ── Filter enum ────────────────────────────────────────────────────────────────
enum TransactionFilter { all, income, expense }

// ── TransactionProvider ────────────────────────────────────────────────────────
class TransactionProvider with ChangeNotifier {
  static const String _storageKey = 'transactions';

  List<Transaction> _transactions = [];
  TransactionFilter _activeFilter = TransactionFilter.all;
  bool _isLoading = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  TransactionFilter get activeFilter => _activeFilter;

  /// All transactions sorted newest first
  List<Transaction> get allTransactions {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Filtered list based on [_activeFilter]
  List<Transaction> get filteredTransactions {
    switch (_activeFilter) {
      case TransactionFilter.income:
        return allTransactions.where((t) => !t.isExpense).toList();
      case TransactionFilter.expense:
        return allTransactions.where((t) => t.isExpense).toList();
      case TransactionFilter.all:
        return allTransactions;
    }
  }

  /// Total income (sum of all non-expense transactions)
  double get totalIncome => _transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Total expenses (sum of all expense transactions)
  double get totalExpenses => _transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Net balance
  double get balance => totalIncome - totalExpenses;

  // ── Constructor: load saved data ──────────────────────────────────────────────
  TransactionProvider() {
    _loadTransactions();
  }

  // ── Load from SharedPreferences ───────────────────────────────────────────────
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);

      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        _transactions = decoded
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Seed with sample data on first launch
        _transactions = _sampleTransactions();
        await _saveTransactions();
      }
    } catch (_) {
      _transactions = _sampleTransactions();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Save to SharedPreferences ─────────────────────────────────────────────────
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
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
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      date: date,
      amount: amount,
      isExpense: isExpense,
    );
    _transactions.add(tx);
    notifyListeners();
    await _saveTransactions();
  }

  /// Delete a transaction by id
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveTransactions();
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transaction updated) async {
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _transactions[idx] = updated;
      notifyListeners();
      await _saveTransactions();
    }
  }

  /// Clear all transactions
  Future<void> clearAll() async {
    _transactions.clear();
    notifyListeners();
    await _saveTransactions();
  }

  // ── Filter ────────────────────────────────────────────────────────────────────
  void setFilter(TransactionFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // ── Sample seed data ──────────────────────────────────────────────────────────
  List<Transaction> _sampleTransactions() => [
        Transaction(
          id: '1',
          title: 'Salary',
          category: 'Income',
          date: DateTime.now().subtract(const Duration(days: 1)),
          amount: 5000.00,
          isExpense: false,
        ),
        Transaction(
          id: '2',
          title: 'Grocery Shopping',
          category: 'Food',
          date: DateTime.now().subtract(const Duration(days: 2)),
          amount: 150.00,
          isExpense: true,
        ),
        Transaction(
          id: '3',
          title: 'Netflix Subscription',
          category: 'Entertainment',
          date: DateTime.now().subtract(const Duration(days: 3)),
          amount: 15.99,
          isExpense: true,
        ),
        Transaction(
          id: '4',
          title: 'Gas',
          category: 'Transportation',
          date: DateTime.now().subtract(const Duration(days: 4)),
          amount: 60.00,
          isExpense: true,
        ),
        Transaction(
          id: '5',
          title: 'Freelance Project',
          category: 'Income',
          date: DateTime.now().subtract(const Duration(days: 6)),
          amount: 800.00,
          isExpense: false,
        ),
        Transaction(
          id: '6',
          title: 'Restaurant',
          category: 'Food',
          date: DateTime.now().subtract(const Duration(days: 7)),
          amount: 85.00,
          isExpense: true,
        ),
      ];
}
