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
    required bool isCircle,
  }) {
    final points = <DrawingPoint?>[];

    var left = math.min(start.dx, end.dx);
    var top = math.min(start.dy, end.dy);
    var right = math.max(start.dx, end.dx);
    var bottom = math.max(start.dy, end.dy);
    var width = right - left + 1;
    var height = bottom - top + 1;

    // 開始位置と終了位置が同じ場合は1ピクセルのみ描画
    if (width == 1 && height == 1) {
      if (_isInBounds(left.floor(), top.floor(), canvasSize)) {
        points.add(
          DrawingPoint(
            offset: Offset(left.floorToDouble(), top.floorToDouble()),
            paint: paint,
          ),
        );
      }
      return points;
    }

    // 幅に応じた処理分岐
    if (width <= 3 || height <= 3) {
      _addSmallShapePoints(
        points,
        left,
        top,
        right,
        bottom,
        width,
        height,
        paint,
        canvasSize,
      );
      return points;
    }

    if (isCircle) {
      // 正方形に内接する円を描画
      final size = math.max(right - left, bottom - top);
      final center = Offset(left + size / 2, top + size / 2);
      final radius = size / 2;
      _addCirclePoints(points, center, radius, paint, canvasSize, isFilled);
    } else {
      // 長方形に内接する楕円を描画
      final center = Offset((left + right) / 2, (top + bottom) / 2);
      final radiusX = (right - left) / 2;
      final radiusY = (bottom - top) / 2;
      _addOvalPoints(
        points,
        center,
        radiusX,
        radiusY,
        paint,
        canvasSize,
        isFilled,
      );
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

    var left = math.min(start.dx, end.dx);
    var top = math.min(start.dy, end.dy);
    var right = math.max(start.dx, end.dx);
    var bottom = math.max(start.dy, end.dy);
    var width = right - left + 1;
    var height = bottom - top + 1;

    // 開始位置と終了位置が同じ場合は1ピクセルのみ描画
    if (width == 1 && height == 1) {
      if (_isInBounds(left.floor(), top.floor(), canvasSize)) {
        points.add(
          DrawingPoint(
            offset: Offset(left.floorToDouble(), top.floorToDouble()),
            paint: paint,
          ),
        );
      }
      return points;
    }

    // 幅に応じた処理分岐
    if (width <= 3 || height <= 3) {
      if (isSquare) {
        final size = math.max(width, height);
        width = size;
        height = size;
        right = left + size - 1;
        bottom = top + size - 1;
      }
      _addSmallShapePoints(
        points,
        left,
        top,
        right,
        bottom,
        width,
        height,
        paint,
        canvasSize,
      );
      return points;
    }

    if (isSquare) {
      final size = math.max(right - left, bottom - top);
      right = left + size;
      bottom = top + size;
    }

    if (isFilled) {
      for (int x = left.floor(); x <= right.floor(); x++) {
        for (int y = top.floor(); y <= bottom.floor(); y++) {
          if (_isInBounds(x, y, canvasSize)) {
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
      // 水平線を描画
      for (int x = left.floor(); x <= right.floor(); x++) {
        if (_isInBounds(x, top.floor(), canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset(x.toDouble(), top.floorToDouble()),
              paint: paint,
            ),
          );
        }
        if (_isInBounds(x, bottom.floor(), canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset(x.toDouble(), bottom.floorToDouble()),
              paint: paint,
            ),
          );
        }
      }
      // 垂直線を描画
      for (int y = top.floor() + 1; y < bottom.floor(); y++) {
        if (_isInBounds(left.floor(), y, canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset(left.floorToDouble(), y.toDouble()),
              paint: paint,
            ),
          );
        }
        if (_isInBounds(right.floor(), y, canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset(right.floorToDouble(), y.toDouble()),
              paint: paint,
            ),
          );
        }
      }
    }

    return points;
  }

  static void _addSmallShapePoints(
    List<DrawingPoint?> points,
    double left,
    double top,
    double right,
    double bottom,
    double width,
    double height,
    Paint paint,
    Size canvasSize,
  ) {
    if (width <= 3 && height > 3) {
      // 垂直方向の細い図形
      if (width == 1) {
        // 1ピクセル幅の直線
        for (int y = top.floor(); y <= bottom.floor(); y++) {
          if (_isInBounds(left.floor(), y, canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset(left.floorToDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        }
      } else if (width == 2) {
        // 2ピクセル幅の直線
        for (int y = top.floor(); y <= bottom.floor(); y++) {
          for (int x = left.floor(); x <= left.floor() + 1; x++) {
            if (_isInBounds(x, y, canvasSize)) {
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
        // width == 3
        // 端部のパターン
        if (_isInBounds(left.floor() + 1, top.floor(), canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset((left + 1).floorToDouble(), top.floorToDouble()),
              paint: paint,
            ),
          );
        }

        // 中間部分のパターン
        for (int y = top.floor() + 1; y < bottom.floor(); y++) {
          // 左のドット
          if (_isInBounds(left.floor(), y, canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset(left.floorToDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
          // 右のドット
          if (_isInBounds(left.floor() + 2, y, canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset((left + 2).floorToDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        }

        // 端部のパターン
        if (_isInBounds(left.floor() + 1, bottom.floor(), canvasSize)) {
          points.add(
            DrawingPoint(
              offset: Offset(
                (left + 1).floorToDouble(),
                bottom.floorToDouble(),
              ),
              paint: paint,
            ),
          );
        }
      }
    } else if (height <= 3 && width > 3) {
      // 水平方向の細い図形
      if (height == 1) {
        // 1ピクセル高さの直線
        for (int x = left.floor(); x <= right.floor(); x++) {
          if (_isInBounds(x, top.floor(), canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), top.floorToDouble()),
                paint: paint,
              ),
            );
          }
        }
      } else if (height == 2) {
        // 2ピクセル高さの直線
        for (int x = left.floor(); x <= right.floor(); x++) {
          for (int y = top.floor(); y <= top.floor() + 1; y++) {
            if (_isInBounds(x, y, canvasSize)) {
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
        // height == 3
        // 3x3の場合
        if (width == 3) {
          _add3x3Pattern(points, left, top, paint, canvasSize);
        } else {
          // 横長の3px高さパターン
          for (int x = left.floor(); x <= right.floor(); x++) {
            // 上のドット（まばら）
            if (x % 2 == 1 && _isInBounds(x, top.floor(), canvasSize)) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), top.floorToDouble()),
                  paint: paint,
                ),
              );
            }
            // 中央のドット（まばら）
            if (x % 2 == 0 && _isInBounds(x, top.floor() + 1, canvasSize)) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), (top + 1).floorToDouble()),
                  paint: paint,
                ),
              );
            }
            // 下のドット（まばら）
            if (x % 2 == 1 && _isInBounds(x, top.floor() + 2, canvasSize)) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), (top + 2).floorToDouble()),
                  paint: paint,
                ),
              );
            }
          }
        }
      }
    } else {
      // 3x3のパターン
      _add3x3Pattern(points, left, top, paint, canvasSize);
    }
  }

  static void _add3x3Pattern(
    List<DrawingPoint?> points,
    double left,
    double top,
    Paint paint,
    Size canvasSize,
  ) {
    // 上段の中央
    if (_isInBounds(left.floor() + 1, top.floor(), canvasSize)) {
      points.add(
        DrawingPoint(
          offset: Offset((left + 1).floorToDouble(), top.floorToDouble()),
          paint: paint,
        ),
      );
    }

    // 中段の左右
    if (_isInBounds(left.floor(), top.floor() + 1, canvasSize)) {
      points.add(
        DrawingPoint(
          offset: Offset(left.floorToDouble(), (top + 1).floorToDouble()),
          paint: paint,
        ),
      );
    }
    if (_isInBounds(left.floor() + 2, top.floor() + 1, canvasSize)) {
      points.add(
        DrawingPoint(
          offset: Offset((left + 2).floorToDouble(), (top + 1).floorToDouble()),
          paint: paint,
        ),
      );
    }

    // 下段の中央
    if (_isInBounds(left.floor() + 1, top.floor() + 2, canvasSize)) {
      points.add(
        DrawingPoint(
          offset: Offset((left + 1).floorToDouble(), (top + 2).floorToDouble()),
          paint: paint,
        ),
      );
    }
  }

  static void _addCirclePoints(
    List<DrawingPoint?> points,
    Offset center,
    double radius,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    final boundLeft = math.max(0, (center.dx - radius).floor());
    final boundRight = math.min(
      canvasSize.width.floor() - 1,
      (center.dx + radius).floor(),
    );
    final boundTop = math.max(0, (center.dy - radius).floor());
    final boundBottom = math.min(
      canvasSize.height.floor() - 1,
      (center.dy + radius).floor(),
    );

    for (int x = boundLeft; x <= boundRight; x++) {
      for (int y = boundTop; y <= boundBottom; y++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (isFilled) {
          if (distance <= radius && _isInBounds(x, y, canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        } else {
          if ((distance - radius).abs() <= 0.5 &&
              _isInBounds(x, y, canvasSize)) {
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

  static void _addOvalPoints(
    List<DrawingPoint?> points,
    Offset center,
    double radiusX,
    double radiusY,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
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

        if (isFilled) {
          if (distance <= 1.0 && _isInBounds(x, y, canvasSize)) {
            points.add(
              DrawingPoint(
                offset: Offset(x.toDouble(), y.toDouble()),
                paint: paint,
              ),
            );
          }
        } else {
          if ((distance - 1.0).abs() <= 0.5 / math.min(radiusX, radiusY) &&
              _isInBounds(x, y, canvasSize)) {
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

  static bool _isInBounds(int x, int y, Size canvasSize) {
    return x >= 0 && x < canvasSize.width && y >= 0 && y < canvasSize.height;
  }
}
