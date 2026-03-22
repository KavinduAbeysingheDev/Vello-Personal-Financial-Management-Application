import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';
import 'database_helper.dart';

class AppProvider with ChangeNotifier {
  final _uuid = const Uuid();
  bool _isLoaded = false;

  // ─── TRANSACTIONS ─────────────────────────────────────────────────────────

  List<AppTransaction> _transactions = [];
  List<AppTransaction> get transactions => List.unmodifiable(_transactions);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  double get savingsRate =>
      totalIncome == 0 ? 0 : ((totalIncome - totalExpense) / totalIncome * 100).clamp(0, 100);

  /// Returns total spent per category for the current month.
  Map<String, double> get categorySpendThisMonth {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final tx in _transactions) {
      if (tx.type == TransactionType.expense &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    _transactions.insert(0, transaction);
    notifyListeners();
    await DatabaseHelper.instance.insertTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteTransaction(id);
  }

  // ─── SAVINGS GOALS ────────────────────────────────────────────────────────

  List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    notifyListeners();
    await DatabaseHelper.instance.insertSavingsGoal(goal);
  }

  Future<void> updateSavingsGoalProgress(String id, double amountAdded) async {
    final index = _savingsGoals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    _savingsGoals[index].currentAmount += amountAdded;
    notifyListeners();
    await DatabaseHelper.instance.updateSavingsGoal(_savingsGoals[index]);
  }

  // ─── SUBSCRIPTIONS ────────────────────────────────────────────────────────

  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  Future<void> addSubscription(Subscription sub) async {
    _subscriptions.add(sub);
    notifyListeners();
    await DatabaseHelper.instance.insertSubscription(sub);
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
    await DatabaseHelper.instance.deleteSubscription(id);
  }

  // ─── DEBTS ────────────────────────────────────────────────────────────────

  List<Debt> _debts = [];
  List<Debt> get debts => List.unmodifiable(_debts);

  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    notifyListeners();
    await DatabaseHelper.instance.insertDebt(debt);
  }

  Future<void> payDebt(String id, double amount) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index == -1) return;
    _debts[index].paidAmount += amount;
    notifyListeners();
    await DatabaseHelper.instance.updateDebtPaid(id, _debts[index].paidAmount);
  }

  // ─── INITIALISATION ───────────────────────────────────────────────────────

  bool get isLoaded => _isLoaded;

  /// Call once at app startup (from main.dart or FutureBuilder in MaterialApp).
  Future<void> loadAll() async {
    if (_isLoaded) return;

    try {
      final results = await Future.wait([
        DatabaseHelper.instance.readAllTransactions(),
        DatabaseHelper.instance.readAllSavingsGoals(),
        DatabaseHelper.instance.readAllSubscriptions(),
        DatabaseHelper.instance.readAllDebts(),
      ]);

      _transactions = results[0] as List<AppTransaction>;
      _savingsGoals = results[1] as List<SavingsGoal>;
      _subscriptions = results[2] as List<Subscription>;
      _debts = results[3] as List<Debt>;

      // Seed defaults only if DB is completely empty (first ever launch)
      if (_transactions.isEmpty) _seedDefaultTransactions();
      if (_savingsGoals.isEmpty) await _seedDefaultGoals();
      if (_subscriptions.isEmpty) await _seedDefaultSubscriptions();
      if (_debts.isEmpty) await _seedDefaultDebts();
    } catch (_) {
      // On Web or other unsupported platforms, use in-memory seeds
      if (_transactions.isEmpty) _seedDefaultTransactions();
    }

    _isLoaded = true;
    notifyListeners();
  }

  void _seedDefaultTransactions() {
    _transactions = [
      AppTransaction(
        id: _uuid.v4(),
        title: 'Salary',
        category: 'Income',
        amount: 5800.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.income,
        icon: Icons.account_balance_wallet,
      ),
      AppTransaction(
        id: _uuid.v4(),
        title: 'Grocery Shopping',
        category: 'Food',
        amount: 150.00,
        date: DateTime.now(),
        type: TransactionType.expense,
        icon: Icons.shopping_cart,
      ),
      AppTransaction(
        id: _uuid.v4(),
        title: 'Electric Company',
        category: 'Bills',
        amount: 89.50,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.expense,
        icon: Icons.electrical_services,
      ),
      AppTransaction(
        id: _uuid.v4(),
        title: 'Netflix',
        category: 'Entertainment',
        amount: 15.99,
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: TransactionType.expense,
        icon: Icons.movie,
      ),
    ];
    // Persist seeds to DB (fire and forget)
    for (final tx in _transactions) {
      DatabaseHelper.instance.insertTransaction(tx).catchError((_) {});
    }
  }

  Future<void> _seedDefaultGoals() async {
    _savingsGoals = [
      SavingsGoal(id: _uuid.v4(), title: 'New MacBook', targetAmount: 2000, currentAmount: 1200, iconStr: '💻', color: const Color(0xFF4A84E8)),
      SavingsGoal(id: _uuid.v4(), title: 'Emergency Fund', targetAmount: 10000, currentAmount: 8500, iconStr: '🛡️', color: const Color(0xFF00C853)),
      SavingsGoal(id: _uuid.v4(), title: 'Vacation to Japan', targetAmount: 5000, currentAmount: 1500, iconStr: '✈️', color: const Color(0xFFFF9800)),
    ];
    for (final g in _savingsGoals) {
      await DatabaseHelper.instance.insertSavingsGoal(g).catchError((_) {});
    }
  }

  Future<void> _seedDefaultSubscriptions() async {
    _subscriptions = [
      Subscription(id: _uuid.v4(), name: 'Netflix', cost: 15.99, billingCycle: 'Monthly', nextBillingDate: DateTime.now().add(const Duration(days: 12)), logoUrl: 'N'),
      Subscription(id: _uuid.v4(), name: 'Spotify', cost: 9.99, billingCycle: 'Monthly', nextBillingDate: DateTime.now().add(const Duration(days: 3)), logoUrl: 'S'),
      Subscription(id: _uuid.v4(), name: 'Gym Membership', cost: 45.00, billingCycle: 'Monthly', nextBillingDate: DateTime.now().add(const Duration(days: 20)), logoUrl: 'G'),
    ];
    for (final s in _subscriptions) {
      await DatabaseHelper.instance.insertSubscription(s).catchError((_) {});
    }
  }

  Future<void> _seedDefaultDebts() async {
    _debts = [
      Debt(id: _uuid.v4(), name: 'Car Loan', totalAmount: 15000, paidAmount: 5000, dueDate: DateTime.now().add(const Duration(days: 180))),
      Debt(id: _uuid.v4(), name: 'Student Loan', totalAmount: 40000, paidAmount: 12000, dueDate: DateTime.now().add(const Duration(days: 1000))),
    ];
    for (final d in _debts) {
      await DatabaseHelper.instance.insertDebt(d).catchError((_) {});
    }
  }
}
