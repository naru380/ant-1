import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:io';

void main() => runApp(
      MyApp(),
    );

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

List<Widget> containerChild = [];

class ImagePickerUtil {
  static Future<PickedFile> getImage({ImageSource source}) async {
    final ImagePicker picker = ImagePicker();
    final file = await picker.getImage(source: source);
    // var croppedFile = CropImage(file);
    // return croppedFile;
    return file;
  }
}

CameraCrop() async {
  PickedFile imageFile = await ImagePicker().getImage(
    source: ImageSource.gallery,
  );
  File tmpImage = File(imageFile.path);
  File croppedFile = await ImageCropper.cropImage(
    sourcePath: tmpImage.path,
    aspectRatio: CropAspectRatio(
      ratioX: 1.0,
      ratioY: 1.0,
    ),
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
    var tmp = ModalRoute.of(context).settings.arguments;
    if (tmp != null) {
      setState(() {
        containerChild.add(ActionContainer(cnt));
      });
    }

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
              Navigator.of(context).pushNamed('/test');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            children: List.generate(
          containerChild.length,
          (int index) {
            return containerChild[index];
          },
        )),
      ),
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
                      final _image = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (_image != null) {
                        File _fileImage = File(
                          _image.path,
                        );
                        Navigator.of(context).pushNamed(
                          '/create',
                          arguments: _fileImage,
                        );
                      } else {
                        print('object');
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('カメラロール'),
                    onPressed: () async {
                      final _coppedImage = await CameraCrop();
                      if (_coppedImage != null) {
                        Navigator.of(context).pushNamed(
                          '/create',
                          arguments: _coppedImage,
                        );
                        // if (tmp == null){
                        //   print('nulll');
                        // }
                        // print(tmp);
                        // final result =
                        //     ModalRoute.of(context).settings.arguments;
                        // print('object');
                        // if (result != null) {
                        //   print(result);
                        //   print('aa');
                        // } else {
                        //   print('null');
                        // }
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

class ActionContainer extends StatefulWidget {
  ActionContainer(int cnt);

  @override
  _ActionContainerState createState() => _ActionContainerState();
}

class _ActionContainerState extends State<ActionContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      child: GestureDetector(
        onTap: () {
          setState(
            () {
              print(this.widget);
              print(containerChild);
              // print(containerChild[ind]);
              // var del = this;
              containerChild.remove(this);
            },
          );
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(10.0),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$widget.cnt',
                    style: TextStyle(
                      // color: Colors.blue,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
