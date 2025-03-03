import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF7D2424),
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,

      automaticallyImplyLeading: false, // ปิดการแสดงปุ่มย้อนกลับ
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
