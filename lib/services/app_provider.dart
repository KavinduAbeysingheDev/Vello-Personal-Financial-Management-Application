import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../models/budget.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/savings_goal_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/debt_repository.dart';
import '../repositories/budget_repository.dart';

class AppProvider with ChangeNotifier {
  final _uuid = const Uuid();
  bool _isLoaded = false;

  // Repositories
  final _txRepo = TransactionRepository();
  final _savingsRepo = SavingsGoalRepository();
  final _subRepo = SubscriptionRepository();
  final _debtRepo = DebtRepository();
  final _budgetRepo = BudgetRepository();

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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final txWithUser = AppTransaction(
      id: transaction.id,
      userId: userId,
      rawImportId: transaction.rawImportId,
      title: transaction.title,
      category: transaction.category,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type,
      icon: transaction.icon,
    );
    _transactions.insert(0, txWithUser);
    await syncBudgetStatus();
    notifyListeners();
    await _txRepo.insertTransaction(txWithUser);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await syncBudgetStatus();
    notifyListeners();
    await _txRepo.deleteTransaction(id);
  }

  // ─── SAVINGS GOALS ────────────────────────────────────────────────────────

  List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final goalWithUser = SavingsGoal(
      id: goal.id,
      userId: userId,
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      iconStr: goal.iconStr,
      color: goal.color,
    );
    _savingsGoals.add(goalWithUser);
    notifyListeners();
    await _savingsRepo.upsertGoal(goalWithUser);
  }

  Future<void> updateSavingsGoalProgress(String id, double amountAdded) async {
    final index = _savingsGoals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    _savingsGoals[index].currentAmount += amountAdded;
    notifyListeners();
    await _savingsRepo.upsertGoal(_savingsGoals[index]);
  }

  // ─── SUBSCRIPTIONS ────────────────────────────────────────────────────────

  List<Subscription> _subscriptions = [];
  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  Future<void> addSubscription(Subscription sub) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final subWithUser = Subscription(
      id: sub.id,
      userId: userId,
      name: sub.name,
      cost: sub.cost,
      billingCycle: sub.billingCycle,
      nextBillingDate: sub.nextBillingDate,
      logoUrl: sub.logoUrl,
    );
    _subscriptions.add(subWithUser);
    notifyListeners();
    await _subRepo.upsertSubscription(subWithUser);
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
    await _subRepo.deleteSubscription(id);
  }

  // ─── DEBTS ────────────────────────────────────────────────────────────────

  List<Debt> _debts = [];
  List<Debt> get debts => List.unmodifiable(_debts);

  Future<void> addDebt(Debt debt) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final debtWithUser = Debt(
      id: debt.id,
      userId: userId,
      name: debt.name,
      totalAmount: debt.totalAmount,
      paidAmount: debt.paidAmount,
      dueDate: debt.dueDate,
    );
    _debts.add(debtWithUser);
    notifyListeners();
    await _debtRepo.upsertDebt(debtWithUser);
  }

  Future<void> payDebt(String id, double amount) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index == -1) return;
    _debts[index].paidAmount += amount;
    notifyListeners();
    await _debtRepo.upsertDebt(_debts[index]);
  }

  // ─── BUDGETS ──────────────────────────────────────────────────────────────

  List<Budget> _budgets = [];
  List<Budget> get budgets => List.unmodifiable(_budgets);

  Future<void> addBudget(Budget budget) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final budgetWithUser = budget.copyWith(userId: userId);
    _budgets.add(budgetWithUser);
    notifyListeners();
    await _budgetRepo.upsertBudget(budgetWithUser);
    await syncBudgetStatus();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
    await _budgetRepo.deleteBudget(id);
  }

  Future<void> syncBudgetStatus() async {
    // Recalculate 'currentSpent' for all budgets based on transactions
    final now = DateTime.now();
    for (var i = 0; i < _budgets.length; i++) {
      final category = _budgets[i].category;
      final spent = _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.category == category &&
              t.date.month == now.month &&
              t.date.year == now.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      _budgets[i] = _budgets[i].copyWith(currentSpent: spent);
    }
    notifyListeners();
  }

  // ─── INITIALISATION ───────────────────────────────────────────────────────

  bool get isLoaded => _isLoaded;

  Future<void> loadAll() async {
    if (_isLoaded) return;

    try {
      final results = await Future.wait([
        _txRepo.fetchTransactions(),
        _savingsRepo.fetchGoals(),
        _subRepo.fetchSubscriptions(),
        _debtRepo.fetchDebts(),
        _budgetRepo.fetchBudgets(),
      ]);

      _transactions = results[0] as List<AppTransaction>;
      _savingsGoals = results[1] as List<SavingsGoal>;
      _subscriptions = results[2] as List<Subscription>;
      _debts = results[3] as List<Debt>;
      _budgets = results[4] as List<Budget>;

      await syncBudgetStatus();

      if (_transactions.isEmpty) {
        await forceSeedRichData();
      }
    } catch (e) {
      debugPrint('Error loading full backend data: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> forceSeedRichData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    final now = DateTime.now();
    _transactions = [
      AppTransaction(id: _uuid.v4(), userId: userId, title: 'Salary', category: 'Income', amount: 6500, date: now, type: TransactionType.income, icon: Icons.attach_money),
      AppTransaction(id: _uuid.v4(), userId: userId, title: 'Groceries', category: 'Food', amount: 150, date: now.subtract(const Duration(days: 1)), type: TransactionType.expense, icon: Icons.shopping_cart),
      AppTransaction(id: _uuid.v4(), userId: userId, title: 'Rent', category: 'Housing', amount: 2000, date: now.subtract(const Duration(days: 2)), type: TransactionType.expense, icon: Icons.home),
    ];
    for (var tx in _transactions) await _txRepo.insertTransaction(tx);

    _savingsGoals = [
      SavingsGoal(id: _uuid.v4(), userId: userId, title: 'Emergency Fund', targetAmount: 15000, currentAmount: 12000, iconStr: '🛡️', color: const Color(0xFF00C853)),
      SavingsGoal(id: _uuid.v4(), userId: userId, title: 'Japan Trip', targetAmount: 5000, currentAmount: 3200, iconStr: '✈️', color: const Color(0xFFFF9800)),
    ];
    for (var g in _savingsGoals) await _savingsRepo.upsertGoal(g);

    notifyListeners();
  }
}

