import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class FinanceService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required String category,
    required String type,
    required DateTime date,
  }) async {
    final transaction = TransactionModel(
      id: '',
      userId: userId,
      title: title,
      amount: amount,
      category: category,
      type: type,
      date: date,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('transactions').add(transaction.toMap());
    if (type == 'expense') {
      await _updateBudgetSpent(userId, category, amount);
    }
  }

  Future<void> _updateBudgetSpent(String userId, String category, double amount) async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final budgetQuery = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .where('month', isEqualTo: Timestamp.fromDate(currentMonth))
          .get();
      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        final currentSpent = (budgetDoc.data()['spent'] as num?)?.toDouble() ?? 0.0;
        await budgetDoc.reference.update({'spent': currentSpent + amount});
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }
}
