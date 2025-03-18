import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../models/user.dart';

class AuthService {
  static const String _isMemberKey = 'isMember';
  static const String _userIdKey = 'userId';

  static Future<void> setMemberStatus(bool isMember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMemberKey, isMember);
  }

  static Future<bool> getMemberStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isMemberKey) ?? false;
  }

  // Add new database methods
  static Future<bool> register(
      String email, String password, String username) async {
    try {
      print('Debug - Registering new user:');
      print('Email: $email');
      print('Username: $username');

      final db = await DatabaseHelper.instance.database;

      // ตรวจสอบว่ามีอีเมลนี้ในระบบแล้วหรือไม่
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        print('Debug - Email already exists');
        return false;
      }

      // สร้างข้อมูลผู้ใช้
      final Map<String, dynamic> userData = {
        'email': email,
        'password': password,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      };

      // บันทึกข้อมูล
      final id = await db.insert('users', userData);
      print('Debug - User registered with ID: $id');

      // เก็บ ID ผู้ใช้
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, id);

      // ตรวจสอบว่าบันทึกสำเร็จ
      await DatabaseHelper.instance.debugPrintUsers();

      return true;
    } catch (e) {
      print('Debug - Registration error: $e');
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      // เพิ่ม debug logs
      print('Debug - Login attempt:');
      print('Email: $email');
      print('Password: $password');

      final db = await DatabaseHelper.instance.database;

      // ดึงข้อมูลผู้ใช้ทั้งหมดมาตรวจสอบ
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      print('Debug - Query results: $results'); // แสดงผลลัพธ์ที่ได้

      if (results.isNotEmpty) {
        final user = results.first;
        if (user['password'] == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_userIdKey, user['id'] as int);
          print('Debug - Login successful for user ID: ${user['id']}');
          return true;
        }
      }

      print('Debug - Login failed: No matching user or incorrect password');
      return false;
    } catch (e) {
      print('Debug - Login error: $e');
      return false;
    }
  }

  // Add isMember method
  static Future<bool> isMember() async {
    return getMemberStatus();
  }
}
