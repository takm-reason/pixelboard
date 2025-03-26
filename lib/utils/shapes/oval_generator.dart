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
    final width = (end.dx - start.dx).abs().floor() + 1;
    final height = (end.dy - start.dy).abs().floor() + 1;
    final strokeThickness = math.min(width, height);

    if (strokeThickness <= 2) {
      // 2ピクセル幅以下の矩形は塗りつぶし
      return _generateFilledRectangle(start, end, paint, canvasSize);
    } else if (strokeThickness <= 4) {
      //
      return _generateSmallOvalShape(start, end, paint, canvasSize, isFilled);
    } else {
      // 通常サイズの楕円を描画
      return _generateNormalOvalShape(start, end, paint, canvasSize, isFilled);
    }
  }

  /// 指定された矩形領域を全て塗りつぶす
  List<DrawingPoint?> _generateFilledRectangle(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
  ) {
    final points = <DrawingPoint?>[];

    for (int x = start.dx.toInt(); x <= end.dx.toInt(); x++) {
      for (int y = start.dy.toInt(); y <= end.dy.toInt(); y++) {
        addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
      }
    }

    return points;
  }

  /// 3-4ピクセル幅の楕円を描画
  List<DrawingPoint?> _generateSmallOvalShape(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final points = <DrawingPoint?>[];

    final dx = (end.dx - start.dx).abs();
    final dy = (end.dy - start.dy).abs();

    for (var i = 1; i < dx; i++) {
      final x = start.dx + i;
      final y = start.dy;
      addPoint(points, x, y, paint, canvasSize);
    }

    for (var i = 1; i < dx; i++) {
      final x = start.dx + i;
      final y = end.dy;
      addPoint(points, x, y, paint, canvasSize);
    }

    for (var i = 1; i < dy; i++) {
      final x = start.dx;
      final y = start.dy + i;
      addPoint(points, x, y, paint, canvasSize);
    }

    for (var i = 1; i < dy; i++) {
      final x = end.dx;
      final y = start.dy + i;
      addPoint(points, x, y, paint, canvasSize);
    }

    if (isFilled) {
      for (int x = start.dx.toInt() + 1; x < end.dx.toInt(); x++) {
        for (int y = start.dy.toInt() + 1; y < end.dy.toInt(); y++) {
          addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
        }
      }
    }

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

    if (isFilled) {
      return _generateFilledOval(center, radiusX, radiusY, paint, canvasSize);
    }

    // 楕円の輪郭を描画
    // スタート位置を設定
    final firstX = start.dx.floor();
    final firstY = ((start.dy + end.dy) / 2).floor();
    var currentX = firstX;
    var currentY = firstY;

    // 円の中心座標（doubleのまま）
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;

    while (true) {
      addPoint(
        points,
        currentX.toDouble(),
        currentY.toDouble(),
        paint,
        canvasSize,
      );

      // 次の候補点を評価
      var bestDistance = double.infinity;
      var nextX = currentX;
      var nextY = currentY;

      // 現在の位置に応じて候補方向を決定
      final List<List<int>> directions;
      if (currentY > centerY) {
        // 中心より下にいる場合
        if (currentX > centerX) {
          // 右下にいる場合: 左、左下、下
          directions = [
            [-1, 0], // ←
            [-1, 1], // ↙
            [0, 1], // ↓
          ];
        } else {
          // 左下にいる場合: 左、左上、上
          directions = [
            [-1, 0], // ←
            [-1, -1], // ↖
            [0, -1], // ↑
          ];
        }
      } else {
        // 中心より上にいる場合
        if (currentX < centerX) {
          // 左上にいる場合: 右、右上、上
          directions = [
            [1, 0], // →
            [1, -1], // ↗
            [0, -1], // ↑
          ];
        } else {
          // 右上にいる場合: 右、右下、下
          directions = [
            [1, 0], // →
            [1, 1], // ↘
            [0, 1], // ↓
          ];
        }
      }

      // スタート位置が候補に含まれるかチェック
      var containsStart = false;

      for (final dir in directions) {
        final newX = currentX + dir[0];
        final newY = currentY + dir[1];

        // スタート位置かどうかチェック
        if (newX == firstX && newY == firstY) {
          containsStart = true;
          continue;
        }

        // キャンバスの範囲内かチェック
        if (newX < 0 ||
            newX >= canvasSize.width ||
            newY < 0 ||
            newY >= canvasSize.height) {
          continue;
        }

        final dx = newX - centerX;
        final dy = newY - centerY;
        final normalizedX = dx / radiusX;
        final normalizedY = dy / radiusY;
        final distance =
            (math.sqrt(normalizedX * normalizedX + normalizedY * normalizedY) -
                    1.0)
                .abs();

        if (distance < bestDistance) {
          bestDistance = distance;
          nextX = newX;
          nextY = newY;
        }
      }

      // スタート位置が候補に含まれていた場合は終了
      if (containsStart) {
        break;
      }

      currentX = nextX;
      currentY = nextY;
    }

    return points;
  }

  /// 塗りつぶされた楕円を生成
  List<DrawingPoint?> _generateFilledOval(
    Offset center,
    double radiusX,
    double radiusY,
    Paint paint,
    Size canvasSize,
  ) {
    final points = <DrawingPoint?>[];

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

        if (distance <= 1.0) {
          addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
        }
      }
    }

    return points;
  }
}
