import 'package:flutter/material.dart';
import '../../../navigation/member_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar

class SettingsScreenMember extends StatelessWidget {
  const SettingsScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Change Name Account
            _buildButton(context, "Change Name Account", () {
              Navigator.pushNamed(context, '/member/change-name');
            }),

            const SizedBox(height: 20),
            // ✅ History
            _buildButton(context, "History", () {
              Navigator.pushNamed(context, '/member/history');
            }),

            const SizedBox(height: 20),
            // ✅ Logout
            _buildButton(context, "Logout", () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            }),
          ],
        ),
      ),
      bottomNavigationBar: const MemberNavigation(selectedIndex: 4),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7D2424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Questrial',
          ),
        ),
      ),
    );
  }
}
