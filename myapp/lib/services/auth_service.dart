import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../services/database_helper.dart';

class AuthService {
  static final _logger = Logger('AuthService');
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

  static Future<bool> register(
      String email, String password, String username) async {
    try {
      _logger.info('Registering new user - Email: $email, Username: $username');

      final db = await DatabaseHelper.instance.database;
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        _logger.warning('Registration failed - Email already exists');
        return false;
      }

      final Map<String, dynamic> userData = {
        'email': email,
        'password': password,
        'username': username,
        'created_at': DateTime.now().toIso8601String(),
      };

      final id = await db.insert('users', userData);
      _logger.info('User registered successfully with ID: $id');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, id);

      await DatabaseHelper.instance.debugPrintUsers();

      return true;
    } catch (e) {
      _logger.severe('Registration error', e);
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      _logger.info('Login attempt - Email: $email');

      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      _logger.fine('Query results: $results');

      if (results.isNotEmpty) {
        final user = results.first;
        if (user['password'] == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_userIdKey, user['id'] as int);
          _logger.info('Login successful for user ID: ${user['id']}');
          return true;
        }
      }

      _logger.warning('Login failed - Invalid credentials');
      return false;
    } catch (e) {
      _logger.severe('Login error', e);
      return false;
    }
  }

  static Future<bool> isMember() async {
    return getMemberStatus();
  }
}
