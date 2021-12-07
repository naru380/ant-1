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
      await ImageGallerySaver.saveImage(dotImage);
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue[900],
        title: Text(
          'Confirm',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: size.width / 2,
            height: size.width * (imageSize[1] / imageSize[0]) / 2,
            child: Center(
              child: Image.memory(
                dotImage,
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          Center(
            child: Container(
              height: size.width / 8,
              width: size.width / 3,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(100))),
              child: GestureDetector(
                onTap: () async {
                  // final ui.Image boardDao =
                  //     await getImageFromPainter(boardPainter, boardSize);
                  // ByteData byte = await boardDao.toByteData();
                  // compLogic.imageList = byte.buffer.asUint8List();
                  // compLogic.stateList = byte.buffer.asUint8List();
                  LogicPuzzleDao logicPuzzleDao = LogicPuzzleDao();
                  // await logicPuzzleDao.deleteDB();
                  // print('object');
                  // DBProvider db = new DBProvider();
                  // Database database;
                  // // print('object');
                  // database = await db.initDB();

                  await logicPuzzleDao.create(compLogic);
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (_) => false);
                },
                child: Center(
                  child: Text(
                    'FINISH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              height: size.width / 8,
              width: size.width / 3,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(100))),
              child: GestureDetector(
                onTap: () async {
                  await Share.file(
                    title,
                    title + '.png',
                    dotImage,
                    'image/png',
                  );
                },
                child: Center(
                  child: Text(
                    'POST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.download_sharp),
        onPressed: () async {
          await _saveImage(dotImage);
          Fluttertoast.showToast(msg: 'ダウンロードしました');
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
