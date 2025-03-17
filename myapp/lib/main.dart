import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/guest/home_screen_guest.dart';
import 'screens/guest/settings_screen_guest.dart'; // Fix path
import 'screens/member/home_screen_member.dart';
import 'screens/member/settings_screen_member.dart'; // Fix path
import 'screens/member/post_screen_member.dart';
import 'screens/member/change_name.dart';
import 'screens/member/history.dart';
import 'screens/guest/camera_screen_guest.dart';
import 'screens/guest/gallery_screen_guest.dart';
import 'screens/member/camera_screen_member.dart';
import 'screens/member/gallery_screen_member.dart';

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
      initialRoute: '/splash', // Set initial route to splash
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());

          case '/guest/home':
            return MaterialPageRoute(
                builder: (context) => const HomeScreenGuest());

          case '/guest/gallery':
            return MaterialPageRoute(
              builder: (context) => const GalleryScreenGuest(),
            );

          case '/guest/settings':
            return MaterialPageRoute(
                builder: (context) =>
                    const SettingsScreenGuest()); // Fix class name

          case '/member/home':
            return MaterialPageRoute(
                builder: (context) => const HomeScreenMember());

          case '/member/camera':
            return MaterialPageRoute(
              builder: (context) => const CameraScreenMember(),
            );

          case '/member/post':
            return MaterialPageRoute(
                builder: (context) => const PostScreenMember());

          case '/member/settings':
            return MaterialPageRoute(
                builder: (context) =>
                    const SettingsScreenMember()); // Fix class name

          case '/member/change-name':
            return MaterialPageRoute(
                builder: (context) => const ChangeNameScreen());

          case '/member/history':
            return MaterialPageRoute(
                builder: (context) => const HistoryScreen());

          case '/member/gallery':
            return MaterialPageRoute(
              builder: (context) => const GalleryScreenMember(),
            );

          case '/guest/camera':
            return MaterialPageRoute(
              builder: (context) => const CameraScreenGuest(),
            );

          default:
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
        }
      },
    );
  }
}
