import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import splash screen
import 'home_screen_guest.dart'; // Import หน้า home สำหรับ guest

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TomatoCare',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SplashScreen(), // ใช้ SplashScreen เป็นหน้าหลัก
    );
  }
}
