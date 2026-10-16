import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PerlinNoise extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double devicePixelRatio;
  final ui.Image atlasImage;
  PerlinNoise(this.shader, this.time, this.devicePixelRatio, this.atlasImage);
  @override
  void paint(Canvas canvas, Size size) {
    final Size gridSize = Size(
      (size.width * devicePixelRatio / 8).floor().toDouble(),
      (size.height * devicePixelRatio / 8).floor().toDouble(),
    );
    final Size atlasGrid = Size(10, 1);
    final double scale = size.shortestSide / 100;
    shader
      ..setFloat(0, scale)
      ..setFloat(1, time)
      ..setFloat(2, size.width * devicePixelRatio)
      ..setFloat(3, size.height * devicePixelRatio)
      ..setFloat(4, gridSize.width)
      ..setFloat(5, gridSize.height)
      ..setFloat(6, atlasGrid.width)
      ..setFloat(7, atlasGrid.height)
      ..setFloat(8, 0)
      ..setFloat(9, 0)
      ..setImageSampler(0, atlasImage);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
