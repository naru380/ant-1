import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayViewModel with ChangeNotifier {
  LogicPuzzle logicPuzzle;
  Offset offset;
  Offset initialFocalPoint;
  Offset sessionOffset;
  double scale;
  Function isCorrect;
  LogicPuzzleDao logicPuzzleDao;
  final List<int> checkedList = [];
  void init() {
    offset = Offset.zero;
    initialFocalPoint = Offset.zero;
    sessionOffset = Offset.zero;
    scale = 0.9;
    logicPuzzleDao = LogicPuzzleDao();
    checkedList.removeWhere((_) => true);
    logicPuzzle.lastState.asMap().forEach((int i, int value) {
      if (value == 1) checkedList.add(i);
    });
  }
  void checked(int index) {
    checkedList.add(index);
  }
  void unchecked(int index) {
    checkedList.remove(index);
  }
  void save() async {
    List<int> currentState = List.generate(logicPuzzle.dots.length, (_) => 0);
    for (int i in checkedList) {
      currentState[i] = 1;
    }
    LogicPuzzle saveLogicPuzzle = LogicPuzzle(lastState: currentState);
    await logicPuzzleDao.update(logicPuzzle.id, saveLogicPuzzle);
  }
  void notify() async {
    notifyListeners();
  }
}