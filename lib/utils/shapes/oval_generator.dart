import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'circle_shape_base.dart';

class OvalGenerator extends CircleShapeBase {
  @override
  List<double> calculateRadii(Offset center, Offset start, Offset end) {
    // 楕円の場合はX軸とY軸で異なる半径を計算
    final radiusX = (end.dx - start.dx).abs() / 2;
    final radiusY = (end.dy - start.dy).abs() / 2;
    return [radiusX, radiusY];
  }
}
