import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ขอสิทธิ์กล้องก่อนเข้าแอป
  await requestCameraPermission();

  // ✅ ตรวจสอบว่าสมาชิกหรือไม่
  bool isMember = await AuthService.isMember();

  runApp(MyApp(isMember: isMember));
}

// ✅ ฟังก์ชันขอสิทธิ์กล้อง
Future<void> requestCameraPermission() async {
  var status = await Permission.camera.request();
  if (status.isGranted) {
    log("✅ ได้รับสิทธิ์ใช้กล้องแล้ว");
  } else {
    log("❌ ไม่ได้รับสิทธิ์ใช้กล้อง");
  }
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
        '/guest/home': (context) => const HomeScreenGuest(),
        '/guest/gallery': (context) => const GalleryScreenGuest(),
        '/guest/camera': (context) => const CameraScreenGuest(),
        '/guest/settings': (context) => const SettingsScreenGuest(),

        // Member Routes
        '/member/home': (context) => const HomeScreenMember(),
        '/member/gallery': (context) => const GalleryScreenMember(),
        '/member/camera': (context) => const CameraScreenMember(),
        '/member/post': (context) => const PostScreenMember(),
        '/member/settings': (context) => const SettingsScreenMember(),
      },
    );
  }
}
