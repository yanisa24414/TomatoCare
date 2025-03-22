import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:myapp/screens/auth/login_screen.dart';

import '../../db.dart'; // ใช้แค่อันนี้อันเดียว และลบ database_helper.dart ออก

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _logger = Logger('RegisterScreen');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!mounted) return;

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ตรวจสอบอีเมล
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format.")),
      );
      return;
    }

    // ตรวจสอบรหัสผ่าน
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must be at least 6 characters long")),
      );
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Password must contain at least one uppercase letter")),
      );
      return;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Password must contain at least one lowercase letter")),
      );
      return;
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password must contain at least one number")),
      );
      return;
    }

    // ตรวจสอบรหัสผ่านตรงกัน
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // ถ้าผ่านการตรวจสอบทั้งหมด ดำเนินการลงทะเบียน
    try {
      // ใช้ DatabaseHelper แทน AuthService
      await DatabaseHelper.instance.registerUser(
        email: email,
        username: username,
        password: password,
      );

      if (!mounted) return;

      // แสดง SnackBar แจ้งสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Color(0xFF22512F),
        ),
      );

      _logger.info('New user registered: $email, username: $username');

      // รอ 2 วินาทีแล้วนำทางไปหน้า login
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      _logger.severe('Registration error occurred', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final height = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: isWeb
            ? Center(
                // Web layout
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(32),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7D2424),
                              fontFamily: 'Questrial',
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildTextField(
                              emailController, "Enter your email", Icons.email),
                          _buildTextField(usernameController,
                              "Choose a username", Icons.person),
                          _buildTextField(passwordController,
                              "Enter your password", Icons.lock,
                              obscureText: !_isPasswordVisible,
                              toggleObscureText: () {
                            setState(
                                () => _isPasswordVisible = !_isPasswordVisible);
                          }),
                          _buildTextField(confirmPasswordController,
                              "Confirm your password", Icons.lock,
                              obscureText: !_isConfirmPasswordVisible,
                              toggleObscureText: () {
                            setState(() => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible);
                          }),
                          SizedBox(height: 20),
                          _buildButton(
                              "Register", Color(0xFF7D2424), _register),
                          SizedBox(height: 15),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              ),
                              child: Text(
                                "Go to Login",
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: Color(0xFF22512F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Stack(
                // Mobile layout
                children: [
                  // Background Image (mobile only)
                  Container(
                    height: height * 0.5,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/start.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Bottom Section with Form
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      top: keyboardHeight > 0
                          ? height * 0.15 // ขยับขึ้นเมื่อแป้นพิมพ์แสดง
                          : height * 0.45, // ตำแหน่งปกติ
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.fromLTRB(20, 20, 20, keyboardHeight + 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create New Account',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7D2424),
                              fontFamily: 'Questrial',
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(
                              emailController, "Enter your email", Icons.email),
                          _buildTextField(usernameController,
                              "Choose a username", Icons.person),
                          _buildTextField(passwordController,
                              "Enter your password", Icons.lock,
                              obscureText: !_isPasswordVisible,
                              toggleObscureText: () {
                            setState(
                                () => _isPasswordVisible = !_isPasswordVisible);
                          }),
                          _buildTextField(confirmPasswordController,
                              "Confirm your password", Icons.lock,
                              obscureText: !_isConfirmPasswordVisible,
                              toggleObscureText: () {
                            setState(() => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible);
                          }),
                          const SizedBox(height: 20),
                          _buildButton(
                              "Register", const Color(0xFF7D2424), _register),
                          const SizedBox(height: 15),
                          // Replace button with text
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              ),
                              child: Text(
                                "Go to Login",
                                style: TextStyle(
                                  fontFamily: 'Questrial',
                                  color: const Color(0xFF22512F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง TextField พร้อมไอคอนเปิด/ปิดรหัสผ่าน
  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false, VoidCallback? toggleObscureText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontFamily: 'Questrial'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Questrial', color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.brown),
          suffixIcon: toggleObscureText != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.brown,
                  ),
                  onPressed: toggleObscureText,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.brown, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7D2424)),
          ),
        ),
      ),
    );
  }
}
