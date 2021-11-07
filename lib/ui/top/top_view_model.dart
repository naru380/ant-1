import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:flutter/material.dart';

class TopViewModel with ChangeNotifier {
  List<LogicPuzzle> logicPuzzles = [];
  int get numLogicPuzzle => logicPuzzles.length;
  LogicPuzzleDao logicPuzzleDao;

  void notify() => notifyListeners();

  void init() async {
    logicPuzzleDao = LogicPuzzleDao();
    logicPuzzles = await logicPuzzleDao.findAll();
    notify();
  }
}

