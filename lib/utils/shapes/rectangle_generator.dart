import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import '../patterns/three_pixel_patterns.dart';
import 'base_shape_generator.dart';

class RectangleGenerator extends ShapeGenerator {
  final bool isSquare;
  final ThreePixelPatterns _smallShapeGenerator = ThreePixelPatterns();

  RectangleGenerator({this.isSquare = false});

  @override
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    final points = <DrawingPoint?>[];
    var topLeft = getTopLeft(start, end);
    var bottomRight = getBottomRight(start, end);
    var width = getWidth(start, end);
    var height = getHeight(start, end);

    // 正方形の場合、大きい方のサイズを使用
    if (isSquare) {
      final size = math.max(width, height);
      width = size;
      height = size;
      bottomRight = Offset(topLeft.dx + size - 1, topLeft.dy + size - 1);
    }

    // 小さいサイズの場合は特殊パターンを使用
    if (width <= 3 || height <= 3) {
      return _smallShapeGenerator.generateShape(
        start: topLeft,
        end: bottomRight,
        paint: paint,
        canvasSize: canvasSize,
        isFilled: isFilled,
      );
    }

    // 通常の四角形描画
    if (isFilled) {
      _drawFilledRectangle(points, topLeft, bottomRight, paint, canvasSize);
    } else {
      _drawRectangleBorder(points, topLeft, bottomRight, paint, canvasSize);
    }

    return points;
  }

  void _drawFilledRectangle(
    List<DrawingPoint?> points,
    Offset topLeft,
    Offset bottomRight,
    Paint paint,
    Size canvasSize,
  ) {
    for (int x = topLeft.dx.floor(); x <= bottomRight.dx.floor(); x++) {
      for (int y = topLeft.dy.floor(); y <= bottomRight.dy.floor(); y++) {
        addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
      }
    }
  }

  void _drawRectangleBorder(
    List<DrawingPoint?> points,
    Offset topLeft,
    Offset bottomRight,
    Paint paint,
    Size canvasSize,
  ) {
    // 上辺と下辺
    for (int x = topLeft.dx.floor(); x <= bottomRight.dx.floor(); x++) {
      addPoint(points, x.toDouble(), topLeft.dy, paint, canvasSize);
      addPoint(points, x.toDouble(), bottomRight.dy, paint, canvasSize);
    }

    // 左辺と右辺（上下の角を除く）
    for (int y = topLeft.dy.floor() + 1; y < bottomRight.dy.floor(); y++) {
      addPoint(points, topLeft.dx, y.toDouble(), paint, canvasSize);
      addPoint(points, bottomRight.dx, y.toDouble(), paint, canvasSize);
    }
  }
}
