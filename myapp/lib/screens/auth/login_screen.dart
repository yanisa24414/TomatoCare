import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../db.dart';
import 'register_screen.dart';
import 'forgot_password.dart';

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

        // Try to login using Supabase directly
        final res =
            await DatabaseHelper.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;
        Navigator.pop(context); // Remove loading indicator

        if (res.user != null) {
          // Login successful
          Navigator.pushReplacementNamed(context, '/member');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back!'),
              backgroundColor: Color(0xFF22512F),
            ),
          );
        } else {
          throw 'Login failed';
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Remove loading indicator

        _logger.severe('Login error occurred', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            45, 125, 45, 20), // Changed from symmetric to fromLTRB
        child: Form(
          // เพิ่ม Form widget
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                width: 400, // Reduced from 500
                height: 250, // Reduced from 300
                child: Image.asset(
                  'assets/logo3.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40), // Increased from original spacing
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
        ),
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
