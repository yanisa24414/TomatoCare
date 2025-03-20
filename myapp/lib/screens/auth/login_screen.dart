import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:myapp/screens/auth/register_screen.dart';
import 'package:myapp/screens/auth/forgot_password.dart';
import '../../services/auth_service.dart';
import '../../db.dart'; // ใช้อันนี้อันเดียว ลบ database_helper.dart ออก

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _logger = Logger('LoginScreen');
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleGuestLogin() async {
    await AuthService.setMemberStatus(false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/guest');
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        _logger.info('Login attempt for email: $email');

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Try to login with Supabase
        final user = await DatabaseHelper.instance.loginUser(
          email: email,
          password: password,
        );

        if (!mounted) return;
        Navigator.pop(context); // Hide loading

        if (user != null) {
          print("Login successful, navigating to member screen");
          await AuthService.setMemberStatus(true);
          Navigator.pushReplacementNamed(context, '/member');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back!'),
              backgroundColor: Color(0xFF22512F),
            ),
          );
        } else {
          throw 'Invalid email or password';
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Hide loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isWeb
          ? Center(
              // ครอบด้วย Center
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: 1200), // จำกัดความกว้างสูงสุด
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // โลโก้
                    Container(
                      height: 200,
                      width: 300,
                      child: Image.asset(
                        'assets/logo3.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 50),
                    // ฟอร์มล็อกอิน
                    Container(
                      width: 400, // กำหนดความกว้างฟอร์ม
                      padding: EdgeInsets.all(30),
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
                      child: _buildLoginForm(),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              // mobile version ยังคงเหมือนเดิม
              padding: const EdgeInsets.fromLTRB(45, 125, 45, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: 400,
                    height: 250,
                    child: Image.asset(
                      'assets/logo3.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildLoginForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoginForm() {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // แสดงข้อความ Welcome เฉพาะบน web
          if (isWeb)
            Text(
              'Welcome to TomatoCare !',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D2424),
                fontFamily: 'Questrial',
              ),
            ),
          if (isWeb) SizedBox(height: 40),

          // ส่วนที่เหลือเหมือนเดิม
          _buildTextField(
            controller: _emailController,
            hint: 'Enter your Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Enter your Password',
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Positioned(
                    right: 12,
                    child: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xFF22512F),
                      ),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Color(0xFF22512F),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Questrial',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildButton(
            text: 'Sign In',
            color: const Color(0xFF22512F),
            onPressed: _handleSubmit,
            // Remove context parameter
          ),
          const SizedBox(height: 15),
          _buildButton(
            text: 'Continue as Guest',
            color: const Color(0xFF7D2424),
            onPressed: _handleGuestLogin, // Remove context parameter
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: Color(0xFF22512F),
                  fontSize: 14,
                  fontFamily: 'Questrial',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Color(0xFF7D2424),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Questrial',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool isPasswordVisible = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator, // เพิ่ม validator parameter
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        // เปลี่ยนจาก TextField เป็น TextFormField
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Color(0xFF22512F),
          fontFamily: 'Questrial',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Questrial',
          ),
          filled: true,
          fillColor: Color(0xFFE8E8E8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Questrial',
          ),
        ),
      ),
    );
  }
}
