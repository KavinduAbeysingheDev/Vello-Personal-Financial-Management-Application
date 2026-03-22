import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

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
      title: 'Vello Financial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      // This loads your register_screen.dart file
      home: const RegisterScreen(),
    );
  }
      debugShowCheckedModeBanner: false,
      title: 'Vello App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00674F),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;
  final _gmailService = GmailDetectorService();
  final _smsService = SmsDetectorService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _gmailService.isEnabled().then((enabled) {
        if (enabled) _gmailService.scanAndStore().catchError((_) => 0);
      }).catchError((_) {});
      _smsService.isEnabled().then((enabled) {
        if (enabled) _smsService.scanAndStore().catchError((_) => 0);
      }).catchError((_) {});
    }
  }

  final List<Widget> _pages = [
    const PlaceholderPage(label: 'Home'),
    const BillScannerScreen(),
    const PlaceholderPage(label: 'Events'),
    const PlaceholderPage(label: 'AI'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF3B5BDB),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _currentIndex == 1 ? null : BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _navItem(icon: Icons.document_scanner_rounded, label: 'Scan', index: 1),
            const SizedBox(width: 48),
            _navItem(icon: Icons.event_rounded, label: 'Events', index: 2),
            _navItem(icon: Icons.auto_awesome_rounded, label: 'AI', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00674F) : const Color(0xFF6B7280),
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF00674F) : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final items = [
      {
        'icon': Icons.list_alt_rounded,
        'title': 'All Transactions',
        'sub': 'View transaction history',
        'screen': null,
      },
      {
        'icon': Icons.pie_chart_rounded,
        'title': 'Budget Overview',
        'sub': 'Track your budgets',
        'screen': null,
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': 'Weekly Planner',
        'sub': 'AI-powered budget planning',
        'screen': null,
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Statistics',
        'sub': 'View spending analytics',
        'screen': null,
      },
      {
        'icon': Icons.track_changes_rounded,
        'title': 'Savings Goals',
        'sub': 'Set and track savings goals',
        'screen': null,
      },
      {
        'icon': Icons.credit_card_rounded,
        'title': 'Subscription Manager',
        'sub': 'Manage and cancel subscriptions',
        'screen': null,
      },
      {
        'icon': Icons.warning_amber_rounded,
        'title': 'Debt Tracker',
        'sub': 'Track and manage debt',
        'screen': null,
      },
      {
        'icon': Icons.mic_rounded,
        'title': 'Voice Expense',
        'sub': 'Add expenses using voice',
        'screen': null,
      },
      {
        'icon': Icons.favorite_border_rounded,
        'title': 'Financial Health',
        'sub': 'Assess your financial health',
        'screen': null,
      },
      {
        'icon': Icons.email_rounded,
        'title': 'Email Bills',
        'sub': 'Auto-detect bills from Gmail',
        'screen': null,
      },
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 160),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    leading: Icon(
                      item['icon'] as IconData,
                      color: const Color(0xFF00674F),
                      size: 24,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    subtitle: Text(
                      item['sub'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (item['screen'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => item['screen'] as Widget,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


class PlaceholderPage extends StatelessWidget {
  final String label;
  const PlaceholderPage({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00674F),
          ),
        ),
      ),
    );
  }
}