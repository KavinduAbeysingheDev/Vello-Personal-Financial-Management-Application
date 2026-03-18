import 'package:flutter/material.dart';
import 'Saving_goals/saving_goals_frontend.dart';
import 'Statistic/Statistic_Frontend.dart';
import 'AI/AI_frontend.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vello',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF059669)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      routes: {
        '/savings': (context) => const SavingsGoalsScreen(),
        '/ai': (context) => const AIFinanceScreen(),
        '/statistics': (context) => const StatisticScreen(),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN NAVIGATION WRAPPER (Updated to remove Statistics from Bottom Bar)
// ─────────────────────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens available in the navigation bar
  final List<Widget> _screens = [
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Home Dashboard\n(To be developed by teammate)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ), // Index 0: Home Placeholder
    const SavingsGoalsScreen(), // Index 1: Savings Goals
    const Center(child: Text('Add Transaction Placeholder')), // Index 2: Add
    const AIFinanceScreen(), // Index 3: AI (Moved from index 4)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.home_outlined, 'Home'),
                _buildNavItem(
                  1,
                  Icons.account_balance_wallet_outlined,
                  'Savings',
                ),
                _buildCenterAddButton(),
                _buildNavItem(
                  3,
                  Icons.smart_toy_outlined,
                  'AI Chat',
                ), // Statistics removed
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? const Color(0xFF059669)
        : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
