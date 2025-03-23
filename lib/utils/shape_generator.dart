import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drawing_point.dart';

class ShapeGenerator {
  static List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
    required bool isCircle, // true for circle, false for oval
  }) {
    final points = <DrawingPoint?>[];

    if (isCircle) {
      _addCirclePoints(points, start, end, paint, canvasSize, isFilled);
    } else {
      _addOvalPoints(points, start, end, paint, canvasSize, isFilled);
    }

    return points;
  }

  static List<DrawingPoint?> generateRectangle({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
    required bool isSquare,
  }) {
    final points = <DrawingPoint?>[];

    if (isSquare) {
      final size = math.max(
        (end.dx - start.dx).abs(),
        (end.dy - start.dy).abs(),
      );
      _addRectanglePoints(
        points,
        start,
        Offset(start.dx + size, start.dy + size),
        paint,
        canvasSize,
        isFilled,
      );
    } else {
      _addRectanglePoints(points, start, end, paint, canvasSize, isFilled);
    }

    return points;
  }

  static void _addCirclePoints(
    List<DrawingPoint?> points,
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final radius = ((end - start).distance / 2).floor();

    _addOvalPoints(
      points,
      start,
      end,
      paint,
      canvasSize,
      isFilled,
      forceCircle: true,
    );
  }

  static void _addOvalPoints(
    List<DrawingPoint?> points,
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled, {
    bool forceCircle = false,
  }) {
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    var radiusX = ((end.dx - start.dx).abs() / 2);
    var radiusY = ((end.dy - start.dy).abs() / 2);

    if (forceCircle) {
      final maxRadius = math.max(radiusX, radiusY);
      radiusX = maxRadius;
      radiusY = maxRadius;
    }

    for (
      int x = (centerX - radiusX - 1).floor();
      x <= (centerX + radiusX + 1).ceil();
      x++
    ) {
      for (
        int y = (centerY - radiusY - 1).floor();
        y <= (centerY + radiusY + 1).ceil();
        y++
      ) {
        if (x >= 0 && x < canvasSize.width && y >= 0 && y < canvasSize.height) {
          final dx = x - centerX;
          final dy = y - centerY;
          final normalizedX = dx / radiusX;
          final normalizedY = dy / radiusY;
          final distance = math.sqrt(
            normalizedX * normalizedX + normalizedY * normalizedY,
          );

          if (isFilled) {
            if (distance <= 1.0) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), y.toDouble()),
                  paint: paint,
                ),
              );
            }
          } else {
            if ((distance - 1.0).abs() <= 0.5 / math.min(radiusX, radiusY)) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), y.toDouble()),
                  paint: paint,
                ),
              );
            }
          }
        }
      }
    }
  }

  static void _addRectanglePoints(
    List<DrawingPoint?> points,
    Offset start,
    Offset end,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final left = start.dx.floor();
    final top = start.dy.floor();
    final right = end.dx.floor();
    final bottom = end.dy.floor();

    final minX = math.min(left, right);
    final maxX = math.max(left, right);
    final minY = math.min(top, bottom);
    final maxY = math.max(top, bottom);

    if (isFilled) {
      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          if (x >= 0 &&
              x < canvasSize.width &&
              y >= 0 &&
              y < canvasSize.height) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        }
      }
    } else {
      // Draw horizontal lines
      for (int x = minX; x <= maxX; x++) {
        if (x >= 0 && x < canvasSize.width) {
          if (minY >= 0 && minY < canvasSize.height) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), minY.toDouble()),
                paint: paint,
              ),
            );
          }
          if (maxY >= 0 && maxY < canvasSize.height) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), maxY.toDouble()),
                paint: paint,
              ),
            );
          }
        }
      }
      // Draw vertical lines
      for (int y = minY; y <= maxY; y++) {
        if (y >= 0 && y < canvasSize.height) {
          if (minX >= 0 && minX < canvasSize.width) {
            points.add(
              DrawingPoint(
                offset: Offset(minX.toDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
          if (maxX >= 0 && maxX < canvasSize.width) {
            points.add(
              DrawingPoint(
                offset: Offset(maxX.toDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        }
      }
    }
  }
}
