import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/guest/home_screen_guest.dart';
import 'screens/common/gallery_screen.dart';
import 'screens/common/camera_screen.dart';
import 'screens/guest/setting_screen_guest.dart';
import 'screens/member/home_screen_member.dart';
import 'screens/member/setting_screen_member.dart';
import 'screens/member/post_screen_member.dart';
import 'screens/member/change_name.dart';
import 'screens/member/history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tomato Leaf Disease Analyzer',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/splash', // หน้าแรก
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());

          case '/guest/home':
            return MaterialPageRoute(
                builder: (context) => const HomeScreenGuest());

          case '/common/gallery':
            final args =
                settings.arguments as Map<String, dynamic>?; // ✅ รองรับ Map
            final bool isMember =
                args?['isMember'] ?? false; // ✅ ดึงค่า isMember ออกมา
            return MaterialPageRoute(
              builder: (context) => GalleryScreen(isMember: isMember),
            );

          case '/guest/settings':
            return MaterialPageRoute(
                builder: (context) => const SettingsScreenGuest());

          case '/member/home':
            return MaterialPageRoute(
                builder: (context) => const HomeScreenMember());

          case '/common/camera':
            final args =
                settings.arguments as Map<String, dynamic>?; // ✅ รองรับ Map
            final bool isMember =
                args?['isMember'] ?? false; // ✅ ดึงค่า isMember ออกมา
            return MaterialPageRoute(
              builder: (context) => CameraScreen(isMember: isMember),
            );

          case '/member/post':
            return MaterialPageRoute(
                builder: (context) => const PostScreenMember());

          case '/member/settings':
            return MaterialPageRoute(
                builder: (context) => const SettingsScreenMember());

          case '/member/change-name':
            return MaterialPageRoute(
                builder: (context) => const ChangeNameScreen());

          case '/member/history':
            return MaterialPageRoute(
                builder: (context) => const HistoryScreen());

          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
