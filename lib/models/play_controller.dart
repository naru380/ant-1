import 'package:ant_1/entities/logic_puzzle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayController with ChangeNotifier {
  LogicPuzzle logicPuzzle;
  Offset offset;
  Offset initialFocalPoint;
  Offset sessionOffset;
  double scale;
  Function isCorrect;
  final List<int> checkedList = [];
  void init() {
    offset = Offset.zero;
    initialFocalPoint = Offset.zero;
    sessionOffset = Offset.zero;
    scale = 0.9;
    checkedList.removeWhere((_) => true);
  }
  void checked(int index) {
    checkedList.add(index);
  }
  void unchecked(int index) {
    checkedList.remove(index);
  }
  void notify() {
    notifyListeners();
  }
}