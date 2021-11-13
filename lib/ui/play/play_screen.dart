import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class PlayScreen extends StatelessWidget {
  void afterBuild(){

    print("builded");
  }
  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) => showDialog(
    //     context: context, 
    //     builder: (_) {
    //       return AlertDialog(
    //         title: Center(child: Text("タイトル"),),
    //         content: Text("ここにメッセージが表示される"),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text("キャンセル"),
    //             onPressed: () => Navigator.pop(context),
    //           ),
    //           FlatButton(
    //             child: Text("OK"),
    //             onPressed: () => Navigator.pop(context),
    //           ),
    //         ],
    //       );
    //     }
    //   )
    // );

    // WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayViewModel>().isBuildedOnce = true;
      print("first builded.");
    });


    final GlobalKey customPaintWidgetKey = GlobalKey();
    final GlobalKey customPaintWidgetKey2 = GlobalKey();
    LogicPuzzle logicPuzzle = context.read<PlayViewModel>().logicPuzzle;
    // LogicPuzzle logicPuzzle = Provider.of(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // print('width: $width');
    // print('height: $height');

    print(context.read<PlayViewModel>().logicPuzzle.lastState);

    return Scaffold(
      appBar: AppBar(
        title: Text('${logicPuzzle.name}'),
        //automaticallyImplyLeading: false,
      ),
      body: Consumer<PlayViewModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onScaleStart: (details) {
              // model.isShouldrepaint = false;
              // model.notify();
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
              // model.isShouldrepaint = true;
              // model.notify();
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
                  model.notifier = ValueNotifier(model.logicPuzzle.lastState);
                  model.notify();
                  print('tapped $index th square');
                  break;
                }
              }
              print(model.logicPuzzle.lastState);
              print('isBuildOnce: ${model.isBuildedOnce}');
              // model.isShouldrepaint = false;
              // model.notify();
            },
            child: Column(
              children: <Widget>[
                Text('${model.isShouldrepaint}'),
                Expanded(
                  child: Container(
                    child: Transform.translate(
                      offset: model.offset,
                      // offset: Offset(0,0),
                      child: Transform.scale(
                        scale: 0.9,
                        // scale: model.scale,
                        child: child,
        //                 Stack(
        //   children: [
        //     buildPuzzleBackground(context, customPaintWidgetKey),
        //     buildPuzzleState(context),
        //     Consumer<PlayViewModel>(
        //       builder: (context, model, _) {
        //         return Row(
        //           children: [
        //             // Text('${model.logicPuzzle.lastState}'),
        //             //Text('${model.logicPuzzle.lastState[1]}'),
        //           ]
        //         );
        //       }
        //     )
        //   ],
        // ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child:
                  Consumer<PlayViewModel>(
              builder: (context, model, _) {
                return 
        Stack(

          children: [
            if(!model.isBuildedOnce) buildPuzzleBackground(context, customPaintWidgetKey),
            // if(!context.read<PlayViewModel>().isBuildedOnce) buildPuzzleBackground(context, customPaintWidgetKey),
            // if(context.read<PlayViewModel>().puzzleBytes == null) buildPuzzleBackground(context, customPaintWidgetKey),
            if(model.isBuildedOnce) buildPuzzleState(context, customPaintWidgetKey2),
            // if(context.read<PlayViewModel>().isBuildedOnce) buildPuzzleState(context),
            Consumer<PlayViewModel>(
              builder: (context, model, _) {
                return Row(
                  children: [
                    // Text('${model.logicPuzzle.lastState}'),
                    //Text('${model.logicPuzzle.lastState[1]}'),
                    //model.puzzleBytes!=null ? Image.memory(Uint8List.view(model.puzzleBytes.buffer)) : Text('aaa'),
                    //Text('aaa')
                  ]
                );
              }
            )
          ],
        )
        ;
              }),
      ),
    );
  }

  Widget buildPuzzleBackground(BuildContext context, GlobalKey widgetKey) {
    print('start buildPuzzleBackground');
    Size size = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width);
    PuzzlePainter painter = PuzzlePainter(
      context: context,
    );   
    if(context.read<PlayViewModel>().puzzleBytes == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => save(context, painter, size));
    }
    
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

  // Widget buildPuzzleState(BuildContext context) {
  //   return RepaintBoundary(
  //     child: 
  //     Selector<PlayViewModel, List<int>>(
  //       selector: (_, model) => model.logicPuzzle.lastState,
  //       builder: (context, model, child) {
  //         return CustomPaint(
  //           size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width),
  //           painter: PuzzleStatePainter(
  //             context: context,
  //             notifier: context.read<PlayViewModel>().notifier,
  //             state: model
  //           ),
  //           isComplex: true,
  //         );
  //       } ,
  //     )
  //   );
  // }

  void save(BuildContext context, CustomPainter painter, Size size) async {
    print('start saved');
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), size);
    final ui.Picture picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    context.read<PlayViewModel>().puzzleBytes = pngBytes;
    context.read<PlayViewModel>().puzzleImage = image;
    //final image = await decodeImageFromList(Uint8List.view(pngBytes.buffer));

    print('end saved');
  }

  void save2(BuildContext context, CustomPainter painter, Size size) async {
    print('start saved2');
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), size);
    final ui.Picture picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    context.read<PlayViewModel>().puzzleBytes = pngBytes;
    context.read<PlayViewModel>().puzzleImage = image;
    // final image = await decodeImageFromList(Uint8List.view(pngBytes.buffer));
    context.read<PlayViewModel>().tappedSquaeIndex = null;

    print('end saved2');
  }

  Widget buildPuzzleState(BuildContext context, GlobalKey widgetKey) {
    print('start buildPuzzleState');
    return 
    Consumer<PlayViewModel>(
      builder: (context, model, child) {
        Size size = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width);
        PuzzleStatePainter painter = PuzzleStatePainter(
          context: context,
          notifier: model.notifier,
          state: model.logicPuzzle.lastState
        );
        // if(context.read<PlayViewModel>().puzzleBytes != null && model.tappedSquaeIndex != null) {
        // if(model.tappedSquaeIndex != null) {
        if(context.read<PlayViewModel>().isBuildedOnce && model.tappedSquaeIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => save2(context, painter, size));
        }
        // return RepaintBoundary(child: 
        return 
        CustomPaint(
          key: widgetKey,
          size: size,
          // painter: PuzzleStatePainter(
          //   context: context,
          //   notifier: model.notifier,
          //   state: model.logicPuzzle.lastState
          // ),
          painter: painter,
          child: Center(),
          // isComplex: true,
        // )
        );
      }
    );
  }

}

