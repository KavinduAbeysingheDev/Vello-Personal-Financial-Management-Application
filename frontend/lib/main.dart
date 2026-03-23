import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:vello_app/firebase_options.dart';
import 'package:vello_app/services/app_provider.dart';
import 'package:vello_app/screens/setting_screen_backend.dart';
import 'package:vello_app/config/supabase_config.dart';

// ── Screen imports ──────────────────────────────────────────────────────────
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
import 'package:vello_app/all transactions/alltransactions_frontend.dart';
import 'package:vello_app/all transactions/alltransactions_backend.dart';
import 'package:vello_app/screens/splash_screen.dart';

// Settings (full version with dark mode, localization, notifications)
import 'package:vello_app/screens/settings_screen_frontend.dart' as full_settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load Environment Variables
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ .env loaded successfully");
    } catch (e) {
      debugPrint("⚠️ Could not load .env file: $e");
    }

    /* 
    // 2. Initialize Firebase (Optional/Resilient)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase initialized");
    } catch (e) {
      debugPrint("⚠️ Firebase initialization failed (skipping): $e");
    }
    */

    // 3. Initialize Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? SupabaseConfig.supabaseUrl;
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? SupabaseConfig.supabaseAnonKey;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    debugPrint("✅ Supabase initialized");

  } catch (e) {
    debugPrint("❌ CRITICAL STARTUP ERROR: $e");
  }
  
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
          title: 'Vello',
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

// ─────────────────────────────────────────────────────────────────────────────
// AUTH GATE — shows Login if not signed in, otherwise MainScreen
// ─────────────────────────────────────────────────────────────────────────────
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

  // 0: Home, 1: Scan, 2: Add, 3: Statistics, 4: AI
  final List<Widget> _screens = [
    const HomeScreen(),
    const BillScannerScreen(),
    const AddTransactionScreen(),
    const StatisticScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    
    return Scaffold(
      // ── Custom Header (fills status bar) ──────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF042F2E) : const Color(0xFF03724E),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 8),
                // Logo & Title
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CustomPaint(painter: VelloLogoPainter()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  settings.t('Vello'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Profile/Login
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      // ── Drawer ───────────────────────────────────────────────────────
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF042F2E) : const Color(0xFF26a69a),
              ),
              accountName: Text(
                settings.t('Welcome'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                Supabase.instance.client.auth.currentUser?.email ?? '',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(
                  Supabase.instance.client.auth.currentUser?.email?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: isDark ? Colors.white : Colors.black87),
              title: Text(settings.t('My Profile'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: isDark ? Colors.white : Colors.black87),
              title: Text(settings.t('Settings'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(settings.t('Log Out'), style: const TextStyle(color: Colors.red)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // ── Body ─────────────────────────────────────────────────────────
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // ── Bottom Navigation Bar ────────────────────────────────────────
      bottomNavigationBar: Container(
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
                _buildNavItem(0, Icons.account_balance_wallet_outlined, settings.t('Home')),
                _buildNavItem(1, Icons.camera_alt_outlined, settings.t('Scan')),
                _buildCenterAddButton(),
                _buildNavItem(3, Icons.bar_chart_outlined, settings.t('Stats')),
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