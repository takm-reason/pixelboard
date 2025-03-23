import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import '../shapes/base_shape_generator.dart';

class ThreePixelPatterns extends ShapeGenerator {
  @override
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    final points = <DrawingPoint?>[];
    final width = getWidth(start, end);
    final height = getHeight(start, end);
    final topLeft = getTopLeft(start, end);

    if (width == 1 && height == 1) {
      addPoint(points, topLeft.dx, topLeft.dy, paint, canvasSize);
      return points;
    }

    // 縦方向の処理
    if (width <= 3 && height > width) {
      if (width == 1) {
        addVerticalLine(points, topLeft, height, paint, canvasSize);
      } else if (width == 2) {
        addVertical2pxLine(points, topLeft, height, paint, canvasSize);
      } else {
        // width == 3
        addVertical3pxPattern(points, topLeft, height, paint, canvasSize);
      }
      return points;
    }

    // 横方向の処理
    if (height <= 3 && width > height) {
      if (height == 1) {
        addHorizontalLine(points, topLeft, width, paint, canvasSize);
      } else if (height == 2) {
        addHorizontal2pxLine(points, topLeft, width, paint, canvasSize);
      } else {
        // height == 3
        addHorizontal3pxPattern(points, topLeft, width, paint, canvasSize);
      }
      return points;
    }

    // 3x3の場合
    if (width == 3 && height == 3) {
      add3x3Pattern(points, topLeft, paint, canvasSize);
    }

    return points;
  }

  // 縦方向の1px線
  void addVerticalLine(
    List<DrawingPoint?> points,
    Offset topLeft,
    double height,
    Paint paint,
    Size canvasSize,
  ) {
    for (int y = 0; y < height; y++) {
      addPoint(points, topLeft.dx, topLeft.dy + y, paint, canvasSize);
    }
  }

  // 縦方向の2px線
  void addVertical2pxLine(
    List<DrawingPoint?> points,
    Offset topLeft,
    double height,
    Paint paint,
    Size canvasSize,
  ) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < 2; x++) {
        addPoint(points, topLeft.dx + x, topLeft.dy + y, paint, canvasSize);
      }
    }
  }

  // 横方向の1px線
  void addHorizontalLine(
    List<DrawingPoint?> points,
    Offset topLeft,
    double width,
    Paint paint,
    Size canvasSize,
  ) {
    for (int x = 0; x < width; x++) {
      addPoint(points, topLeft.dx + x, topLeft.dy, paint, canvasSize);
    }
  }

  // 横方向の2px線
  void addHorizontal2pxLine(
    List<DrawingPoint?> points,
    Offset topLeft,
    double width,
    Paint paint,
    Size canvasSize,
  ) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < 2; y++) {
        addPoint(points, topLeft.dx + x, topLeft.dy + y, paint, canvasSize);
      }
    }
  }

  // 3x3の基本パターン
  void add3x3Pattern(
    List<DrawingPoint?> points,
    Offset topLeft,
    Paint paint,
    Size canvasSize,
  ) {
    // 上段: □ ■ □
    addPoint(points, topLeft.dx + 1, topLeft.dy, paint, canvasSize);

    // 中段: ■ □ ■
    addPoint(points, topLeft.dx, topLeft.dy + 1, paint, canvasSize);
    addPoint(points, topLeft.dx + 2, topLeft.dy + 1, paint, canvasSize);

    // 下段: □ ■ □
    addPoint(points, topLeft.dx + 1, topLeft.dy + 2, paint, canvasSize);
  }

  // 縦長の3px幅パターン
  void addVertical3pxPattern(
    List<DrawingPoint?> points,
    Offset topLeft,
    double height,
    Paint paint,
    Size canvasSize,
  ) {
    // 上端: □ ■ □
    addPoint(points, topLeft.dx + 1, topLeft.dy, paint, canvasSize);

    // 中間部分: ■ □ ■ (繰り返し)
    for (int y = 1; y < height - 1; y++) {
      addPoint(points, topLeft.dx, topLeft.dy + y, paint, canvasSize);
      addPoint(points, topLeft.dx + 2, topLeft.dy + y, paint, canvasSize);
    }

    // 下端: □ ■ □
    addPoint(
      points,
      topLeft.dx + 1,
      topLeft.dy + height - 1,
      paint,
      canvasSize,
    );
  }

  // 横長の3px高さパターン
  void addHorizontal3pxPattern(
    List<DrawingPoint?> points,
    Offset topLeft,
    double width,
    Paint paint,
    Size canvasSize,
  ) {
    // 上段: □ ■ ■ ■ ■ ■ □
    addPoint(points, topLeft.dx + 1, topLeft.dy, paint, canvasSize);
    for (int x = 2; x < width - 1; x++) {
      addPoint(points, topLeft.dx + x, topLeft.dy, paint, canvasSize);
    }

    // 中段: ■ □ □ □ □ □ ■
    addPoint(points, topLeft.dx, topLeft.dy + 1, paint, canvasSize);
    addPoint(points, topLeft.dx + width - 1, topLeft.dy + 1, paint, canvasSize);

    // 下段: □ ■ ■ ■ ■ ■ □
    addPoint(points, topLeft.dx + 1, topLeft.dy + 2, paint, canvasSize);
    for (int x = 2; x < width - 1; x++) {
      addPoint(points, topLeft.dx + x, topLeft.dy + 2, paint, canvasSize);
    }
  }
}
