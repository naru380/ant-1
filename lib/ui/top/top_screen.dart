import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:ant_1/ui/create/create_screen.dart';
import 'package:ant_1/ui/create/create_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:io';
import 'dart:typed_data';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      title: 'logic_maker',
      home: TopScreen(),
    );
  }
}

class TopScreen extends StatefulWidget {
  @override
  _TopScreenState createState() => _TopScreenState();
}

Future<File> cameraCrop(XFile imageFile) async {
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: imageFile.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
  );
  return croppedFile;
}

class _TopScreenState extends State<TopScreen> {
  int cnt = 0;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cnt = 0;
  }

  @override
  Widget build(BuildContext context) {
    context.read<TopViewModel>().init();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              Navigator.of(context).pushNamed('/setting');
            },
          ),
        ],
      ),
      body: Consumer<TopViewModel>(builder: (context, model, _) {
        return ListView.builder(
            itemCount: model.numLogicPuzzle,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  context.read<PlayViewModel>().logicPuzzle =
                      model.logicPuzzles[index];
                  context.read<PlayViewModel>().init();
                  Navigator.of(context).pushNamed('/play');
                },
                child: Card(
                  child: Padding(
                    child: Text(
                      '${model.logicPuzzles[index].name}',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    padding: EdgeInsets.all(20.0),
                  ),
                ),
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showCupertinoDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('ドット絵作成'),
                content: const Text('取り込み方を選択してください'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('カメラ'),
                    onPressed: () async {
                      final _image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (_image != null) {
                        initCreate(context, _image);
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('カメラロール'),
                    onPressed: () async {
                      final _image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (_image != null) {
                        initCreate(context, _image);
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('キャンセル'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

void initCreate(BuildContext context, XFile image) async {
  File tookImage = await cameraCrop(image);
  if (tookImage != null) {
    // imgLib.Image decodedImage = imgLib.decodeImage(tookImage.readAsBytesSync());

    Uint8List compressedImage = await compressFile(tookImage);
    imgLib.Image decodedImage = imgLib.decodeImage(compressedImage);

    bool widthIsShorter;
    double rectSize;
    List<double> imageSize;
    int rectWidth;
    List<int> rectNum = [0, 0];

    (decodedImage.height > decodedImage.width)
        ? widthIsShorter = true
        : widthIsShorter = false;
    widthIsShorter
        ? rectSize = decodedImage.width / 100
        : rectSize = decodedImage.height / 100;
    imageSize = getImageSize(decodedImage, rectSize);
    rectWidth = (imageSize[0] / rectSize).round();
    rectNum[0] = rectWidth;
    rectNum[1] = (imageSize[1] / rectSize).round();

    imgLib.Image croppedImage = imgLib.copyCrop(
      decodedImage,
      0,
      0,
      imageSize[0].round(),
      imageSize[1].round(),
    );

    List<double> aveList =
        createAverageList(croppedImage, 1, imageSize, rectSize);

    // int switcher = 1;

    context.read<CreateViewModel>().selectNum = 4;
    context.read<CreateViewModel>().selectThr = 150;
    context.read<CreateViewModel>().title = "タイトル";
    context.read<CreateViewModel>().rectWidth = rectNum[0];
    context.read<CreateViewModel>().dotList = createDotList(aveList, 150);
    context.read<CreateViewModel>().interList =
        createInterList(aveList, rectNum, 4);
    context.read<CreateViewModel>().gridList =
        createGrid(context.read<CreateViewModel>().dotList, rectWidth);

    Navigator.of(context).pushNamed(
      '/create',
      arguments: {
        'croppedImage': croppedImage,
        'rectSize': rectSize,
        'imageSize': imageSize,
        'rectNum': rectNum,
        'aveList': aveList,
      },
    );
  }
}

Future<Uint8List> compressFile(File file) async {
  Uint8List result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minHeight: 500,
    minWidth: 500,
    quality: 1,
  );
  int i = 0;
  while (result.length > 50000 && i < 3) {
    result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minHeight: 500,
      minWidth: 500,
      quality: 1,
    );
    i++;
  }
  return result;
}

List<double> getImageSize(imgLib.Image _image, double rectSize) {
  int tmp;
  tmp = ((_image.width / rectSize + 0.00001) / 20).floor();
  double _width = tmp * rectSize * 20;
  tmp = ((_image.height / rectSize + 0.00001) / 20).floor();
  double _height = tmp * rectSize * 20;
  return [_width, _height];
}

List<double> createAverageList(
    imgLib.Image image, int value, List<double> imageSize, double rectSize) {
  imgLib.Image cloneImage = image.clone();
  imgLib.grayscale(cloneImage);

  List<int> rectNum = [
    (imageSize[0] / (rectSize * value)).round(),
    (imageSize[1] / (rectSize * value)).round()
  ];

  List<double> result = [];

  Uint8List test = cloneImage.getBytes();

  // print(test.length);
  // print(imageSize);
  // print(rectSize);

  for (int y = 0; y < rectNum[1]; y++) {
    for (int x = 0; x < rectNum[0]; x++) {
      imgLib.Image croppedImage = imgLib.copyCrop(
        cloneImage,
        (x * rectSize * value).round(),
        (y * rectSize * value).round(),
        (rectSize * value).round(),
        (rectSize * value).round(),
      );
      Uint8List encoded = croppedImage.getBytes();
      double average = encoded.reduce((a, b) => a + b) / encoded.length;
      // if (average > thresh) {
      //   result.add(0);
      // } else {
      //   result.add(1);
      // }
      result.add(average);
    }
  }
  return result;
}

// int calcDotSize(List<int> rectNum, Uint8List listImage) {
//   double coef = rectNum[0] / rectNum[1];
//   int _pix = sqrt(listImage.length * coef).floor();
//   int _num = (_pix / rectNum[0]).floor();

//   return _num;
// }

// List<double> makeInterList(List<int> rectNum, Uint8List listImage) {
//   int _width = calcDotSize(rectNum, listImage);
//   int _num = _width * _width;
//   List<double> interList = [];
//   int cursor = 0;
//   int topCursor = 0;
//   int topIndex = _width * rectNum[0];

//   print(_width);

//   for (int y = 0; y < rectNum[1]; y++) {
//     var tmp = new List<double>.filled(rectNum[0], 0);
//     for (int q = 0; q < _width; q++) {
//       for (int x = 0; x < rectNum[0]; x++) {
//         double sumX = 0;
//         for (int p = 0; p < _width; p++) {
//           sumX += listImage[cursor];
//           cursor++;
//         }
//         tmp[x] += sumX;
//       }
//       topCursor += topIndex;
//       cursor = topCursor;
//     }
//     for (int n = 0; n < rectNum[0]; n++) {
//       tmp[n] /= _num;
//       interList.add(tmp[n]);
//     }
//   }

//   print(cursor);
//   return interList;
// }
