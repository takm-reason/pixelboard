import 'package:flutter/material.dart';
// dart:htmlはWebプラットフォームでのみ使用可能
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:typed_data';

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

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  Color selectedColor = Colors.black;
  List<DrawingPoint?> points = [];
  Size canvasSize = const Size(32, 32);
  bool showGrid = true;
  double scale = 10.0;
  final GlobalKey _canvasKey = GlobalKey();

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

  Future<void> _exportToPNG() async {
    // 描画用のキャンバスを作成
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // 背景を白で塗りつぶし
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      paint,
    );

    // ドット単位で描画
    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        canvas.drawRect(
          Rect.fromLTWH(points[i]!.offset.dx, points[i]!.offset.dy, 1, 1),
          points[i]!.paint,
        );
      }
    }

    // 描画内容をイメージに変換
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
            onPressed: () {
              setState(() {
                showGrid = !showGrid;
              });
            },
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
                    Listener(
                      onPointerDown: (event) {
                        final offset = _getCanvasOffset(event.position);
                        if (offset != null) {
                          setState(() {
                            points.add(
                              DrawingPoint(
                                offset: offset,
                                paint:
                                    Paint()
                                      ..color = selectedColor
                                      ..isAntiAlias = false
                                      ..strokeWidth = scale
                                      ..strokeCap = StrokeCap.square,
                              ),
                            );
                          });
                        }
                      },
                      onPointerMove: (event) {
                        final offset = _getCanvasOffset(event.position);
                        if (offset != null) {
                          setState(() {
                            points.add(
                              DrawingPoint(
                                offset: offset,
                                paint:
                                    Paint()
                                      ..color = selectedColor
                                      ..isAntiAlias = false
                                      ..strokeWidth = scale
                                      ..strokeCap = StrokeCap.square,
                              ),
                            );
                          });
                        }
                      },
                      onPointerUp: (event) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(points: points, scale: scale),
                        size: Size(
                          canvasSize.width * scale,
                          canvasSize.height * scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.8),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            points.clear();
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
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
  final double scale;

  DrawingPainter({required this.points, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}
