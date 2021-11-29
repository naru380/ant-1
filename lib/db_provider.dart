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

  static const bool INIT_MODE = false;

  Database _database;

  Future<Database> get database async {
    if (_database != null && !INIT_MODE) {
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

    // Delete the db file.
    if (INIT_MODE)
      await deleteDatabase(path);

    return await openDatabase(
      path, 
      version: _databaseVersion,
      onCreate: (Database database, int version) async {
        _createTable(database, version);
        _createSampleData(database, version);
      }
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

  Future<void> _createSampleData(Database database, int version) async {
    await database.execute(
      '''
      INSERT INTO $tableName ('name', 'width', 'dots', 'last_state', 'is_clear')
      values (?, ?, ?, ?, ?)
      ''',
      [SampleData2.name, SampleData2.width, SampleData2.dots, SampleData2.lastState, SampleData2.isClear]
    );

    return await database.execute(
      '''
      INSERT INTO $tableName ('name', 'width', 'dots', 'last_state', 'is_clear')
      values (?, ?, ?, ?, ?)
      ''',
      [SampleData.name, SampleData.width, SampleData.dots, SampleData.lastState, SampleData.isClear]
    );
  }
}

class SampleData {
  static const String name = 'sample';
  static const int width = 10;
  static const List<int> _dots = [
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 0, 1, 0, 0, 1, 0, 1, 1,
    0, 0, 1, 1, 1, 1, 1, 1, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 0, 0, 0, 0, 1, 1, 1, 0,
    1, 0, 1, 1, 1, 1, 0, 1, 1, 1,
    1, 0, 1, 1, 1, 1, 0, 1, 1, 1,
    1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
  ];
  static String dots = _dots.toString();
  static List<int> _lastState = List.generate(_dots.length, (_) => 0);
  static String lastState = _lastState.toString();
  static const int isClear = 0;
}

class SampleData2 {
  static const String name = 'sample2';
  static const int width = 2;
  static const List<int> _dots = [
    0, 1,
    1, 0
  ];
  static String dots = _dots.toString();
  static List<int> _lastState = List.generate(_dots.length, (_) => 0);
  static String lastState = _lastState.toString();
  static const int isClear = 0;
}