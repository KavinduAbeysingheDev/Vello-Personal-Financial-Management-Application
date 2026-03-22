import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class FinanceService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

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
        final currentSpent = budgetDoc.data()['spent'] ?? 0.0;
        await budgetDoc.reference.update({
          'spent': currentSpent + amount,
        });
      }
    } catch (e) {
      debugPrint('Error updating budget: $e');
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

  // Get transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.date.compareTo(a.date));
      return docs;
    });
  }

  // Get transactions for the last N weeks (for budget planner)
  Future<List<TransactionModel>> getTransactionsForLastNWeeks(
      String userId,
      int weeks,
      ) async {
    final startDate = DateTime.now().subtract(Duration(days: weeks * 7));
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();
    final docs =
    snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    docs.sort((a, b) => a.date.compareTo(b.date));
    return docs;
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get budgets for current month
  Stream<List<Budget>> getBudgets(String userId) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    return _firestore
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: Timestamp.fromDate(currentMonth))
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList());
  }

  // Create or update budget
  Future<void> setBudget({
    required String userId,
    required String category,
    required double limit,
  }) async {
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
        // Update existing budget
        await budgetQuery.docs.first.reference.update({'limit': limit});
      } else {
        // Create new budget
        await _firestore.collection('budgets').add({
          'userId': userId,
          'category': category,
          'limit': limit,
          'spent': 0.0,
          'month': Timestamp.fromDate(currentMonth),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get financial summary
  Stream<Map<String, double>> getFinancialSummary(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) {
      double income = 0;
      double expenses = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] ?? 'expense';

        if (type == 'income') {
          income += amount;
        } else {
          expenses += amount;
        }
      }

      return {
        'income': income,
        'expenses': expenses,
        'totalBalance': income - expenses,
      };
    });
  }

  // Get category-wise spending
  Future<Map<String, double>> getCategorySpending(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, double> categorySpending = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Other';
        final amount = (data['amount'] ?? 0).toDouble();

        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      return categorySpending;
    } catch (e) {
      rethrow;
    }
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
