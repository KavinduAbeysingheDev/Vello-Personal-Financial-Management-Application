import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/app_provider.dart';

// ── Screen imports ──────────────────────────────────────────────────────────
import 'Saving_goals/saving_goals_frontend.dart';
import 'Saving_goals/saving_goals_painter.dart';
import 'Statistic/Statistic_Frontend.dart';
import 'AI/AI_frontend.dart';
import 'screens/add_transaction_page.dart';
import 'screens/budget_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_page.dart';
import 'screens/login_screen.dart';
import 'features/bill_scanner/bill_scanner_screen.dart';
import 'all transactions/alltransactions_frontend.dart';
import 'all transactions/alltransactions_backend.dart';
import 'screens/splash_screen.dart';

// Settings (full version with dark mode, localization, notifications)
import 'screens/settings_screen_frontend.dart' as full_settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://akhhxegpljrzmkziirng.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFraGh4ZWdwbGpyem1remlpcm5nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxNzE0NzksImV4cCI6MjA4OTc0NzQ3OX0.M5-oSPlXcfeHdY66q622RtrMDMl6sI9phGRlrQzaKnk',
  );
  
  // We wrap AppProvider here but then initialize it in AppLoader
  runApp(const VelloApp());
}

class VelloApp extends StatelessWidget {
  const VelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vello',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF03724E)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        ),
        home: const _AppLoader(),
        routes: {
          '/savings': (context) => const SavingsGoalsScreen(),
          '/ai': (context) => const AIFinanceScreen(),
          '/statistics': (context) => const StatisticScreen(),
        },
      ),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = Provider.of<AppProvider>(context, listen: false).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF004D40),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // Once database defaults are loaded, go to AuthGate
        return const AuthGate();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH GATE — shows Login if not signed in, otherwise MainScreen
// ─────────────────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const MainScreen();
    }
    return const LoginScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN NAVIGATION WRAPPER (Global Header & Footer)
// ─────────────────────────────────────────────────────────────────────────────
>>>>>>> 7788682 (fix(nav): wire up main navigation and fix missing scaffolding on pushed screens)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

<<<<<<< HEAD
  final List<Widget> _screens = [
    const SavingsGoalsScreen(),
    const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Scan / QR\n(Placeholder)', textAlign: TextAlign.center),
        ],
      ),
    ),
    const Center(child: Text('Add Transaction Placeholder')),
    const StatisticScreen(),
    const AIFinanceScreen(),
=======
  // 0: Home (Savings Goals), 1: Scan (Bill Scanner), 2: Add (center btn),
  // 3: Events (Statistics), 4: AI
  final List<Widget> _screens = [
    const HomeScreen(),               // Index 0: Home
    const BillScannerScreen(),        // Index 1: Scan
    const Center(child: Text('Add')), // Index 2: placeholder (center btn navigates)
    const StatisticScreen(),          // Index 3: Events / Statistics
    const AIFinanceScreen(),          // Index 4: AI
>>>>>>> 7788682 (fix(nav): wire up main navigation and fix missing scaffolding on pushed screens)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
=======
      // ── Global Header ─────────────────────────────────────────────────
>>>>>>> 7788682 (fix(nav): wire up main navigation and fix missing scaffolding on pushed screens)
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
          // ── Menu Popup ──────────────────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onSelected: (value) {
              switch (value) {
                case 'transactions':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllTransactionsScreen(),
                    ),
                  );
                  break;
                case 'statistics':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StatisticScreen(),
                    ),
                  );
                  break;
                case 'savings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SavingsGoalsScreen(),
                    ),
                  );
                  break;
                case 'budget':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BudgetScreen(),
                    ),
                  );
                  break;
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'transactions',
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('All Transactions'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.bar_chart_outlined),
                  title: Text('Statistics'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'savings',
                child: ListTile(
                  leading: Icon(Icons.savings_outlined),
                  title: Text('Saving Goals'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'budget',
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet_outlined),
                  title: Text('Budget'),
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  dense: true,
                ),
              ),
            ],
          ),
          // ── Settings Button ────────────────────────────────────────
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const full_settings.SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
<<<<<<< HEAD
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
=======

      // ── Body ─────────────────────────────────────────────────────────
      body: IndexedStack(index: _currentIndex, children: _screens),

      // ── Bottom Navigation Bar ────────────────────────────────────────
>>>>>>> 7788682 (fix(nav): wire up main navigation and fix missing scaffolding on pushed screens)
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
                _buildNavItem(0, Icons.account_balance_wallet_outlined, 'Home'),
                _buildNavItem(1, Icons.camera_alt_outlined, 'Scan'),
                _buildCenterAddButton(),
                _buildNavItem(3, Icons.calendar_today_outlined, 'Events'),
                _buildNavItem(4, Icons.smart_toy_outlined, 'AI'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color =
        isSelected ? const Color(0xFF059669) : const Color(0xFF9CA3AF);

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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
        );
      },
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