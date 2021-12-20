import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image/image.dart' as imgLib;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ant_1/ui/create/create_screen.dart';
import 'package:ant_1/ui/create/create_view_model.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

void initCreate(BuildContext context, File tookImage) async {
  Uint8List compressedImage = await compressFile(tookImage);
  imgLib.Image decodedImage = imgLib.decodeImage(compressedImage);

  bool widthIsShorter;
  List<int> rectNum = [0, 0];
  double rectSize;
  List<double> imageSize = [0, 0];
  List<double> aveList = [0, 0];
  List<int> dots;
  CreateViewModel createModel = context.read<CreateViewModel>();

  final Size size = MediaQuery.of(context).size;

  (decodedImage.height > decodedImage.width)
      ? widthIsShorter = true
      : widthIsShorter = false;
  widthIsShorter
      ? rectSize = decodedImage.width / 100
      : rectSize = decodedImage.height / 100;
  imageSize = getImageSize(decodedImage, rectSize);
  int rectWidth = (imageSize[0] / rectSize).round();
  rectNum[0] = rectWidth;
  rectNum[1] = (imageSize[1] / rectSize).round();

  List<int> containerSize = [
    (size.width / 3).floor(),
    (size.width / 3 * (imageSize[1] / imageSize[0])).floor()
  ];

  imgLib.Image croppedImage = imgLib.copyCrop(
    decodedImage,
    0,
    0,
    imageSize[0].round(),
    imageSize[1].round(),
  );

  imgLib.Image originImage = imgLib.decodeImage(tookImage.readAsBytesSync());

  int originWidth =
      (originImage.width * (imageSize[0] / decodedImage.width)).round();
  int originHeight =
      (originImage.height * (imageSize[1] / decodedImage.height)).round();

  // int magnificant = (containerSize[0] / originWidth).round() * 400;

  // if(magnificant > 100){
  //   magnificant = 100;
  //   print('100');
  // }

  // Uint8List compressedOriginList = await FlutterImageCompress.compressWithFile(
  //   tookImage.path,
  //   quality: magnificant,
  // );

  // imgLib.Image compressedOrigin = imgLib.decodeImage(compressedOriginList);

  imgLib.Image originCroppedImage = imgLib.copyCrop(
    // compressedOrigin,
    originImage,
    0,
    0,
    originWidth,
    originHeight,
  );

  aveList = createAverageList(croppedImage, 1, imageSize, rectSize);
  List<double> thrList = createThrList(aveList);

  createModel.selectNum = 4;
  createModel.selectThr = 4;
  createModel.title = "タイトル";
  createModel.rectWidth = rectNum[0];
  createModel.interList = createInterList(
    aveList,
    rectNum,
    4,
  );
  createModel.widthNum =
      (imageSize[0] / (rectSize * createModel.selectNum)).round();
  createDotList(createModel.interList, aveList[4].round(), 4,
      createModel.widthNum, createModel);

  createModel.compImage = await makeImage(
    createModel.dotList,
    rectNum[0],
    rectNum[1],
    containerSize,
  );

  List<int> jpg = imgLib.encodeJpg(originCroppedImage);
  Uint8List byteList = Uint8List.fromList(jpg);
  ui.Image compImage = await byte2Image(byteList, size);

  Navigator.of(context).pushNamed(
    '/create',
    arguments: {
      'croppedImage': compImage,
      'rectSize': rectSize,
      'imageSize': imageSize,
      'rectNum': rectNum,
      'aveList': aveList,
      'thrList': thrList,
    },
  );
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
      result.add(average);
    }
  }
  return result;
}

Future<void> syncVariable(Future<ui.Image> futureVar, model) async {
  model.compImage = await futureVar;
}

Future<ui.Image> makeImage(List<int> listImage, int rectWidth, int rectHeight,
    List<int> containerSize) {
  final _image = Completer<ui.Image>();
  final pixels = Int32List(rectWidth * rectHeight);
  for (int i = 0; i < pixels.length; i++) {
    // pixels[i] = listImage[i] * 0xFF000000;
    pixels[i] = 0xFFFFFFFF - (0x00FFFFFF * listImage[i]);
  }
  ui.decodeImageFromPixels(
    pixels.buffer.asUint8List(),
    rectWidth,
    rectHeight,
    ui.PixelFormat.rgba8888,
    _image.complete,
    targetWidth: containerSize[0],
    targetHeight: containerSize[1],
  );
  return _image.future;
}

class OriginalPainter extends CustomPainter {
  final ui.Image image;
  OriginalPainter(this.image);

  @override
  void paint(ui.Canvas canvas, Size size) {
    final paint = Paint();
    if (image != null) {
      canvas.drawImage(image, Offset(0, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant OriginalPainter oldDelegate) => false;
}

Future<ui.Image> byte2Image(Uint8List byte, Size size) async {
  ui.Codec codecImage = await ui.instantiateImageCodec(
    byte,
    targetWidth: (size.width / 3).floor(),
  );
  ui.FrameInfo frame = await codecImage.getNextFrame();
  ui.Image image = frame.image;
  return image;
}

List<double> createThrList(List<double> aveList) {
  double ave = 0;
  for (int i = 0; i < aveList.length; i++) {
    ave += aveList[i];
  }
  ave /= aveList.length;
  double aveLow = ave / 20;
  double aveHigh = (255 - ave) / 20;
  List<double> thrList = [
    ave - (aveLow * 4),
    ave - (aveLow * 3),
    ave - (aveLow * 2),
    ave - aveLow,
    ave,
    ave + aveHigh,
    ave + (aveHigh * 2),
    ave + (aveHigh * 3),
    ave + (aveHigh * 4),
  ];

  return thrList;
}
