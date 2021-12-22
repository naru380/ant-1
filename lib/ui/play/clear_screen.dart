import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClearScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    Uint8List image = args['image'];
    String title = args['title'];
    return Scaffold(
      body: Container(
        color: Color(0xFFFFD65A),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 100.h, 0, 20.h),
              child: Center(
                child: Text(
                  'COMPLETE',
                  style: TextStyle(
                    fontSize: 45.sp,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C4444),
                  ),
                ),
              ),
            ),
            SizedBox(
              child: DecoratedBox(
                child: Padding(
                  padding: EdgeInsets.all(5.h),
                  child: DecoratedBox(
                    child: Padding(
                      padding: EdgeInsets.all(5.h),
                      child: Image.memory(
                        image,
                        scale: 0.5,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      // spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(5, 5),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20.h, 0, 0),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C4444),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 70.h, 0, 30.h),
                child: Container(
                  height: 40.h,
                  width: 300.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF3D99E5),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (_) => false);
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
          ],
        ),
      ),
    );
  }
}
