import 'dart:math';

import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:flutter/material.dart';

class PuzzlePainter extends CustomPainter {
  final BuildContext context;
  final LogicPuzzle logicPuzzle;
  PuzzlePainter({this.context, this.logicPuzzle});

  @override
  void paint(Canvas canvas, Size size) {
    drawBorderArea(canvas);
    drawViewArea(canvas);
    drawColumnHintsArea(canvas);
    drawRowHintsArea(canvas);
    drawBoardArea(canvas);
    drawLastState(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
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

  List<int> _hintsInEachRow() { // left-area hints
    List<List<int>> hints = [];
    List<int> tmp;
    int pre;
    int n;
    int maxN = 0;
    for (int j = 0; j < boardRowsNum; j++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int i = 0; i < boardColumnsNum; i++) {
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

  List<int> _hintsInEachColumn() { // upper-area hints
    List<List<int>> hints = [];
    List<int> tmp;
    int pre;
    int n;
    int maxN = 0;
    for (int j = 0; j < boardColumnsNum; j++) {
      tmp = [];
      pre = 0;
      n = 0;
      for (int i = 0; i < boardRowsNum; i++) {
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
    drawLastStateInViewArea(canvas);
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
      for (int j = 0; j < boardRowsNum; j++) {
    for (int i = 0; i < maxNumOfHintsInEachRow; i++) {
        Offset offset = Offset(
          rowHintsAreaLeftOffset + (squareSize + borderWidth) * i,
          rowHintsAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
        );
        drawSquare(canvas, offset, size, PaintingStyle.fill, hintBackgroundColor, 0);
        int hintNum = hintsInEachRow[maxNumOfHintsInEachRow * j + i];
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

  void drawLastState(Canvas canvas) {
    for (int j = 0; j < boardRowsNum; j++) {
      for (int i = 0; i < boardColumnsNum; i++) {
        int index = boardColumnsNum * j + i;
        int state = logicPuzzle.lastState[index];
        drawState(canvas, index, state);
      }
    }
  }

  void drawState(Canvas canvas, int index, int state) {
    Size size = Size(squareSize, squareSize);
    int puzzleWidth = logicPuzzle.width;

    int i = index % puzzleWidth;
    int j = index ~/ puzzleWidth;

    Offset offset = Offset(
      boardAreaLeftOffset + squareSize * i + borderWidth * (i - i ~/ boldBorderInterval) + boldBorderWidth * (i ~/ boldBorderInterval),
      boardAreaTopOffset + squareSize * j + borderWidth * (j - j ~/ boldBorderInterval) + boldBorderWidth * (j ~/ boldBorderInterval)
    );
    
    drawSquare(canvas, offset, size, PaintingStyle.fill, nonMarkedColor, 0);
    switch (state) {
      case 0:
        break;
      case 1:
        drawMarked1(canvas, offset, size, markedColor, 0);
        break;
      case 2:
        drawMarked2(canvas, offset, size, markedColor, borderWidth);
        break;
    }
  }

  double get drawAreaInViewAreaWidth => min(viewAreaWidth, viewAreaHeight) * 0.9;
  double get drawAreaInViewAreaHeight => min(viewAreaWidth, viewAreaHeight) * 0.9;
  Size get drawAreaInViewAreaSize => Size(drawAreaInViewAreaWidth, drawAreaInViewAreaHeight);
  double get drawAreaInViewAreaLeftOffset => viewAreaLeftOffset + (viewAreaWidth - drawAreaInViewAreaWidth) / 2;
  double get drawAreaInViewAreaTopOffset => viewAreaTopOffset + (viewAreaHeight - drawAreaInViewAreaHeight) / 2;
  Offset get drawAreaInViewAreaOffset => Offset(drawAreaInViewAreaLeftOffset, drawAreaInViewAreaTopOffset);
  Size get drawAreaInViewAreaSquareSize => drawAreaInViewAreaSize / max(boardColumnsNum.toDouble(), boardRowsNum.toDouble());
  void drawLastStateInViewArea(Canvas canvas) {
    for (int i = 0; i < boardColumnsNum; i++) {
      for (int j = 0; j < boardRowsNum; j++) {
        int index = boardColumnsNum * j + i;
        int state = logicPuzzle.lastState[index];
        drawStateInViewArea(canvas, index, state);
      }
    }
  }

  void drawStateInViewArea(Canvas canvas, int index, int state) {
    int puzzleWidth = logicPuzzle.width;
    int i = index % puzzleWidth;
    int j = index ~/ puzzleWidth;

    Offset offset = Offset(
      drawAreaInViewAreaLeftOffset + drawAreaInViewAreaSquareSize.width * i,
      drawAreaInViewAreaTopOffset + drawAreaInViewAreaSquareSize.height * j
    );
    Size size = drawAreaInViewAreaSquareSize;

    double padding1 = size.width * 0.01;
    Offset offset1 = offset + Offset(padding1, padding1) / 2;
    Size size1 = size * 0.99;
    double padding2 = size.width * 0.1;
    Offset offset2 = offset + Offset(padding2, padding2) / 2;
    Size size2 = size * 0.9;

    drawSquare(canvas, offset1, size1, PaintingStyle.fill, nonMarkedColor, 0);
    switch (state) {
      case 0:
        break;
      case 1:
        drawSquare(canvas, offset2, size2, PaintingStyle.fill, markedColor, 0);
        break;
      case 2:
        break;
    }
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

  void drawMarked1(Canvas canvas, Offset offset, Size size, Color color, double strokeWidth) {
    double padding = squareSize * 0.9;
    Offset filledSquareOffset = Offset(
      offset.dx + padding,
      offset.dy + padding
    );
    Size filledSquareSize = Size(
      size.width - padding * 2,
      size.height - padding * 2 
    );
    drawSquare(canvas, filledSquareOffset, filledSquareSize, PaintingStyle.fill, color, 0);
  }

  void drawMarked2(Canvas canvas, Offset offset, Size size, Color color, double strokeWidth) {
    double padding = squareSize * 0.9;
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    Offset checkedMarkOffset = Offset(
      offset.dx + padding,
      offset.dy + padding
    );
    Size checkedMarkSize = Size(
      size.width - padding * 2,
      size.height - padding * 2 
    );

    Path path = Path();
    path.moveTo(checkedMarkOffset.dx, checkedMarkOffset.dy);
    path.lineTo(checkedMarkOffset.dx + checkedMarkSize.width, checkedMarkOffset.dy + checkedMarkSize.height);
    path.close();
    
    Path path2 = Path();
    path.moveTo(checkedMarkOffset.dx, checkedMarkOffset.dy + checkedMarkSize.height);
    path.lineTo(checkedMarkOffset.dx + checkedMarkSize.width, checkedMarkOffset.dy);
   
    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
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