class PuzzleStatePainter extends PuzzlePainter {
  final BuildContext context;
  final ValueNotifier notifier;
  final List<int> state;
  PuzzleStatePainter({this.context, this.notifier, this.state}): super(context: context, notifier: notifier);

  @override
  void paint(Canvas canvas, Size size) async {
    bool isBuildedOnce = context.read<PlayViewModel>().isBuildedOnce;
    print('start PuzzleStatePainter.paint');
    print('isBuildedOnce: $isBuildedOnce');
    // context.read<PlayViewModel>().isCorrect = isCorrect;
    // context.read<PlayViewModel>().inputSquareLocalPointsList = getInputSquareLocalPointsList();
    // drawSquare(canvas, Offset(10, -100), Size(200, 200), PaintingStyle.fill, markedColor, 0);
    // final PictureRecorder recorder = PictureRecorder();
    // Canvas rCanvas = Canvas(recorder);
    List<int> lastState = context.read<PlayViewModel>().logicPuzzle.lastState;
    print('lastState: $lastState');
    print('state: $state');
    int tappedSquareIndex = context.read<PlayViewModel>().tappedSquaeIndex;
    print('tappedSquareIndex: $tappedSquareIndex');

    ui.Image puzzleImage = context.read<PlayViewModel>().puzzleImage;
    // if(puzzleImage != null) {


    // if(!context.read<PlayViewModel>().isBuildedOnce) {
    //   final paint = Paint();
    //   canvas.drawImage(puzzleImage, Offset(0, 0), paint);
    //   // drawBoardInitState(canvas);
    // } else {
    //   if (tappedSquareIndex!=null) {
    //     print('call drawBoardState');
    //     drawBoardState(canvas);
    //   }
    // }
    final paint = Paint();
    canvas.drawImage(puzzleImage, Offset(0, 0), paint);
    if (tappedSquareIndex!=null) {
      print('call drawBoardState');
      drawBoardState(canvas);
    }

    context.read<PlayViewModel>().isDrawImage = true;
    // canvas = rCanvas;
    print('end PuzzleStatePainter.paint');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // return false;
    return true;
  }
  void drawBoardState(Canvas canvas) {
    print('exe drawBoardState');

    Size size = Size(squareSize, squareSize);
    int tappedSquareIndex = context.read<PlayViewModel>().tappedSquaeIndex;
    int puzzleWidth = context.read<PlayViewModel>().logicPuzzle.width;

    int i = tappedSquareIndex % puzzleWidth;
    int j = tappedSquareIndex ~/ puzzleWidth;

    Offset offset = Offset(
      boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
      boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
    );
    
    //if (tappedSquareIndex > 1) return;
    // switch (context.read<PlayViewModel>().logicPuzzle.lastState[index]) {
    switch (state[tappedSquareIndex]) {
      case 0:
        drawSquare(canvas, offset, size, PaintingStyle.fill, nonMarkedColor, 0);
        break;
      case 1:
        drawSquare(canvas, offset, size, PaintingStyle.fill, markedColor, 0);
        break;
      case 2:
        break;
    }

  }
  void drawBoardInitState(Canvas canvas) {
    print('exe drawBoardInitState');
    Size size = Size(squareSize, squareSize);
    for (int j = 0; j < boardRowsNum; j++) {
      for (int i = 0; i < boardColumnsNum; i++) {
        Offset offset = Offset(
          boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
          boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        int index = boardColumnsNum * j + i;
        //if (index > 10) return;
        // switch (context.read<PlayViewModel>().logicPuzzle.lastState[index]) {
        switch (state[index]) {
          case 0:
            break;
          case 1:
            drawSquare(canvas, offset, size, PaintingStyle.fill, markedColor, 0);
            break;
          case 2:
            break;
        }
      }
    }
  }
}

class PuzzlePainter extends CustomPainter {
  final BuildContext context;
  final ValueNotifier notifier;
  PuzzlePainter({this.context, this.notifier}) : super(repaint: notifier);

