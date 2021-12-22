import 'package:ant_1/domain/entities/logic_puzzle.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

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
  Color buttonColor = Color(0xFFFFD65A);
  Color textColor = Color(0xFF5C4444);
  Color appbarColor = Color(0xFF3DEFE2);
  Color playColor = Color(0xFFFF595F);
  Color playInnerColor = Color(0xFFFF9C94);
  Color backColor = Color(0xFFFFFBE5);

  @override
  Widget build(BuildContext context) {
    context.read<TopViewModel>().init();
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MENU',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5.h),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: playColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    // spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(4, 4),
                  )
                ],
              ),
              child: SizedBox(
                height: 460.h,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.h, 10.h, 8.h, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.h),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: playInnerColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: SizedBox(
                          height: 410.h,
                          child: Consumer<TopViewModel>(
                              builder: (context, model, _) {
                            return ListView.builder(
                                itemCount: model.numLogicPuzzle,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      context
                                              .read<PlayViewModel>()
                                              .logicPuzzle =
                                          model.logicPuzzles[index];
                                      context.read<PlayViewModel>().init();
                                      ui.Codec codecImage =
                                          await ui.instantiateImageCodec(
                                        model.logicPuzzles[index].stateList,
                                        targetWidth: (size.width).floor(),
                                      );
                                      ui.FrameInfo frame =
                                          await codecImage.getNextFrame();
                                      ui.Image image = frame.image;
                                      context
                                          .read<PlayViewModel>()
                                          .puzzleImage = image;
                                      Navigator.of(context).pushNamed('/play');
                                    },
                                    child: Dismissible(
                                      key: ObjectKey(model.logicPuzzles[index]),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        model.logicPuzzleDao.deleteElement(
                                            model.logicPuzzles[index].id);
                                        model.logicPuzzles.removeAt(index);
                                        model.notify();
                                      },
                                      background: Container(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        color: Colors.red,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            5.h, 5.h, 5.h, 0),
                                        child: SizedBox(
                                          width: 300.h,
                                          height: 45.h,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: backColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  // spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: Offset(3, 3),
                                                )
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.h, 0, 0, 0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '${model.logicPuzzles[index].name}',
                                                  style: TextStyle(
                                                    fontSize: 25.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    // spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(4, 4),
                  )
                ],
              ),
              child: GestureDetector(
                child: SizedBox(
                  height: 80.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15.h, 0, 15.h, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 70.h,
                          color: textColor,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 3.h, 0, 0),
                          child: Text(
                            '  CREATE NEW \n  PUZZLE',
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
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
                              final pickedImage = await picker.pickImage(
                                  source: ImageSource.camera);
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
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.of(context).pushNamed('/clear');
      //   },
      // ),
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
