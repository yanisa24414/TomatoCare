import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> isMember() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isMember') ?? false; // ค่าเริ่มต้นคือ false (Guest)
  }

  static Future<void> setMemberStatus(bool isMember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMember', isMember);
  }
}
