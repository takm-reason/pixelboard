import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import 'base_shape_drawer.dart';

class OvalGenerator extends BaseShapeDrawer {
  bool isDebugMode = false;

  @override
  List<DrawingPoint?> drawFromDrag({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
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
    if (isDebugMode) {
      return _generateFilledRectangle(start, end, paint, canvasSize);
    }

    final width = (end.dx - start.dx).abs().floor() + 1;
    final height = (end.dy - start.dy).abs().floor() + 1;
    final strokeThickness = math.min(width, height);

    if (strokeThickness <= 2) {
      // 2ピクセル幅以下の矩形は塗りつぶし
      return _generateFilledRectangle(start, end, paint, canvasSize);
    } else if (strokeThickness <= 3) {
      // 3ピクセル幅の楕円を描画
      return _generateTripleThickShape(start, end, paint, canvasSize, isFilled);
    } else {
      // 通常サイズの楕円を描画
      return _generateNormalOvalShape(start, end, paint, canvasSize, isFilled);
    }
  }

  /// 3ピクセル幅の楕円を描画
  List<DrawingPoint?> _generateTripleThickShape(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final points = <DrawingPoint?>[];

    final minX = math.min(start.dx, end.dx).floor();
    final maxX = math.max(start.dx, end.dx).floor();
    final minY = math.min(start.dy, end.dy).floor();
    final maxY = math.max(start.dy, end.dy).floor();

    final isHorizontal = (maxX - minX) > (maxY - minY);
    final center = isHorizontal ? (minY + maxY) ~/ 2 : (minX + maxX) ~/ 2;

    // 直線を描画
    for (
      var i = (isHorizontal ? minX : minY) + 1;
      i < (isHorizontal ? maxX : maxY);
      i++
    ) {
      final pos1 =
          isHorizontal
              ? Offset(i.toDouble(), (center - 1).toDouble())
              : Offset((center - 1).toDouble(), i.toDouble());
      final pos2 =
          isHorizontal
              ? Offset(i.toDouble(), (center + 1).toDouble())
              : Offset((center + 1).toDouble(), i.toDouble());

      addPoint(points, pos1.dx, pos1.dy, paint, canvasSize);
      addPoint(points, pos2.dx, pos2.dy, paint, canvasSize);
    }

    // 端点を描画
    final endPos1 =
        isHorizontal
            ? Offset(minX.toDouble(), center.toDouble())
            : Offset(center.toDouble(), minY.toDouble());
    final endPos2 =
        isHorizontal
            ? Offset(maxX.toDouble(), center.toDouble())
            : Offset(center.toDouble(), maxY.toDouble());

    addPoint(points, endPos1.dx, endPos1.dy, paint, canvasSize);
    addPoint(points, endPos2.dx, endPos2.dy, paint, canvasSize);

    return points;
  }

  /// 通常サイズの楕円を描画
  List<DrawingPoint?> _generateNormalOvalShape(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final points = <DrawingPoint?>[];

    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 2;
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

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
          if ((distance - 1.0).abs() <= 0.05) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        }
      }
    }

    return points;
  }

  /// 指定された矩形領域を全て塗りつぶす
  List<DrawingPoint?> _generateFilledRectangle(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
  ) {
    final points = <DrawingPoint?>[];

    final left = math.min(start.dx, end.dx).floor();
    final right = math.max(start.dx, end.dx).floor();
    final top = math.min(start.dy, end.dy).floor();
    final bottom = math.max(start.dy, end.dy).floor();

    for (int x = left; x <= right; x++) {
      for (int y = top; y <= bottom; y++) {
        addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
      }
    }

    return points;
  }
}
