import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ฟังก์ชันแสดง Dialog สำหรับแสดงข้อความผิดพลาด
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
                const Text(
                  "",
                  style: TextStyle(
                    fontFamily: 'Questrial',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
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
                  style: TextStyle(
                    color: const Color(0xFF22512F), // สีข้อความเป็นสีเขียว
                  ),
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
                  style: TextStyle(
                    color: const Color(0xFF22512F), // สีข้อความเป็นสีเขียว
                  ),
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
                      onPressed: () {
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
                          // ใส่โค้ดตรวจสอบข้อมูลผู้ใช้ที่นี่
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
                              builder: (context) =>
                                  RegisterScreen()), // ไปที่หน้าลงทะเบียน
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
                  onPressed: () {},
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Questrial'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
