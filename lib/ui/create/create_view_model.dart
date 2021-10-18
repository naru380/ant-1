import 'package:ant_1/ui/create/create_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateViewModel with ChangeNotifier {
  int selectNum;
  int selectThr;
  String title;
  List<int> dotList;
  List<Widget> gridList;
  List<double> ave;
  List<List<DropdownMenuItem<int>>> itemList;
  List<DropdownMenuItem<int>> nums;
  List<DropdownMenuItem<int>> thrs;

  void notify() async {
    notifyListeners();
  }
}
