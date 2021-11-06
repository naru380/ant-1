import 'dart:ui' as ui;
import 'package:ant_1/ui/create/init_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:ant_1/ui/create/create_view_model.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    imgLib.Image croppedImage = args['croppedImage'];
    double rectSize = args['rectSize'];
    List<double> imageSize = args['imageSize'];
    List<int> rectNum = args['rectNum'];
    List<double> aveList = args['aveList'];
    List<List<DropdownMenuItem<int>>> itemList = setItems(imageSize, rectSize);
    List<DropdownMenuItem<int>> _nums = itemList[0];
    List<DropdownMenuItem<int>> _thrs = itemList[1];
    List<int> containerSize = [
      (size.width / 3).floor(),
      (size.width / 3 * (imageSize[1] / imageSize[0])).floor()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Column(
                children: [
                  SizedBox(
                    width: containerSize[0].toDouble(),
                    height: containerSize[1].toDouble(),
                    child: Image.memory(
                      imgLib.encodeJpg(croppedImage),
                      width: 130,
                    ),
                  ),
                  Text(
                    '元画像',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: size.width / 10,
              ),
              Column(
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Consumer<CreateViewModel>(
                      builder: (context, model, _) {
                        return SizedBox(
                          width: containerSize[0].toDouble(),
                          height: containerSize[1].toDouble(),
                          child: CustomPaint(
                              painter: OriginalPainter(model.compImage)),
                        );
                      },
                    ),
                  ),
                  Text(
                    'ドット絵',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    ' ドット幅: ',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Consumer<CreateViewModel>(
                    builder: (context, model, _) {
                      return SizedBox(
                        width: size.width / 3,
                        height: size.width / 10,
                        child: DropdownButton(
                          items: _nums,
                          value: model.selectNum,
                          onChanged: (value) => {
                            model.selectNum = value,
                            model.rectWidth =
                                (imageSize[0] / (rectSize * model.selectNum))
                                    .round(),
                            model.interList = createInterList(
                                aveList, rectNum, model.selectNum),
                            model.widthNum =
                                (imageSize[0] / (rectSize * model.selectNum))
                                    .round(),
                            model.dotList = createDotList(
                                model.interList,
                                model.selectThr,
                                model.selectNum,
                                model.widthNum),
                            syncVariable(
                                makeImage(model.dotList, rectNum[0], rectNum[1],
                                    containerSize),
                                model),
                            model.notify(),
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    ' 閾値: ',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Consumer<CreateViewModel>(
                    builder: (context, model, _) {
                      return SizedBox(
                        width: size.width / 4,
                        height: size.width / 10,
                        child: DropdownButton(
                          items: _thrs,
                          value: model.selectThr,
                          onChanged: (value) => {
                            model.selectThr = value,
                            model.dotList = createDotList(
                                model.interList,
                                model.selectThr,
                                model.selectNum,
                                model.widthNum),
                            syncVariable(
                                makeImage(model.dotList, rectNum[0], rectNum[1],
                                    containerSize),
                                model),
                            model.notify(),
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
              Consumer<CreateViewModel>(
                builder: (context, model, _) {
                  return TextField(
                    maxLength: 20,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 20.0,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'タイトル',
                    ),
                    style: TextStyle(
                      fontSize: 25,
                    ),
                    onChanged: (value) => {
                      model.title = value,
                    },
                  );
                },
              )
            ],
          ),
          Consumer<CreateViewModel>(
            builder: (context, model, _) {
              return Container(
                height: size.width / 8,
                width: size.width / 3,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: GestureDetector(
                  onTap: () async {
                    ByteData byteData = await model.compImage
                        .toByteData(format: ui.ImageByteFormat.png);
                    var dotImage = byteData.buffer.asUint8List();
                    Navigator.of(context).pushNamed(
                      '/confirm',
                      arguments: {
                        'title': model.title,
                        'dotList': model.dotList,
                        'width': model.widthNum,
                        'dotImage': dotImage,
                        'imageSize': imageSize,
                      },
                    );
                  },
                  child: Center(
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

List<int> createDotList(
    List<double> interList, int thresh, int num, int widthNum) {
  List<int> result = [];
  List<int> tmp;
  int p = 0;
  for (int i = 0; i < (interList.length / widthNum); i++) {
    tmp = [];
    for (int j = 0; j < widthNum; j++) {
      if (interList[p] > thresh) {
        for (int n = 0; n < num; n++) {
          tmp.add(0);
        }
      } else {
        for (int n = 0; n < num; n++) {
          tmp.add(1);
        }
      }
      p++;
    }
    for (int k = 0; k < num; k++) {
      result += tmp;
    }
  }
  return result;
}

// List<int> createDotList(
//     List<double> interList, int thresh, int num, int widthNum) {
//   List<int> result = [];
//   for (int i = 0; i < interList.length; i++) {
//       if (interList[i] > thresh) {
//         for (int n = 0; n < num; n++) {
//           result.add(0);
//         }
//       } else {
//         for (int n = 0; n < num; n++) {
//           result.add(1);
//         }
//       }
//   }
//   return result;
// }

List<List<DropdownMenuItem<int>>> setItems(
    List<double> imageSize, double rectSize) {
  List<DropdownMenuItem<int>> _nums = [];
  List<DropdownMenuItem<int>> _thrs = [];

  _nums
    ..add(
      DropdownMenuItem(
        child: Text(
          (imageSize[0] / (rectSize * 10)).round().toString() +
              ' × ' +
              (imageSize[1] / (rectSize * 10)).round().toString(),
          style: TextStyle(fontSize: 20.0),
        ),
        value: 10,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          (imageSize[0] / (rectSize * 4)).round().toString() +
              ' × ' +
              (imageSize[1] / (rectSize * 4)).round().toString(),
          style: TextStyle(fontSize: 20.0),
        ),
        value: 4,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          (imageSize[0] / (rectSize * 2)).round().toString() +
              ' × ' +
              (imageSize[1] / (rectSize * 2)).round().toString(),
          style: TextStyle(fontSize: 20.0),
        ),
        value: 2,
      ),
    );
  _thrs
    ..add(
      DropdownMenuItem(
        child: Text(
          '100',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 100,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '125',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 125,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '150',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 150,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '175',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 175,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '200',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 200,
      ),
    );
  return [_nums, _thrs];
}

List<double> createInterList(
    List<double> aveList, List<int> rectNum, int selectNum) {
  List<double> result = [];
  int cursor = 0;
  int _num = selectNum * selectNum;

  for (int y = 0; y < (rectNum[1] / selectNum); y++) {
    var tmp = new List<double>.filled((rectNum[0] / selectNum).floor(), 0);
    for (int q = 0; q < selectNum; q++) {
      for (int x = 0; x < (rectNum[0] / selectNum); x++) {
        double sumX = 0;
        for (int p = 0; p < selectNum; p++) {
          sumX += aveList[cursor];
          cursor++;
        }
        tmp[x] += sumX;
      }
    }
    for (int n = 0; n < tmp.length; n++) {
      tmp[n] /= _num;
      result.add(tmp[n]);
    }
  }
  return result;
}
