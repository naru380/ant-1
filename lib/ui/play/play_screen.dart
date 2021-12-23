import 'dart:math';
import 'dart:ui' as ui;
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ant_1/service/admob.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/service/utils.dart';
import 'package:ant_1/service/puzzle_painter.dart';
import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PlayScreen extends StatelessWidget {
  static const Color appBarColor = Color(0xFF3DEFE2);
  static const Color backgroundColor = Color(0xFFFFFBE5);
  Color textColor = Color(0xFF5C4444);
  Color playColor = Color(0xFFFF595F);
  Color playInnerColor = Color(0xFFFF9C94);
  Color backColor = Color(0xFFFFFBE5);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayViewModel>().isBuildedOnce = true;
    });

    final GlobalKey customPaintWidgetKey = GlobalKey();
    final GlobalKey customPaintWidgetKey2 = GlobalKey();
    LogicPuzzle logicPuzzle = context.read<PlayViewModel>().logicPuzzle;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${logicPuzzle.name}',
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        centerTitle: false,
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: backgroundColor,
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

              model.offset = Offset(
                min(max(-screenWidth*0.5, model.offset.dx), screenWidth*0.5), 
                min(max(-screenWidth*0.5, model.offset.dy), screenWidth*0.5)
              );

              model.scale += (details.scale - 1.0) * 0.1;
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
                      child: Transform.scale(
                        scale: model.scale,
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
      bottomNavigationBar: AdmobBanner(
            adUnitId: AdMobService().getBannerAdUnitId(),
            adSize: AdmobBannerSize(
              width: MediaQuery.of(context).size.width.toInt(),
              height: AdMobService().getHeight(context).toInt(),
              name: 'SMART_BANNER',
            ),
          ),
    );
  }

  Widget buildInitPuzzle(BuildContext context, GlobalKey widgetKey) {
    PuzzleInitPainter painter = PuzzleInitPainter(
      context: context,
      state: context.read<PlayViewModel>().logicPuzzle.lastState,
      puzzleImage: context.read<PlayViewModel>().puzzleImage
    );
    Size size = Size(painter.borderLayerWidth, painter.borderLayerHeight);

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
        PuzzleUpdatePainter painter = PuzzleUpdatePainter(
          context: context,
          state: model.logicPuzzle.lastState
        );
        Size size = Size(painter.borderLayerWidth, painter.borderLayerHeight);
        if (context.read<PlayViewModel>().isBuildedOnce && model.tappedSquaeIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            context.read<PlayViewModel>().puzzleImage = await getImageFromPainter(painter, size);
            context.read<PlayViewModel>().tappedSquaeIndex = null;
            ByteData byteData = await context.read<PlayViewModel>().puzzleImage.toByteData(format: ui.ImageByteFormat.png);
            context.read<PlayViewModel>().logicPuzzle.stateList = byteData.buffer.asUint8List();
            context.read<PlayViewModel>().save();
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

  static const Color backButtonColor = Color(0xFF3D99E5);
  static const Color changeOprMethodButtonColor = Color(0xFFFF595F);
  static const Color inactiveChangeOprMethodButtonStrokeColor = Color(0xFFFF9C94);
  static const Color checkButtonColor = Color(0xFFFFD65A);
  static const Color buttonFontColor = Color(0xFF5C4444);
  static const Color backgroundColor = Color(0xFFFFFBE5);
  final double operationBarHight = 60.h;
  final double buttonWidth = 80.w;
  final double buttonHeight = 40.h;
  final double buttonMargin = 5.w;
  double get buttonRadius => 10.r;
  final double buttonFontSize = 35.sp;
  ButtonStyle get activeButtonStyle => ElevatedButton.styleFrom(
    primary: changeOprMethodButtonColor,
    shadowColor: backgroundColor,
    onPrimary: changeOprMethodButtonColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
  );
  ButtonStyle get inactiveButtonStyle => ElevatedButton.styleFrom(
    primary: backgroundColor,
    shadowColor: backgroundColor,
    onPrimary: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    side: BorderSide(
      color: inactiveChangeOprMethodButtonStrokeColor,
      width: 3.w,
    ),
  );

  @override
  Widget build(BuildContext context) {

    return Consumer<PlayViewModel>(builder: (context, model, _) {
      return Container(
        height: operationBarHight,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.all(buttonMargin),
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
                    style: ElevatedButton.styleFrom(
                      primary: backButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    child: Icon(
                      IconData(0xee85, fontFamily: 'MaterialIcons', matchTextDirection: true),
                      color: buttonFontColor,
                      size: buttonFontSize,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(buttonMargin),
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: (() {
                      if (model.operationMethodIndex == 1) {
                        return activeButtonStyle;
                      } else {
                        return inactiveButtonStyle;
                      }
                    })(),
                    onPressed: () {
                    },
                    child: Icon(
                      IconData(0xefd2, fontFamily: 'MaterialIcons'),
                      color: buttonFontColor,
                      size: buttonFontSize,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(buttonMargin),
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: (() {
                      if (model.operationMethodIndex == 0) {
                        return activeButtonStyle;
                      } else {
                        return inactiveButtonStyle;
                      }
                    })(),
                    onPressed: () {
                    },
                    child: Container(
                      width: buttonFontSize*0.7,
                      height: buttonFontSize*0.7,
                      decoration: BoxDecoration(
                        color: buttonFontColor,
                      ),
                      child: Text(''),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(buttonMargin),
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: checkButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                    ),
                    onPressed: () {
                      if (model.isCorrect()) {
                        model.logicPuzzle.isClear = true;
                        model.save();
                        Navigator.of(context).pushNamed(
                          '/clear',
                            arguments: {
                              'title': model.logicPuzzle.name,
                              'image': model.logicPuzzle.compImage,
                            },
                          );
                        // showDialog<int>(
                        //     context: context,
                        //     barrierDismissible: false,
                        //     builder: (BuildContext context) {
                        //       return AlertDialog(
                        //         title: Text('COMPLETE'),
                        //         content: Text('TOPページに戻ります。'),
                        //         actions: <Widget>[
                        //           TextButton(
                        //             child: Text('OK'),
                        //             onPressed: () =>
                        //                 Navigator.of(context).pushNamed('/'),
                        //           ),
                        //         ],
                        //       );
                        //     });
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
                      IconData(0xefe7, fontFamily: 'MaterialIcons'),
                      color: buttonFontColor,
                      size: buttonFontSize,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              child: TextButton(
                onPressed: () {
                  model.changeOperationMethod();
                  model.notify();
                },
                child: Icon(
                  IconData(0xeeb1, fontFamily: 'MaterialIcons'),
                  color: buttonFontColor,
                  size: buttonFontSize,
                ),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(buttonMargin*2),
                  primary: changeOprMethodButtonColor,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

class PuzzleInitPainter extends PuzzlePainter {
  final BuildContext context;
  final List<int> state;
  final ui.Image puzzleImage;
  PuzzleInitPainter({this.context, this.state, this.puzzleImage}) : super(context: context, logicPuzzle: context.read<PlayViewModel>().logicPuzzle);

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzleImage == null) {
      super.paint(canvas, size);
    } else {
      final paint = Paint();
      canvas.drawImage(puzzleImage, Offset(0, 0), paint);
    }
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
