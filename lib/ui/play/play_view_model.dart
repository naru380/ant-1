import 'dart:typed_data';
import 'dart:ui' as ui;

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
  ui.Image puzzleImage;
  int tappedSquaeIndex;
  bool isBuildedOnce;
  bool isDrawImage;
  final List<int> checkedList = [];
  void init() {
    print('provider init.');
    offset = Offset.zero;
    initialFocalPoint = Offset.zero;
    sessionOffset = Offset.zero;
    scale = 0.9;
    operationMethodIndex = 0;
    isBuildedOnce = false;
    isDrawImage= false;
    logicPuzzleDao = LogicPuzzleDao();
    checkedList.removeWhere((_) => true);
    logicPuzzle.lastState.asMap().forEach((int i, int value) {
      if (value == 1) checkedList.add(i);
    });
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