import 'dart:ui' as ui;
import 'package:ant_1/ui/create/init_create_screen.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as imgLib;
import 'package:flutter/rendering.dart';
import 'package:ant_1/ui/create/create_view_model.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ant_1/service/admob.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    ui.Image croppedImage = args['croppedImage'];
    // imgLib.Image croppedImage = args['croppedImage'];
    // Uint8List croppedImage = args['croppedImage'];
    double rectSize = args['rectSize'];
    List<double> imageSize = args['imageSize'];
    List<int> rectNum = args['rectNum'];
    List<double> aveList = args['aveList'];
    List<double> thrList = args['thrList'];
    List<List<DropdownMenuItem<int>>> itemList = setItems(imageSize, rectSize);
    List<DropdownMenuItem<int>> _nums = itemList[0];
    List<DropdownMenuItem<int>> _thrs = itemList[1];
    final List<int> containerSize = [
      (size.width / 3).floor(),
      (size.width / 3 * (imageSize[1] / imageSize[0])).floor()
    ];
    // List<int> jpgImage = imgLib.encodeJpg(croppedImage);
    // List<int> pngImage = imgLib.encodePng(croppedImage);
    // final jpgImage = imgLib.encodeJpg(croppedImage);

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
                    child: CustomPaint(painter: OriginalPainter(croppedImage)),
                    // child: Image.memory(croppedImage),
                    // child: Image.memory(jpgImage),
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
                              aveList,
                              rectNum,
                              model.selectNum,
                            ),
                            model.widthNum =
                                (imageSize[0] / (rectSize * model.selectNum))
                                    .round(),
                            createDotList(
                              model.interList,
                              thrList[model.selectThr].round(),
                              model.selectNum,
                              model.widthNum,
                              model,
                            ),
                            syncVariable(
                              makeImage(
                                model.dotList,
                                rectNum[0],
                                rectNum[1],
                                containerSize,
                              ),
                              model,
                            ),
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
                            createDotList(
                              model.interList,
                              thrList[model.selectThr].round(),
                              model.selectNum,
                              model.widthNum,
                              model,
                            ),
                            syncVariable(
                              makeImage(
                                model.dotList,
                                rectNum[0],
                                rectNum[1],
                                containerSize,
                              ),
                              model,
                            ),
                            model.notify(),
                          },
                        ),
                      );
                    },
                  ),
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
                        'dotList': model.dots,
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
}

void createDotList(List<double> interList, int thresh, int num,
    int widthNum, CreateViewModel model) {
  List<int> result = [];
  List<int> boardDots = [];
  List<int> tmp;
  int p = 0;
  for (int i = 0; i < (interList.length / widthNum); i++) {
    tmp = [];
    for (int j = 0; j < widthNum; j++) {
      if (interList[p] > thresh) {
        for (int n = 0; n < num; n++) {
          tmp.add(0);
        }
        boardDots.add(0);
      } else {
        for (int n = 0; n < num; n++) {
          tmp.add(1);
        }
        boardDots.add(1);
      }
      p++;
    }
    for (int k = 0; k < num; k++) {
      result += tmp;
    }
  }
  model.dotList = result;
  model.dots = boardDots;
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
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '100',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 100,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '125',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 125,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '150',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 150,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '175',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 175,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '200',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 200,
    //   ),
    // );
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '20%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 0,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '30%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 1,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '40%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 2,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '50%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 3,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '60%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 4,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '70%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 5,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '80%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 6,
    //   ),
    // );

    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '30%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 0,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '35%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 1,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '40%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 2,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '45%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 3,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '50%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 4,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '55%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 5,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '60%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 6,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '65%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 7,
    //   ),
    // )
    // ..add(
    //   DropdownMenuItem(
    //     child: Text(
    //       '70%',
    //       style: TextStyle(fontSize: 20.0),
    //     ),
    //     value: 8,
    //   ),
    // );

    ..add(
      DropdownMenuItem(
        child: Text(
          '40%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 0,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '42.5%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 1,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '45%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 2,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '47.5%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 3,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '50%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 4,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '52.5%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 5,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '55%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 6,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '57.5%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 7,
      ),
    )
    ..add(
      DropdownMenuItem(
        child: Text(
          '60%',
          style: TextStyle(fontSize: 20.0),
        ),
        value: 8,
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
