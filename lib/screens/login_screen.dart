import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @Override
  State<LoginScreen> createState()=> _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @Override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF26a69a), Color(0xFF1e8c82)],
          ),
        ),
      ),
    );
  }
}