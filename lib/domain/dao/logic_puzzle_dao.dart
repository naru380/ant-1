import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/db_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LogicPuzzleDao {
  final DBProvider _dbProvider = DBProvider();
  String _tbName = DBProvider.tableName;

  Future<List<LogicPuzzle>> findAll() async {
    Database db = await _dbProvider.database;
    List<Map<String, dynamic>> result = await db.query(_tbName);
    List<LogicPuzzle> logicPuzzles = List.generate(result.length, (i) {
      return LogicPuzzle.fromMap(result[i]);
    });
    return logicPuzzles;
  }

  Future<int> create(LogicPuzzle logicPuzzle) async {
    Database db = await _dbProvider.database;
    int result = await db.insert(_tbName, logicPuzzle.toMapExceptId());
    return result;
  }

  // update
  Future<int> update(int id, LogicPuzzle logicPuzzle) async {
    Database db = await _dbProvider.database;
    int result = await db.update(
      _tbName,
      logicPuzzle.toMapExceptId(),
      where: 'id=?',
      whereArgs: [id],
    );
    return result;
  }

  // delete
  void deleteAll() async {
    Database db = await _dbProvider.database;
    await db.delete(
      '$_tbName',
    );
  }

  void deleteElement(int id) async {
    Database db = await _dbProvider.database;
    await db.delete('$_tbName', where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'myDatabase.db');
    await deleteDatabase(path);
    print(_tbName);
  }
}
