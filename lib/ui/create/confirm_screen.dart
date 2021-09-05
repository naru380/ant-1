import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ant_1/ui/top/top_view_model.dart';
import 'package:ant_1/domain/entities/logic_puzzle.dart';
import 'package:ant_1/domain/dao/logic_puzzle_dao.dart';
import 'dart:io';

class ConfirmScreen extends StatefulWidget {
  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<ConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    File dotImage = args['croppedImage'];
    String title = args['title'];
    List<int> dotList = args['dotList'];
    int width = args['width'];
    if (title == null) {
      title = 'タイトル';
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
            child: Image.file(
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
                  print(dotList);
                  print(width);
                  LogicPuzzleDao logicPuzzleDao = LogicPuzzleDao();
                  var logicPuzzle = LogicPuzzle(
                      name: title,
                      width: width,
                      dots: dotList,
                      lastState:
                          List.generate(dotList.length, (_) => 0),
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
    );
  }
}
