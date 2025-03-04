import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424), // ✅ สีพื้นหลัง
        title: const Text(
          "History",
          style: TextStyle(
            fontFamily: 'Questrial', // ✅ ฟอนต์
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ สีตัวอักษร
          ),
        ),
        centerTitle: true, // ✅ จัด title ให้อยู่ตรงกลาง
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // ✅ ปุ่มย้อนกลับ
          },
        ),
      ),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: Text(
          "Your past scans will appear here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
