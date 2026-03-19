import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'all transactions/alltransactions_backend.dart';
import 'all transactions/alltransactions_frontend.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
