import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'screens/guest/login_screen_guest.dart';
import 'screens/guest/home_screen_guest.dart';
import 'screens/guest/gallery_screen_guest.dart';
import 'screens/guest/camera_screen_guest.dart';
import 'screens/guest/setting_screen_guest.dart';
import 'screens/member/home_screen_member.dart';
import 'screens/member/gallery_screen_member.dart';
import 'screens/member/camera_screen_member.dart';
import 'screens/member/post_screen_member.dart';
import 'screens/member/setting_screen_member.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isMember = await AuthService.isMember(); // ตรวจสอบสถานะ

  runApp(MyApp(isMember: isMember));
}

class MyApp extends StatelessWidget {
  final bool isMember;

  const MyApp({super.key, required this.isMember});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isMember ? '/member/home' : '/guest/login',
      routes: {
        // Guest Routes
        '/guest/login': (context) => LoginScreenGuest(),
        '/guest/home': (context) => HomeScreenGuest(),
        '/guest/gallery': (context) => GalleryScreenGuest(),
        '/guest/camera': (context) => CameraScreenGuest(),
        '/guest/settings': (context) => SettingsScreenGuest(),

        // Member Routes
        '/member/home': (context) => HomeScreenMember(),
        '/member/gallery': (context) => GalleryScreenMember(),
        '/member/camera': (context) => CameraScreenMember(),
        '/member/post': (context) => PostScreenMember(),
        '/member/settings': (context) => SettingsScreenMember(),
      },
    );
  }
}
