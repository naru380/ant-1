import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:ant_1/ui/create/create_view_model.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class CreateScreen extends StatelessWidget {
  final _globalKey = GlobalKey();

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    imgLib.Image croppedImage = args['croppedImage'];
    double rectSize = args['rectSize'];
    List<double> imageSize = args['imageSize'];
    List<int> rectNum = args['rectNum'];
    List<double> aveList = args['aveList'];

    // imgLib.Image testImage = imgLib.Image.fromBytes(150, 49, half);

    // Future<File> compImage = compressFile(argImage);

    //imgLib.Image compDecoded = imgLib.decodeImage(compImage.readAsBytesSync());

    List<List<DropdownMenuItem<int>>> itemList = setItems(imageSize, rectSize);
    List<DropdownMenuItem<int>> _nums = itemList[0];
    List<DropdownMenuItem<int>> _thrs = itemList[1];

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
                    width: size.width / 3,
                    // child: Image.memory(
                    //   croppedImage,
                    //   width: 130,
                    // ),
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
                  Consumer<CreateViewModel>(
                    builder: (context, model, _) {
                      return SizedBox(
                        width: size.width / 3,
                        height: size.width / 3 * (imageSize[1] / imageSize[0]),
                        child: Center(
                          child: RepaintBoundary(
                            key: _globalKey,
                            child: GridView.count(
                              crossAxisCount: model.rectWidth,
                              children: model.gridList,
                            ),
                          ),
                        ),
                      );
                    },
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
                            model.dotList =
                                createDotList(model.interList, model.selectThr),
                            model.gridList =
                                createGrid(model.dotList, model.rectWidth),
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
                            model.dotList =
                                createDotList(model.interList, model.selectThr),
                            model.gridList =
                                createGrid(model.dotList, model.rectWidth),
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
                      model.title = '後でやる',
                      model.notify(),
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
                    var dotImage = await convertWidgetToImage(_globalKey);
                    Navigator.of(context).pushNamed(
                      '/confirm',
                      arguments: {
                        'title': model.title,
                        'dotList': model.dotList,
                        'width': (imageSize[0] / (rectSize * model.selectNum))
                            .round(),
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

List<int> createDotList(List<double> aveList, int thresh) {
  List<int> result = [];
  for (int i = 0; i < aveList.length; i++) {
    if (aveList[i] > thresh) {
      result.add(0);
    } else {
      result.add(1);
    }
  }
  return result;
}

// List<int> createDots(imgLib.Image image, int value, int thresh,
//     List<double> imageSize, double rectSize) {
//   List<int> result = [];
//   int cursor = 0;
//   int size = (rectSize * 2).floor() * 2;
//   int tes = 0;
//   int tt = 0;

//   List<int> rectNum = [
//     (imageSize[0] / (rectSize * value)).floor(),
//     (imageSize[1] / (rectSize * value)).floor()
//   ];

//   imgLib.Image cloneImage = image.clone();
//   imgLib.grayscale(cloneImage);
//   Uint8List encoded = cloneImage.getBytes();

//   for (int y = 0; y < rectNum[1]; y++) {
//     var tmp = new List<int>.filled(rectNum[0], 0);
//     tes++;
//     for (int q = 0; q < size; q++) {
//       for (int x = 0; x < rectNum[0]; x++) {
//         for (int p = 0; p < size; p++) {
//           tmp[x] += encoded[cursor];
//           cursor++;
//           tt += encoded[cursor];
//         }
//       }
//     }
//     for (int i = 0; i < tmp.length; i++) {
//       if (tmp[i] / size / size > thresh) {
//         result.add(0);
//       } else {
//         result.add(1);
//       }
//     }
//   }
//   print(result.length);
//   var tmp1 = new List<int>.filled(rectNum[0], 0);
//   print(tmp1.length);
//   print(size);
//   print(imageSize);
//   print(encoded.length);
//   print(cursor);
//   print(tes);
//   print(tt/cursor);
//   print(result.length);
//   return result;
// }

Widget dotItem(int col, int rectWidth) {
  double size = 130 / rectWidth;
  if (col == 0) {
    return Container(
      height: size,
      width: size,
      color: Colors.white,
    );
  } else {
    return Container(
      width: size,
      height: size,
      color: Colors.black,
    );
  }
}

List<Widget> createGrid(List<int> dotList, int rectWidth) {
  List<Widget> list = [];
  for (int i = 0; i < dotList.length; i++) {
    list.add(dotItem(dotList[i], rectWidth));
  }
  return list;
}

Future<Uint8List> convertWidgetToImage(GlobalKey widgetGlobalKey) async {
  RenderRepaintBoundary boundary =
      widgetGlobalKey.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage();
  ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

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
