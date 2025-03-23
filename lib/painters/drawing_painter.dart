import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  final List<DrawingPoint?> previewPoints;
  final double scale;

  DrawingPainter({
    required this.points,
    required this.previewPoints,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw actual points
    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        canvas.drawRect(
          Rect.fromLTWH(
            points[i]!.offset.dx * scale,
            points[i]!.offset.dy * scale,
            scale,
            scale,
          ),
          points[i]!.paint,
        );
      }
    }

    // Draw preview points
    for (int i = 0; i < previewPoints.length; i++) {
      if (previewPoints[i] != null) {
        canvas.drawRect(
          Rect.fromLTWH(
            previewPoints[i]!.offset.dx * scale,
            previewPoints[i]!.offset.dy * scale,
            scale,
            scale,
          ),
          previewPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
