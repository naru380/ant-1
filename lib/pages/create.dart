import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;

class Create extends StatefulWidget {
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {
  double _dot = 50.0;
  double _thr = 50.0;

  @override
  Widget build(BuildContext context) {
    String _text1 = '$_dot';
    String text1 = _text1;
    String _text2 = '$_thr';
    String _title;
    int thresh = 122;
    File originImage = ModalRoute.of(context).settings.arguments;
    imgLib.Image imageData = imgLib.decodeImage(originImage.readAsBytesSync());
    imgLib.Image cloneImage = imageData.clone();
    imgLib.grayscale(cloneImage);

    List<int> rectNum = [10, 10];
    int rectSize = (cloneImage.width / rectNum[0]).round();
    List<int> dotList = [];

    for (int x = 0; x < rectNum[0]; x++) {
      for (int y = 0; y < rectNum[1]; y++) {
        final croppedImage = imgLib.copyCrop(
          cloneImage,
          x * rectSize,
          y * rectSize,
          rectSize,
          rectSize,
        );
        final encoded = imgLib.encodeJpg(croppedImage);
        print(encoded);
        double average = encoded.reduce((a, b) => a + b) / encoded.length;
        if(average > thresh){
          dotList.add(1);
          print('aaaa');
        }else{
          dotList.add(0);
        }
      }
    }
    print(dotList);

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
                    width: 150,
                    height: 150,
                    child: Image.file(
                      originImage,
                      height: 150,
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
              Image(
                image: AssetImage('lib/image/arrow.jpeg'),
                width: 30,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.memory(imgLib.encodeJpg(cloneImage)),
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
                Navigator.of(context).pushNamed(
                  '/confirm',
                  arguments: cloneImage,
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
          ),
        ],
      ),
    );
  }
}
