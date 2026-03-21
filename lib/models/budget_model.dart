import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final double spent;
  final DateTime month;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.spent,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'limit': limit,
      'spent': spent,
      'month': Timestamp.fromDate(month),
    };
  }

  factory BudgetModel.fromMap(String id, Map<String, dynamic> data) {
    return BudgetModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      category: data['category'] as String? ?? '',
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0.0,
      month: (data['month'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
