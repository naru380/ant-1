import 'package:ant_1/ui/create/init_create_screen.dart';
import 'package:ant_1/ui/play/play_view_model.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ant_1/service/admob.dart';
import 'dart:io';
import 'package:ant_1/db_provider.dart';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//         // visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       title: 'logic_maker',
//       home: TopScreen(),
//     );
//   }
// }

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

class TopScreen extends StatelessWidget {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    context.read<TopViewModel>().init();
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Top',
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
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
                child: Dismissible(
                  key: ObjectKey(model.logicPuzzles[index]),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    model.logicPuzzleDao
                        .deleteElement(model.logicPuzzles[index].id);
                    model.logicPuzzles.removeAt(index);
                    model.notify();
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: SizedBox(
                    width: size.width,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '${model.logicPuzzles[index].name}',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                    ),
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
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedImage != null) {
                        File tookImage = await cameraCrop(pickedImage);
                        if (tookImage != null) {
                          initCreate(context, tookImage);
                        }
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('カメラロール'),
                    onPressed: () async {
                      final pickedImage = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedImage != null) {
                        File tookImage = await cameraCrop(pickedImage);
                        if (tookImage != null) {
                          initCreate(context, tookImage);
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
