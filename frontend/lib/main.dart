import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vello_app/l10n/app_localizations.dart';
// import 'package:vello_app/firebase_options.dart';
import 'package:vello_app/services/app_provider.dart';
import 'package:vello_app/screens/setting_screen_backend.dart';
import 'package:vello_app/config/supabase_config.dart';
import 'package:vello_app/services/reminder_service.dart';

// â”€â”€ Screen imports â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
import 'package:vello_app/Saving_goals/saving_goals_frontend.dart';
import 'package:vello_app/Saving_goals/saving_goals_painter.dart';
import 'package:vello_app/Statistic/Statistic_Frontend.dart';
import 'package:vello_app/screens/add_transaction_page.dart';
import 'package:vello_app/screens/budget_screen.dart';
import 'package:vello_app/screens/home_screen.dart';
import 'package:vello_app/screens/profile_page.dart';
import 'package:vello_app/screens/login_screen.dart';
import 'package:vello_app/screens/settings_screen_frontend.dart';
import 'package:vello_app/screens/register_screen.dart';
import 'package:vello_app/features/bill_scanner/bill_scanner_screen.dart';
import 'package:vello_app/screens/event_planner_screen.dart';
import 'package:vello_app/all transactions/alltransactions_frontend.dart';
import 'package:vello_app/all transactions/alltransactions_backend.dart';
import 'package:vello_app/screens/splash_screen.dart';
import 'package:vello_app/screens/drawer_screens/weekly_planner_screen.dart';
import 'package:vello_app/widgets/vello_top_bar.dart';
import 'package:vello_app/widgets/vello_drawer.dart';
import 'package:vello_app/l10n/l10n.dart';

// Settings (full version with dark mode, localization, notifications)
import 'package:vello_app/screens/settings_screen_frontend.dart' as full_settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load Environment Variables
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("âœ… .env loaded successfully");
    } catch (e) {
      debugPrint("âš ï¸ Could not load .env file: $e");
    }

    /* 
    // 2. Initialize Firebase (Optional/Resilient)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("âœ… Firebase initialized");
    } catch (e) {
      debugPrint("âš ï¸ Firebase initialization failed (skipping): $e");
    }
    */

    // 3. Initialize Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? SupabaseConfig.supabaseUrl;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? SupabaseConfig.supabaseAnonKey;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint("âœ… Supabase initialized");

  } catch (e) {
    debugPrint("âŒ CRITICAL STARTUP ERROR: $e");
  }

  await ReminderService.instance.initialize();
  
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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: settings.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('si'),
            Locale('ta'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF03724E),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF03724E),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF111827),
          ),
          home: const SplashScreen(),
          routes: {
            '/load': (context) => const _AppLoader(),
            '/savings': (context) => const SavingsGoalsScreen(),
            '/statistics': (context) => const StatisticScreen(),
          },
          );
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AUTH GATE â€” shows Login if not signed in, otherwise MainScreen
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// MAIN NAVIGATION WRAPPER (Global Header & Footer)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  // 0: Home, 1: Scan, 2: Event, 3: AI
  final List<Widget> _screens = [
    const HomeScreen(),
    const BillScannerScreen(),
    const EventPlannerScreen(),
    const WeeklyPlannerScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    
    return Scaffold(
      // â”€â”€ Custom Header (fills status bar) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // â”€â”€ Bottom Navigation Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _currentIndex,
        isDark: isDark,
        homeLabel: context.l10n.home,
        scanLabel: context.l10n.scan,
        eventLabel: context.l10n.event,
        aiLabel: context.l10n.ai,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        onAddTransactionTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }
}

class MainBottomNavigationBar extends StatelessWidget {
  const MainBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.isDark,
    required this.homeLabel,
    required this.scanLabel,
    required this.eventLabel,
    required this.aiLabel,
    required this.onItemSelected,
    required this.onAddTransactionTap,
  });

  final int currentIndex;
  final bool isDark;
  final String homeLabel;
  final String scanLabel;
  final String eventLabel;
  final String aiLabel;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.account_balance_wallet_outlined,
                label: homeLabel,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.camera_alt_outlined,
                label: scanLabel,
              ),
              _buildCenterAddButton(),
              _buildNavItem(
                index: 2,
                icon: Icons.calendar_month_outlined,
                label: eventLabel,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.smart_toy_outlined,
                label: aiLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color =
        isSelected ? const Color(0xFF059669) : const Color(0xFF9CA3AF);

    return InkWell(
      key: Key('main-nav-$index'),
      onTap: () => onItemSelected(index),
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
      key: const Key('main-nav-add'),
      onTap: onAddTransactionTap,
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

