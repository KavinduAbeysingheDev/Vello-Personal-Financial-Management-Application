import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container( // creating a background gradiant
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF26a69a), Color(0xFF1e8c82)],
          )
        ),
        child: SafeArea( // push the content down to prevent content from impact with the phones notches and status bars
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Making the vello logo appear on the top of the page
                  Center(
                    child: Image.asset(
                      'assets/images/vello_logo.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain
                    ),
                  ),
                  // Add the Application Name
                  const SizedBox(height: 20),
                  const Text(
                    'Vello',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              )
            )
          )
        )
      ),
    );
  }
}