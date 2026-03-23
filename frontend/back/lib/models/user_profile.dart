import 'transaction.dart';
import 'budget.dart';

/// Represents a user's financial profile with all their data.
class UserProfile {
  final String userId;
  final String name;
  final double totalIncome;
  final double totalExpenses;
  final double savingsGoal;
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final String currency;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.totalIncome,
    required this.totalExpenses,
    this.savingsGoal = 0.0,
    this.transactions = const [],
    this.budgets = const [],
    this.currency = 'USD',
  });

  /// Current balance.
  double get balance => totalIncome - totalExpenses;

  /// Savings rate as a percentage.
  double get savingsRate =>
      totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

  /// Get only expense transactions.
  List<Transaction> get expenses =>
      transactions.where((t) => !t.isIncome).toList();

  /// Get only income transactions.
  List<Transaction> get incomes =>
      transactions.where((t) => t.isIncome).toList();

  /// Create a copy with updated fields.
  UserProfile copyWith({
    String? userId,
    String? name,
    double? totalIncome,
    double? totalExpenses,
    double? savingsGoal,
    List<Transaction>? transactions,
    List<Budget>? budgets,
    String? currency,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      transactions: transactions ?? this.transactions,
      budgets: budgets ?? this.budgets,
      currency: currency ?? this.currency,
    );
  }

  /// Convert UserProfile to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'savingsRate': savingsRate,
      'savingsGoal': savingsGoal,
      'currency': currency,
      'transactionCount': transactions.length,
      'budgetCount': budgets.length,
    };
  }
}
