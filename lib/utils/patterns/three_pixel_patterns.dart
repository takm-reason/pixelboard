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

    if (width == 3 && height == 3) {
      add3x3Pattern(points, topLeft, paint, canvasSize);
    } else if (width == 3) {
      addVertical3pxPattern(points, topLeft, height, paint, canvasSize);
    } else if (height == 3) {
      addHorizontal3pxPattern(points, topLeft, width, paint, canvasSize);
    }

    return points;
  }

  // 3x3の基本パターン
  void add3x3Pattern(
    List<DrawingPoint?> points,
    Offset topLeft,
    Paint paint,
    Size canvasSize,
  ) {
    // 上段の中央
    addPoint(points, topLeft.dx + 1, topLeft.dy, paint, canvasSize);

    // 中段の左右
    addPoint(points, topLeft.dx, topLeft.dy + 1, paint, canvasSize);
    addPoint(points, topLeft.dx + 2, topLeft.dy + 1, paint, canvasSize);

    // 下段の中央
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
    // 上端
    addPoint(points, topLeft.dx + 1, topLeft.dy, paint, canvasSize);

    // 中間部分
    for (int y = 1; y < height - 1; y++) {
      if (y % 2 == 0) {
        // 中央のドット
        addPoint(points, topLeft.dx + 1, topLeft.dy + y, paint, canvasSize);
      } else {
        // 左右のドット
        addPoint(points, topLeft.dx, topLeft.dy + y, paint, canvasSize);
        addPoint(points, topLeft.dx + 2, topLeft.dy + y, paint, canvasSize);
      }
    }

    // 下端
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
    // 上段の中央ドット
    for (int x = 0; x < width; x++) {
      if (x % 2 == 1) {
        addPoint(points, topLeft.dx + x, topLeft.dy, paint, canvasSize);
      }
    }

    // 中段の両端ドット
    for (int x = 0; x < width; x++) {
      if (x % 2 == 0) {
        addPoint(points, topLeft.dx + x, topLeft.dy + 1, paint, canvasSize);
      }
    }

    // 下段の中央ドット
    for (int x = 0; x < width; x++) {
      if (x % 2 == 1) {
        addPoint(points, topLeft.dx + x, topLeft.dy + 2, paint, canvasSize);
      }
    }
  }
}
