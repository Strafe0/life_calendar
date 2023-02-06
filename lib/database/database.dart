import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String tableName = 'TheCalendarDatabase';
  late Database _db;
  final int _dbVersion = 1;

  Future init() async {
    _db = await openDatabase(join(await getDatabasesPath(), tableName),
      version: _dbVersion,
      onCreate: (db, version) {
        return db.execute('CREATE TABLE IF NOT EXISTS calendar ('
            'id INTEGER PRIMARY KEY,'
            'state TEXT NOT NULL,'
            'start TEXT NOT NULL,'
            'end TEXT NOT NULL)');
      }
    );
  }
}