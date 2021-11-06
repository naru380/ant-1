import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CreateViewModel with ChangeNotifier {
  int selectNum;
  int selectThr;
  String title;
  List<int> dotList;
  int rectWidth;
  List<double> interList;
  List<List<DropdownMenuItem<int>>> itemList;
  List<DropdownMenuItem<int>> nums;
  List<DropdownMenuItem<int>> thrs;
  GlobalKey<State<StatefulWidget>> globalKey;
  Uint8List testImage;
  ui.Image compImage;
  int widthNum;

  void notify() async {
    notifyListeners();
  }
}
