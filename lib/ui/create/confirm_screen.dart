import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/ui/create/init_create_screen.dart';
import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ant_1/service/admob.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:ant_1/service/puzzle_painter.dart';
import 'package:ant_1/service/utils.dart';
import 'package:ant_1/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    String title = args['title'];
    List<int> dotList = args['dotList'];
    int width = args['width'];
    Uint8List dotImage = args['dotImage'];
    List<double> imageSize = args['imageSize'];
    if (title == null) {
      title = 'タイトル';
    }

    final Size size = MediaQuery.of(context).size;

    // final LogicPuzzle compLogic = LogicPuzzle(
    //   name: title,
    //   width: width,
    //   dots: dotList,
    //   lastState: List.generate(dotList.length, (_) => 0),
    //   isClear: false,
    //   imageList: dotImage,
    //   stateList: dotImage,
    //   compImage: dotImage,
    // );
    final LogicPuzzle compLogic = LogicPuzzle(
      name: title,
      width: 2,
      dots: [0, 1, 1, 0],
      lastState: [0, 0, 0, 0],
      isClear: false,
      imageList: dotImage,
      stateList: dotImage,
      compImage: dotImage,
    );

    final Size boardSize = Size(size.width, size.width);
    CustomPainter boardPainter = PuzzlePainter(
      context: context,
      logicPuzzle: compLogic,
    );

    Future _saveImage(Uint8List dotImage) async {
      await ImageGallerySaver.saveImage(dotImage, quality: 100);
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue[900],
        title: Text(
          'CONFIRM',
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(25.w, 40.h, 25.w, 0),
            child: SizedBox(
              width: 250.w,
              height: 300.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  children: [
                    Center(
                      child: Image.memory(
                        dotImage,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.h),
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5C4444),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 70.h, 0, 30.h),
              child: Container(
                height: 40.h,
                width: 130.w,
                decoration: BoxDecoration(
                  color: Color(0xFFFFD65A),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      // spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(3, 3),
                    )
                  ],
                ),
                child: GestureDetector(
                  onTap: () async {
                    await Share.file(
                        title, title + '.png', dotImage, 'image/png',
                        text: 'ドット絵を作成しました！！');
                  },
                  child: Center(
                    child: Text(
                      'POST',
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C4444),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30.w, 0, 10.w, 0),
                child: SizedBox(
                  width: 60.w,
                  height: 40.h,
                  child: GestureDetector(
                    child: DecoratedBox(
                      child: Icon(
                        Icons.arrow_back_outlined,
                        size: 45.w,
                        color: Color(0xFF5C4444),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF3D99E5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            // spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
                child: Center(
                  child: Container(
                    height: 40.h,
                    width: 130.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF595F),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          // spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    child: GestureDetector(
                      // onTap: () async {
                      //   // final ui.Image boardDao =
                      //   //     await getImageFromPainter(boardPainter, boardSize);
                      //   // ByteData byte = await boardDao.toByteData();
                      //   // compLogic.imageList = byte.buffer.asUint8List();
                      //   // compLogic.stateList = byte.buffer.asUint8List();
                      //   LogicPuzzleDao logicPuzzleDao = LogicPuzzleDao();
                      //   // await logicPuzzleDao.deleteDB();
                      //   // print('object');
                      //   // DBProvider db = new DBProvider();
                      //   // Database database;
                      //   // // print('object');
                      //   // database = await db.initDB();
                      //   await logicPuzzleDao.create(compLogic);
                      //   Navigator.of(context)
                      //       .pushNamedAndRemoveUntil('/', (_) => false);
                      // },
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/clear',
                          arguments: {
                            'image': dotImage,
                            'title': title,
                          },
                        );
                      },
                      child: Center(
                        child: Text(
                          'FINISH',
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5C4444),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 0, 0, 0),
                child: Center(
                  child: Container(
                    height: 40.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD65A),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          // spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        await _saveImage(dotImage);
                        Fluttertoast.showToast(msg: 'ダウンロードしました');
                      },
                      child: Center(
                        child: Icon(
                          Icons.file_download_outlined,
                          size: 45.w,
                          color: Color(0xFF5C4444),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
