import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../db.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper.instance.client.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: Color(0xFF22512F),
        ),
      );

      // Redirect to login after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo3.png',
                height: 150,
              ),
              const SizedBox(height: 40),
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D2424),
                  fontFamily: 'Questrial',
                ),
              ),
              const SizedBox(height: 30),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D2424),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Reset Password',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF7D2424),
          fontFamily: 'Questrial',
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7D2424)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7D2424), width: 2),
        ),
      ),
    );
  }
}
