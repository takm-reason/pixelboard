import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';

abstract class ShapeGenerator {
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  });

  bool isInBounds(int x, int y, Size canvasSize) {
    return x >= 0 && x < canvasSize.width && y >= 0 && y < canvasSize.height;
  }

  void addPoint(
    List<DrawingPoint?> points,
    double x,
    double y,
    Paint paint,
    Size canvasSize,
  ) {
    final intX = x.floor();
    final intY = y.floor();
    if (isInBounds(intX, intY, canvasSize)) {
      points.add(
        DrawingPoint(
          offset: Offset(x.floorToDouble(), y.floorToDouble()),
          paint: paint,
        ),
      );
    }
  }

  // よく使用される計算のユーティリティメソッド
  double getWidth(Offset start, Offset end) {
    return (end.dx - start.dx).abs() + 1;
  }

  double getHeight(Offset start, Offset end) {
    return (end.dy - start.dy).abs() + 1;
  }

  Offset getTopLeft(Offset start, Offset end) {
    return Offset(math.min(start.dx, end.dx), math.min(start.dy, end.dy));
  }

  Offset getBottomRight(Offset start, Offset end) {
    return Offset(math.max(start.dx, end.dx), math.max(start.dy, end.dy));
  }
}
