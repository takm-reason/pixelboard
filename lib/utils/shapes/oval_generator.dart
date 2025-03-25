import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import 'base_shape_drawer.dart';

class OvalGenerator extends BaseShapeDrawer {
  @override
  List<DrawingPoint?> drawFromDrag({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    // 開始位置と終了位置から直接左上と右下を計算
    final topLeft = Offset(
      math.min(start.dx, end.dx),
      math.min(start.dy, end.dy),
    );
    final bottomRight = Offset(
      math.max(start.dx, end.dx),
      math.max(start.dy, end.dy),
    );

    return drawFromBounds(
      topLeft: topLeft,
      bottomRight: bottomRight,
      paint: paint,
      canvasSize: canvasSize,
      isFilled: isFilled,
    );
  }

  @override
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    final points = <DrawingPoint?>[];

    // X軸とY軸の半径を計算
    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 2;

    // 中心点を計算
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    // 楕円を描画
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
          if ((distance - 1.0).abs() <= 0.1) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        }
      }
    }

    return points;
  }
}
