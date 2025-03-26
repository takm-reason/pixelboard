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
    final leftTop = Offset(
      math.min(start.dx, end.dx),
      math.min(start.dy, end.dy),
    );
    final rightBottom = Offset(
      math.max(start.dx, end.dx),
      math.max(start.dy, end.dy),
    );

    if (strokeThickness <= 2) {
      // 2ピクセル幅以下の矩形は塗りつぶし
      return _generateFilledRectangle(leftTop, rightBottom, paint, canvasSize);
    } else if (strokeThickness <= 4) {
      // 3-4ピクセル幅の楕円を描画
      return _generateSmallOvalShape(
        leftTop,
        rightBottom,
        paint,
        canvasSize,
        isFilled,
      );
    } else {
      // 通常サイズの楕円を描画
      return _generateNormalOvalShape(
        leftTop,
        rightBottom,
        paint,
        canvasSize,
        isFilled,
      );
    }
  }

  // 指定された矩形領域を全て塗りつぶす
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

  // 3-4ピクセル幅の楕円を描画
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

  // 開始点側（左上）の中心点を取得（端数切り捨て）
  Offset _getStartCenterPoint(Offset start, Offset end) {
    // X軸の中点を計算（左側）
    final centerX =
        (math.min(start.dx, end.dx) + math.max(start.dx, end.dx)) / 2;

    // Y軸の中点を計算
    final centerY =
        (math.min(start.dy, end.dy) + math.max(start.dy, end.dy)) / 2;

    // 座標は常に切り捨て
    final adjustedX = centerX.floor().toDouble();
    final adjustedY = centerY.floor().toDouble();

    return Offset(adjustedX, adjustedY);
  }

  // 終了点側（右下）の中心点を取得（端数切り上げ）
  Offset _getEndCenterPoint(Offset start, Offset end) {
    // X軸の中点を計算（右側）
    final centerX =
        (math.min(start.dx, end.dx) + math.max(start.dx, end.dx)) / 2;

    // Y軸の中点を計算
    final centerY =
        (math.min(start.dy, end.dy) + math.max(start.dy, end.dy)) / 2;

    // 座標は常に切り上げ
    final adjustedX = centerX.ceil().toDouble();
    final adjustedY = centerY.ceil().toDouble();

    return Offset(adjustedX, adjustedY);
  }

  List<Offset> generateDirectionalOffsets({
    required Offset from,
    required Offset to,
  }) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;

    if (dx == 0 && dy == 0) {
      return []; // 同じ位置
    }

    final stepX = dx == 0 ? 0 : (dx > 0 ? 1 : -1);
    final stepY = dy == 0 ? 0 : (dy > 0 ? 1 : -1);

    // どちらか一方だけが異なる場合（水平または垂直）
    if (dx == 0 || dy == 0) {
      return [Offset(from.dx + stepX, from.dy + stepY)];
    }

    // 斜めの場合 → 3方向に進める
    return [
      Offset(from.dx + stepX, from.dy), // 横
      Offset(from.dx, from.dy + stepY), // 縦
      Offset(from.dx + stepX, from.dy + stepY), // 斜め
    ];
  }

  /// 候補座標の中から、楕円の境界に最も近い点を返す
  Offset findClosestPointOnEllipse({
    required Offset center,
    required Offset start,
    required Offset end,
    required List<Offset> candidates,
  }) {
    final a = (end.dx - start.dx).abs();
    final b = (end.dy - start.dy).abs();
    if (a == 0 || b == 0) return center; // 楕円にならない場合

    final a2 = a * a;
    final b2 = b * b;

    Offset? closest;
    double minError = double.infinity;

    for (final p in candidates) {
      final dx = p.dx - center.dx;
      final dy = p.dy - center.dy;
      final value = (dx * dx) / a2 + (dy * dy) / b2;
      final error = (value - 1.0).abs(); // 楕円からの誤差

      if (error < minError) {
        minError = error;
        closest = p;
      }
    }

    return closest ?? center;
  }

  // 楕円の4分の1を描画
  List<DrawingPoint?> _generateQuarterOval(
    Offset center,
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
  ) {
    final points = <DrawingPoint?>[];
    Offset current = start;

    while ((current.dx.round() != end.dx.round()) ||
        (current.dy.round() != end.dy.round())) {
      addPoint(points, current.dx, current.dy, paint, canvasSize);

      final candidates = generateDirectionalOffsets(from: current, to: end);
      final next = findClosestPointOnEllipse(
        center: center,
        start: start,
        end: end,
        candidates: candidates,
      );

      if (next == current) {
        // 進行不能な場合ループ終了（無限ループ防止）
        break;
      }

      current = next;
    }

    // 最終点も追加
    addPoint(points, end.dx, end.dy, paint, canvasSize);

    return points;
  }

  // 通常サイズの楕円を描画
  List<DrawingPoint?> _generateNormalOvalShape(
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final points = <DrawingPoint?>[];

    final centerStart = _getStartCenterPoint(start, end); // 切り捨て
    final centerEnd = _getEndCenterPoint(start, end); // 切り上げ

    // 縦長かどうかを判定
    final isVertical = (end.dy - start.dy).abs() > (end.dx - start.dx).abs();

    if (isVertical) {
      points.addAll(
        _generateQuarterOval(
          Offset(centerEnd.dx, centerStart.dy),
          Offset(end.dx, centerStart.dy),
          Offset(centerEnd.dx, start.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerEnd.dx, centerEnd.dy),
          Offset(end.dx, centerEnd.dy),
          Offset(centerEnd.dx, end.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerStart.dx, centerEnd.dy),
          Offset(start.dx, centerEnd.dy),
          Offset(centerStart.dx, end.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerStart.dx, centerStart.dy),
          Offset(start.dx, centerStart.dy),
          Offset(centerStart.dx, start.dy),
          paint,
          canvasSize,
        ),
      );
    } else {
      points.addAll(
        _generateQuarterOval(
          Offset(centerEnd.dx, centerStart.dy),
          Offset(centerEnd.dx, start.dy),
          Offset(end.dx, centerStart.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerEnd.dx, centerEnd.dy),
          Offset(centerEnd.dx, end.dy),
          Offset(end.dx, centerEnd.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerStart.dx, centerEnd.dy),
          Offset(centerStart.dx, end.dy),
          Offset(start.dx, centerEnd.dy),
          paint,
          canvasSize,
        ),
      );
      points.addAll(
        _generateQuarterOval(
          Offset(centerStart.dx, centerStart.dy),
          Offset(centerStart.dx, start.dy),
          Offset(start.dx, centerStart.dy),
          paint,
          canvasSize,
        ),
      );
    }

    return points;
  }
}
