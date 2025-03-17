import 'package:flutter/material.dart';
import 'package:myapp/db.dart';
import 'package:myapp/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  DatabaseHelper? _dbHelper;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _dbHelper = await DatabaseHelper.createInstance();
    setState(() {});
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _dbHelper?.close();
    super.dispose();
  }

  void _register() {
    if (!mounted) return;

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ตรวจสอบอีเมลว่าต้องมี @ และรูปแบบถูกต้อง
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid email format.",
              style: TextStyle(fontFamily: 'Questrial'))));
      return;
    }

    // ตรวจสอบรหัสผ่านต้องมี 5 ตัวขึ้นไปและมีทั้งตัวอักษรและตัวเลข
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{5,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Password must be at least 5 characters long and include letters and numbers.",
              style: TextStyle(fontFamily: 'Questrial'))));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Passwords do not match.",
              style: TextStyle(fontFamily: 'Questrial'))));
      return;
    }

    try {
      _dbHelper?.registerUser(
          email: email, username: username, password: password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration successful!",
              style: TextStyle(fontFamily: 'Questrial'))));

      emailController.clear();
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      _dbHelper?.queryUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration failed: $e",
              style: TextStyle(fontFamily: 'Questrial'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, // ป้องกันการ resize อัตโนมัติ
      body: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // ปิดแป้นพิมพ์เมื่อแตะพื้นที่ว่าง
        child: Stack(
          children: [
            // Top Section with Image
            Container(
              height: height * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/start.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Bottom Section with Form
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(
                top: isKeyboardVisible
                    ? height * 0.15 // ขยับขึ้นเมื่อแป้นพิมพ์แสดง
                    : height * 0.35, // ตำแหน่งปกติ
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardHeight + 20),
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
                    _buildTextField(
                        usernameController, "Choose a username", Icons.person),
                    _buildTextField(
                        passwordController, "Enter your password", Icons.lock,
                        obscureText: !_isPasswordVisible,
                        toggleObscureText: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
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
