import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/common/base_screen.dart';
import 'utils/file_utils.dart';
import 'services/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'screens/auth/reset_password_page.dart'; // เพิ่ม import นี้
import 'screens/auth/email_confirmed_screen.dart'; // เพิ่มบรรทัดนี้
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // เพิ่มบรรทัดนี้เพื่อรอให้ WidgetsBinding พร้อมใช้งาน
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่า Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.toString()}');
  };

  // ตั้งค่า logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ใช้ debugPrint แทน print เพื่อป้องกัน throttling
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // เพิ่ม error catching
  try {
    await Supabase.initialize(
      url: 'https://rayksxmgvgyadekzbico.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJheWtzeG1ndmd5YWRla3piaWNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzOTUwNzEsImV4cCI6MjA1Nzk3MTA3MX0.2sh0B02iM8-KR_CAvLYcoWnvLzVINrChgLXwKH1_yp0',
    );
  } catch (e) {
    debugPrint('Supabase initialization error: $e');
  }

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
        '/auth/email-confirmed': (context) => const EmailConfirmedScreen(),
      },
    );
  }
}
