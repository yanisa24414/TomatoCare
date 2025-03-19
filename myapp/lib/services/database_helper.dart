import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final _logger = Logger('DatabaseHelper');
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'tomato_care.db');
      _logger.info('Creating database at: $path');

      // ลบฐานข้อมูลเก่าถ้ามี
      if (await databaseExists(path)) {
        await deleteDatabase(path);
        _logger.info('Deleted existing database');
      }

      _logger.info('Opening database with write permissions');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await _onCreate(db, version);

          // เพิ่มข้อมูล user เริ่มต้น
          await db.insert('users', {
            'email': 'test@test.com',
            'password': '123456',
            'username': 'test',
            'created_at': DateTime.now().toIso8601String(),
          });
          _logger.info('Test user added successfully');
        },
      );
    } catch (e) {
      _logger.severe('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table with profile_image column
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        profile_image TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Posts table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        content TEXT,
        image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Analysis History table
    await db.execute('''
      CREATE TABLE analysis_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        image_path TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // เพิ่ม methods สำหรับดูข้อมูล
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await database;
    return await db.query('posts');
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    final db = await database;
    return await db.query('analysis_history');
  }

  // Method สำหรับดูข้อมูลแบบมี conditions
  Future<List<Map<String, dynamic>>> getUserPosts(int userId) async {
    final db = await database;
    return await db.query(
      'posts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserHistory(int userId) async {
    final db = await database;
    return await db.query(
      'analysis_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  // Method สำหรับลบข้อมูล
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('analysis_history');
    await db.delete('posts');
    await db.delete('users');
  }

  // เพิ่ม method เพื่อดูที่อยู่ของ database
  Future<String> getDatabasePath() async {
    String path = join(await getDatabasesPath(), 'tomato_care.db');
    _logger.info('Database path: $path');
    return path;
  }

  Future<List<Map<String, dynamic>>> validateUser(
      String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    _logger.info('User found: ${result.isNotEmpty}');
    return result;
  }

  // เพิ่มเมธอดสำหรับตรวจสอบข้อมูลในตาราง users
  Future<void> debugPrintUsers() async {
    final db = await database;
    final users = await db.query('users');
    _logger.info('All users in database:');
    for (var user in users) {
      _logger.info(user.toString());
    }
  }

  // เพิ่ม method close
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // เพิ่มเมธอดสำหรับรีเซ็ตฐานข้อมูล
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'tomato_care.db');
    _logger.info('Resetting database');

    await deleteDatabase(path);
    _database = null; // ทำให้สร้าง instance ใหม่

    await database; // สร้างฐานข้อมูลใหม่พร้อมข้อมูลเริ่มต้น
  }

  Future<void> updateUsername(int userId, String newUsername) async {
    final db = await database;
    await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
    _logger.info('Username updated for user ID: $userId');
  }

  Future<void> updateUser({
    required int userId,
    String? username,
    String? profileImagePath,
  }) async {
    try {
      final db = await database;

      Map<String, dynamic> updates = {};
      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }
      if (profileImagePath != null) {
        updates['profile_image'] = profileImagePath;
      }

      if (updates.isEmpty) return;

      final result = await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.info('Updated user $userId: $result rows affected');
    } catch (e) {
      _logger.severe('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final db = await database;
      final results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting user by ID: $e');
      return null;
    }
  }
}
