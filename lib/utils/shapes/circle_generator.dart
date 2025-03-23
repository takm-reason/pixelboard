import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'circle_shape_base.dart';

class CircleGenerator extends CircleShapeBase {
  @override
  List<double> calculateRadii(Offset center, Offset start, Offset end) {
    final radius = ((end - start).distance / 2);
    // 円の場合は両方の半径が同じ
    return [radius, radius];
  }
}
