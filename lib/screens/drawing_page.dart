import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import '../models/drawing_tool.dart';
import '../models/drawing_point.dart';
import '../painters/grid_painter.dart';
import '../painters/drawing_painter.dart';
import '../utils/shape_generator.dart';
import '../widgets/color_palette.dart';
import '../widgets/tool_bar.dart';

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
                    previewPoints.clear();
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
      setState(() {
        final paint =
            Paint()
              ..color = selectedColor.withOpacity(0.5)
              ..isAntiAlias = false
              ..strokeWidth = 1
              ..style = PaintingStyle.fill;

        switch (selectedTool) {
          case DrawingTool.rectangle:
          case DrawingTool.square:
            previewPoints = ShapeGenerator.generateRectangle(
              start: startPoint!,
              end: currentPoint!,
              paint: paint,
              canvasSize: canvasSize,
              isFilled: isFilled,
              isSquare: selectedTool == DrawingTool.square,
            );
            break;
          case DrawingTool.circle:
          case DrawingTool.oval:
            previewPoints = ShapeGenerator.generateShape(
              start: startPoint!,
              end: currentPoint!,
              paint: paint,
              canvasSize: canvasSize,
              isFilled: isFilled,
              isCircle: selectedTool == DrawingTool.circle,
            );
            break;
          default:
            previewPoints.clear();
        }
      });
    } else {
      setState(() {
        previewPoints.clear();
      });
    }
  }

  void _drawShape() {
    if (startPoint != null && currentPoint != null) {
      final paint =
          Paint()
            ..color = selectedColor
            ..isAntiAlias = false
            ..strokeWidth = 1
            ..style = PaintingStyle.fill;

      List<DrawingPoint?> shapePoints;
      switch (selectedTool) {
        case DrawingTool.rectangle:
        case DrawingTool.square:
          shapePoints = ShapeGenerator.generateRectangle(
            start: startPoint!,
            end: currentPoint!,
            paint: paint,
            canvasSize: canvasSize,
            isFilled: isFilled,
            isSquare: selectedTool == DrawingTool.square,
          );
          break;
        case DrawingTool.circle:
        case DrawingTool.oval:
          shapePoints = ShapeGenerator.generateShape(
            start: startPoint!,
            end: currentPoint!,
            paint: paint,
            canvasSize: canvasSize,
            isFilled: isFilled,
            isCircle: selectedTool == DrawingTool.circle,
          );
          break;
        default:
          shapePoints = [];
      }
      points.addAll(shapePoints);
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
          ToolBar(
            selectedTool: selectedTool,
            onToolSelected: (tool) => setState(() => selectedTool = tool),
            isFilled: isFilled,
            onFillModeChanged: (filled) => setState(() => isFilled = filled),
            brushSize: brushSize,
            onBrushSizeChanged: (size) => setState(() => brushSize = size),
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
                            _drawShape();
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
          ColorPalette(
            selectedColor: selectedColor,
            onColorSelected: (color) => setState(() => selectedColor = color),
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
}
