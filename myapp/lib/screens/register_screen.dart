// register_screen.dart
import 'package:flutter/material.dart';
import 'package:myapp/db.dart'; // Ensure the path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Text controllers for the form fields.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Instance of DatabaseHelper.
  DatabaseHelper? _dbHelper;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Asynchronously initialize the database.
  Future<void> _initDatabase() async {
    _dbHelper = await DatabaseHelper.createInstance();
    setState(() {}); // Rebuild if needed once the db is ready.
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

  // Function called when tapping the Register button.
  void _register() {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match.")));
      return;
    }
    try {
      _dbHelper?.registerUser(
        email: email,
        username: username,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")));

      // Optionally, clear the text fields.
      emailController.clear();
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // For debugging, query the table and print the users.
      _dbHelper?.queryUsers();
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: const Color(0xFF2E572F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
