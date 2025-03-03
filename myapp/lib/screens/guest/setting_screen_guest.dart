import 'package:flutter/material.dart';
import '../../../navigation/guest_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar

class SettingsScreenGuest extends StatelessWidget {
  const SettingsScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"), // ✅ Use the CustomAppBar
      backgroundColor: const Color(0xFFFDF6E3), // Background color
      body: Center(
        child: _buildLogoutButton(context), // Display the logout button
      ),
      bottomNavigationBar: const GuestNavigation(selectedIndex: 3),
    );
  }

  // Function to build the Logout button
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: 200, // Set width
      height: 50, // Set height
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(
              context, '/login'); // Navigate to LoginScreen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7D2424), // Dark red color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Logout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
