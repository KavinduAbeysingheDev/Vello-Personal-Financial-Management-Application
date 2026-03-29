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

  final String? userId; // For Supabase RLS
  final String? rawImportId; // Link to the original SMS/Email text
  final String sourceType; // 'manual', 'sms', 'gmail'

  AppTransaction({
    required this.id,
    this.userId,
    this.rawImportId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
    this.sourceType = 'manual',
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'raw_import_id': rawImportId,
      'source_type': sourceType,
      'merchant': title,
      'amount': amount,
      'category': category,
      'transaction_date': date.toIso8601String(),
      'currency': 'LKR',
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
    };
  }

  factory AppTransaction.fromSupabase(Map<String, dynamic> map) {
    final sourceType = map['source_type'] ?? 'manual';
    final amount = (map['amount'] as num).toDouble();
    final type = sourceType == 'event_auto'
        ? TransactionType.expense
        : (amount >= 0 ? TransactionType.income : TransactionType.expense);

    return AppTransaction(
      id: map['id'],
      userId: map['user_id'],
      rawImportId: map['raw_import_id'],
      sourceType: sourceType,
      title: map['merchant'] ?? 'Unknown',
      category: map['category'] ?? 'Other',
      amount: amount.abs(),
      date: DateTime.parse(map['transaction_date']),
      type: type,
      icon: Icons.receipt_long, // Fallback icon
    );
  }
}

class SavingsGoal {
  String id;
  String? userId;
  String title;
  double targetAmount;
  double currentAmount;
  String iconStr;
  Color color;

  SavingsGoal({
    required this.id,
    this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.iconStr,
    required this.color,
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'icon_str': iconStr,
      'color_hex': '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
    };
  }

  factory SavingsGoal.fromSupabase(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      iconStr: map['icon_str'] ?? '',
      color: Color(int.parse(map['color_hex'].replaceAll('#', ''), radix: 16)),
    );
  }
}

class Subscription {
  String id;
  String? userId;
  String name;
  double cost;
  String billingCycle;
  DateTime nextBillingDate;
  String logoUrl;

  Subscription({
    required this.id,
    this.userId,
    required this.name,
    required this.cost,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.logoUrl,
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'cost': cost,
      'billing_cycle': billingCycle,
      'next_billing_date': nextBillingDate.toIso8601String(),
      'logo_url': logoUrl,
    };
  }

  factory Subscription.fromSupabase(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      cost: (map['cost'] as num).toDouble(),
      billingCycle: map['billing_cycle'] ?? '',
      nextBillingDate: DateTime.parse(map['next_billing_date']),
      logoUrl: map['logo_url'] ?? '',
    );
  }
}

class Debt {
  String id;
  String? userId;
  String name;
  double totalAmount;
  double paidAmount;
  DateTime dueDate;

  Debt({
    required this.id,
    this.userId,
    required this.name,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
  });

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'due_date': dueDate.toIso8601String(),
    };
  }

  factory Debt.fromSupabase(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date']),
    );
  }
}
