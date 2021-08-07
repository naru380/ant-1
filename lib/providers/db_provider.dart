import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._internal();
  static final DBProvider _instance = DBProvider._internal();
  factory DBProvider() => _instance;

  // TODO: move to settinig(const variables) file
  static const String _databaseName = 'myDatabase.db';
  static const int _databaseVersion = 1;
  static const String tableName = 'logic_puzzles';

  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB();
      return _database;
    }
  }

  Future<Database> _initDB() async {
    // The directory where the database data files are stored can be obtained in two ways.

    // --- Pattern 1
    // Directory documentsDrectory = await getApplicationDocumentsDirectory();
    // String path = join(documentsDrectory.path, _databaseName);
    // ---

    // --- Pattern 2
    String path = join(await getDatabasesPath() , _databaseName);
    // ---

    return await openDatabase(
      path, 
      version: _databaseVersion,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database database, int version) async {
    return await database.execute('''
      CREATE TABLE $tableName
      (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        width INTEGER NOT NULL,
        dots TEXT NOT NULL,
        last_state TEXT NOT NULL,
        is_clear INTEGER NOT NULL CHECK(is_clear = 0 OR is_clear = 1)
      )
    ''');
  }
}