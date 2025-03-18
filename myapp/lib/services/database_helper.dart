import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tomato_care.db');
    print('Debug - Creating database at: $path');

    if (await databaseExists(path)) {
      print('Debug - Database already exists');
    } else {
      print('Debug - Creating new database');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print('Debug - Creating tables');
        await _onCreate(db, version);
        print('Debug - Tables created successfully');
      },
      onOpen: (Database db) async {
        print('Debug - Database opened');
        final tables = await db
            .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
        print('Debug - Available tables: ${tables.map((t) => t['name'])}');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
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
    print('Database path: $path');
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
    print('Debug - Found user: ${result.length > 0}'); // เพิ่ม debug log
    return result;
  }

  // เพิ่มเมธอดสำหรับตรวจสอบข้อมูลในตาราง users
  Future<void> debugPrintUsers() async {
    final db = await database;
    final users = await db.query('users');
    print('Debug - All users in database:');
    for (var user in users) {
      print(user);
    }
  }

  // เพิ่ม method close
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
