import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    if (title == null) {
      title = 'タイトル';
    }

    Future _saveImage(Uint8List dotImage) async {
      final result = await ImageGallerySaver.saveImage(dotImage);
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
          Center(
            child: Image.memory(
              dotImage,
              width: 300,
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
              height: 60,
              width: 200,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.download_sharp),
        onPressed: () async {
          await _saveImage(dotImage);
          Fluttertoast.showToast(msg: 'ダウンロードしました');
        },
      ),
    );
  }
}
