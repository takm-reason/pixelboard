import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import 'base_shape_generator.dart';

/// 形状描画の基本クラス
abstract class BaseShapeDrawer extends ShapeGenerator {
  /// 左上と右下の座標から形状を描画
  List<DrawingPoint?> drawFromBounds({
    required Offset topLeft,
    required Offset bottomRight,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    // 開始点と終了点を設定して描画を実行
    return generateShape(
      start: topLeft,
      end: bottomRight,
      paint: paint,
      canvasSize: canvasSize,
      isFilled: isFilled,
    );
  }

  /// ドラッグの開始点と終了点から形状を描画
  List<DrawingPoint?> drawFromDrag({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  });
}
