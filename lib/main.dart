import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/app_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const VelloApp(),
    ),
  );
}

class VelloApp extends StatelessWidget {
  const VelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vello',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      home: const _AppLoader(),
    );
  }
}

/// Loads all persisted data from SQLite before showing the splash screen.
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
        return const SplashScreen();
      },
    );
  }
}
