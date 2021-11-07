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
  int operationMethodIndex;
  List<List<Offset>> inputSquareLocalPointsList;
  Function isCorrect;
  LogicPuzzleDao logicPuzzleDao;
  ValueNotifier<List<int>> notifier;
  bool isShouldrepaint = false;
  final List<int> checkedList = [];
  void init() {
    offset = Offset.zero;
    initialFocalPoint = Offset.zero;
    sessionOffset = Offset.zero;
    scale = 0.9;
    operationMethodIndex = 0;
    logicPuzzleDao = LogicPuzzleDao();
    checkedList.removeWhere((_) => true);
    logicPuzzle.lastState.asMap().forEach((int i, int value) {
      if (value == 1) checkedList.add(i);
    });
    notifier = ValueNotifier(logicPuzzle.lastState);
  }
  void changeOperationMethod() {
    operationMethodIndex = (operationMethodIndex + 1) % 2;
  }
  void save() async {
    await logicPuzzleDao.update(logicPuzzle.id, logicPuzzle);
  }
  void notify() {
    notifyListeners();
  }
}