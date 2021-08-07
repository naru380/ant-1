import 'dart:math';

import 'package:ant_1/entities/logic_puzzle.dart';
import 'package:ant_1/models/play_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class PlayScreen extends StatelessWidget {
  final LogicPuzzle logicPuzzle;
  PlayScreen({key: Key, this.logicPuzzle});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    LogicPuzzle logicPuzzle = args['logicPuzzle'];
    context.read<PlayController>().logicPuzzle = logicPuzzle;

    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Title')
      ),
      body: Consumer<PlayController>(builder: (context, model, _) {
        return GestureDetector(
          onScaleStart: (details) {
            model.initialFocalPoint = details.focalPoint;
          },
          onScaleUpdate: (details) {
            model.sessionOffset = details.focalPoint - model.initialFocalPoint;
            model.initialFocalPoint = details.focalPoint;
            model.offset += model.sessionOffset;

            model.scale *= details.scale;
            if (model.scale < 0.5) {
              model.scale = 0.5;
            }
            if (model.scale > 1.5) {
              model.scale = 1.5;
            }

            model.notify();
          },
          onScaleEnd: (details) {
            // nothnig
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Transform.translate(
                    offset: model.offset,
                    child: Transform.scale(
                      scale: model.scale,
                      child: Puzzle(
                        context: context,
                        logicPuzzle: logicPuzzle,  
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (model.isCorrect()) {
                        showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('COMPLETE'),
                              content: Text('TOPページに戻ります。'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pushNamed('/'),
                                ),
                              ],
                            );
                          }
                        );
                      } else {
                        showDialog<int>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('INCOMPLETE'),
                              content: Text('解答を再度確認してください。'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(0),
                                ),
                              ],
                            );
                          }
                        );
                      }
                    },
                    child: Text('Check'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class Puzzle extends StatelessWidget{
  final BuildContext context;
  final LogicPuzzle logicPuzzle;
  Puzzle({this.context, this.logicPuzzle});

  @override
  Widget build(BuildContext context) {
    //context.read<PlayController>().checkedList.removeWhere((_) => true);
    context.read<PlayController>().isCorrect = isCorrect;
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        buildBorderArea(),
        buildViewArea(),
        buildColumnHintsArea(),
        buildRowHintsArea(),
        buildBoardArea(),
      ],
    );
  }

  List<int> get answer => logicPuzzle.dots;
  int get boardColumnsNum => 10;//logicPuzzle.width;
  int get boardRowsNum => answer.length ~/ boardColumnsNum;
  List<int> get hintsInEachRow => _hintsInEachRow();
  int get maxNumOfHintsInEachRow => hintsInEachRow.length ~/ boardRowsNum;
  List<int> get hintsInEachColumn => _hintsInEachColumn();
  int get maxNumOfHintsInEachColumn => hintsInEachColumn.length ~/ boardColumnsNum;

  List<int> _hintsInEachRow() {
    List<List<int>> hints = [];
    List<int> tmp;
    int pre;
    int n;
    int maxN = 0;
    for (int i=0; i < boardColumnsNum; i++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int j=0; j < boardRowsNum; j++) {
        int now = answer[boardColumnsNum * i + j];
        if (now == 0) {
          if (pre == 1) {
            tmp.add(n);
          }
          n = 0;
          pre = 0;
        } else {
          n++;
          pre = 1;
        }
      }
      if (n != 0) {
        tmp.add(n);
      }
      maxN = max(maxN, tmp.length);
      hints.add(tmp.reversed.toList());
    }

    List<int> result = List.generate(maxN * boardColumnsNum, (_) => 0);
    for (int i = 0; i < boardColumnsNum; i++) {
      List<int> hint = hints[i];
      for (int j = 0; j < hint.length; j++) {
        result[maxN * (i + 1) - j - 1] = hint[j];
      }
    }

    return result;
  }
  List<int> _hintsInEachColumn() {
    List<List<int>> hints = [];
    List<int> tmp;
    int pre;
    int n;
    int maxN = 0;
    for (int i=0; i < boardRowsNum; i++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int j=0; j < boardColumnsNum; j++) {
        int now = answer[boardColumnsNum * j + i];
        if (now == 0) {
          if (pre == 1) {
            tmp.add(n);
          }
          n = 0;
          pre = 0;
        } else {
          n++;
          pre = 1;
        }
      }
      if (n != 0) {
        tmp.add(n);
      }
      maxN = max(maxN, tmp.length);
      hints.add(tmp.reversed.toList());
    }

    List<int> result = List.generate(maxN * boardRowsNum, (_) => 0);
    for (int i = 0; i < boardRowsNum; i++) {
      List<int> hint = hints[i];
      for (int j = 0; j < hint.length; j++) {
        result[maxN * (i + 1) - j - 1] = hint[j];
      }
    }

    return result;
  }
  
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _puzzleWidth => _borderLayerWidth;
  double get _puzzleHeight => _borderLayerHeight;
  double get ratioOfScreenToPuzzle =>
    _screenWidth/_puzzleWidth < _screenHeight/_puzzleHeight
    ? _screenWidth/_borderLayerWidth
    : _screenHeight/_borderLayerHeight;

  final double _squareSize = PuzzleSetting.squareSize;
  final double _borderWidth = PuzzleSetting.borderWidth; 
  double get borderWidth => _borderWidth * ratioOfScreenToPuzzle;
  final double _boldBorderWidth = PuzzleSetting.boldBorderWidth;
  double get boldBorderWidth => _boldBorderWidth * ratioOfScreenToPuzzle;

  Color borderColor = PuzzleSetting.borderColor;
  Color boldBorderColor = PuzzleSetting.boldBorderColor;
  Color hintBackgroundColor = PuzzleSetting.hintBackgroundColor;
  Color markedColor = PuzzleSetting.markedColor;
  Color nonMarkedColor = PuzzleSetting.nonMarkedColor;

  double get _borderLayerWidth =>
    _boldBorderWidth 
    + maxNumOfHintsInEachRow*_squareSize 
    + _boldBorderWidth
    + boardColumnsNum*_squareSize
    + _boldBorderWidth; 
  double get borderLayerWidth => _borderLayerWidth * ratioOfScreenToPuzzle;
  double get _borderLayerHeight =>
    _boldBorderWidth
    + maxNumOfHintsInEachColumn*_squareSize
    + _boldBorderWidth
    + boardRowsNum*_squareSize
    + _boldBorderWidth;
  double get borderLayerHeight => _borderLayerHeight * ratioOfScreenToPuzzle;
  Widget buildBorderArea() {
    return Positioned(
      left: 0,
      top: 0,
      width: borderLayerWidth,
      height: borderLayerHeight,
      child: Container(
        color: boldBorderColor,
      ),
    );
  }

  double get viewAreaLeftOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get viewAreaTopOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get viewAreaWidth => maxNumOfHintsInEachRow.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  double get viewAreaHeight => maxNumOfHintsInEachColumn.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  Widget buildViewArea() {
    return Consumer<PlayController>(builder: (context, model, _) {
      return Positioned(
        left: viewAreaLeftOffset,
        top: viewAreaTopOffset,
        width: viewAreaWidth,
        height: viewAreaHeight,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: nonMarkedColor,
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardColumnsNum,
            ),
            itemCount: boardColumnsNum * boardRowsNum,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: model.checkedList.indexOf(index) == -1 ? nonMarkedColor : markedColor,
                ),
                child: Text(''),
              );
            }
          )
        ),
      );
    });
  }

  double get columnHintsAreaLeftOffset => (_boldBorderWidth * 2 + maxNumOfHintsInEachRow.toDouble() * _squareSize) * ratioOfScreenToPuzzle;
  double get columnHintsAreaTopOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get columnHintsAreaWidth => boardColumnsNum.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  double get columnHintsAreaHeight => maxNumOfHintsInEachColumn.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  Widget buildColumnHintsArea() {
    return Positioned(
      left: columnHintsAreaLeftOffset,
      top: columnHintsAreaTopOffset,
      width: columnHintsAreaWidth,
      height: columnHintsAreaHeight,
      child: Container(
        color: borderColor,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: maxNumOfHintsInEachColumn,
            crossAxisSpacing: borderWidth,
            mainAxisExtent: _squareSize*ratioOfScreenToPuzzle-borderWidth*(1.0-1.0/boardColumnsNum),
            mainAxisSpacing: borderWidth,
            childAspectRatio: 1,
          ), 
          itemCount: hintsInEachColumn.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: hintBackgroundColor,
              ),
              child: Center(
                child: hintsInEachColumn[index] != 0
                  ? Text(
                      '${hintsInEachColumn[index]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ) 
                  : Text(''),
              )
            );
          }
        ),
      ),
    );
  }

  double get rowHintsAreaLeftOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get rowHintsAreaTopOffset => (_boldBorderWidth * 2 + maxNumOfHintsInEachColumn.toDouble() * _squareSize) * ratioOfScreenToPuzzle;
  double get rowHintsAreaWidth => maxNumOfHintsInEachRow.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  double get rowHintsAreaHeight => (boardRowsNum.toDouble() * _squareSize) * ratioOfScreenToPuzzle;
  Widget buildRowHintsArea() {
    return Positioned(
      left: rowHintsAreaLeftOffset,
      top: rowHintsAreaTopOffset,
      width: rowHintsAreaWidth,
      height: rowHintsAreaHeight,
      child: Container(
        color: borderColor,
        child: GridView.builder(
          shrinkWrap: false,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: maxNumOfHintsInEachRow,
            crossAxisSpacing: borderWidth,
            mainAxisExtent: _squareSize*ratioOfScreenToPuzzle-borderWidth*(1.0-1.0/boardRowsNum),
            mainAxisSpacing: borderWidth,
            childAspectRatio: 1,
          ), 
          itemCount: hintsInEachRow.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: hintBackgroundColor,
              ),
              child: Center(
                child: hintsInEachRow[index] != 0 
                  ? Text(
                      '${hintsInEachRow[index]}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ) 
                  : Text(''),
              ),
            );
          }
        )
      ),
    );
  }

  double get boardAreaLeftOffset => (_boldBorderWidth * 2 + maxNumOfHintsInEachRow.toDouble() * _squareSize) * ratioOfScreenToPuzzle;
  double get boardAreaTopOffset => (_boldBorderWidth * 2 + maxNumOfHintsInEachColumn.toDouble() * _squareSize) * ratioOfScreenToPuzzle;
  double get boardAreaWidth => boardColumnsNum.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  double get boardAreaHeight => boardRowsNum.toDouble() * _squareSize * ratioOfScreenToPuzzle;
  Widget buildBoardArea() {
    return Consumer<PlayController>(builder: (context, model, _) {
      return Positioned(
        left: boardAreaLeftOffset,
        top: boardAreaTopOffset,
        width: boardAreaWidth,
        height: boardAreaHeight,
        child: Container(
          color: borderColor,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardColumnsNum,
              crossAxisSpacing: borderWidth,
              mainAxisSpacing: borderWidth,
            ), 
            itemCount: boardColumnsNum * boardRowsNum,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final bool checked = model.checkedList.contains(index);
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    color: nonMarkedColor,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: checked ? markedColor : nonMarkedColor,
                    ),
                    child: Text(''),
                    ),
                ),
                onTap: () {
                  if (checked) {
                    model.unchecked(index);
                  } else {
                    model.checked(index);
                  }
                  model.notify();
                },
              );
            }
          )
        )
      );
    });
  }

  bool isCorrect() {
    List<int> answerCheckedList = answer.asMap().entries.where((e) => (e.value == 1)).toList().map((e) => e.key).toList();
    List<int> userCheckedList = context.read<PlayController>().checkedList;
    answerCheckedList.sort((a, b) => a - b);
    userCheckedList.sort((a, b) => a - b);
    //print('answer: $answerCheckedList');
    //print('user: $userCheckedList');
    return listEquals(answerCheckedList, userCheckedList);
  }
}

class PuzzleSetting {
  // TODO: move to settinig(const variables) file
  static const double squareSize = 10.0;
  static const double borderWidth = 0.8; 
  static const double boldBorderWidth = 1.5;
  static const Color borderColor = Colors.black;
  static const Color boldBorderColor = Colors.black;
  //static final Color hintBackgroundColor = Colors.blue[50];
  static const Color hintBackgroundColor = Color(0xFFE3F2FD);
  //static final Color markedColor = Colors.blue[500];
  static const Color markedColor = Color(0xFF2196F3);
  static const Color nonMarkedColor = Colors.white;
}