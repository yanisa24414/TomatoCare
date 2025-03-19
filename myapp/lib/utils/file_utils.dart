import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import '../services/database_helper.dart';

class FileUtils {
  static final _logger = Logger('FileUtils');

  static Future<void> copyDatabaseToAccessibleLocation() async {
    try {
      String dbPath = await DatabaseHelper.instance.getDatabasePath();

      final downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir == null) {
        _logger.severe("Unable to access external storage.");
        return;
      }

      final newDbPath = join(downloadsDir.path, 'tomato_care.db');

      if (await File(dbPath).exists()) {
        await File(dbPath).copy(newDbPath);
        _logger.info("Database copied to: $newDbPath");
      } else {
        _logger.warning("Source database not found at: $dbPath");
      }
    } catch (e) {
      _logger.severe("Error copying database", e);
    }
  }
}
