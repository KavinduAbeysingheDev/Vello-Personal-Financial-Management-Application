import 'category.dart';

/// Represents a single financial transaction (income or expense).
class Transaction {
  final String id;
  final double amount;
  final Category category;
  final String description;
  final DateTime date;
  final bool isIncome;

  const Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isIncome = false,
  });

  /// Create a Transaction from JSON map.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: Category.fromString(json['category'] as String),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      isIncome: json['isIncome'] as bool? ?? false,
    );
  }

  /// Convert Transaction to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'description': description,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }

  @override
  String toString() =>
      'Transaction(${isIncome ? "+" : "-"}\$${amount.toStringAsFixed(2)} '
      '${category.displayName} - $description)';
}
