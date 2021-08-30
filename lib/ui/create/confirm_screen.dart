import 'dart:ui';
import 'package:flutter/material.dart';
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
    // var dotImage = ModalRoute.of(context).settings.arguments;
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
            child: Container(
              height: 60,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.all(Radius.circular(100))),
              child: GestureDetector(
                onTap: () {
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