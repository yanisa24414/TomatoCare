import 'package:flutter/material.dart';
import '../../../navigation/member_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar

class SettingsScreenMember extends StatelessWidget {
  const SettingsScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"), // ✅ เพิ่ม AppBar
      backgroundColor: const Color(0xFFFDF6E3), // สีพื้นหลังครีม
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ปุ่ม Change Name Account
            _buildButton(context, "Change Name Account", () {}),

            const SizedBox(height: 20),
            // ปุ่ม History
            _buildButton(context, "History", () {}),

            const SizedBox(height: 20),
            // ปุ่ม Logout
            _buildButton(context, "Logout", () {}),
          ],
        ),
      ),
      // ✅ เพิ่ม Bottom Navigation
      bottomNavigationBar: const MemberNavigation(selectedIndex: 4),
    );
  }

  // ✅ ฟังก์ชันสร้างปุ่ม
  Widget _buildButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 250, // กำหนดความกว้างให้เท่ากัน
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7D2424), // สีแดงเข้ม
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
