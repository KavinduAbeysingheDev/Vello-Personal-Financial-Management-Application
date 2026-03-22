import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'all transactions/alltransactions_backend.dart';
import 'all transactions/alltransactions_frontend.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vello',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
          useMaterial3: true,
        ),
        home: const AllTransactionsScreen(),
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