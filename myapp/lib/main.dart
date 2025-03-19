import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/common/base_screen.dart';
import 'utils/file_utils.dart';
import 'services/database_helper.dart'; // เพิ่ม import
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ขอสิทธิ์ทั้งหมดที่จำเป็น
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.photos,
    Permission.mediaLibrary,
    Permission.camera,
  ].request();

  // เช็คสถานะการขอสิทธิ์
  bool allGranted = true;
  statuses.forEach((permission, status) {
    print('$permission: $status');
    if (!status.isGranted) {
      allGranted = false;
    }
  });

  // สร้างและตรวจสอบฐานข้อมูล
  await DatabaseHelper.instance.database;

  await FileUtils.copyDatabaseToAccessibleLocation();
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/guest': (context) => const BaseScreen(isMember: false),
        '/member': (context) => const BaseScreen(isMember: true),
      },
    );
  }
}
