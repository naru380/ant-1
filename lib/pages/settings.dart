import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.pink[100],
        appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text(
              'Setting',
              style: TextStyle(fontSize: 16),
            )
        ),
        body: Center(child: Icon(Icons.settings))
    );
  }
}
