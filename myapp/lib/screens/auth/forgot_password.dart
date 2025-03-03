import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22512F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22512F),
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontFamily: 'Questrial', color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your email to reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Questrial',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Color(0xFF22512F)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFFF2D8),
                hintText: 'Email Address',
                hintStyle: const TextStyle(
                  fontFamily: 'Questrial',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(136, 38, 87, 52),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF2D8),
                foregroundColor: const Color(0xFF22512F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Implement password reset logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Reset Password',
                style: TextStyle(
                  fontFamily: 'Questrial',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
