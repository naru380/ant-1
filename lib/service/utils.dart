import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<ui.Image> getImageFromPainter(CustomPainter painter, Size size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), size);
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(size.width.toInt(), size.height.toInt());
    return image;
  }