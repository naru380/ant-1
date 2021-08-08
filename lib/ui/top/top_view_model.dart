import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:flutter/material.dart';

class TopViewModel with ChangeNotifier {
  List<LogicPuzzle> logicPuzzles = [];
  int get numLogicPuzzle => logicPuzzles.length;

  void notify() => notifyListeners();

  void init() async {
    LogicPuzzleDao logicPuzzleDao = LogicPuzzleDao();
    // ---
    // TODO: For Debug code. So we must remove it.
    logicPuzzleDao.deleteAll();
    var logicPuzzle = LogicPuzzle(
      name: 'sample', 
      width: PuzzleData.boardColumnsNum, 
      dots: PuzzleData.answer, 
      lastState: List.generate(PuzzleData.answer.length, (_) => 0), 
      isClear: false);
    await logicPuzzleDao.create(logicPuzzle);
    // ---
    logicPuzzles = await logicPuzzleDao.findAll();
    notify();
  }
}

class PuzzleData {
  static const List<int> answer = [
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
  static const int boardColumnsNum = 10;
}