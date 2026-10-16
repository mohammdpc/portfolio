import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_styles.dart';

class AsciiPainter extends CustomPainter {
  // 1. Configuration & Constants (Sorted by memory size)
  static const int period = 150;
  final int randomizationThreshHold = 10;
  final double halfPeriod = period / 2;
  final String asciiChars;
  int density = 3;

  // 2. State & Grid Data (Sorted by memory size)
  static List<RSTransform> transforms = [];
  static List<TextPainter> painters = [];
  static List<Rect> rects = [];
  static List<Rect> atlasRects = [];
  static Uint8List grid = Uint8List.fromList([]);
  static ui.Size previousSize = ui.Size(100, 100);
  static double? cellHeight;
  static double? cellWidth;
  static int? columnCount;
  static int? rowCount;
  late final int maxIndex;

  // 3. Interaction & Input (Sorted by memory size)
  late final Random _random;
  final double mx, my;

  // 4. Rendering Resources (Sorted by memory size)
  static ui.Image? atlas;

  AsciiPainter({required this.mx, required this.my, required this.asciiChars}) {
    _random = Random(DateTime.now().microsecond);
    maxIndex = asciiChars.length - 1;
    if (atlas == null || rects.isEmpty) {
      createAtlas();
    }
  }

  void createAtlas() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 1. Determine size of one character
    final tp = TextPainter(
      text: TextSpan(
        text: 'W',
        style: AppStyles.title,
      ), // Use a wide char for sizing
      textDirection: TextDirection.ltr,
    )..layout();

    final charW = tp.width;
    final charH = tp.height;
    if (rects.isEmpty) {
      rects = List.generate(asciiChars.length, (i) {
        return Rect.fromLTWH(i * charW, 0, charW, charH);
      });
    }
    // 2. Draw all characters side-by-side into the recorder
    for (int i = 0; i < asciiChars.length; i++) {
      Color c = AppColors.accent.withAlpha(((i/(asciiChars.length - 1)) * 255).round());
      TextPainter(
          text: TextSpan(text: asciiChars[i], style: AppStyles.title.copyWith(color: c)),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(i * charW, 0));
    }

    // 3. Convert to ui.Image
    final picture = recorder.endRecording();
    atlas = await picture.toImage(
      (charW * asciiChars.length).ceil(),
      charH.ceil(),
    );
  }

  void setTransform(ui.Size size) {
    columnCount = (size.width * (density / 100)).round();
    rowCount = (size.height * columnCount! / size.width).round();
    grid = Uint8List.fromList(
      List.generate(
        columnCount! * rowCount!,
        (i) => _random.nextInt(maxIndex),
      ),
    );
    atlasRects = List.generate(columnCount! * rowCount!, (i) => rects[grid[i]]);
    transforms.clear();
    transforms = [];
    cellHeight = size.height / rowCount!;
    cellWidth = size.width / columnCount!;

    for (int columnIndex = 0; columnIndex < columnCount!; columnIndex++) {
      final px = columnIndex * cellWidth!; // row index → vertical position
      for (int rowIndex = 0; rowIndex < rowCount!; rowIndex++) {
        final py = rowIndex * cellHeight!; // column index → horizontal position
        transforms.add(
          RSTransform.fromComponents(
            rotation: 0,
            scale: 1,
            anchorX: 0,
            anchorY: 0,
            translateX: px,
            translateY: py,
          ),
        );
      }
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (atlas == null) {
      return;
    }
    if (transforms.isEmpty || size != previousSize) {
      setTransform(size);
      previousSize = size;
    }
    for (int columnIndex = 0; columnIndex < columnCount!; columnIndex++) {
      final dx = (columnIndex + 0.5) * cellWidth! - mx;
      for (int rowIndex = 0; rowIndex < rowCount!; rowIndex++) {
        final dy = (rowIndex + 0.5) * cellHeight! - my;
        final distanceSquared = dx * dx + dy * dy;
        final int index = columnIndex * rowCount! + rowIndex;

        if (distanceSquared < (period + randomizationThreshHold) * (period + randomizationThreshHold)) {
          final distance = sqrt(distanceSquared);
          if (distance <= period + randomizationThreshHold &&
              distance > period) {
            grid[index] = _random.nextInt(maxIndex + 1);
            atlasRects[index] = (rects[grid[index]]);
          } else {
            grid[index] =
                ((distance < halfPeriod ? distance : period - distance) /
                        halfPeriod *
                        maxIndex)
                    .round()
                    .clamp(0, maxIndex);
            atlasRects[index] = (rects[grid[index]]);
          }
        }
      }
    }
    canvas.drawAtlas(atlas!, transforms, atlasRects, null, null, null, Paint());
  }

  @override
  bool shouldRepaint(covariant AsciiPainter oldDelegate) {
    if (oldDelegate.mx != mx || oldDelegate.my != my) {
      return true;
    } else {
      return false;
    }
  }
}
