import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../all transactions/alltransactions_backend.dart';
import '../models/app_models.dart';
import '../screens/setting_screen_backend.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  static const Color _teal = Color(0xFF00875A);
  static const Color _incomeGreen = Color(0xFF2ECC71);
  static const Color _expenseRed = Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) {    final isDark = Provider.of<SettingsProvider>(context).isDarkMode;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF2F2F2);
    final card = isDark ? const Color(0xFF1F2937) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryText =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF888888);
    final dateText = isDark ? const Color(0xFF6B7280) : const Color(0xFFAAAAAA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'All Transactions',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _teal),
            );
          }

          final transactions = provider.filteredTransactions;

          return transactions.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final bool isExpense = tx.type == TransactionType.expense;
                    final String amountStr =
                        (isExpense ? '-' : '+') + r'$' + tx.amount.toStringAsFixed(2);
                    final String dateStr = DateFormat('MMM dd, yyyy').format(tx.date);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isExpense
                                  ? _expenseRed.withOpacity(0.12)
                                  : _incomeGreen.withOpacity(0.12),
                              border: Border.all(
                                color: isExpense
                                    ? _expenseRed.withOpacity(0.5)
                                    : _incomeGreen.withOpacity(0.5),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              isExpense
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: isExpense ? _expenseRed : _incomeGreen,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                    color: primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: dateText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            amountStr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: isExpense ? _expenseRed : _incomeGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => provider.deleteTransaction(tx.id),
                            child: const Icon(
                              Icons.delete_outline,
                              color: _expenseRed,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}


