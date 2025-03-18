import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../services/database_helper.dart';

class FileUtils {
  static Future<void> copyDatabaseToAccessibleLocation() async {
    try {
      // Get database path using DatabaseHelper
      String dbPath = await DatabaseHelper.instance.getDatabasePath();

      final downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir == null) {
        print("Error: Unable to access external storage.");
        return;
      }

      final newDbPath = join(downloadsDir.path, 'tomato_care.db');

      // Only copy if source file exists
      if (await File(dbPath).exists()) {
        await File(dbPath).copy(newDbPath);
        print("Database copied to: $newDbPath");
      } else {
        print("Source database not found at: $dbPath");
      }
    } catch (e) {
      print("Error copying database: $e");
    }
  }
}
