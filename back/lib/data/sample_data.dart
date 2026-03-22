import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/user_profile.dart';

/// Sample data for demo/testing the chatbot without a real database.
class SampleData {
  SampleData._();

  static final DateTime _now = DateTime.now();

  /// Generate a sample user profile with realistic financial data.
  static UserProfile getSampleUser() {
    final transactions = _getSampleTransactions();
    final budgets = _getSampleBudgets(transactions);

    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return UserProfile(
      userId: 'demo_user_001',
      name: 'Demo User',
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      savingsGoal: 1000.0,
      transactions: transactions,
      budgets: budgets,
      currency: 'USD',
    );
  }

  /// Sample transactions for the current month.
  static List<Transaction> _getSampleTransactions() {
    return [
      // ── Income ──────────────────────────────────────────────────────
      Transaction(
        id: 'txn_001',
        amount: 4500.00,
        category: Category.salary,
        description: 'Monthly Salary',
        date: DateTime(_now.year, _now.month, 1),
        isIncome: true,
      ),
      Transaction(
        id: 'txn_002',
        amount: 350.00,
        category: Category.freelance,
        description: 'Freelance Web Design',
        date: DateTime(_now.year, _now.month, 5),
        isIncome: true,
      ),

      // ── Food & Groceries ────────────────────────────────────────────
      Transaction(
        id: 'txn_010',
        amount: 45.20,
        category: Category.food,
        description: 'Restaurant dinner',
        date: DateTime(_now.year, _now.month, 2),
      ),
      Transaction(
        id: 'txn_011',
        amount: 12.50,
        category: Category.food,
        description: 'Coffee shop',
        date: DateTime(_now.year, _now.month, 3),
      ),
      Transaction(
        id: 'txn_012',
        amount: 32.80,
        category: Category.food,
        description: 'Lunch with colleagues',
        date: DateTime(_now.year, _now.month, 5),
      ),
      Transaction(
        id: 'txn_013',
        amount: 8.90,
        category: Category.food,
        description: 'Morning coffee & pastry',
        date: DateTime(_now.year, _now.month, 7),
      ),
      Transaction(
        id: 'txn_014',
        amount: 67.50,
        category: Category.food,
        description: 'Weekend brunch',
        date: DateTime(_now.year, _now.month, 8),
      ),
      Transaction(
        id: 'txn_020',
        amount: 125.30,
        category: Category.groceries,
        description: 'Weekly groceries',
        date: DateTime(_now.year, _now.month, 3),
      ),
      Transaction(
        id: 'txn_021',
        amount: 98.40,
        category: Category.groceries,
        description: 'Weekly groceries',
        date: DateTime(_now.year, _now.month, 10),
      ),

      // ── Transport ──────────────────────────────────────────────────
      Transaction(
        id: 'txn_030',
        amount: 55.00,
        category: Category.transport,
        description: 'Gas/fuel',
        date: DateTime(_now.year, _now.month, 4),
      ),
      Transaction(
        id: 'txn_031',
        amount: 15.00,
        category: Category.transport,
        description: 'Uber ride',
        date: DateTime(_now.year, _now.month, 6),
      ),
      Transaction(
        id: 'txn_032',
        amount: 85.00,
        category: Category.transport,
        description: 'Monthly transit pass',
        date: DateTime(_now.year, _now.month, 1),
      ),

      // ── Bills & Utilities ──────────────────────────────────────────
      Transaction(
        id: 'txn_040',
        amount: 89.50,
        category: Category.bills,
        description: 'Electric Company',
        date: DateTime(_now.year, _now.month, 5),
      ),
      Transaction(
        id: 'txn_041',
        amount: 65.00,
        category: Category.bills,
        description: 'Internet Service',
        date: DateTime(_now.year, _now.month, 5),
      ),
      Transaction(
        id: 'txn_042',
        amount: 45.00,
        category: Category.bills,
        description: 'Phone Bill',
        date: DateTime(_now.year, _now.month, 7),
      ),

      // ── Rent ──────────────────────────────────────────────────────
      Transaction(
        id: 'txn_050',
        amount: 1200.00,
        category: Category.rent,
        description: 'Monthly Rent',
        date: DateTime(_now.year, _now.month, 1),
      ),

      // ── Entertainment ─────────────────────────────────────────────
      Transaction(
        id: 'txn_060',
        amount: 15.99,
        category: Category.entertainment,
        description: 'Netflix subscription',
        date: DateTime(_now.year, _now.month, 1),
      ),
      Transaction(
        id: 'txn_061',
        amount: 42.00,
        category: Category.entertainment,
        description: 'Movie tickets',
        date: DateTime(_now.year, _now.month, 9),
      ),
      Transaction(
        id: 'txn_062',
        amount: 25.00,
        category: Category.entertainment,
        description: 'Spotify Premium',
        date: DateTime(_now.year, _now.month, 1),
      ),

      // ── Shopping ──────────────────────────────────────────────────
      Transaction(
        id: 'txn_070',
        amount: 89.99,
        category: Category.shopping,
        description: 'New sneakers',
        date: DateTime(_now.year, _now.month, 6),
      ),
      Transaction(
        id: 'txn_071',
        amount: 34.50,
        category: Category.shopping,
        description: 'Amazon order',
        date: DateTime(_now.year, _now.month, 8),
      ),

      // ── Health ────────────────────────────────────────────────────
      Transaction(
        id: 'txn_080',
        amount: 30.00,
        category: Category.health,
        description: 'Gym membership',
        date: DateTime(_now.year, _now.month, 1),
      ),
      Transaction(
        id: 'txn_081',
        amount: 25.00,
        category: Category.health,
        description: 'Pharmacy',
        date: DateTime(_now.year, _now.month, 4),
      ),

      // ── Education ─────────────────────────────────────────────────
      Transaction(
        id: 'txn_090',
        amount: 29.99,
        category: Category.education,
        description: 'Online course',
        date: DateTime(_now.year, _now.month, 3),
      ),
    ];
  }

  /// Sample budgets based on actual spending.
  static List<Budget> _getSampleBudgets(List<Transaction> transactions) {
    // Calculate actual spending per category
    final spendingByCategory = <Category, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      spendingByCategory[t.category] =
          (spendingByCategory[t.category] ?? 0) + t.amount;
    }

    return [
      Budget(
        category: Category.food,
        limit: 200.00,
        spent: spendingByCategory[Category.food] ?? 0,
      ),
      Budget(
        category: Category.groceries,
        limit: 250.00,
        spent: spendingByCategory[Category.groceries] ?? 0,
      ),
      Budget(
        category: Category.transport,
        limit: 200.00,
        spent: spendingByCategory[Category.transport] ?? 0,
      ),
      Budget(
        category: Category.entertainment,
        limit: 100.00,
        spent: spendingByCategory[Category.entertainment] ?? 0,
      ),
      Budget(
        category: Category.shopping,
        limit: 150.00,
        spent: spendingByCategory[Category.shopping] ?? 0,
      ),
      Budget(
        category: Category.bills,
        limit: 250.00,
        spent: spendingByCategory[Category.bills] ?? 0,
      ),
      Budget(
        category: Category.health,
        limit: 100.00,
        spent: spendingByCategory[Category.health] ?? 0,
      ),
      Budget(
        category: Category.rent,
        limit: 1200.00,
        spent: spendingByCategory[Category.rent] ?? 0,
      ),
    ];
  }
}
