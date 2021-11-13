import 'dart:ui' as ui;

import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/service/utils.dart';
import 'package:ant_1/service/puzzle_painter.dart';
import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayViewModel>().isBuildedOnce = true;
    });

    final GlobalKey customPaintWidgetKey = GlobalKey();
    final GlobalKey customPaintWidgetKey2 = GlobalKey();
    LogicPuzzle logicPuzzle = context.read<PlayViewModel>().logicPuzzle;

    return Scaffold(
      appBar: AppBar(
        title: Text('${logicPuzzle.name}'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<PlayViewModel>(
        builder: (context, model, child) {
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
            onTapDown: (details) {
              Offset tapOffset = details.globalPosition;
              RenderBox box;
              if (!model.isDrawImage) {
                box = customPaintWidgetKey.currentContext.findRenderObject();
              } else {
                box = customPaintWidgetKey2.currentContext.findRenderObject();
              }
              Offset customPaintOffset = box.localToGlobal(Offset.zero);

              for (int index = 0; index < logicPuzzle.dots.length; index++) {
                Offset upperLeftOffset = model.inputSquareLocalPointsList[index][0] * model.scale + customPaintOffset;
                Offset lowerRightOffset = model.inputSquareLocalPointsList[index][1] * model.scale + customPaintOffset;
                if (upperLeftOffset <= tapOffset && tapOffset <= lowerRightOffset) {
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
                  model.tappedSquaeIndex = index;
                  model.save();
                  model.notify();
                  break;
                }
              }
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Transform.translate(
                      offset: model.offset,
                      // offset: Offset(0,0),
                      child: Transform.scale(
                        scale: 0.9,
                        // scale: model.scale,
                        child: child,
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
        },
        child: Consumer<PlayViewModel>(
          builder: (context, model, _) {
            return Stack(
              children: [
                if(!model.isBuildedOnce) buildInitPuzzle(context, customPaintWidgetKey),
                if(model.isBuildedOnce) buildPuzzle(context, customPaintWidgetKey2),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildInitPuzzle(BuildContext context, GlobalKey widgetKey) {
    Size size = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width);
    PuzzleInitPainter painter = PuzzleInitPainter(
      context: context,
      state: context.read<PlayViewModel>().logicPuzzle.lastState,
    );   

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PlayViewModel>().puzzleImage = await getImageFromPainter(painter, size);
    });
    
    return RepaintBoundary(
      key: widgetKey,
      child: CustomPaint(
        size: size,
        painter: painter,
        isComplex: true,
        willChange: false,
      ),
    );
  }

  Widget buildPuzzle(BuildContext context, GlobalKey widgetKey) {
    return Consumer<PlayViewModel>(
      builder: (context, model, child) {
        Size size = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width);
        PuzzleUpdatePainter painter = PuzzleUpdatePainter(
          context: context,
          state: model.logicPuzzle.lastState
        );
        if(context.read<PlayViewModel>().isBuildedOnce && model.tappedSquaeIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            context.read<PlayViewModel>().puzzleImage = await getImageFromPainter(painter, size);
            context.read<PlayViewModel>().tappedSquaeIndex = null;
          });
        }

        return CustomPaint(
          key: widgetKey,
          size: size,
          painter: painter,
          child: Center(),
        );
      }
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

class PuzzleInitPainter extends PuzzlePainter {
  final BuildContext context;
  final List<int> state;
  PuzzleInitPainter({this.context, this.state}) : super(context: context, logicPuzzle: context.read<PlayViewModel>().logicPuzzle); 

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    context.read<PlayViewModel>().isCorrect = isCorrect;
    context.read<PlayViewModel>().inputSquareLocalPointsList = getInputSquareLocalPointsList();
  }

  bool isCorrect() {
    List<int> answerCheckedList = answer
      .asMap()
      .entries
      .where((e) => (e.value == 1))
      .toList()
      .map((e) => e.key)
      .toList();
    LogicPuzzle logicPuzzle = context.read<PlayViewModel>().logicPuzzle;
    List<int> userCheckedList = [];
    logicPuzzle.lastState.asMap().forEach((int i, int value) {
      if (value == 1) userCheckedList.add(i);
    });
    answerCheckedList.sort((a, b) => a - b);
    userCheckedList.sort((a, b) => a - b);
    return listEquals(answerCheckedList, userCheckedList);
  }

  List<List<Offset>> getInputSquareLocalPointsList() {
    List<List<Offset>> inputSquarePointsList = [];
    for (int j = 0; j < boardRowsNum; j++) {
      for (int i = 0; i < boardColumnsNum; i++) {
        Offset upperLeftOffset = Offset(
          boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
          boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        Offset lowerRightOffset = upperLeftOffset + Offset(squareSize, squareSize);
        List<Offset> inputSquarePoints = [upperLeftOffset, lowerRightOffset];
        inputSquarePointsList.add(inputSquarePoints);
      }
    }
    return inputSquarePointsList;
  }
}

class PuzzleUpdatePainter extends PuzzlePainter {
  final BuildContext context;
  final List<int> state;
  PuzzleUpdatePainter({this.context, this.state}) :super(context: context, logicPuzzle: context.read<PlayViewModel>().logicPuzzle);

  @override
  void paint(Canvas canvas, Size size) async {
    int tappedSquareIndex = context.read<PlayViewModel>().tappedSquaeIndex;
    ui.Image puzzleImage = context.read<PlayViewModel>().puzzleImage;

    final paint = Paint();
    canvas.drawImage(puzzleImage, Offset(0, 0), paint);
    if (tappedSquareIndex!=null) {
      drawState(canvas, tappedSquareIndex, state[tappedSquareIndex]);
      drawStateInViewArea(canvas, tappedSquareIndex, state[tappedSquareIndex]);
    }

    context.read<PlayViewModel>().isDrawImage = true;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
