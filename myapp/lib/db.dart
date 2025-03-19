// database_helper.dart
/*import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  late final Database database;

  // Private constructor
  DatabaseHelper._create(this.database);

  // Factory method to asynchronously create an instance.
  static Future<DatabaseHelper> createInstance() async {
    // Get the application's documents directory.
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dbPath = join(directory.path, 'my_database.sqlite3');
    print('Database path: $dbPath');

    // Open or create the database file.
    final Database db = sqlite3.open(dbPath);

    // Ensure the Users table exists.
    db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      );
    ''');
    print("Database opened and Users table ensured.");

    return DatabaseHelper._create(db);
  }

  // Insert a new user.
  void registerUser({
    required String email,
    required String username,
    required String password,
  }) {
    final stmt = database.prepare(
      'INSERT INTO Users (email, username, password) VALUES (?, ?, ?)',
    );
    stmt.execute([email, username, password]);
    stmt.dispose();
    print("User inserted: email=$email, username=$username");
  }

  // Query all users (for debugging).
  List<Map<String, Object?>> queryUsers() {
    final result = database.select('SELECT * FROM Users');
    print("Query result: $result");
    return result;
  }

  // Dispose (close) the database.
  void close() {
    database.dispose();
    print("Database connection closed.");
  }
}
*/
