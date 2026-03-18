import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class FinanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a transaction
  Future<void> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required String category,
    required String type,
    required DateTime date,
  }) async {
    try {
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

      // Update budget if it's an expense
      if (type == 'expense') {
        await _updateBudgetSpent(userId, category, amount);
      }
    } catch (e) {
      rethrow;
    }
  }