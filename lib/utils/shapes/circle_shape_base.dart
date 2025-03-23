import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import '../patterns/three_pixel_patterns.dart';
import 'base_shape_generator.dart';

abstract class CircleShapeBase extends ShapeGenerator {
  final ThreePixelPatterns _smallShapeGenerator = ThreePixelPatterns();

  // サブクラスで実装する半径の計算方法
  List<double> calculateRadii(Offset center, Offset start, Offset end);

  @override
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    final points = <DrawingPoint?>[];
    final topLeft = getTopLeft(start, end);
    final bottomRight = getBottomRight(start, end);
    final width = getWidth(start, end);
    final height = getHeight(start, end);

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

    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    final radii = calculateRadii(center, start, end);
    final radiusX = radii[0];
    final radiusY = radii[1];

    _drawEllipse(points, center, radiusX, radiusY, paint, canvasSize, isFilled);

    return points;
  }

  void _drawEllipse(
    List<DrawingPoint?> points,
    Offset center,
    double radiusX,
    double radiusY,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final boundLeft = math.max(0, (center.dx - radiusX).floor());
    final boundRight = math.min(
      canvasSize.width.floor() - 1,
      (center.dx + radiusX).floor(),
    );
    final boundTop = math.max(0, (center.dy - radiusY).floor());
    final boundBottom = math.min(
      canvasSize.height.floor() - 1,
      (center.dy + radiusY).floor(),
    );

    for (int x = boundLeft; x <= boundRight; x++) {
      for (int y = boundTop; y <= boundBottom; y++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        final normalizedX = dx / radiusX;
        final normalizedY = dy / radiusY;
        final distance = math.sqrt(
          normalizedX * normalizedX + normalizedY * normalizedY,
        );

        if (isFilled) {
          if (distance <= 1.0) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        } else {
          if ((distance - 1.0).abs() <= 0.5 / math.min(radiusX, radiusY)) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        }
      }
    }
  }
}
