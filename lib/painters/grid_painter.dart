import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSize;
  final double width;
  final double height;

  GridPainter({
    required this.gridSize,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1;

    for (double i = 0; i <= width; i++) {
      canvas.drawLine(
        Offset(i * gridSize, 0),
        Offset(i * gridSize, height * gridSize),
        paint,
      );
    }

    for (double i = 0; i <= height; i++) {
      canvas.drawLine(
        Offset(0, i * gridSize),
        Offset(width * gridSize, i * gridSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => false;
}
