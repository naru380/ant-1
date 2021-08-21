import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'play.dart';
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

Future<File> cameraCrop() async {
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

Future<File> createImage() async {
  const opencv = const MethodChannel('api.opencv.dev/opencv');
  File _image = await cameraCrop();
  var result = await opencv.invokeMethod('toPerspectiveTransformation',
        <String, dynamic>{'srcPath': _image.path});
  return result;
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
              //Navigator.of(context).pushNamed('/setting');

              // temporary change on  branch feature/#4
              // TODO: create link for game-play page.
              context.read<PuzzleProvider>().init();
              Navigator.of(context).pushNamed('/play');
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
                      final _image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (_image != null) {
                        File _fileImage = File(_image.path);
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
                      // final _croppedImage = await cameraCrop();
                      final _croppedImage = await createImage();
                      if (_croppedImage != null) {
                        // Navigator.of(context).pushNamed('/create',
                        //     arguments: _croppedImage,);
                        Navigator.of(context).pushNamed(
                          '/test',
                          arguments: _croppedImage,
                        );
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
