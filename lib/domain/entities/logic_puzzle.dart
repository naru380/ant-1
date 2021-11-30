import 'dart:convert';

import 'dart:typed_data';

class LogicPuzzle {
  int id;
  String name;
  int width;
  List<int> dots;
  List<int> lastState;
  bool isClear;
  Uint8List imageList;

  LogicPuzzle({this.id, this.name, this.width, this.dots, this.lastState, this.isClear, this.imageList});

  Map<String, dynamic> toMap() => {
    if(id != null) 'id': id,
    if(name != null) 'name': name,
    if(width != null) 'width': width,
    if(dots != null) 'dots': dots.toString(),
    if(lastState != null) 'last_state': lastState.toString(),
    if(isClear != null) 'is_clear': isClear ? 1 : 0,
    if(imageList != null) 'imageList': imageList,
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
    this.isClear = paramMap['is_clear'] == 0 ? false : true,
    this.imageList = paramMap['imageList'];
}