import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:ant_1/ui/create/init_create_screen.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    ui.Image image = args['Image'];
    return Scaffold(
        backgroundColor: Colors.pink[100],
        appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text(
              'Setting',
              style: TextStyle(fontSize: 16),
            )
        ),
        body: Center(child: CustomPaint(painter: OriginalPainter(image)),)
    );
  }
}
