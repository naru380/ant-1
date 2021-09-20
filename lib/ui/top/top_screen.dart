import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
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
                        final _coppedImage = await cameraCrop(_image);
                        if (_coppedImage != null) {
                          Navigator.of(context).pushNamed(
                            '/create',
                            arguments: {
                              'croppedImage': _coppedImage,
                            },
                          );
                        }
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
                        final _coppedImage = await cameraCrop(_image);
                        if (_coppedImage != null) {
                          Navigator.of(context)
                              .pushNamed('/create', arguments:{'croppedImage': _coppedImage});
                        }
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
