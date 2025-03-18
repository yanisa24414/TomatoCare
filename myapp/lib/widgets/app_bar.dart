import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF7D2424), // ✅ สีพื้นหลัง
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // ✅ ปิดการแสดงปุ่มย้อนกลับ
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // ✅ สีตัวอักษร
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontFamily: 'Questrial', // ✅ ใช้ฟอนต์ Questrial
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
