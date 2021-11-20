import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ant_1/service/admob.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class ConfirmScreen extends StatefulWidget {
  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<ConfirmScreen> {
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
                  LogicPuzzleDao logicPuzzleDao = LogicPuzzleDao();
                  var logicPuzzle = LogicPuzzle(
                      name: title,
                      width: width,
                      dots: dotList,
                      lastState: List.generate(dotList.length, (_) => 0),
                      isClear: false);
                  await logicPuzzleDao.create(logicPuzzle);
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
