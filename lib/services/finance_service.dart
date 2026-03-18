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

  // Update budget spent amount
  Future<void> _updateBudgetSpent(
      String userId, String category, double amount) async {
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
        final currentSpent = budgetDoc.data()['spent'] ?? 0.0;
        await budgetDoc.reference.update({
          'spent': currentSpent + amount,
        });
      }
    } catch (e) {
      print('Error updating budget: $e');
    }
  }

  // Get all transactions for a user
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList());
  }