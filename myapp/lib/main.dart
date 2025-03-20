import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/common/base_screen.dart';
import 'screens/auth/register_screen.dart'; // Add this line
import 'db.dart'; // Change this import
import 'package:permission_handler/permission_handler.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://nzsquekmnibttwcpobam.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im56c3F1ZWttbmlidHR3Y3BvYmFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzOTY1MTcsImV4cCI6MjA1Nzk3MjUxN30.PjuhCdWjd_hT2ucRzegLOqlEXyziNb7REbQoVs0kkIo',
  );

  // ตั้งชื่อตัวแปรใหม่ไม่ขึ้นต้นด้วย underscore
  final mainLogger = Logger('Main');

  // เช็คว่าเป็น web หรือไม่ก่อนขอ permissions
  if (!kIsWeb) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    // เช็คสถานะ permissions
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
  }

  // Test database connection
  try {
    final isConnected = await DatabaseHelper.instance.testConnection();
    print('Database connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
  } catch (e) {
    print('Database connection failed: $e');
  }

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
      // เลือก initial route ตาม platform
      initialRoute: kIsWeb ? '/login' : '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/guest': (context) => const BaseScreen(isMember: false),
        '/member': (context) => const BaseScreen(isMember: true),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