  @override
  void paint(Canvas canvas, Size size) {
    print('start PuzllePainter.paint');
    context.read<PlayViewModel>().isCorrect = isCorrect;
    context.read<PlayViewModel>().inputSquareLocalPointsList = getInputSquareLocalPointsList();

    drawBorderArea(canvas);
    drawViewArea(canvas);
    drawColumnHintsArea(canvas);
    drawRowHintsArea(canvas);
    drawBoardArea(canvas);
    drawState(canvas);
    print('end PuzzlePainter.paint');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  LogicPuzzle get logicPuzzle => context.read<PlayViewModel>().logicPuzzle;
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

  Color borderColor = PuzzleSetting.borderColor;
  Color hintBackgroundColor = PuzzleSetting.hintBackgroundColor;
  Color hintTextColor = PuzzleSetting.hintTextColor;
  Color markedColor = PuzzleSetting.markedColor;
  Color nonMarkedColor = PuzzleSetting.nonMarkedColor;

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
  Offset get borderLayerOffset => Offset(0, 0);
  Size get borderLayerSize => Size(borderLayerWidth, borderLayerHeight);
  void drawBorderArea(Canvas canvas) {
    drawSquare(canvas, borderLayerOffset, borderLayerSize, PaintingStyle.fill, borderColor, 0);
  }

  double get viewAreaLeftOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get viewAreaTopOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  Offset get viewAreaOffset => Offset(viewAreaLeftOffset, viewAreaTopOffset);
  double get viewAreaWidth => (maxNumOfHintsInEachRow.toDouble() * _squareSize + (maxNumOfHintsInEachRow.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  double get viewAreaHeight => (maxNumOfHintsInEachColumn.toDouble() * _squareSize + (maxNumOfHintsInEachColumn.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  Size get viewAreaSize => Size(viewAreaWidth, viewAreaHeight);
  void drawViewArea(Canvas canvas) {
    drawSquare(canvas, viewAreaOffset, viewAreaSize, PaintingStyle.fill, nonMarkedColor, 0);
  }

  int get _columnHintsAreaBoldBorderNum => (boardColumnsNum - 1) ~/ boldBorderInterval;
  int get _columnHintsAreaBorderNum => boardColumnsNum - _columnHintsAreaBoldBorderNum - 1;
  double get columnHintsAreaLeftOffset => viewAreaLeftOffset + viewAreaWidth + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get columnHintsAreaTopOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  Offset get columnHintsAreaOffset => Offset(columnHintsAreaLeftOffset, columnHintsAreaTopOffset);
  double get columnHintsAreaWidth => (_squareSize * boardColumnsNum.toDouble() + _borderWidth * _columnHintsAreaBorderNum + _boldBorderWidth * _columnHintsAreaBoldBorderNum) * ratioOfScreenToPuzzle;
  double get columnHintsAreaHeight => (maxNumOfHintsInEachColumn.toDouble() * _squareSize + (maxNumOfHintsInEachColumn.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  Size get columnHiintsAreraSize => Size(columnHintsAreaWidth, columnHintsAreaHeight);
  void drawColumnHintsArea(Canvas canvas) {
    Size size = Size(squareSize, squareSize);
    for (int i = 0; i < boardColumnsNum; i++) {
      for (int j = 0; j < maxNumOfHintsInEachColumn; j++) {
        Offset offset = Offset(
          columnHintsAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
          columnHintsAreaTopOffset + (squareSize + borderWidth) * j
        );
        drawSquare(canvas, offset, size, PaintingStyle.fill, hintBackgroundColor, 0);
        int hintNum = hintsInEachColumn[maxNumOfHintsInEachColumn * i + j];
        String hintText = hintNum > 0 ? '$hintNum' : ''; 
        drawHintText(canvas, offset, size, hintText);
      }
    }
  }

  int get _rowHintsAreaBoldBorderNum => (boardRowsNum - 1) ~/ boldBorderInterval;
  int get _rowHintsAreaBorderNum => boardColumnsNum - _rowHintsAreaBoldBorderNum - 1;
  double get rowHintsAreaLeftOffset => _boldBorderWidth * ratioOfScreenToPuzzle;
  double get rowHintsAreaTopOffset => viewAreaTopOffset + viewAreaHeight + _boldBorderWidth * ratioOfScreenToPuzzle;
  Offset get rowHintsAreaOffset => Offset(rowHintsAreaLeftOffset, rowHintsAreaTopOffset);
  double get rowHintsAreaWidth => (maxNumOfHintsInEachRow.toDouble() * _squareSize + (maxNumOfHintsInEachRow.toDouble() - 1) * _borderWidth) * ratioOfScreenToPuzzle;
  double get rowHintsAreaHeight => (_squareSize * boardRowsNum.toDouble() + _borderWidth * _rowHintsAreaBorderNum + _boldBorderWidth * _rowHintsAreaBorderNum) * ratioOfScreenToPuzzle;
  Size get rowHintsAreaSize => Size(rowHintsAreaWidth, rowHintsAreaHeight);
  void drawRowHintsArea(Canvas canvas) {
    Size size = Size(squareSize, squareSize);
    for (int i = 0; i < maxNumOfHintsInEachRow; i++) {
      for (int j = 0; j < boardRowsNum; j++) {
        Offset offset = Offset(
          rowHintsAreaLeftOffset + (squareSize + borderWidth) * i,
          rowHintsAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        drawSquare(canvas, offset, size, PaintingStyle.fill, hintBackgroundColor, 0);
        int hintNum = hintsInEachRow[maxNumOfHintsInEachColumn * j + i];
        String hintText = hintNum > 0 ? '$hintNum' : ''; 
        drawHintText(canvas, offset, size, hintText);
      }
    }
  }

  int get _boardAreaRowBoldBorderNum => (boardColumnsNum - 1) ~/ boldBorderInterval;
  int get _boardAreaColumnBoldBorderNum => (boardRowsNum - 1) ~/ boldBorderInterval;
  int get _boardAreaRowBorderNum => boardColumnsNum - _boardAreaRowBoldBorderNum - 1;
  int get _boardAreaColumnBorderNum => boardRowsNum - _boardAreaColumnBoldBorderNum - 1;
  double get boardAreaLeftOffset => rowHintsAreaLeftOffset + rowHintsAreaWidth + _boldBorderWidth * ratioOfScreenToPuzzle;
  double get boardAreaTopOffset => columnHintsAreaTopOffset + columnHintsAreaHeight + _boldBorderWidth * ratioOfScreenToPuzzle;
  Offset get boardAreaOffset => Offset(boardAreaLeftOffset, boardAreaTopOffset);
  double get boardAreaWidth => (_squareSize * boardColumnsNum.toDouble() + borderWidth * _boardAreaRowBorderNum + boldBorderWidth * _boardAreaRowBoldBorderNum) * ratioOfScreenToPuzzle;
  double get boardAreaHeight => (_squareSize * boardRowsNum.toDouble() + borderWidth * _boardAreaColumnBorderNum + boldBorderWidth * _boardAreaColumnBoldBorderNum) * ratioOfScreenToPuzzle;
  Size get boardAreaSize => Size(boardAreaWidth, boardAreaHeight);
  void drawBoardArea(Canvas canvas) {
    Size size = Size(squareSize, squareSize);
    for (int i = 0; i < boardColumnsNum; i++) {
      for (int j = 0; j < boardRowsNum; j++) {
        Offset offset = Offset(
          boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
          boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        drawSquare(canvas, offset, size, PaintingStyle.fill, nonMarkedColor, 0);
      }
    }
  }

  void drawState(Canvas canvas) {
    print('exe drawState');
    List<int> state = context.read<PlayViewModel>().logicPuzzle.lastState;
    Size size = Size(squareSize, squareSize);
    for (int j = 0; j < boardRowsNum; j++) {
      for (int i = 0; i < boardColumnsNum; i++) {
        Offset offset = Offset(
          boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
          boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        int index = boardColumnsNum * j + i;
        // switch (context.read<PlayViewModel>().logicPuzzle.lastState[index]) {
        switch (state[index]) {
          case 0:
            break;
          case 1:
            drawSquare(canvas, offset, size, PaintingStyle.fill, markedColor, 0);
            break;
          case 2:
            break;
        }
      }
    }
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

  void drawSquare(Canvas canvas, Offset offset, Size size, PaintingStyle style, Color color, double strokeWidth) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.butt
      ..style = style
      ..strokeWidth = strokeWidth;
    
    Path path = Path();
    path.moveTo(offset.dx, offset.dy);
    path.lineTo(offset.dx, offset.dy + size.height);
    path.lineTo(offset.dx + size.width, offset.dy + size.height);
    path.lineTo(offset.dx + size.width, offset.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void drawHintText(Canvas canvas, Offset squareOffset, Size squareSize, String text) {
    TextStyle textStyle = TextStyle(
      color: hintTextColor,
      fontSize: squareSize.width * 0.9,
    );
    TextSpan textSpan = TextSpan(
      style: textStyle,
      children: <TextSpan>[
        TextSpan(text: text),
      ]
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr
    );
    textPainter.layout();
    Offset offset = squareOffset 
      - Offset(textPainter.width/2.0, textPainter.height/2.0) 
      + Offset(squareSize.width/2.0, squareSize.height/2.0);
    textPainter.paint(canvas, offset);
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
  //static final Color hintBackgroundColor = Colors.blue[50];
  static const Color hintBackgroundColor = Color(0xFFE3F2FD);
  static const Color hintTextColor = Colors.black;
  //static final Color markedColor = Colors.blue[500];
  static const Color markedColor = Color(0xFF2196F3);
  static const Color nonMarkedColor = Colors.white;
}