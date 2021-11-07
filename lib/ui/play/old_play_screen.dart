import 'dart:math';

import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LogicPuzzle logicPuzzle = context.read<PlayViewModel>().logicPuzzle;

    return Scaffold(
      appBar: AppBar(
        title: Text('${logicPuzzle.name}'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<PlayViewModel>(builder: (context, model, _) {
        return GestureDetector(
          onScaleStart: (details) {
            model.initialFocalPoint = details.focalPoint;
          },
          onScaleUpdate: (details) async {
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
            // nothing
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
              OperationBar(
                context: context,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class OperationBar extends StatelessWidget {
  final BuildContext context;
  OperationBar({this.context});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayViewModel>(builder: (context, model, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
              child: Icon(
                IconData(0xf82c, fontFamily: 'MaterialIcons'),
                color: Colors.white
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: 100,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                model.changeOperationMethod();
                model.notify();
              },
              child: (() {
                switch (model.operationMethodIndex) {
                  case 0:
                    return Icon(
                      IconData(59563, fontFamily: 'MaterialIcons'),
                      color: Colors.white
                    );
                  case 1:
                    return Icon(
                      IconData(57704, fontFamily: 'MaterialIcons'),
                      color: Colors.white
                    );
                }
              })(),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: 100,
            height: 40,
            child: ElevatedButton(
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
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/'),
                            ),
                          ],
                        );
                      });
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
                            onPressed: () =>
                                Navigator.of(context).pop(0),
                          ),
                        ],
                      );
                    }
                  );
                }
              },
              child: Icon(
                IconData(
                  57846, 
                  fontFamily: 'MaterialIcons'
                ),
                color: Colors.white
              ),
            ),
          ),
        ],
      );
    });
  }
}

class Puzzle extends StatelessWidget {
  final BuildContext context;
  final LogicPuzzle logicPuzzle;
  Puzzle({this.context, this.logicPuzzle});

