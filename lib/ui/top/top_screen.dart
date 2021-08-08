import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';

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
                context.read<PlayViewModel>().init();
                Navigator.of(context).pushNamed(
                  '/play',
                  arguments: {
                    'logicPuzzle': model.logicPuzzles[index],
                  }
                );
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
          }
        );
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
                      final _coppedImage = await CameraCrop();
                      if (_coppedImage != null) {
                        Navigator.of(context).pushNamed('/create',
                            arguments: _coppedImage);
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