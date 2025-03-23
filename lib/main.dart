import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelBoard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DrawingPage(),
    );
  }
}

enum DrawingTool { brush, fill, rectangle, square, circle }

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  Color selectedColor = Colors.black;
  List<DrawingPoint?> points = [];
  List<DrawingPoint?> previewPoints = [];
  Size canvasSize = const Size(32, 32);
  bool showGrid = true;
  double scale = 10.0;
  final GlobalKey _canvasKey = GlobalKey();
  DrawingTool selectedTool = DrawingTool.brush;
  bool isFilled = false;
  int brushSize = 1;
  Offset? startPoint;
  Offset? currentPoint;

  void _showSizeDialog() {
    TextEditingController widthController = TextEditingController(
      text: canvasSize.width.toStringAsFixed(0),
    );
    TextEditingController heightController = TextEditingController(
      text: canvasSize.height.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('キャンバスサイズ設定'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '幅（ドット）'),
                ),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '高さ（ドット）'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  int width = int.tryParse(widthController.text) ?? 32;
                  int height = int.tryParse(heightController.text) ?? 32;
                  setState(() {
                    canvasSize = Size(width.toDouble(), height.toDouble());
                    points.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _addPoint(Offset point) {
    for (int i = 0; i < brushSize; i++) {
      for (int j = 0; j < brushSize; j++) {
        final adjustedPoint = Offset(point.dx + i, point.dy + j);
        if (adjustedPoint.dx < canvasSize.width &&
            adjustedPoint.dy < canvasSize.height) {
          points.add(
            DrawingPoint(
              offset: adjustedPoint,
              paint:
                  Paint()
                    ..color = selectedColor
                    ..isAntiAlias = false
                    ..strokeWidth = 1
                    ..strokeCap = StrokeCap.square
                    ..style = PaintingStyle.fill,
            ),
          );
        }
      }
    }
  }

  void _addPreviewPoint(List<DrawingPoint?> points, Offset point, Paint paint) {
    points.add(DrawingPoint(offset: point, paint: paint));
  }

  void _drawShape(Offset start, Offset end) {
    final paint =
        Paint()
          ..color = selectedColor
          ..isAntiAlias = false
          ..strokeWidth = 1
          ..style = PaintingStyle.fill;

    points.addAll(_generateShapePoints(start, end, paint));
  }

  List<DrawingPoint?> _generateShapePoints(
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final shapePoints = <DrawingPoint?>[];

    if (selectedTool == DrawingTool.square) {
      final size =
          math
              .max((end.dx - start.dx).abs(), (end.dy - start.dy).abs())
              .floor();
      _addSquarePoints(shapePoints, start, size, paint);
    } else if (selectedTool == DrawingTool.rectangle) {
      _addRectanglePoints(
        shapePoints,
        start,
        Offset(end.dx.floor().toDouble(), end.dy.floor().toDouble()),
        paint,
      );
    } else if (selectedTool == DrawingTool.circle) {
      _addCirclePoints(shapePoints, start, end, paint);
    }

    return shapePoints;
  }

  void _addSquarePoints(
    List<DrawingPoint?> points,
    Offset start,
    int size,
    Paint paint,
  ) {
    _addRectanglePoints(
      points,
      start,
      Offset(start.dx + size, start.dy + size),
      paint,
    );
  }

  void _addRectanglePoints(
    List<DrawingPoint?> points,
    Offset start,
    Offset end,
    Paint paint,
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

  void _addCirclePoints(
    List<DrawingPoint?> points,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final centerX = (start.dx + end.dx) / 2;
    final centerY = (start.dy + end.dy) / 2;
    final radius = ((end - start).distance / 2).floor();

    for (
      int x = (centerX - radius).floor();
      x <= (centerX + radius).ceil();
      x++
    ) {
      for (
        int y = (centerY - radius).floor();
        y <= (centerY + radius).ceil();
        y++
      ) {
        if (x >= 0 && x < canvasSize.width && y >= 0 && y < canvasSize.height) {
          final dx = x - centerX;
          final dy = y - centerY;
          final distance = math.sqrt(dx * dx + dy * dy);

          if (isFilled) {
            if (distance <= radius) {
              points.add(
                DrawingPoint(
                  offset: Offset(x.toDouble(), y.toDouble()),
                  paint: paint,
                ),
              );
            }
          } else {
            if ((distance - radius).abs() <= 0.5) {
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

  void _fill(Offset target) {
    final targetColor = points
        .where((p) => p?.offset == target)
        .map((p) => p?.paint.color)
        .firstWhere((c) => c != null, orElse: () => Colors.white);

    final queue = <Offset>[target];
    final visited = <Offset>{};

    while (queue.isNotEmpty) {
      final point = queue.removeAt(0);
      if (visited.contains(point)) continue;
      visited.add(point);

      final currentColor = points
          .where((p) => p?.offset == point)
          .map((p) => p?.paint.color)
          .firstWhere((c) => c != null, orElse: () => Colors.white);

      if (currentColor != targetColor) continue;

      points.add(
        DrawingPoint(
          offset: point,
          paint:
              Paint()
                ..color = selectedColor
                ..isAntiAlias = false
                ..strokeWidth = 1
                ..style = PaintingStyle.fill,
        ),
      );

      final neighbors = [
        Offset(point.dx + 1, point.dy),
        Offset(point.dx - 1, point.dy),
        Offset(point.dx, point.dy + 1),
        Offset(point.dx, point.dy - 1),
      ];

      for (final neighbor in neighbors) {
        if (neighbor.dx >= 0 &&
            neighbor.dx < canvasSize.width &&
            neighbor.dy >= 0 &&
            neighbor.dy < canvasSize.height &&
            !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
  }

  void _updatePreview() {
    if (startPoint != null &&
        currentPoint != null &&
        selectedTool != DrawingTool.brush &&
        selectedTool != DrawingTool.fill) {
      final paint =
          Paint()
            ..color = selectedColor.withOpacity(0.5)
            ..isAntiAlias = false
            ..strokeWidth = 1
            ..style = PaintingStyle.fill;

      setState(() {
        previewPoints = _generateShapePoints(startPoint!, currentPoint!, paint);
      });
    } else {
      setState(() {
        previewPoints.clear();
      });
    }
  }

  Future<void> _exportToPNG() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      paint,
    );

    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        canvas.drawRect(
          Rect.fromLTWH(points[i]!.offset.dx, points[i]!.offset.dy, 1, 1),
          points[i]!.paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    if (pngBytes != null) {
      final blob = html.Blob([pngBytes.buffer.asUint8List()], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', 'pixel_art.png')
            ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Offset? _getCanvasOffset(Offset globalPosition) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localPosition = renderBox.globalToLocal(globalPosition);
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx > canvasSize.width * scale ||
        localPosition.dy > canvasSize.height * scale) {
      return null;
    }

    final x = (localPosition.dx / scale).floor().toDouble();
    final y = (localPosition.dy / scale).floor().toDouble();
    return Offset(
      x.clamp(0, canvasSize.width - 1),
      y.clamp(0, canvasSize.height - 1),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon) {
    return IconButton(
      icon: Icon(icon),
      color: selectedTool == tool ? Colors.blue : null,
      onPressed: () => setState(() => selectedTool = tool),
      tooltip: tool.toString().split('.').last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PixelBoard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_on),
            onPressed: () => setState(() => showGrid = !showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSizeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToPNG,
            tooltip: 'PNGでエクスポート',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildToolButton(DrawingTool.brush, Icons.brush),
                _buildToolButton(DrawingTool.fill, Icons.format_color_fill),
                _buildToolButton(
                  DrawingTool.rectangle,
                  Icons.rectangle_outlined,
                ),
                _buildToolButton(DrawingTool.square, Icons.crop_square),
                _buildToolButton(DrawingTool.circle, Icons.circle_outlined),
                const SizedBox(width: 16),
                if (selectedTool == DrawingTool.brush) ...[
                  const Text('ブラシサイズ: '),
                  DropdownButton<int>(
                    value: brushSize,
                    items:
                        [1, 2, 3, 4]
                            .map(
                              (size) => DropdownMenuItem(
                                value: size,
                                child: Text('$size'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => brushSize = value!),
                  ),
                ],
                if (selectedTool != DrawingTool.brush &&
                    selectedTool != DrawingTool.fill) ...[
                  IconButton(
                    icon: Icon(
                      isFilled ? Icons.format_color_fill : Icons.border_color,
                    ),
                    onPressed: () => setState(() => isFilled = !isFilled),
                    tooltip: isFilled ? '塗りつぶし' : '枠線のみ',
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                key: _canvasKey,
                width: canvasSize.width * scale,
                height: canvasSize.height * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                  children: [
                    if (showGrid)
                      CustomPaint(
                        painter: GridPainter(
                          gridSize: scale,
                          width: canvasSize.width,
                          height: canvasSize.height,
                        ),
                        size: Size(
                          canvasSize.width * scale,
                          canvasSize.height * scale,
                        ),
                      ),
                    CustomPaint(
                      painter: DrawingPainter(
                        points: points,
                        previewPoints: previewPoints,
                        scale: scale,
                      ),
                      size: Size(
                        canvasSize.width * scale,
                        canvasSize.height * scale,
                      ),
                    ),
                    Listener(
                      onPointerDown: (event) {
                        final offset = _getCanvasOffset(event.position);
                        if (offset != null) {
                          setState(() {
                            startPoint = offset;
                            currentPoint = offset;
                            if (selectedTool == DrawingTool.brush) {
                              _addPoint(offset);
                            } else if (selectedTool == DrawingTool.fill) {
                              _fill(offset);
                            }
                            _updatePreview();
                          });
                        }
                      },
                      onPointerMove: (event) {
                        final offset = _getCanvasOffset(event.position);
                        if (offset != null) {
                          setState(() {
                            currentPoint = offset;
                            if (selectedTool == DrawingTool.brush) {
                              _addPoint(offset);
                            }
                            _updatePreview();
                          });
                        }
                      },
                      onPointerUp: (event) {
                        if (startPoint != null &&
                            currentPoint != null &&
                            selectedTool != DrawingTool.brush &&
                            selectedTool != DrawingTool.fill) {
                          setState(() {
                            _drawShape(startPoint!, currentPoint!);
                            startPoint = null;
                            currentPoint = null;
                            previewPoints.clear();
                          });
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.8),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildColorButton(Colors.black),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.yellow),
                _buildColorButton(Colors.white),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => setState(() {
              points.clear();
              previewPoints.clear();
            }),
        child: const Icon(Icons.clear),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.blue : Colors.grey,
            width: 3,
          ),
        ),
      ),
    );
  }
}

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

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}
