import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:typed_data';
import 'dart:io';

class CreateScreen extends StatefulWidget {
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<CreateScreen> {
  @override
  double _dot = 50.0;
  double _thr = 50.0;

  Widget build(BuildContext context) {
    String _text1 = '$_dot';
    String text1 = _text1;
    String _text2 = '$_thr';
    String _title;

    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    File argImage = args['croppedImage'];
    final decodedImage = imgLib.decodeImage(argImage.readAsBytesSync());
    var dotList;

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
                  // Image(
                  //   image: test,
                  //   width: 180,
                  // ),
                  Image.file(
                    argImage,
                    width: 130,
                  ),
                  // Image.memory(pre),
                  Text(
                    '元画像',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Image(
                image: AssetImage('assets/images/arrow.jpeg'),
                width: 30,
              ),
              // Image.file(ExampleImage),
              Column(
                children: [
                  // Image(
                  //   image: test,
                  //   width: 180,
                  // ),
                  // Image.memory(
                  //   jpg,
                  //   width: 130,
                  // ),
                  // Image.memory(test),
                  // CustomPaint(
                  //   painter: OriginalPainter(),
                  // ),
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
                  SizedBox(
                    width: 40,
                    height: 35,
                    child: TextField(
                      controller: TextEditingController(text: _text1),
                      onChanged: (_text1) {
                        setState(
                          () {
                            try {
                              _dot = _text1 as double;
                            } catch (e) {
                              _text1 = text1;
                            }
                            text1 = _text1;
                          },
                        );
                      },
                      // decoration: InputDecoration(
                      //   border: OutlineInputBorder(),
                      // ),
                    ),
                  ),
                ],
              ),
              Slider.adaptive(
                value: _dot,
                min: 0.0,
                max: 100.0,
                divisions: 100,
                onChanged: (double value1) {
                  setState(
                    () {
                      _dot = value1;
                      _text1 = '$_dot';
                    },
                  );
                },
              ),
              Row(
                children: [
                  Text(
                    ' 閾値: ',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 35,
                    child: TextField(
                      controller: TextEditingController(text: _text2),
                      onChanged: (_text2) {
                        setState(
                          () {
                            _thr = _text2 as double;
                          },
                        );
                      },
                      // decoration: InputDecoration(
                      //   border: OutlineInputBorder(),
                      // ),
                    ),
                  ),
                ],
              ),
              Slider.adaptive(
                value: _thr,
                min: 1.0,
                max: 100.0,
                onChanged: (double value1) {
                  setState(
                    () {
                      _thr = value1;
                      _text2 = '$_thr';
                    },
                  );
                },
              ),
              TextField(
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
                controller: TextEditingController(text: _title),
              ),
            ],
          ),
          Container(
            height: 60,
            width: 200,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(100))),
            child: GestureDetector(
              onTap: () {
                // Navigator.of(context).pushNamed(
                //   '/confirm',
                //   arguments: exampleImage,
                // );
                setState(() {
                  dotList = createDots(decodedImage);
                });
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
          ),
        ],
      ),
    );
  }
}

Uint8List createDots(imgLib.Image image) {
  imgLib.Image cloneImage = image.clone();
  imgLib.grayscale(cloneImage);

  List<int> rectNum = [100, 100];
  int rectSize = (cloneImage.width / rectNum[0]).round();

  int thresh = 200;
  List<int> result = [];

  for (int y = 0; y < rectNum[0]; y++) {
    for (int x = 0; x < rectNum[1]; x++) {
      final croppedImage = imgLib.copyCrop(
        cloneImage,
        x * rectSize,
        y * rectSize,
        rectSize,
        rectSize,
      );
      Uint8List encoded = croppedImage.getBytes();
      double average = encoded.reduce((a, b) => a + b) / encoded.length;
      if (average > thresh) {
        result.add(1);
      } else {
        result.add(0);
      }
    }
  }
  return result;
}
