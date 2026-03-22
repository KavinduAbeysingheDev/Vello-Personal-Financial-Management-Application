import 'package:flutter/material.dart';
import 'Saving_goals/saving_goals_frontend.dart';
import 'Statistic/Statistic_Frontend.dart';
import 'AI/AI_frontend.dart';

import 'Saving_goals/saving_goals_painter.dart';

void main() {
  runApp(const VelloApp());
import 'package:firebase_core/firebase_core.dart';
import 'features/bill_scanner/bill_scanner_screen.dart';
import 'features/gmail_detector/gmail_detector_service.dart';
import 'features/sms_detector/sms_detector_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class VelloApp extends StatelessWidget {
  // Corrected constructor name to match the class name
  const VelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vello',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF03724E)),
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
// MAIN NAVIGATION WRAPPER (Global Header & Footer)
// ─────────────────────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens available in the navigation bar
  // 0: Home (Wallet icon), 1: Scan (Camera), 2: Add, 3: Events (Calendar icon), 4: AI (Robot icon)
  final List<Widget> _screens = [
    const SavingsGoalsScreen(), // Index 0: Home (Mapped to Savings Goals for now as it's the most wallet-related)
    const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Scan / QR\n(Placeholder)', textAlign: TextAlign.center),
        ],
      ),
    ), // Index 1: Scan
    const Center(child: Text('Add Transaction Placeholder')), // Index 2: Add
    const StatisticScreen(), // Index 3: Events (Mapped to Statistics)
    const AIFinanceScreen(), // Index 4: AI
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Global Header consistently visible across all main screens
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF03724E), Color(0xFF069668)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(painter: VelloLogoPainter()),
              ),
            ),
          ),
        ),
        title: const Text(
          'Vello',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.account_balance_wallet_outlined, 'Home'), // Wallet Icon
                _buildNavItem(1, Icons.camera_alt_outlined, 'Scan'), // Camera/QR Icon
                _buildCenterAddButton(),
                _buildNavItem(3, Icons.calendar_today_outlined, 'Events'), // Calendar Icon
                _buildNavItem(4, Icons.smart_toy_outlined, 'AI'), // Robot Icon
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