import 'package:flutter/material.dart';

import 'package:myapp/services/auth_service.dart'; // ✅ Import AuthService
import 'register_screen.dart';
import '../guest/home_screen_guest.dart';
import '../member/home_screen_member.dart';
import '../auth/forgot_password.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFFF2D8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Questrial',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF882424),
                    foregroundColor: const Color(0xFFFFF2D8),
                  ),
                  child: const Text(
                    "OK",
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22512F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 300,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Color(0xFF22512F)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFF2D8),
                    hintText: 'Username or Email',
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
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF22512F)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFFFF2D8),
                    hintText: 'Password',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF2D8),
                        foregroundColor: const Color(0xFF22512F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (usernameController.text.isEmpty &&
                            passwordController.text.isEmpty) {
                          _showErrorDialog(context,
                              "Please provide both username and password.");
                        } else if (usernameController.text.isEmpty) {
                          _showErrorDialog(
                              context, "Please provide your username.");
                        } else if (passwordController.text.isEmpty) {
                          _showErrorDialog(
                              context, "Please provide your password.");
                        } else {
                          // ✅ บันทึกว่าเป็น Member
                          await AuthService.setMemberStatus(true);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreenMember()),
                          );
                        }
                      },
                      child: const Text('Sign In',
                          style: TextStyle(
                              fontFamily: 'Questrial',
                              fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF2D8),
                        foregroundColor: const Color(0xFF22512F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: const Text('Register',
                          style: TextStyle(
                              fontFamily: 'Questrial',
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Questrial'),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF2D8),
                    foregroundColor: const Color(0xFF22512F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // ✅ บันทึกว่าเป็น Guest
                    await AuthService.setMemberStatus(false);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreenGuest()),
                    );
                  },
                  child: const Text('Guest',
                      style: TextStyle(
                          fontFamily: 'Questrial',
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
