import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class AppTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final IconData icon;

  AppTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      icon: IconData(map['iconCodePoint'], fontFamily: map['iconFontFamily']),
    );
  }
}

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final String iconStr;
  final Color color;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.iconStr,
    required this.color,
  });
}

class Subscription {
  final String id;
  final String name;
  final double cost;
  final String billingCycle;
  final DateTime nextBillingDate;
  final String logoUrl;

  Subscription({
    required this.id,
    required this.name,
    required this.cost,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.logoUrl,
  });
}

class Debt {
  final String id;
  final String name;
  final double totalAmount;
  double paidAmount;
  final DateTime dueDate;

  Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
  });
}
