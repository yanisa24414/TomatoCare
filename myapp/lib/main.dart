import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/common/base_screen.dart';
import 'utils/file_utils.dart';
import 'services/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'screens/auth/reset_password_page.dart'; // เพิ่ม import นี้
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase without authFlowType
  await Supabase.initialize(
    url: 'https://nzsquekmnibttwcpobam.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im56c3F1ZWttbmlidHR3Y3BvYmFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzOTY1MTcsImV4cCI6MjA1Nzk3MjUxN30.PjuhCdWjd_hT2ucRzegLOqlEXyziNb7REbQoVs0kkIo',
  );

  // ตั้งชื่อตัวแปรใหม่ไม่ขึ้นต้นด้วย underscore
  final mainLogger = Logger('Main');

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
    mainLogger.info('$permission: $status');
    if (!status.isGranted) {
      allGranted = false;
    }
  });

  if (!allGranted) {
    mainLogger.warning('Not all permissions were granted');
  }

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
        '/auth/reset-password': (context) => const ResetPasswordPage(),
      },
    );
  }
}