  @override
  Widget build(BuildContext context) {
    //context.read<PlayController>().checkedList.removeWhere((_) => true);
    context.read<PlayViewModel>().isCorrect = isCorrect;

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
  int get boardColumnsNum => logicPuzzle.width;
  int get boardRowsNum => answer.length ~/ boardColumnsNum;
  List<int> get hintsInEachRow => _hintsInEachRow();
  int get _maxNumOfHintsInEachRow => hintsInEachRow.length ~/ boardRowsNum;
  int get maxNumOfHintsInEachRow => _maxNumOfHintsInEachRow > 0 ? _maxNumOfHintsInEachRow : 1;
  List<int> get hintsInEachColumn => _hintsInEachColumn();
  int get _maxNumOfHintsInEachColumn => hintsInEachColumn.length ~/ boardColumnsNum;
  int get maxNumOfHintsInEachColumn => _maxNumOfHintsInEachColumn > 0 ? _maxNumOfHintsInEachColumn : 1;

  List<int> _hintsInEachRow() {
    List<List<int>> hints = [];
    List<int> tmp;
    int pre;
    int n;
    int maxN = 0;
    for (int i = 0; i < boardColumnsNum; i++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int j = 0; j < boardRowsNum; j++) {
        int now = answer[boardRowsNum * i + j];
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
    for (int i = 0; i < boardRowsNum; i++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int j = 0; j < boardColumnsNum; j++) {
        int now = answer[boardRowsNum * j + i];
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
    _screenWidth / _puzzleWidth < _screenHeight / _puzzleHeight
    ? _screenWidth / _borderLayerWidth
    : _screenHeight / _borderLayerHeight;

  final double _squareSize = PuzzleSetting.squareSize;
  double get squareSize => _squareSize * ratioOfScreenToPuzzle;
  final double _borderWidth = PuzzleSetting.borderWidth;
  double get borderWidth => _borderWidth * ratioOfScreenToPuzzle;
  final double _boldBorderWidth = PuzzleSetting.boldBorderWidth;
  double get boldBorderWidth => _boldBorderWidth * ratioOfScreenToPuzzle;
  final int boldBorderInterval = PuzzleSetting.boldBorderInterval;

  Color borderColor = PuzzleSetting.borderColor;
  Color boldBorderColor = PuzzleSetting.boldBorderColor;
  Color hintBackgroundColor = PuzzleSetting.hintBackgroundColor;
  Color markedColor = PuzzleSetting.markedColor;
  Color nonMarkedColor = PuzzleSetting.nonMarkedColor;

  double get _borderLayerWidth =>
    _boldBorderWidth +
    maxNumOfHintsInEachRow * _squareSize +
    (maxNumOfHintsInEachRow - 1) * _borderWidth + 
    _boldBorderWidth +
    boardColumnsNum * _squareSize +
    (boardColumnsNum - ((boardColumnsNum - 1) ~/ boldBorderInterval) - 1) * _borderWidth + 
    ((boardColumnsNum - 1) ~/ boldBorderInterval) * _boldBorderWidth +
    _boldBorderWidth;
  double get borderLayerWidth => _borderLayerWidth * ratioOfScreenToPuzzle;
  double get _borderLayerHeight =>
    _boldBorderWidth +
    maxNumOfHintsInEachColumn * _squareSize +
    (maxNumOfHintsInEachColumn - 1) * _borderWidth + 
    _boldBorderWidth +
    boardRowsNum * _squareSize +
    (boardRowsNum - ((boardRowsNum - 1) ~/ boldBorderInterval) - 1) * _borderWidth + 
    ((boardRowsNum - 1) ~/ boldBorderInterval) * _boldBorderWidth +
    _boldBorderWidth;
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
  double get viewAreaWidth => (maxNumOfHintsInEachRow.toDouble() * _squareSize + (maxNumOfHintsInEachRow.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  double get viewAreaHeight => (maxNumOfHintsInEachColumn.toDouble() * _squareSize + (maxNumOfHintsInEachColumn.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  Widget buildViewArea() {
    return Consumer<PlayViewModel>(builder: (context, model, _) {
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
                      color: model.logicPuzzle.lastState[index] == 1
                          ? markedColor
                          : nonMarkedColor,
                    ),
                    child: Text(''),
                  );
                })),
      );
    });
  }

  int get _columnHintsAreaBoldBorderNum => (boardColumnsNum - 1) ~/ boldBorderInterval;
  int get _columnHintsAreaBorderNum => boardColumnsNum - _columnHintsAreaBoldBorderNum - 1;
  double get columnHintsAreaLeftOffset => viewAreaLeftOffset + viewAreaWidth + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get columnHintsAreaTopOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get columnHintsAreaWidth => (_squareSize * boardColumnsNum.toDouble() + _borderWidth * _columnHintsAreaBorderNum + _boldBorderWidth * _columnHintsAreaBoldBorderNum) * ratioOfScreenToPuzzle;
  double get columnHintsAreaHeight => (maxNumOfHintsInEachColumn.toDouble() * _squareSize + (maxNumOfHintsInEachColumn.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  Widget buildColumnHintsArea() {
    return Stack(
      children: [
        for (int i = 0; i < boardColumnsNum; i++) 
          for (int j = 0; j < maxNumOfHintsInEachColumn; j++)
            buildHintSquare(
              columnHintsAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
              columnHintsAreaTopOffset + (squareSize + borderWidth) * j,
              squareSize,
              squareSize,
              hintsInEachColumn[maxNumOfHintsInEachColumn * i + j]
            )
      ],
    );
  }

  int get _rowHintsAreaBoldBorderNum => (boardRowsNum - 1) ~/ boldBorderInterval;
  int get _rowHintsAreaBorderNum => boardColumnsNum - _rowHintsAreaBoldBorderNum - 1;
  double get rowHintsAreaLeftOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get rowHintsAreaTopOffset => viewAreaTopOffset + viewAreaHeight + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get rowHintsAreaWidth => (maxNumOfHintsInEachRow.toDouble() * _squareSize + (maxNumOfHintsInEachRow.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  double get rowHintsAreaHeight => (_squareSize * boardRowsNum.toDouble() + _borderWidth * _rowHintsAreaBorderNum + _boldBorderWidth * _rowHintsAreaBorderNum) * ratioOfScreenToPuzzle;
  Widget buildRowHintsArea() {
    return Stack(
      children: [
        for (int i = 0; i < maxNumOfHintsInEachRow; i++) 
          for (int j = 0; j < boardRowsNum; j++)
            buildHintSquare(
              rowHintsAreaLeftOffset + (squareSize + borderWidth) * i,
              rowHintsAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval),
              squareSize,
              squareSize,
              hintsInEachRow[maxNumOfHintsInEachColumn * j + i]
            )
      ],
    );
  }

  int get _boardAreaRowBoldBorderNum => (boardColumnsNum - 1) ~/ boldBorderInterval;
  int get _boardAreaColumnBoldBorderNum => (boardRowsNum - 1) ~/ boldBorderInterval;
  int get _boardAreaRowBorderNum => boardColumnsNum - _boardAreaRowBoldBorderNum - 1;
  int get _boardAreaColumnBorderNum => boardRowsNum - _boardAreaColumnBoldBorderNum - 1;
  double get boardAreaLeftOffset => rowHintsAreaLeftOffset + rowHintsAreaWidth + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get boardAreaTopOffset => columnHintsAreaTopOffset + columnHintsAreaHeight + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get boardAreaWidth => (_squareSize * boardColumnsNum.toDouble() + borderWidth * _boardAreaRowBorderNum + boldBorderWidth * _boardAreaRowBoldBorderNum) * ratioOfScreenToPuzzle;
  double get boardAreaHeight => (_squareSize * boardRowsNum.toDouble() + borderWidth * _boardAreaColumnBorderNum + boldBorderWidth * _boardAreaColumnBoldBorderNum) * ratioOfScreenToPuzzle;
  Widget buildBoardArea() {
    return Consumer<PlayViewModel>(builder: (context, model, _) {
      return Stack(
        children: [
          for (int i = 0; i < boardColumnsNum; i++) 
            for (int j = 0; j < boardRowsNum; j++)
              buildInputSquare(
                boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
                boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval),
                squareSize,
                squareSize,
                boardColumnsNum * j + i
              )
        ],
      );
    });
  }

  Widget buildHintSquare(double left, double top, double width, double height, int hintNum) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: hintBackgroundColor
        ),
        child: FittedBox(
          child: hintNum != 0
            ? Text(
              '${hintNum}',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
            : Text(''),
        )
      )
    );
  }

  Widget buildInputSquare(double left, double top, double width, double height, int index) {
    return Consumer<PlayViewModel>(builder: (context, model, _) {
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: nonMarkedColor,
            ),
            child: ((){ 
              switch (model.logicPuzzle.lastState[index]) {
                case 0:
                  return Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: nonMarkedColor,
                    ),
                    child: Text(''),
                  );
                case 1:
                  return Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: markedColor,
                    ),
                    child: Text(''),
                  );
                case 2:
                  return Container(
                    margin: EdgeInsets.all(2),
                    child: Icon(                        
                      IconData(57704, fontFamily: 'MaterialIcons'),
                          color: markedColor,
                      ),
                  );
              }
            })(),
          ),
          onTap: () {
            if (model.logicPuzzle.lastState[index] == 0) {                
              switch (model.operationMethodIndex) {
                case 0:
                  model.logicPuzzle.lastState[index] = 1;
                  break;
                case 1:
                  model.logicPuzzle.lastState[index] = 2;
                  break;
              }
            } else {
              model.logicPuzzle.lastState[index] = 0;
            }
            model.save();
            model.notify();
          },
        ),
      );
    });
  }

  bool isCorrect() {
    List<int> answerCheckedList = answer
      .asMap()
      .entries
      .where((e) => (e.value == 1))
      .toList()
      .map((e) => e.key)
      .toList();
    List<int> userCheckedList = context.read<PlayViewModel>().checkedList;
    answerCheckedList.sort((a, b) => a - b);
    userCheckedList.sort((a, b) => a - b);
    return listEquals(answerCheckedList, userCheckedList);
  }
}

class PuzzleSetting {
  // TODO: move to settinig(const variables) file
  static const double squareSize = 10.0;
  static const double borderWidth = 0.8;
  static const double boldBorderWidth = 1.5;
  static const int boldBorderInterval = 5;
  static const Color borderColor = Colors.black;
  static const Color boldBorderColor = Colors.black;
  //static final Color hintBackgroundColor = Colors.blue[50];
  static const Color hintBackgroundColor = Color(0xFFE3F2FD);
  //static final Color markedColor = Colors.blue[500];
  static const Color markedColor = Color(0xFF2196F3);
  static const Color nonMarkedColor = Colors.white;
}
