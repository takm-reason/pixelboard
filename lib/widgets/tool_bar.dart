import 'package:flutter/material.dart';
import '../models/drawing_tool.dart';

class ToolBar extends StatelessWidget {
  final DrawingTool selectedTool;
  final Function(DrawingTool) onToolSelected;
  final bool isFilled;
  final Function(bool) onFillModeChanged;
  final int brushSize;
  final Function(int) onBrushSizeChanged;

  const ToolBar({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.isFilled,
    required this.onFillModeChanged,
    required this.brushSize,
    required this.onBrushSizeChanged,
  });

  Widget _buildToolButton(DrawingTool tool, IconData icon) {
    return IconButton(
      icon: Icon(icon),
      color: selectedTool == tool ? Colors.blue : null,
      onPressed: () => onToolSelected(tool),
      tooltip: tool.toString().split('.').last,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildToolButton(DrawingTool.brush, Icons.brush),
          _buildToolButton(DrawingTool.fill, Icons.format_color_fill),
          _buildToolButton(DrawingTool.rectangle, Icons.rectangle_outlined),
          _buildToolButton(DrawingTool.square, Icons.crop_square),
          _buildToolButton(DrawingTool.circle, Icons.circle_outlined),
          _buildToolButton(DrawingTool.oval, Icons.panorama_wide_angle),
          const SizedBox(width: 16),
          if (selectedTool == DrawingTool.brush) ...[
            const Text('ブラシサイズ: '),
            DropdownButton<int>(
              value: brushSize,
              items:
                  [1, 2, 3, 4]
                      .map(
                        (size) =>
                            DropdownMenuItem(value: size, child: Text('$size')),
                      )
                      .toList(),
              onChanged: (value) => onBrushSizeChanged(value!),
            ),
          ],
          if (selectedTool != DrawingTool.brush &&
              selectedTool != DrawingTool.fill) ...[
            IconButton(
              icon: Icon(
                isFilled ? Icons.format_color_fill : Icons.border_color,
              ),
              onPressed: () => onFillModeChanged(!isFilled),
              tooltip: isFilled ? '塗りつぶし' : '枠線のみ',
            ),
          ],
        ],
      ),
    );
  }
}
