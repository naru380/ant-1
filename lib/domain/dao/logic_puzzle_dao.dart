import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/providers/db_provider.dart';
import 'package:sqflite/sqflite.dart';

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

  // delete
  void deleteAll() async {
    Database db = await _dbProvider.database;
    await db.delete(
      '$_tbName',
    );
  }
}