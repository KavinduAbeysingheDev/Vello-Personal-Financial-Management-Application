import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const VelloApp());
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
}