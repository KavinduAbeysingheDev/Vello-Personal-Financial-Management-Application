import 'package:flutter/material.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Salary',
      'category': 'Income',
      'date': 'Today, 10:00 AM',
      'amount': 5000.00,
      'isExpense': false,
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Groceries',
      'category': 'Food',
      'date': 'Today, 08:30 AM',
      'amount': 120.50,
      'isExpense': true,
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'date': 'Yesterday',
      'amount': 15.99,
      'isExpense': true,
      'icon': Icons.movie,
    },
    {
      'title': 'Freelance Client',
      'category': 'Income',
      'date': 'Yesterday',
      'amount': 850.00,
      'isExpense': false,
      'icon': Icons.work,
    },
    {
      'title': 'Electricity Bill',
      'category': 'Utilities',
      'date': 'Oct 12',
      'amount': 65.20,
      'isExpense': true,
      'icon': Icons.electric_bolt,
    },
    {
      'title': 'Coffee Shop',
      'category': 'Food & Drinks',
      'date': 'Oct 11',
      'amount': 5.50,
      'isExpense': true,
      'icon': Icons.local_cafe,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the transactions based on the selected chip
    final filteredTransactions = _selectedFilter == 'All'
        ? _transactions
        : _transactions.where((t) => 
            (_selectedFilter == 'Income' && !t['isExpense']) || 
            (_selectedFilter == 'Expense' && t['isExpense'])).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Transactions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Income, Expense)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Income', 'Expense'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: const Color(0xFF0D9488),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[100],
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Transactions List section
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];
                  final isExpense = transaction['isExpense'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isExpense ? Colors.red.withOpacity(0.1) : const Color(0xFF0D9488).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          transaction['icon'] as IconData,
                          color: isExpense ? Colors.red[600] : const Color(0xFF0D9488),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        transaction['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${transaction['category']} • ${transaction['date']}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isExpense ? '-' : '+'}\$${transaction['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isExpense ? Colors.black87 : const Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
