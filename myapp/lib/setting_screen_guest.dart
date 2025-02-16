import 'package:flutter/material.dart';
import 'navigation/guest_navigation.dart';

class SettingScreenGuest extends StatefulWidget {
  const SettingScreenGuest({super.key});

  @override
  State<SettingScreenGuest> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreenGuest> {
  int _selectedIndex = 3; // ตั้งค่า index ให้ตรงกับ Setting (index 3)

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/camera');
        break;
      case 3:
        // อยู่ที่หน้า Setting อยู่แล้ว
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D8), // สีพื้นหลังครีม
      body: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวนอน
        children: [
          const SizedBox(height: 80), // ระยะห่างจากขอบบน

          // Header (TOMATO CARE)
          Center(
            // ใช้ Center ครอบเพื่อให้ตรงกลางแนวนอน
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22512F), // สีเขียว
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "TOMATO CARE",
                style: TextStyle(
                  fontFamily: 'Questrial',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // ปุ่ม Setting
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF882424), // สีแดงเข้ม
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Setting",
                style: TextStyle(
                  fontFamily: 'Questrial',
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ปุ่ม Log In
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF882424), // สีแดงเข้ม
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // ไปหน้า Login
              },
              child: const Text(
                "Log In",
                style: TextStyle(
                  fontFamily: 'Questrial',
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const Spacer(), // ดันเนื้อหาให้อยู่ข้างบน
        ],
      ),

      // ใช้ GuestNavigation
      bottomNavigationBar: GuestNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
