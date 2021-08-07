import 'dart:convert';

import 'package:ant_1/dao/logic_puzzle_dao.dart';

class LogicPuzzle {
  int id;
  String name;
  int width;
  List<int> dots;
  List<int> lastState;
  bool isClear;

  LogicPuzzle({this.id, this.name, this.width, this.dots, this.lastState, this.isClear});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'width': width,
    'dots': dots.toString(),
    'last_state': lastState.toString(),
    'is_clear': isClear ? 1 : 0,
  };

  Map<String, dynamic> toMapExceptId() {
    Map<String, dynamic> cloneMap = {...toMap()};
    cloneMap.remove('id');
    return cloneMap;
  }

  LogicPuzzle.fromMap(Map<String, dynamic> paramMap) :
    this.id = paramMap['id'],
    this.name = paramMap['name'],
    this.width = paramMap['width'],
    this.dots = jsonDecode(paramMap['dots']).cast<int>(),
    this.lastState = jsonDecode(paramMap['last_state']).cast<int>(),
    this.isClear = paramMap['is_clear'] == 0 ? false : true;
}