import 'package:flutter/material.dart';

class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo3.png',
                width: 200,
              ),
              const SizedBox(height: 40),
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF22512F),
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D2424),
                  fontFamily: 'Questrial',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your email has been successfully verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Questrial',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D2424),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue to Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Questrial',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
