import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import 'base_shape_drawer.dart';
import 'oval_generator.dart';

class CircleGenerator extends BaseShapeDrawer {
  // 楕円描画のロジックを使用
  final _ovalDrawer = OvalGenerator();

  @override
  List<DrawingPoint?> drawFromDrag({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    // 開始点と終了点の差分を計算
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    // 最大の直径を計算（縦横の差の大きい方）
    final diameter = math.max(dx.abs(), dy.abs());
    final radius = diameter / 2;

    // 終了点の方向を単位ベクトルとして計算
    final distance = math.sqrt(dx * dx + dy * dy);
    final dirX = distance > 0 ? dx / distance : 0.0;
    final dirY = distance > 0 ? dy / distance : 0.0;

    // 開始点から距離radiusの位置を中心とする
    final center = Offset(start.dx + radius * dirX, start.dy + radius * dirY);

    // 中心点を基準に正確な正方形の領域を計算
    final topLeft = Offset(center.dx - radius, center.dy - radius);
    final bottomRight = Offset(center.dx + radius, center.dy + radius);

    // 楕円描画のロジックを使用して円を描画
    return _ovalDrawer.drawFromBounds(
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
    // 正方形の領域を計算（円を描画するため）
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final size = math.max(dx.abs(), dy.abs());

    // 開始点からの正方形の領域を計算
    final newEnd = Offset(
      start.dx + size * (dx >= 0 ? 1 : -1),
      start.dy + size * (dy >= 0 ? 1 : -1),
    );

    // 楕円描画のロジックを使用して円を描画
    return _ovalDrawer.generateShape(
      start: start,
      end: newEnd,
      paint: paint,
      canvasSize: canvasSize,
      isFilled: isFilled,
    );
  }
}
