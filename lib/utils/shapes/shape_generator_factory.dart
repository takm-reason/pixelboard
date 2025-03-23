import 'package:flutter/material.dart';
import '../../models/drawing_tool.dart';
import 'base_shape_generator.dart';
import 'circle_generator.dart';
import 'oval_generator.dart';
import 'rectangle_generator.dart';

class ShapeGeneratorFactory {
  static ShapeGenerator createGenerator(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.rectangle:
        return RectangleGenerator(isSquare: false);
      case DrawingTool.square:
        return RectangleGenerator(isSquare: true);
      case DrawingTool.circle:
        return CircleGenerator();
      case DrawingTool.oval:
        return OvalGenerator();
      case DrawingTool.brush:
      case DrawingTool.fill:
        throw ArgumentError('Brush and Fill tools do not use shape generators');
    }
  }

  static bool usesGenerator(DrawingTool tool) {
    return tool == DrawingTool.rectangle ||
        tool == DrawingTool.square ||
        tool == DrawingTool.circle ||
        tool == DrawingTool.oval;
  }
}
