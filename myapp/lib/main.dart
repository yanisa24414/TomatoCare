import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen_guest.dart';
import 'home_screen_guest.dart';
import 'gallery_screen.dart';
import 'camera_screen.dart';
import 'setting_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreenGuest(), // ❌ ลบ const ออก
        '/home': (context) => HomeScreen(),
        '/gallery': (context) => GalleryScreen(),
        '/camera': (context) => CameraScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
