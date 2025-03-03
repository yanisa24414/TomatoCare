import 'package:flutter/material.dart';
import 'package:myapp/db.dart'; // Ensure the path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration successful!",
              style: TextStyle(fontFamily: 'Questrial'))));

      emailController.clear();
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      _dbHelper?.queryUsers();
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration failed: $e",
              style: TextStyle(fontFamily: 'Questrial'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3), // พื้นหลังสีเดียว
      appBar: AppBar(
        backgroundColor: Color(0xFF22512F),
        elevation: 0,
        title: Text(
          "Register",
          style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: null, // ลบปุ่มลูกศรย้อนกลับออก
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ทำให้ Column ไม่ยืดเต็มหน้าจอ
          crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
          children: [
            Align(
              alignment: Alignment.topCenter, // จัดให้อยู่ด้านบนตรงกลาง
              child: Column(
                children: [
                  _buildTextField(
                      emailController, "Enter your email", Icons.email),
                  _buildTextField(
                      usernameController, "Choose a username", Icons.person),
                  _buildTextField(
                      passwordController, "Enter your password", Icons.lock,
                      obscureText: !_isPasswordVisible, toggleObscureText: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  _buildTextField(confirmPasswordController,
                      "Confirm your password", Icons.lock,
                      obscureText: !_isConfirmPasswordVisible,
                      toggleObscureText: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 20), // เพิ่มระยะห่าง
                  GestureDetector(
                    onTap: _register,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF7D2424),
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
                          "Register",
                          style: TextStyle(
                            fontFamily: 'Questrial',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // เพิ่มระยะห่าง
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, '/login'); // เพิ่มปุ่มไปหน้า Login
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFF22512F),
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
                          "Go to Login",
                          style: TextStyle(
                            fontFamily: 'Questrial',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50), // เว้นที่ว่างด้านล่าง
          ],
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
